package l2s.gameserver.model.entity.events.objects;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;
import l2s.commons.util.Rnd;
import l2s.gameserver.Announcements;
import l2s.gameserver.data.xml.holder.DoorHolder;
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.geometry.ILocation;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.listener.hooks.ListenerHookType;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.model.actor.instances.player.Cubic;
import l2s.gameserver.model.base.TeamType;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.events.hooks.PvPEventHook;
import l2s.gameserver.model.entity.events.impl.DuelEvent;
import l2s.gameserver.model.entity.events.impl.PvPEvent;
import l2s.gameserver.model.entity.events.objects.DoorObject;
import l2s.gameserver.model.entity.events.objects.PvPEventPlayerObject;
import l2s.gameserver.model.entity.events.objects.RewardObject;
import l2s.gameserver.model.entity.events.objects.SpawnableObject;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExShowScreenMessage;
import l2s.gameserver.skills.TimeStamp;
import l2s.gameserver.templates.DoorTemplate;
import l2s.gameserver.templates.ZoneTemplate;
import l2s.gameserver.utils.ItemFunctions;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.HashIntObjectMap;

public class PvPEventArenaObject
extends Reflection {
    private final PvPEvent _pvpEvent;
    private final List<Set<PvPEventPlayerObject>> _teamsList;

    public PvPEventArenaObject(PvPEvent pvpEvent, int teams) {
        this._pvpEvent = pvpEvent;
        List<DoorObject> doors = this._pvpEvent.getObjects("doors");
        HashIntObjectMap doorTemplates = new HashIntObjectMap(doors.size());
        for (DoorObject door : doors) {
            DoorTemplate doorTemplate = DoorHolder.getInstance().getTemplate(door.getId());
            if (doorTemplate == null) continue;
            doorTemplates.put(doorTemplate.getId(), doorTemplate);
        }
        this.init((IntObjectMap<DoorTemplate>)doorTemplates, new HashMap<String, ZoneTemplate>());
        List<SpawnableObject> spawns = this._pvpEvent.getObjects("spawns");
        for (SpawnableObject spawn : spawns) {
            spawn.spawnObject(this._pvpEvent, this);
        }
        this._teamsList = new ArrayList<Set<PvPEventPlayerObject>>(teams);
        for (int i = 0; i < teams; ++i) {
            this._teamsList.add(new CopyOnWriteArraySet());
        }
    }

    public void addPlayer(Player player, int teamId) {
        switch (teamId) {
            case 0: {
                player.setTeam(TeamType.BLUE);
                break;
            }
            case 1: {
                player.setTeam(TeamType.RED);
            }
        }
        this._teamsList.get(teamId).add(new PvPEventPlayerObject(player, teamId));
    }

    public void sortPlayers(List<Player> players) {
        Collections.shuffle(players);
        int teamId = 0;
        for (Player player : players) {
            if (this._teamsList.size() == 1) {
                player.setTeam(TeamType.RED);
                this._teamsList.get(0).add(new PvPEventPlayerObject(player, -1));
                continue;
            }
            switch (teamId) {
                case 0: {
                    player.setTeam(TeamType.BLUE);
                    break;
                }
                case 1: {
                    player.setTeam(TeamType.RED);
                }
            }
            this._teamsList.get(teamId).add(new PvPEventPlayerObject(player, teamId));
            if (++teamId != this._teamsList.size()) continue;
            teamId = 0;
        }
    }

    public void teleportPlayers() {
        for (int i = 0; i < this._teamsList.size(); ++i) {
            for (PvPEventPlayerObject member : this._teamsList.get(i)) {
                Player player = member.getPlayer();
                if (player == null) continue;
                player.leaveParty(false);
                player.setStablePoint(player.getLoc());
                player.addEvent(this._pvpEvent);
                this.teleportPlayer(player, this._pvpEvent.getLocation("team" + i));
                this.block(player);
                this._pvpEvent.abnormals(player, true);
                this.addHook(player);
                player.getInventory().validateItems();
                player.getInventory().refreshEquip();
            }
        }
    }

    public void startBattle() {
        for (int i = 0; i < this._teamsList.size(); ++i) {
            for (PvPEventPlayerObject member : this._teamsList.get(i)) {
                Player player = member.getPlayer();
                if (player == null) continue;
                this.unBlock(player);
                this.buff(player);
                player.sendPacket((IBroadcastPacket)new ExShowScreenMessage(new CustomMessage("l2s.gameserver.model.entity.events.impl.PvPEvent.toBattle").toString(player), 5000, ExShowScreenMessage.ScreenMessageAlign.TOP_CENTER, true, 1, -1, true));
            }
        }
    }

    public void stopBattle() {
        this.rewardTeams();
        for (int i = 0; i < this._teamsList.size(); ++i) {
            for (PvPEventPlayerObject member : this._teamsList.get(i)) {
                Player player = member.getPlayer();
                if (player == null) continue;
                this.removePlayer(player);
            }
        }
        this._pvpEvent.removeObject("arenas", this);
        this.collapse();
    }

    public void check() {
        if (this._teamsList.size() >= 2) {
            int emptyTeams = 0;
            for (Set<PvPEventPlayerObject> team : this._teamsList) {
                if (!team.isEmpty()) continue;
                ++emptyTeams;
            }
            if (this._teamsList.size() - emptyTeams <= 1) {
                this.stopBattle();
            }
        } else if (this._teamsList.get(0).size() <= 1) {
            if (this._teamsList.get(0).size() == 1) {
                PvPEventPlayerObject object = this._teamsList.get(0).iterator().next();
                if (this._pvpEvent.isAddHeroLastPlayer() && !object.getPlayer().isHero()) {
                    object.getPlayer().setCustomHero(1);
                }
                List<RewardObject> rewards = this._pvpEvent.getObjects("reward_for_last_player");
                for (RewardObject reward : rewards) {
                    if (!Rnd.chance((double)reward.getChance())) continue;
                    ItemFunctions.addItem(object.getPlayer(), reward.getItemId(), Rnd.get((long)reward.getMinCount(), (long)reward.getMaxCount()));
                }
                Announcements.announceToAllFromStringHolder("l2s.gameserver.model.entity.events.impl.PvPEvent.eventWinner", this._pvpEvent.getName(), object.getPlayer().getName());
            }
            this.stopBattle();
        }
    }

    public void teleportPlayer(Player player, Location location) {
        if (player.isTeleporting()) {
            return;
        }
        if (player.isDead()) {
            player.doRevive(100.0);
            player.setCurrentHp(player.getMaxHp(), true);
        } else {
            player.setCurrentHp(player.getMaxHp(), false);
        }
        player.setCurrentCp(player.getMaxCp());
        player.setCurrentMp(player.getMaxMp());
        if (player.isInObserverMode()) {
            player.leaveObserverMode();
        }
        if (this._pvpEvent.isDisableHeroAndClanSkills()) {
            if (player.getClan() != null) {
                player.getClan().disableSkills(player);
            }
            player.activateHeroSkills(false);
        }
        player.abortCast(true, true);
        player.abortAttack(true, true);
        for (Abnormal abnormal : player.getAbnormalList()) {
            if (player.isSpecialAbnormal(abnormal.getSkill())) continue;
            abnormal.exit();
        }
        for (Cubic cubic : player.getCubics()) {
            if (player.getSkillLevel(cubic.getSkill().getId()) > 0) continue;
            cubic.delete();
        }
        for (Servitor servitor : player.getServitors()) {
            if (servitor.isPet()) {
                servitor.unSummon(false);
                continue;
            }
            servitor.getAbnormalList().stopAll();
            servitor.transferOwnerBuffs();
        }
        if (player.getAgathionNpcId() > 0) {
            player.deleteAgathion();
        }
        if (this._pvpEvent.isResetSkills()) {
            for (TimeStamp sts : player.getSkillReuses()) {
                Skill skill;
                if (sts == null || (skill = SkillHolder.getInstance().getSkill(sts.getId(), sts.getLevel())) == null || sts.getReuseBasic() > 900015L) continue;
                player.enableSkill(skill);
            }
        }
        player.sendSkillList();
        player.getInventory().validateItems();
        player.removeAutoShots(true);
        player.broadcastUserInfo(true);
        DuelEvent duel = player.getEvent(DuelEvent.class);
        if (duel != null) {
            duel.abortDuel(player);
        }
        if (player.isSitting()) {
            player.standUp();
        }
        player.setTarget(null);
        player.teleToLocation((ILocation)location, this);
    }

    public void block(Player player) {
        player.getFlags().getImmobilized().start(this);
        player.getFlags().getInvulnerable().start(this);
    }

    public void unBlock(Player player) {
        player.getFlags().getImmobilized().stop(this);
        player.getFlags().getInvulnerable().stop(this);
    }

    public void buff(Player player) {
        for (Abnormal abnormal : player.getAbnormalList()) {
            if (player.isSpecialAbnormal(abnormal.getSkill())) continue;
            abnormal.exit();
        }
        for (int[] skillId : this._pvpEvent.getBuffs()) {
            Skill skill = SkillHolder.getInstance().getSkill(skillId[0], skillId[1]);
            if (skill == null) continue;
            skill.getEffects(player, player);
        }
        Skill skill = SkillHolder.getInstance().getSkill(1323, 1);
        if (skill != null) {
            skill.getEffects(player, player);
        }
    }

    public void heal(Player player) {
        player.setCurrentHp(player.getMaxHp(), false);
        player.setCurrentCp(player.getMaxCp());
        player.setCurrentMp(player.getMaxMp());
    }

    public void addHook(Player player) {
        player.addListenerHook(ListenerHookType.PLAYER_TELEPORT, PvPEventHook.getInstance());
        player.addListenerHook(ListenerHookType.PLAYER_DIE, PvPEventHook.getInstance());
    }

    public void removeHook(Player player) {
        player.removeListenerHookType(ListenerHookType.PLAYER_QUIT_GAME, PvPEventHook.getInstance());
        player.removeListenerHookType(ListenerHookType.PLAYER_TELEPORT, PvPEventHook.getInstance());
        player.removeListenerHookType(ListenerHookType.PLAYER_DIE, PvPEventHook.getInstance());
    }

    public void removePlayer(Player player) {
        PvPEventPlayerObject member = this.getParticipant(player);
        if (member == null) {
            return;
        }
        this._pvpEvent.abnormals(player, false);
        int teamId = member.getTeam();
        if (teamId == -1) {
            teamId = 0;
        }
        this._teamsList.get(teamId).remove(member);
        this.removeHook(player);
        this.unBlock(player);
        player.removeEvent(this._pvpEvent);
        player.setTeam(TeamType.NONE);
        player.teleToLocation((ILocation)player.getStablePoint(), ReflectionManager.MAIN);
        if (player.isDead()) {
            player.doRevive(100.0);
            player.setCurrentHp(player.getMaxHp(), true);
        } else {
            player.setCurrentHp(player.getMaxHp(), false);
        }
        player.setCurrentCp(player.getMaxCp());
        player.setCurrentMp(player.getMaxMp());
        if (player.getClan() != null) {
            player.getClan().enableSkills(player);
        }
        player.activateHeroSkills(true);
        player.sendSkillList();
    }

    public void rewardTeams() {
        List<RewardObject> rewards;
        this._teamsList.sort(new WinComparator());
        Set<PvPEventPlayerObject> teamWin = this._teamsList.get(0);
        if (PvPEventArenaObject.getPointByTeam(teamWin) >= this._pvpEvent.getMinKillTeamFromReward()) {
            rewards = this._pvpEvent.getObjects("reward_for_win_team");
            for (PvPEventPlayerObject object : teamWin) {
                Player player = object.getPlayer();
                player.sendPacket((IBroadcastPacket)new ExShowScreenMessage(new CustomMessage("l2s.gameserver.model.entity.events.impl.PvPEvent.win").toString(player), 5000, ExShowScreenMessage.ScreenMessageAlign.TOP_CENTER, true, 1, -1, true));
            }
            this.takeReward(teamWin, rewards);
        }
        rewards = this._pvpEvent.getObjects("reward_for_lose_team");
        for (int i = 1; i < this._teamsList.size(); ++i) {
            Set<PvPEventPlayerObject> teamLose = this._teamsList.get(i);
            for (PvPEventPlayerObject object : teamLose) {
                Player player = object.getPlayer();
                player.sendPacket((IBroadcastPacket)new ExShowScreenMessage(new CustomMessage("l2s.gameserver.model.entity.events.impl.PvPEvent.lose").toString(player), 5000, ExShowScreenMessage.ScreenMessageAlign.TOP_CENTER, true, 1, -1, true));
            }
            if (PvPEventArenaObject.getPointByTeam(teamLose) < this._pvpEvent.getMinKillTeamFromReward()) continue;
            this.takeReward(teamLose, rewards);
        }
    }

    private static int getPointByTeam(Set<PvPEventPlayerObject> players) {
        int points = 0;
        for (PvPEventPlayerObject member : players) {
            points += member.getPoints();
        }
        return points;
    }

    private void takeReward(Set<PvPEventPlayerObject> players, List<RewardObject> rewards) {
        for (PvPEventPlayerObject member : players) {
            if (member.getPoints() < this._pvpEvent.getMinKillFromReward()) continue;
            rewards.stream().filter(reward -> Rnd.chance((double)reward.getChance())).forEach(reward -> ItemFunctions.addItem(member.getPlayer(), reward.getItemId(), Rnd.get((long)reward.getMinCount(), (long)reward.getMaxCount())));
        }
    }

    public PvPEventPlayerObject getParticipant(Player player) {
        for (int i = 0; i < this._teamsList.size(); ++i) {
            for (PvPEventPlayerObject member : this._teamsList.get(i)) {
                if (member.getPlayer() != player) continue;
                return member;
            }
        }
        return null;
    }

    public static class WinComparator
    implements Comparator<Set<PvPEventPlayerObject>> {
        @Override
        public int compare(Set<PvPEventPlayerObject> o1, Set<PvPEventPlayerObject> o2) {
            return Integer.compare(PvPEventArenaObject.getPointByTeam(o2), PvPEventArenaObject.getPointByTeam(o1));
        }
    }
}


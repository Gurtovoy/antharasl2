package l2s.gameserver.model.entity.events.impl;

import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;
import java.util.concurrent.atomic.AtomicBoolean;
import l2s.commons.collections.MultiValueSet;
import l2s.commons.time.cron.SchedulingPattern;
import l2s.commons.util.Rnd;
import l2s.gameserver.Announcements;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.EventHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.listener.actor.player.impl.EventAnswerListner;
import l2s.gameserver.listener.hooks.ListenerHookType;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.base.RestartType;
import l2s.gameserver.model.base.TeamType;
import l2s.gameserver.model.entity.events.EventType;
import l2s.gameserver.model.entity.events.hooks.PvPEventHook;
import l2s.gameserver.model.entity.events.impl.SingleMatchEvent;
import l2s.gameserver.model.entity.events.objects.PvPEventArenaObject;
import l2s.gameserver.model.entity.events.objects.PvPEventPlayerObject;
import l2s.gameserver.model.entity.olympiad.Olympiad;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ConfirmDlgPacket;
import l2s.gameserver.skills.AbnormalEffect;
import l2s.gameserver.stats.conditions.Condition;
import l2s.gameserver.stats.conditions.ConditionPlayerOlympiad;
import l2s.gameserver.utils.Functions;
import l2s.gameserver.utils.velocity.VelocityUtils;

public class PvPEvent
extends SingleMatchEvent {
    private AtomicBoolean isEventActive = new AtomicBoolean(false);
    protected AtomicBoolean isRegActive = new AtomicBoolean(false);
    protected AtomicBoolean isBattleActive = new AtomicBoolean(false);
    private SchedulingPattern datePattern;
    private final CustomMessage _name;
    private final int _minLevel;
    private final int _maxLevel;
    private final int _minPlayers;
    private final int _teams;
    private final int _countDieFromExit;
    private final int _minKillFromReward;
    private final int _minKillTeamFromReward;
    private final boolean _hideNick;
    private final boolean _incPvp;
    private final int _modRewardForPremium;
    private final int[][] _buffs;
    private final boolean _disableHeroAndClanSkills;
    private final boolean _resetSkills;
    private final boolean _enableHeroCond;
    private final boolean _addHeroLastPlayer;
    private long _startTimeMillis = 0L;
    private boolean _isForceScheduled = false;

    public PvPEvent(MultiValueSet<String> set) {
        super(set);
        String cron;
        if (set.getBool("enabled", false) && !(cron = set.getString("start_time", "")).isEmpty()) {
            this.datePattern = new SchedulingPattern(cron);
        }
        this._minLevel = Math.max(1, set.getInteger("min_level", 1));
        this._maxLevel = Math.min(Config.ALT_MAX_LEVEL, set.getInteger("max_level", Config.ALT_MAX_LEVEL));
        VelocityUtils.GLOBAL_VARIABLES.put("PVP_EVENT_" + this.getId() + "_MIN_LEVEL", this._minLevel);
        VelocityUtils.GLOBAL_VARIABLES.put("PVP_EVENT_" + this.getId() + "_MAX_LEVEL", this._maxLevel);
        this._name = new CustomMessage("l2s.gameserver.model.entity.events.impl.PvPEvent.eventname." + this.getId());
        this._minPlayers = set.getInteger("min_players", 1);
        this._teams = set.getInteger("teams");
        this._countDieFromExit = set.getInteger("count_die_from_exit");
        this._minKillFromReward = set.getInteger("min_kill_from_reward", 0);
        this._minKillTeamFromReward = set.getInteger("min_kill_team_from_reward", 0);
        this._hideNick = set.getBool("hide_nick", false);
        this._incPvp = set.getBool("inc_pvp", false);
        this._modRewardForPremium = set.getInteger("mod_reward_for_premium", 1);
        this._buffs = this.parseBuffs(set.getString("buffs", ""));
        this._disableHeroAndClanSkills = set.getBool("disable_hero_and_clan_skills", true);
        this._resetSkills = set.getBool("reset_skills", true);
        this._enableHeroCond = set.getBool("enable_hero_cond", true);
        this._addHeroLastPlayer = set.getBool("add_hero_last_player", false);
    }

    public CustomMessage getEventName() {
        return this._name;
    }

    public int getMinLevel() {
        return this._minLevel;
    }

    public int getMaxLevel() {
        return this._maxLevel;
    }

    public int getTeams() {
        return this._teams;
    }

    public int getCountDieFromExit() {
        return this._countDieFromExit;
    }

    public int getMinKillFromReward() {
        return this._minKillFromReward;
    }

    public int getMinKillTeamFromReward() {
        return this._minKillTeamFromReward;
    }

    public boolean isHideNick() {
        return this._hideNick;
    }

    public boolean isIncPvP() {
        return this._incPvp;
    }

    public int getModRewardForPremium() {
        return this._modRewardForPremium;
    }

    public int[][] getBuffs() {
        return this._buffs;
    }

    public boolean isDisableHeroAndClanSkills() {
        return this._disableHeroAndClanSkills;
    }

    public boolean isResetSkills() {
        return this._resetSkills;
    }

    public boolean isAddHeroLastPlayer() {
        return this._addHeroLastPlayer;
    }

    public boolean isRegActive() {
        return this.isRegActive.get();
    }

    public boolean isBattleActive() {
        return this.isBattleActive.get();
    }

    @Override
    public void reCalcNextTime(boolean onInit) {
        if (this.datePattern != null) {
            this.clearActions();
            this._startTimeMillis = this.datePattern.next(System.currentTimeMillis());
            this.registerActions();
            if (!onInit) {
                this.printInfo();
            }
        }
    }

    @Override
    public EventType getType() {
        return EventType.CUSTOM_PVP_EVENT;
    }

    @Override
    protected long startTimeMillis() {
        return this._startTimeMillis;
    }

    @Override
    public boolean isInProgress() {
        return this.isEventActive.get();
    }

    @Override
    public void startEvent() {
        if (!this.isEventActive.compareAndSet(false, true)) {
            return;
        }
        super.startEvent();
        this.clearActions();
        this._startTimeMillis = System.currentTimeMillis() + 1000L;
        this.registerActions();
    }

    @Override
    public void stopEvent(boolean force) {
        this._isForceScheduled = false;
        if (force) {
            this.action("battle", false);
        }
        this.isEventActive.set(false);
        this.removeObjects("registered_players");
        if (!force) {
            this.reCalcNextTime(false);
        }
    }

    @Override
    public void action(String name, boolean start) {
        switch (name) {
            case "registration": {
                if (start) {
                    this.isRegActive.set(true);
                    Announcements.announceToAllFromStringHolder("l2s.gameserver.model.entity.events.impl.PvPEvent.registration.start", this.getEventName());
                    CustomMessage askMessage = new CustomMessage("l2s.gameserver.model.entity.events.impl.PvPEvent.registration.ask").addCustomMessage(this.getEventName());
                    boolean count = false;
                    for (Player player : GameObjectsStorage.getPlayers(true, false)) {
                        if (player.getLevel() < this.getMinLevel() || player.getLevel() > this.getMaxLevel()) continue;
                        player.ask((ConfirmDlgPacket)new ConfirmDlgPacket(SystemMsg.S1, 60000).addString(askMessage.toString(player)), new EventAnswerListner(player, this.getId()));
                    }
                    break;
                }
                this.isRegActive.set(false);
                List registeredPlayers = this.getObjects("registered_players");
                if (registeredPlayers.size() < this._minPlayers) {
                    Announcements.announceToAllFromStringHolder("l2s.gameserver.model.entity.events.impl.PvPEvent.registration.cancel", this.getEventName());
                    this.stopEvent(false);
                    break;
                }
                Announcements.announceToAllFromStringHolder("l2s.gameserver.model.entity.events.impl.PvPEvent.registration.stop", this.getEventName());
                break;
            }
            case "sort": {
                PvPEventArenaObject arena = new PvPEventArenaObject(this, this._teams);
                this.addObject("arenas", arena);
                List<Player> registeredPlayers = this.getObjects("registered_players");
                arena.sortPlayers(registeredPlayers);
                this.removeObjects("registered_players");
                break;
            }
            case "teleport": {
                this.isBattleActive.set(true);
                List<PvPEventArenaObject> arenas = this.getObjects("arenas");
                for (PvPEventArenaObject arena : arenas) {
                    arena.teleportPlayers();
                }
                break;
            }
            case "battle": {
                List<PvPEventArenaObject> arenas = this.getObjects("arenas");
                for (PvPEventArenaObject arena : arenas) {
                    if (start) {
                        arena.startBattle();
                        continue;
                    }
                    arena.stopBattle();
                }
                if (start) break;
                this.isBattleActive.set(false);
                this.stopEvent(false);
                break;
            }
            default: {
                super.action(name, start);
            }
        }
    }

    private boolean checkReg(Player player) {
        if (player.getLevel() > this.getMaxLevel() || player.getLevel() < this.getMinLevel()) {
            return false;
        }
        if (player.isMounted() || player.isDead() || player.isInObserverMode()) {
            return false;
        }
        SingleMatchEvent evt = player.getEvent(SingleMatchEvent.class);
        if (evt != null && evt != this) {
            return false;
        }
        if (player.getTeam() != TeamType.NONE) {
            return false;
        }
        if (player.getOlympiadGame() != null || Olympiad.isRegistered(player)) {
            return false;
        }
        if (player.isTeleporting()) {
            return false;
        }
        if (!player.getReflection().isMain()) {
            return false;
        }
        if (this.isRegistered(player)) {
            return false;
        }
        for (PvPEvent events : EventHolder.getInstance().getEvents(PvPEvent.class)) {
            if (!events.isRegistered(player)) continue;
            return false;
        }
        return !player.isInZone(Zone.ZoneType.epic);
    }

    public void showReg() {
        for (Player player : GameObjectsStorage.getPlayers(false, false)) {
            if (this.isRegActive()) {
                if (this.isRegistered(player)) {
                    Functions.show("events/event_yesreg.htm", player);
                    continue;
                }
                if (!this.checkReg(player)) continue;
                Functions.show("events/event_" + this.getId() + ".htm", player);
                continue;
            }
            Functions.show("events/event_noreg.htm", player);
        }
    }

    public void reg(Player player) {
        if (this.isRegActive.get() && this.checkReg(player)) {
            this.addObject("registered_players", player);
            player.addListenerHook(ListenerHookType.PLAYER_QUIT_GAME, PvPEventHook.getInstance());
            player.sendMessage(new CustomMessage("l2s.gameserver.model.entity.events.impl.PvPEvent.registration.success").addCustomMessage(this.getEventName()));
        }
    }

    public void regCustom(Player player, String command) {
    }

    public Location getLocation(String teleportWho) {
        List<Location> teleportList = this.getObjects(teleportWho);
        return (Location)teleportList.get(Rnd.get((int)0, (int)(teleportList.size() - 1)));
    }

    public void abnormals(Player player, boolean start) {
        PvPEventPlayerObject member = this.getParticipant(player);
        if (member == null) {
            return;
        }
        int teamId = member.getTeam();
        if (teamId == -1) {
            teamId = 0;
        }
        List<AbnormalEffect> abnormalEffects = this.getObjects("abnormal" + teamId);
        for (AbnormalEffect abnormalEffect : abnormalEffects) {
            if (start) {
                player.startAbnormalEffect(abnormalEffect);
                continue;
            }
            player.stopAbnormalEffect(abnormalEffect);
        }
    }

    @Override
    public SystemMsg checkForAttack(Creature target, Creature attacker, Skill skill, boolean force) {
        if (!this.isEnemy(target, attacker)) {
            return SystemMsg.INVALID_TARGET;
        }
        return null;
    }

    @Override
    public boolean canAttack(Creature target, Creature attacker, Skill skill, boolean force, boolean nextAttackCheck) {
        return this.isEnemy(target, attacker);
    }

    private boolean isEnemy(Creature target, Creature attacker) {
        PvPEventPlayerObject attackerMember = this.getParticipant(attacker.getPlayer());
        if (attackerMember == null) {
            return false;
        }
        PvPEventPlayerObject targetMember = this.getParticipant(target.getPlayer());
        if (targetMember == null) {
            return false;
        }
        return attackerMember.getTeam() == -1 || attackerMember.getTeam() != targetMember.getTeam();
    }

    public boolean isRegistered(Player player) {
        List<Player> players = this.getObjects("registered_players");
        for (Player temp : players) {
            if (!player.equals(temp)) continue;
            return true;
        }
        return false;
    }

    public PvPEventArenaObject getArena(Player player) {
        List<PvPEventArenaObject> arenas = this.getObjects("arenas");
        for (PvPEventArenaObject arena : arenas) {
            if (arena.getParticipant(player) == null) continue;
            return arena;
        }
        return null;
    }

    public PvPEventPlayerObject getParticipant(Player player) {
        PvPEventArenaObject arena = this.getArena(player);
        if (arena != null) {
            return arena.getParticipant(player);
        }
        return null;
    }

    @Override
    public String getVisibleName(Player player, Player observer) {
        if (player != observer && this.isBattleActive() && this.isHideNick()) {
            return new CustomMessage("l2s.gameserver.model.entity.events.impl.PvPEvent.playername").toString(observer);
        }
        return null;
    }

    @Override
    public String getVisibleTitle(Player player, Player observer) {
        if (player != observer && this.isBattleActive() && this.isHideNick()) {
            return "";
        }
        return null;
    }

    @Override
    public Integer getVisibleNameColor(Player player, Player observer) {
        if (player != observer && this.isBattleActive() && this.isHideNick()) {
            return 0xFFFFFF;
        }
        return null;
    }

    @Override
    public Integer getVisibleTitleColor(Player player, Player observer) {
        if (player != observer && this.isBattleActive() && this.isHideNick()) {
            return 0xFFFF77;
        }
        return null;
    }

    @Override
    public boolean isPledgeVisible(Player player, Player observer) {
        return player == observer || !this.isBattleActive() || !this.isHideNick();
    }

    @Override
    public boolean checkCondition(Creature creature, Class<? extends Condition> conditionClass) {
        if (this.isBattleActive() && this._enableHeroCond) {
            if (conditionClass == ConditionPlayerOlympiad.class) {
                return false;
            }
            if (conditionClass.isAssignableFrom(ConditionPlayerOlympiad.class)) {
                return false;
            }
        }
        return true;
    }

    @Override
    public Boolean isInZoneBattle(Creature creature) {
        return this.isBattleActive();
    }

    public boolean checkStop() {
        return true;
    }

    @Override
    public boolean canJoinParty(Player inviter, Player target) {
        return false;
    }

    private int[][] parseBuffs(String buffs) {
        if (buffs == null || buffs.isEmpty()) {
            return new int[0][];
        }
        StringTokenizer st = new StringTokenizer(buffs, ";");
        int[][] realBuffs = new int[st.countTokens()][2];
        int index = 0;
        while (st.hasMoreTokens()) {
            String[] skillLevel = st.nextToken().split(",");
            int[] realHourMin = new int[]{Integer.parseInt(skillLevel[0]), Integer.parseInt(skillLevel[1])};
            realBuffs[index] = realHourMin;
            ++index;
        }
        return realBuffs;
    }

    @Override
    public void checkRestartLocs(Player player, Map<RestartType, Boolean> r) {
        r.clear();
    }

    @Override
    public boolean isForceScheduled() {
        return this._isForceScheduled;
    }

    @Override
    public boolean forceScheduleEvent() {
        if (this.isForceScheduled()) {
            return false;
        }
        if (this.isInProgress()) {
            return false;
        }
        this._isForceScheduled = true;
        this.clearActions();
        this._startTimeMillis = this.getForceStartTime();
        this.registerActions();
        return true;
    }

    @Override
    public boolean forceCancelEvent() {
        if (!this.isForceScheduled()) {
            return false;
        }
        this._isForceScheduled = false;
        this.stopEvent(true);
        this.reCalcNextTime(false);
        return true;
    }
}


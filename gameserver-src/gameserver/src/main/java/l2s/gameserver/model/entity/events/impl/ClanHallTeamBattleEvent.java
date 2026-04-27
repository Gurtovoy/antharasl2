/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.collections.CollectionUtils
 *  l2s.commons.collections.MultiValueSet
 */
package l2s.gameserver.model.entity.events.impl;

import java.util.List;
import l2s.commons.collections.CollectionUtils;
import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.dao.SiegeClanDAO;
import l2s.gameserver.dao.SiegePlayerDAO;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.RestartType;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.model.entity.events.objects.CTBSiegeClanObject;
import l2s.gameserver.model.entity.events.objects.CTBTeamObject;
import l2s.gameserver.model.entity.events.objects.SiegeClanObject;
import l2s.gameserver.model.entity.residence.Residence;
import l2s.gameserver.model.entity.residence.clanhall.SiegeableClanHall;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.PlaySoundPacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.tables.ClanTable;

public class ClanHallTeamBattleEvent
extends SiegeEvent<SiegeableClanHall, CTBSiegeClanObject> {
    public static final String TRYOUT_PART = "tryout_part";
    public static final String CHALLENGER_RESTART_POINTS = "challenger_restart_points";
    public static final String FIRST_DOORS = "first_doors";
    public static final String SECOND_DOORS = "second_doors";
    public static final String NEXT_STEP = "next_step";

    public ClanHallTeamBattleEvent(MultiValueSet<String> set) {
        super(set);
    }

    @Override
    public void startEvent() {
        List attackers = this.getObjects("attackers");
        if (attackers.isEmpty()) {
            if (((SiegeableClanHall)this.getResidence()).getOwner() == null) {
                this.broadcastInZone2(new IBroadcastPacket[]{new SystemMessagePacket(SystemMsg.THE_SIEGE_OF_S1_HAS_BEEN_CANCELED_DUE_TO_LACK_OF_INTEREST).addResidenceName((Residence)this.getResidence())});
            } else {
                this.broadcastInZone2(new IBroadcastPacket[]{new SystemMessagePacket(SystemMsg.S1S_SIEGE_WAS_CANCELED_BECAUSE_THERE_WERE_NO_CLANS_THAT_PARTICIPATED).addResidenceName((Residence)this.getResidence())});
            }
            this.reCalcNextTime(false);
            return;
        }
        this._oldOwner = ((SiegeableClanHall)this.getResidence()).getOwner();
        if (this._oldOwner != null) {
            this.addObject("defenders", new SiegeClanObject("defenders", this._oldOwner, 0L));
        }
        SiegeClanDAO.getInstance().delete((Residence)this.getResidence());
        SiegePlayerDAO.getInstance().delete((Residence)this.getResidence());
        List teams = this.getObjects(TRYOUT_PART);
        for (int i = 0; i < 5; ++i) {
            CTBTeamObject team = (CTBTeamObject)teams.get(i);
            team.setSiegeClan((CTBSiegeClanObject)CollectionUtils.safeGet(attackers, (int)i));
        }
        this.broadcastTo((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THE_SIEGE_TO_CONQUER_S1_HAS_BEGUN).addResidenceName((Residence)this.getResidence()), "attackers", "defenders");
        this.broadcastTo(SystemMsg.THE_TRYOUTS_ARE_ABOUT_TO_BEGIN, "attackers");
        super.startEvent();
    }

    public void nextStep() {
        this.broadcastTo(SystemMsg.THE_TRYOUTS_HAVE_BEGUN, "attackers", "defenders");
        this.updateParticles(true, "attackers", "defenders");
    }

    public void processStep(CTBTeamObject team) {
        if (team.getSiegeClan() != null) {
            CTBSiegeClanObject object = team.getSiegeClan();
            object.setEvent(false, this);
            this.teleportPlayers("spectators");
        }
        team.despawnObject(this, this.getReflection());
        List<CTBTeamObject> teams = this.getObjects(TRYOUT_PART);
        boolean hasWinner = false;
        CTBTeamObject winnerTeam = null;
        for (CTBTeamObject t : teams) {
            if (!t.isParticle()) continue;
            hasWinner = winnerTeam == null;
            winnerTeam = t;
        }
        if (!hasWinner) {
            return;
        }
        CTBSiegeClanObject clan = winnerTeam.getSiegeClan();
        if (clan != null) {
            ((SiegeableClanHall)this.getResidence()).changeOwner(clan.getClan());
        }
        this.stopEvent(true);
    }

    @Override
    public void announce(int id, String value, int time) {
        if (id == 1) {
            int val = Integer.parseInt(value);
            int minute = val / 60;
            if (minute > 0) {
                this.broadcastTo((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THE_CONTEST_WILL_BEGIN_IN_S1_MINUTES).addInteger(minute), "attackers", "defenders");
            } else {
                this.broadcastTo((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THE_PRELIMINARY_MATCH_WILL_BEGIN_IN_S1_SECONDS).addInteger(val), "attackers", "defenders");
            }
        }
    }

    @Override
    public void stopEvent(boolean force) {
        Clan newOwner = ((SiegeableClanHall)this.getResidence()).getOwner();
        if (newOwner != null) {
            if (this._oldOwner != newOwner) {
                newOwner.broadcastToOnlineMembers(PlaySoundPacket.SIEGE_VICTORY);
            }
            this.broadcastTo((IBroadcastPacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.S1_CLAN_HAS_DEFEATED_S2).addString(newOwner.getName())).addResidenceName((Residence)this.getResidence()), "attackers", "defenders");
            this.broadcastTo((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THE_SIEGE_OF_S1_IS_FINISHED).addResidenceName((Residence)this.getResidence()), "attackers", "defenders");
        } else {
            this.broadcastTo((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THE_PRELIMINARY_MATCH_OF_S1_HAS_ENDED_IN_A_DRAW).addResidenceName((Residence)this.getResidence()), "attackers");
        }
        this.updateParticles(false, "attackers", "defenders");
        this.removeObjects("defenders");
        this.removeObjects("attackers");
        super.stopEvent(force);
        this._oldOwner = null;
    }

    @Override
    public void loadSiegeClans() {
        List<SiegeClanObject> siegeClanObjectList = SiegeClanDAO.getInstance().load((Residence)this.getResidence(), "attackers");
        this.addObjects("attackers", siegeClanObjectList);
        List<CTBSiegeClanObject> objects = this.getObjects("attackers");
        for (CTBSiegeClanObject clan : objects) {
            clan.select((Residence)this.getResidence());
        }
    }

    @Override
    public CTBSiegeClanObject newSiegeClan(String type, int clanId, long i, long date) {
        Clan clan = ClanTable.getInstance().getClan(clanId);
        return clan == null ? null : new CTBSiegeClanObject(type, clan, i, date);
    }

    @Override
    public void findEvent(Player player) {
        if (!this.isInProgress() || player.getClan() == null) {
            return;
        }
        CTBSiegeClanObject object = (CTBSiegeClanObject)this.getSiegeClan("attackers", player.getClan());
        if (object != null && object.getPlayers().contains(player.getObjectId())) {
            player.addEvent(this);
        }
    }

    @Override
    public Location getRestartLoc(Player player, RestartType type) {
        if (!this.checkIfInZone(player)) {
            return null;
        }
        Object attackerClan = this.getSiegeClan("attackers", player.getClan());
        Location loc = null;
        switch (type) {
            case TO_VILLAGE: {
                if (attackerClan == null || !this.checkIfInZone(player)) break;
                List objectList = this.getObjects("attackers");
                List teleportList = this.getObjects(CHALLENGER_RESTART_POINTS);
                int index = objectList.indexOf(attackerClan);
                loc = (Location)teleportList.get(index);
            }
        }
        return loc;
    }

    @Override
    public boolean canResurrect(Creature active, Creature target, boolean force, boolean quiet) {
        return true;
    }

    @Override
    public void action(String name, boolean start) {
        if (name.equalsIgnoreCase(NEXT_STEP)) {
            this.nextStep();
        } else {
            super.action(name, start);
        }
    }

    @Override
    public int getUserRelation(Player thisPlayer, int result) {
        return result;
    }

    @Override
    public int getRelation(Player thisPlayer, Player targetPlayer, int result) {
        return result;
    }
}


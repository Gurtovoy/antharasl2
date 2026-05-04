/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity.events.impl;

import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.dao.SiegeClanDAO;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.model.entity.events.objects.SiegeClanObject;
import l2s.gameserver.model.entity.residence.Residence;
import l2s.gameserver.model.entity.residence.clanhall.SiegeableClanHall;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.PlaySoundPacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;

public class ClanHallSiegeEvent
extends SiegeEvent<SiegeableClanHall, SiegeClanObject> {
    public static final String BOSS = "boss";

    public ClanHallSiegeEvent(MultiValueSet<String> set) {
        super(set);
    }

    @Override
    public void startEvent() {
        if (this.getObjects("attackers").size() == 0) {
            this.broadcastInZone2(new IBroadcastPacket[]{new SystemMessagePacket(SystemMsg.THE_SIEGE_OF_S1_HAS_BEEN_CANCELED_DUE_TO_LACK_OF_INTEREST).addResidenceName((Residence)this.getResidence())});
            this.reCalcNextTime(false);
            return;
        }
        this._oldOwner = ((SiegeableClanHall)this.getResidence()).getOwner();
        if (this._oldOwner != null) {
            ((SiegeableClanHall)this.getResidence()).changeOwner(null);
            this.addObject("attackers", new SiegeClanObject("attackers", this._oldOwner, 0L));
        }
        SiegeClanDAO.getInstance().delete((Residence)this.getResidence());
        this.updateParticles(true, "attackers");
        this.broadcastTo((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THE_SIEGE_TO_CONQUER_S1_HAS_BEGUN).addResidenceName((Residence)this.getResidence()), "attackers");
        super.startEvent();
    }

    @Override
    public void stopEvent(boolean force) {
        Clan newOwner = ((SiegeableClanHall)this.getResidence()).getOwner();
        if (newOwner != null) {
            newOwner.broadcastToOnlineMembers(PlaySoundPacket.SIEGE_VICTORY);
            this.broadcastTo((IBroadcastPacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.S1_CLAN_HAS_DEFEATED_S2).addString(newOwner.getName())).addResidenceName((Residence)this.getResidence()), "attackers");
            this.broadcastTo((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THE_SIEGE_OF_S1_IS_FINISHED).addResidenceName((Residence)this.getResidence()), "attackers");
        } else {
            this.broadcastTo((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THE_SIEGE_OF_S1_HAS_ENDED_IN_A_DRAW).addResidenceName((Residence)this.getResidence()), "attackers");
        }
        this.updateParticles(false, "attackers");
        this.removeObjects("attackers");
        super.stopEvent(force);
        this._oldOwner = null;
    }

    @Override
    public void removeState(int val) {
        super.removeState(val);
        if (val == 2) {
            this.broadcastTo((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THE_DEADLINE_TO_REGISTER_FOR_THE_SIEGE_OF_S1_HAS_PASSED).addResidenceName((Residence)this.getResidence()), "attackers");
        }
    }

    @Override
    public void processStep(Clan clan) {
        if (clan != null) {
            ((SiegeableClanHall)this.getResidence()).changeOwner(clan);
        }
        this.stopEvent(true);
    }

    @Override
    public void loadSiegeClans() {
        this.addObjects("attackers", SiegeClanDAO.getInstance().load((Residence)this.getResidence(), "attackers"));
    }

    @Override
    public int getUserRelation(Player thisPlayer, int result) {
        return result;
    }

    @Override
    public int getRelation(Player thisPlayer, Player targetPlayer, int result) {
        return result;
    }

    @Override
    public boolean canResurrect(Creature active, Creature target, boolean force, boolean quiet) {
        boolean playerInZone = this.checkIfInZone(active);
        boolean targetInZone = this.checkIfInZone(target);
        if (!playerInZone && !targetInZone || !targetInZone) {
            return true;
        }
        Player resurectPlayer = active.getPlayer();
        Player targetPlayer = target.getPlayer();
        if (!resurectPlayer.containsEvent(this) || !targetPlayer.containsEvent(this)) {
            if (!quiet) {
                if (force) {
                    targetPlayer.sendPacket((IBroadcastPacket)SystemMsg.IT_IS_NOT_POSSIBLE_TO_RESURRECT_IN_BATTLEFIELDS_WHERE_A_SIEGE_WAR_IS_TAKING_PLACE);
                }
                active.sendPacket((IBroadcastPacket)(force ? SystemMsg.IT_IS_NOT_POSSIBLE_TO_RESURRECT_IN_BATTLEFIELDS_WHERE_A_SIEGE_WAR_IS_TAKING_PLACE : SystemMsg.INVALID_TARGET));
            }
            return false;
        }
        Object targetSiegeClan = this.getSiegeClan("attackers", targetPlayer.getClan());
        if (targetSiegeClan == null || ((SiegeClanObject)targetSiegeClan).getFlag() == null) {
            if (!quiet) {
                if (force) {
                    targetPlayer.sendPacket((IBroadcastPacket)SystemMsg.IF_A_BASE_CAMP_DOES_NOT_EXIST_RESURRECTION_IS_NOT_POSSIBLE);
                }
                active.sendPacket((IBroadcastPacket)(force ? SystemMsg.IF_A_BASE_CAMP_DOES_NOT_EXIST_RESURRECTION_IS_NOT_POSSIBLE : SystemMsg.INVALID_TARGET));
            }
            return false;
        }
        if (force) {
            return true;
        }
        if (!quiet) {
            active.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
        }
        return false;
    }
}


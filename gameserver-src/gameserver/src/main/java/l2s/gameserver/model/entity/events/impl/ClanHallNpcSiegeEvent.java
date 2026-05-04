/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity.events.impl;

import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.model.entity.events.objects.SiegeClanObject;
import l2s.gameserver.model.entity.residence.Residence;
import l2s.gameserver.model.entity.residence.clanhall.SiegeableClanHall;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.PlaySoundPacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;

public class ClanHallNpcSiegeEvent
extends SiegeEvent<SiegeableClanHall, SiegeClanObject> {
    public ClanHallNpcSiegeEvent(MultiValueSet<String> set) {
        super(set);
    }

    @Override
    public void startEvent() {
        this._oldOwner = ((SiegeableClanHall)this.getResidence()).getOwner();
        this.broadcastInZone(new IBroadcastPacket[]{new SystemMessagePacket(SystemMsg.THE_SIEGE_TO_CONQUER_S1_HAS_BEGUN).addResidenceName((Residence)this.getResidence())});
        super.startEvent();
    }

    @Override
    public void stopEvent(boolean force) {
        Clan newOwner = ((SiegeableClanHall)this.getResidence()).getOwner();
        if (newOwner != null) {
            if (this._oldOwner != newOwner) {
                newOwner.broadcastToOnlineMembers(PlaySoundPacket.SIEGE_VICTORY);
            }
            this.broadcastInZone(new IBroadcastPacket[]{((SystemMessagePacket)new SystemMessagePacket(SystemMsg.S1_CLAN_HAS_DEFEATED_S2).addString(newOwner.getName())).addResidenceName((Residence)this.getResidence())});
            this.broadcastInZone(new IBroadcastPacket[]{new SystemMessagePacket(SystemMsg.THE_SIEGE_OF_S1_IS_FINISHED).addResidenceName((Residence)this.getResidence())});
        } else {
            this.broadcastInZone(new IBroadcastPacket[]{new SystemMessagePacket(SystemMsg.THE_SIEGE_OF_S1_HAS_ENDED_IN_A_DRAW).addResidenceName((Residence)this.getResidence())});
        }
        super.stopEvent(force);
        this._oldOwner = null;
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
    }

    @Override
    public boolean canResurrect(Creature active, Creature target, boolean force, boolean quiet) {
        return true;
    }
}


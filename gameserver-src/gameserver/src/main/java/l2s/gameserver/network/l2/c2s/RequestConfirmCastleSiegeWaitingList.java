/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.dao.SiegeClanDAO;
import l2s.gameserver.data.xml.holder.ResidenceHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.events.impl.CastleSiegeEvent;
import l2s.gameserver.model.entity.events.objects.SiegeClanObject;
import l2s.gameserver.model.entity.residence.Castle;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.CastleSiegeDefenderListPacket;

public class RequestConfirmCastleSiegeWaitingList
extends L2GameClientPacket {
    private boolean _approved;
    private int _unitId;
    private int _clanId;

    @Override
    protected boolean readImpl() {
        this._unitId = this.readD();
        this._clanId = this.readD();
        this._approved = this.readD() == 1;
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        Castle castle = ResidenceHolder.getInstance().getResidence(Castle.class, this._unitId);
        if (castle == null) {
            player.sendActionFailed();
            return;
        }
        if (!(player.isGM() || player.getClan() != null && player.getClan().getCastle() == castle.getId() && player.isClanLeader())) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_THE_AUTHORITY_TO_MODIFY_THE_CASTLE_DEFENDER_LIST);
            return;
        }
        CastleSiegeEvent siegeEvent = (CastleSiegeEvent)((Object)castle.getSiegeEvent());
        Object siegeClan = siegeEvent.getSiegeClan("defenders_waiting", this._clanId);
        if (siegeClan == null) {
            siegeClan = siegeEvent.getSiegeClan("defenders", this._clanId);
        }
        if (siegeClan == null) {
            return;
        }
        if (siegeEvent.isRegistrationOver()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.THIS_IS_NOT_THE_TIME_FOR_SIEGE_REGISTRATION_AND_SO_REGISTRATIONS_CANNOT_BE_ACCEPTED_OR_REJECTED);
            return;
        }
        int allSize = siegeEvent.getObjects("defenders").size();
        if (allSize >= CastleSiegeEvent.MAX_SIEGE_CLANS) {
            player.sendPacket((IBroadcastPacket)SystemMsg.NO_MORE_REGISTRATIONS_MAY_BE_ACCEPTED_FOR_THE_DEFENDER_SIDE);
            return;
        }
        siegeEvent.removeObject(((SiegeClanObject)siegeClan).getType(), siegeClan);
        if (this._approved) {
            ((SiegeClanObject)siegeClan).setType("defenders");
        } else {
            ((SiegeClanObject)siegeClan).setType("defenders_refused");
        }
        siegeEvent.addObject(((SiegeClanObject)siegeClan).getType(), siegeClan);
        SiegeClanDAO.getInstance().update(castle, (SiegeClanObject)siegeClan);
        player.sendPacket((IBroadcastPacket)new CastleSiegeDefenderListPacket(castle));
    }
}


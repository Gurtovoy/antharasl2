/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.cache.CrestCache;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;

public class RequestSetPledgeCrest
extends L2GameClientPacket {
    private int _length;
    private byte[] _data;

    @Override
    protected boolean readImpl() {
        this._length = this.readD();
        if (this._length == 256 && this._length == this._buf.remaining()) {
            this._data = new byte[this._length];
            this.readB(this._data);
        }
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (this._length < 0) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THE_SIZE_OF_THE_UPLOADED_SYMBOL_DOES_NOT_MEET_THE_STANDARD_REQUIREMENTS);
            return;
        }
        if (this._length > 256) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THE_SIZE_OF_THE_IMAGE_FILE_IS_INAPPROPRIATE__PLEASE_ADJUST_TO_16X12_PIXELS);
            return;
        }
        Clan clan = activeChar.getClan();
        if ((activeChar.getClanPrivileges() & 0x80) != 128) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_ARE_NOT_AUTHORIZED_TO_DO_THAT);
            return;
        }
        if (clan.isPlacedForDisband()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.AS_YOU_ARE_CURRENTLY_SCHEDULE_FOR_CLAN_DISSOLUTION_YOU_CANNOT_REGISTER_OR_DELETE_A_CLAN_CREST);
            return;
        }
        int crestId = 0;
        if (this._data != null) {
            crestId = CrestCache.getInstance().savePledgeCrest(clan.getClanId(), this._data);
        } else if (clan.hasCrest()) {
            CrestCache.getInstance().removePledgeCrest(clan.getClanId());
        }
        if (crestId > 0) {
            if (clan.getLevel() < 3) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.A_CLAN_CREST_CAN_ONLY_BE_REGISTERED_WHEN_THE_CLANS_SKILL_LEVEL_IS_3_OR_ABOVE);
                return;
            }
            clan.setCrestId(crestId);
            clan.broadcastClanStatus(false, true, false);
            activeChar.sendUserInfo(true);
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THE_CREST_WAS_SUCCESSFULLY_REGISTERED);
        } else if (clan.hasCrest()) {
            clan.setCrestId(0);
            clan.broadcastClanStatus(false, true, false);
            activeChar.sendUserInfo(true);
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THE_CLAN_MARK_HAS_BEEN_DELETED);
        }
    }
}


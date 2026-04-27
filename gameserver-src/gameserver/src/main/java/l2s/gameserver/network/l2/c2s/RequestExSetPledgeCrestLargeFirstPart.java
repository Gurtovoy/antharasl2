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
import l2s.gameserver.network.l2.s2c.ExSetPledgeEmblemAck;

public class RequestExSetPledgeCrestLargeFirstPart
extends L2GameClientPacket {
    private int _crestPart;
    private int _crestLeght;
    private int _length;
    private byte[] _data;

    @Override
    protected boolean readImpl() {
        this._crestPart = this.readD();
        this._crestLeght = this.readD();
        this._length = this.readD();
        if (this._length <= 14336 && this._length == this._buf.remaining()) {
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
        Clan clan = activeChar.getClan();
        if (clan == null) {
            return;
        }
        if ((activeChar.getClanPrivileges() & 0x80) == 128) {
            if (clan.isPlacedForDisband()) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.AS_YOU_ARE_CURRENTLY_SCHEDULE_FOR_CLAN_DISSOLUTION_YOU_CANNOT_REGISTER_OR_DELETE_A_CLAN_CREST);
                return;
            }
            int crestId = 0;
            if (this._data != null) {
                crestId = CrestCache.getInstance().savePledgeCrestLarge(clan.getClanId(), this._crestPart, this._crestLeght, this._data);
                if (crestId > 0) {
                    activeChar.sendPacket((IBroadcastPacket)SystemMsg.THE_CLAN_CREST_WAS_SUCCESSFULLY_REGISTERED);
                    clan.setCrestLargeId(crestId);
                    clan.broadcastClanStatus(false, true, false);
                }
                activeChar.sendPacket((IBroadcastPacket)new ExSetPledgeEmblemAck(this._crestPart));
            } else if (clan.hasCrestLarge()) {
                CrestCache.getInstance().removePledgeCrestLarge(clan.getClanId());
                clan.setCrestLargeId(crestId);
                clan.broadcastClanStatus(false, true, false);
            }
        }
    }
}


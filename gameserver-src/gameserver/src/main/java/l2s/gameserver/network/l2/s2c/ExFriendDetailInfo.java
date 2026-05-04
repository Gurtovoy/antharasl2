package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.cache.CrestCache;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.Friend;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExFriendDetailInfo
extends L2GameServerPacket {
    private final int _objectId;
    private final Friend _friend;
    private final int _clanCrestId;
    private final int _allyCrestId;

    public ExFriendDetailInfo(Player player, Friend friend) {
        this._objectId = player.getObjectId();
        this._friend = friend;
        this._clanCrestId = this._friend.getClanId() > 0 ? CrestCache.getInstance().getPledgeCrestId(this._friend.getClanId()) : 0;
        this._allyCrestId = this._friend.getAllyId() > 0 ? CrestCache.getInstance().getAllyCrestId(this._friend.getAllyId()) : 0;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._objectId);
        this.writeS(this._friend.getName());
        this.writeD(this._friend.isOnline());
        this.writeD(this._friend.isOnline() ? this._friend.getObjectId() : 0);
        this.writeH(this._friend.getLevel());
        this.writeH(this._friend.getClassId());
        this.writeD(this._friend.getClanId());
        this.writeD(this._clanCrestId);
        this.writeS(this._friend.getClanName());
        this.writeD(this._friend.getAllyId());
        this.writeD(this._allyCrestId);
        this.writeS(this._friend.getAllyName());
        this.writeC(this._friend.getCreationMonth() + 1);
        this.writeC(this._friend.getCreationDay());
        this.writeD(this._friend.getLastAccessDelay());
        this.writeS(this._friend.getMemo());
    }
}


package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.cache.ItemInfoCache;
import l2s.gameserver.model.items.ItemInfo;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.s2c.ActionFailPacket;
import l2s.gameserver.network.l2.s2c.ExRpItemLink;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class RequestExRqItemLink
extends L2GameClientPacket {
    private int _objectId;

    @Override
    protected boolean readImpl() {
        this._objectId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        ItemInfo item = ItemInfoCache.getInstance().get(this._objectId);
        if (item == null) {
            this.sendPacket(ActionFailPacket.STATIC);
        } else {
            this.sendPacket((L2GameServerPacket)new ExRpItemLink(item));
        }
    }
}


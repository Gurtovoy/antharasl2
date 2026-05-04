/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.util.Collection;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.TradeItem;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PrivateStoreList
extends L2GameServerPacket {
    private int _sellerId;
    private long _adena;
    private final boolean _package;
    private Collection<TradeItem> _sellList;

    public PrivateStoreList(Player buyer, Player seller) {
        this._sellerId = seller.getObjectId();
        this._adena = buyer.getAdena();
        this._package = seller.getPrivateStoreType() == 8;
        this._sellList = seller.getSellList().values();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._sellerId);
        this.writeD(this._package ? 1 : 0);
        this.writeQ(this._adena);
        this.writeD(0);
        this.writeD(this._sellList.size());
        for (TradeItem si : this._sellList) {
            this.writeItemInfo(si);
            this.writeQ(si.getOwnersPrice());
            this.writeQ(si.getStorePrice());
        }
    }
}


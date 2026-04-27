/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.TradeItem;
import l2s.gameserver.network.l2.ServerPacketOpcodes;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.npc.BuyListTemplate;

public abstract class ExBuySellListPacket
extends L2GameServerPacket {
    @Override
    protected ServerPacketOpcodes getOpcodes() {
        return ServerPacketOpcodes.ExBuySellListPacket;
    }

    public static class SellRefundList
    extends ExBuySellListPacket {
        private final List<TradeItem> _sellList;
        private final List<TradeItem> _refundList;
        private int _done;
        private final double _taxRate;
        private final int _inventoryUsedSlots;

        public SellRefundList(Player activeChar, boolean done, double taxRate) {
            this._done = done ? 1 : 0;
            this._taxRate = taxRate;
            this._inventoryUsedSlots = activeChar.getInventory().getSize();
            if (done) {
                this._refundList = Collections.emptyList();
                this._sellList = Collections.emptyList();
            } else {
                ItemInstance[] items = activeChar.getRefund().getItems();
                if (Config.ALLOW_ITEMS_REFUND) {
                    this._refundList = new ArrayList<TradeItem>(items.length);
                    for (ItemInstance item : items) {
                        this._refundList.add(new TradeItem(item));
                    }
                } else {
                    this._refundList = new ArrayList<TradeItem>(0);
                }
                items = activeChar.getInventory().getItems();
                this._sellList = new ArrayList<TradeItem>(items.length);
                for (ItemInstance item : items) {
                    if (!item.canBeSold(activeChar)) continue;
                    this._sellList.add(new TradeItem(item, item.getTemplate().isBlocked(activeChar, item)));
                }
            }
        }

        @Override
        protected void writeImpl() {
            this.writeD(1);
            this.writeD(this._inventoryUsedSlots);
            this.writeH(this._sellList.size());
            for (TradeItem item : this._sellList) {
                this.writeItemInfo(item);
                if (Config.ALT_SELL_ITEM_ONE_ADENA) {
                    this.writeQ(1L);
                    continue;
                }
                this.writeQ(item.getReferencePrice() / 2L);
            }
            this.writeH(this._refundList.size());
            for (TradeItem item : this._refundList) {
                this.writeItemInfo(item);
                this.writeD(item.getObjectId());
                if (Config.ALT_SELL_ITEM_ONE_ADENA) {
                    this.writeQ(item.getCount());
                    continue;
                }
                this.writeQ((long)((double)(item.getCount() * item.getReferencePrice() / 2L) * (1.0 - this._taxRate)));
            }
            this.writeC(this._done);
        }
    }

    public static class BuyList
    extends ExBuySellListPacket {
        private final int _listId;
        private final List<TradeItem> _buyList;
        private final long _adena;
        private final double _taxRate;
        private final int _inventoryUsedSlots;

        public BuyList(BuyListTemplate buyList, Player activeChar, double taxRate) {
            this._adena = activeChar.getAdena();
            this._taxRate = taxRate;
            this._inventoryUsedSlots = activeChar.getInventory().getSize();
            if (buyList != null) {
                this._listId = buyList.getListId();
                this._buyList = buyList.getItems();
                activeChar.setBuyListId(this._listId);
            } else {
                this._listId = 0;
                this._buyList = Collections.emptyList();
                activeChar.setBuyListId(0);
            }
        }

        @Override
        protected void writeImpl() {
            this.writeD(0);
            this.writeQ(this._adena);
            this.writeD(this._listId);
            this.writeD(this._inventoryUsedSlots);
            this.writeH(this._buyList.size());
            for (TradeItem item : this._buyList) {
                this.writeItemInfo(item, item.getCurrentValue());
                this.writeQ((long)((double)item.getOwnersPrice() * (1.0 + this._taxRate)));
            }
        }
    }
}


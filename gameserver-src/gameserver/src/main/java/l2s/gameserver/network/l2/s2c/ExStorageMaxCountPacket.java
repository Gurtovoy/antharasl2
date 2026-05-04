package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExStorageMaxCountPacket
extends L2GameServerPacket {
    private int _inventory;
    private int _warehouse;
    private int _clan;
    private int _privateSell;
    private int _privateBuy;
    private int _recipeDwarven;
    private int _recipeCommon;
    private int _inventoryExtraSlots;
    private int _questItemsLimit;

    public ExStorageMaxCountPacket(Player player) {
        this._inventory = player.getInventoryLimit();
        this._warehouse = player.getWarehouseLimit();
        this._clan = Config.WAREHOUSE_SLOTS_CLAN;
        this._privateBuy = this._privateSell = player.getTradeLimit();
        this._recipeDwarven = player.getDwarvenRecipeLimit();
        this._recipeCommon = player.getCommonRecipeLimit();
        this._inventoryExtraSlots = player.getBeltInventoryIncrease();
        this._questItemsLimit = Config.QUEST_INVENTORY_MAXIMUM;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._inventory);
        this.writeD(this._warehouse);
        this.writeD(this._clan);
        this.writeD(this._privateSell);
        this.writeD(this._privateBuy);
        this.writeD(this._recipeDwarven);
        this.writeD(this._recipeCommon);
        this.writeD(this._inventoryExtraSlots);
        this.writeD(this._questItemsLimit);
        this.writeD(40);
        this.writeD(40);
    }
}


package l2s.gameserver.network.l2.c2s;

import java.util.LinkedHashMap;
import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ManufactureItem;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.utils.TradeHelper;

public class RequestRecipeShopListSet
extends L2GameClientPacket {
    private int[] _recipes;
    private long[] _prices;
    private int _count;

    @Override
    protected boolean readImpl() {
        this._count = this.readD();
        if (this._count * 12 > this._buf.remaining() || this._count > Short.MAX_VALUE || this._count < 1) {
            this._count = 0;
            return false;
        }
        this._recipes = new int[this._count];
        this._prices = new long[this._count];
        for (int i = 0; i < this._count; ++i) {
            this._recipes[i] = this.readD();
            this._prices[i] = this.readQ();
            if (this._prices[i] >= 0L) continue;
            this._count = 0;
            return false;
        }
        return true;
    }

    @Override
    protected void runImpl() {
        Player manufacturer = ((GameClient)this.getClient()).getActiveChar();
        if (manufacturer == null || this._count == 0) {
            return;
        }
        if (!TradeHelper.checksIfCanOpenStore(manufacturer, 5)) {
            manufacturer.sendActionFailed();
            return;
        }
        if (this._count > Config.MAX_PVTCRAFT_SLOTS) {
            manufacturer.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_EXCEEDED_THE_QUANTITY_THAT_CAN_BE_INPUTTED);
            return;
        }
        LinkedHashMap<Integer, ManufactureItem> createList = new LinkedHashMap<Integer, ManufactureItem>();
        for (int i = 0; i < this._count; ++i) {
            int recipeId = this._recipes[i];
            long price = this._prices[i];
            if (!manufacturer.findRecipe(recipeId)) continue;
            ManufactureItem mi = new ManufactureItem(recipeId, price);
            createList.put(mi.getRecipeId(), mi);
        }
        if (!createList.isEmpty()) {
            manufacturer.setCreateList(createList);
            manufacturer.setPrivateStoreType(5);
            manufacturer.storePrivateStore();
            manufacturer.broadcastPrivateStoreInfo();
            manufacturer.sitDown(null);
            manufacturer.broadcastCharInfo();
        }
        manufacturer.sendActionFailed();
    }
}


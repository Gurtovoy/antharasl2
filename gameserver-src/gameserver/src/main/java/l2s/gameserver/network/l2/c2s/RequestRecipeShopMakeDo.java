/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.commons.util.Rnd;
import l2s.gameserver.data.xml.holder.RecipeHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.ManufactureItem;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.RecipeShopItemInfoPacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.templates.item.RecipeTemplate;
import l2s.gameserver.templates.item.data.ChancedItemData;
import l2s.gameserver.templates.item.data.ItemData;
import l2s.gameserver.utils.ItemFunctions;
import l2s.gameserver.utils.TradeHelper;

public class RequestRecipeShopMakeDo
extends L2GameClientPacket {
    private int _manufacturerId;
    private int _recipeId;
    private long _price;

    @Override
    protected boolean readImpl() {
        this._manufacturerId = this.readD();
        this._recipeId = this.readD();
        this._price = this.readQ();
        return true;
    }

    
    @Override
    protected void runImpl() {
        Player buyer = ((GameClient)this.getClient()).getActiveChar();
        if (buyer == null) {
            return;
        }
        if (buyer.isActionsDisabled()) {
            buyer.sendActionFailed();
            return;
        }
        if (buyer.isInStoreMode()) {
            buyer.sendPacket((IBroadcastPacket)SystemMsg.WHILE_OPERATING_A_PRIVATE_STORE_OR_WORKSHOP_YOU_CANNOT_DISCARD_DESTROY_OR_TRADE_AN_ITEM);
            return;
        }
        if (buyer.isInTrade()) {
            buyer.sendActionFailed();
            return;
        }
        if (buyer.isFishing()) {
            buyer.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_DO_THAT_WHILE_FISHING_2);
            return;
        }
        if (buyer.isInTrainingCamp()) {
            buyer.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_TAKE_OTHER_ACTION_WHILE_ENTERING_THE_TRAINING_CAMP);
            return;
        }
        if (!buyer.getPlayerAccess().UseTrade) {
            buyer.sendPacket((IBroadcastPacket)SystemMsg.SOME_LINEAGE_II_FEATURES_HAVE_BEEN_LIMITED_FOR_FREE_TRIALS_____);
            return;
        }
        Player manufacturer = (Player)buyer.getVisibleObject(this._manufacturerId);
        if (manufacturer == null || manufacturer.getPrivateStoreType() != 5 || !manufacturer.checkInteractionDistance(buyer)) {
            buyer.sendActionFailed();
            return;
        }
        RecipeTemplate recipe = null;
        for (ManufactureItem mi : manufacturer.getCreateList().values()) {
            if (mi.getRecipeId() != this._recipeId || this._price != mi.getCost()) continue;
            recipe = RecipeHolder.getInstance().getRecipeByRecipeId(this._recipeId);
            break;
        }
        if (recipe == null) {
            buyer.sendActionFailed();
            return;
        }
        if (recipe.getMaterials().length == 0 || recipe.getProducts().length == 0) {
            manufacturer.sendPacket((IBroadcastPacket)SystemMsg.THE_RECIPE_IS_INCORRECT);
            buyer.sendPacket((IBroadcastPacket)SystemMsg.THE_RECIPE_IS_INCORRECT);
            return;
        }
        if (recipe.getLevel() > manufacturer.getSkillLevel(!recipe.isCommon() ? 172 : 1320)) {
            buyer.sendActionFailed();
            return;
        }
        if (!manufacturer.findRecipe(this._recipeId)) {
            buyer.sendActionFailed();
            return;
        }
        int success = 0;
        if (manufacturer.getCurrentMp() < (double)recipe.getMpConsume()) {
            manufacturer.sendPacket((IBroadcastPacket)SystemMsg.NOT_ENOUGH_MP);
            buyer.sendPacket(SystemMsg.NOT_ENOUGH_MP, new RecipeShopItemInfoPacket(buyer, manufacturer, this._recipeId, this._price, success));
            return;
        }
        buyer.getInventory().writeLock();
        try {
            ItemData[] materials;
            if (buyer.getAdena() < this._price) {
                buyer.sendPacket(SystemMsg.YOU_DO_NOT_HAVE_ENOUGH_ADENA, new RecipeShopItemInfoPacket(buyer, manufacturer, this._recipeId, this._price, success));
                return;
            }
            for (ItemData material : materials = recipe.getMaterials()) {
                ItemInstance item;
                if (material.getCount() == 0L || (item = buyer.getInventory().getItemByItemId(material.getId())) != null && material.getCount() <= item.getCount()) continue;
                buyer.sendPacket(SystemMsg.YOU_DO_NOT_HAVE_ENOUGH_MATERIALS_TO_PERFORM_THAT_ACTION, new RecipeShopItemInfoPacket(buyer, manufacturer, this._recipeId, this._price, success));
                return;
            }
            if (!buyer.reduceAdena(this._price, false)) {
                buyer.sendPacket(SystemMsg.YOU_DO_NOT_HAVE_ENOUGH_ADENA, new RecipeShopItemInfoPacket(buyer, manufacturer, this._recipeId, this._price, success));
                return;
            }
            for (ItemData material : materials) {
                if (material.getCount() == 0L) continue;
                buyer.getInventory().destroyItemByItemId(material.getId(), material.getCount());
                buyer.sendPacket((IBroadcastPacket)SystemMessagePacket.removeItems(material.getId(), material.getCount()));
            }
            long tax = TradeHelper.getTax(manufacturer, this._price);
            if (tax > 0L) {
                this._price -= tax;
            }
            manufacturer.addAdena(this._price);
        }
        finally {
            buyer.getInventory().writeUnlock();
        }
        manufacturer.reduceCurrentMp(recipe.getMpConsume(), null);
        manufacturer.sendStatusUpdate(false, false, 11);
        ChancedItemData product = recipe.getRandomProduct();
        if (product != null) {
            SystemMessagePacket sm;
            int itemId = product.getId();
            long itemsCount = product.getCount();
            int rate = recipe.getSuccessRate();
            rate = (int)((double)rate + buyer.getPremiumAccount().getCraftChanceBonus());
            rate = (int)((double)rate + buyer.getVIP().getTemplate().getCraftChanceBonus());
            if (Rnd.chance((int)(rate = Math.min(100, rate)))) {
                ItemFunctions.addItem(buyer, itemId, itemsCount, true);
                if (itemsCount > 1L) {
                    sm = new SystemMessagePacket(SystemMsg.C1_CREATED_S2_S3_AT_THE_PRICE_OF_S4_ADENA);
                    sm.addName(manufacturer);
                    sm.addItemName(itemId);
                    sm.addLong(itemsCount);
                    sm.addLong(this._price);
                    buyer.sendPacket((IBroadcastPacket)sm);
                    sm = new SystemMessagePacket(SystemMsg.S2_S3_HAVE_BEEN_SOLD_TO_C1_FOR_S4_ADENA);
                    sm.addName(buyer);
                    sm.addItemName(itemId);
                    sm.addLong(itemsCount);
                    sm.addLong(this._price);
                    manufacturer.sendPacket((IBroadcastPacket)sm);
                } else {
                    sm = new SystemMessagePacket(SystemMsg.C1_CREATED_S2_AFTER_RECEIVING_S3_ADENA);
                    sm.addName(manufacturer);
                    sm.addItemName(itemId);
                    sm.addLong(this._price);
                    buyer.sendPacket((IBroadcastPacket)sm);
                    sm = new SystemMessagePacket(SystemMsg.S2_IS_SOLD_TO_C1_FOR_THE_PRICE_OF_S3_ADENA);
                    sm.addName(buyer);
                    sm.addItemName(itemId);
                    sm.addLong(this._price);
                    manufacturer.sendPacket((IBroadcastPacket)sm);
                }
                success = 1;
            } else {
                sm = new SystemMessagePacket(SystemMsg.C1_HAS_FAILED_TO_CREATE_S2_AT_THE_PRICE_OF_S3_ADENA);
                sm.addName(manufacturer);
                sm.addItemName(itemId);
                sm.addLong(this._price);
                buyer.sendPacket((IBroadcastPacket)sm);
                sm = new SystemMessagePacket(SystemMsg.YOUR_ATTEMPT_TO_CREATE_S2_FOR_C1_AT_THE_PRICE_OF_S3_ADENA_HAS_FAILED);
                sm.addName(buyer);
                sm.addItemName(itemId);
                sm.addLong(this._price);
                manufacturer.sendPacket((IBroadcastPacket)sm);
            }
        } else {
            SystemMessagePacket sm = new SystemMessagePacket(SystemMsg.C1_HAS_FAILED_TO_CREATE_S2_AT_THE_PRICE_OF_S3_ADENA);
            sm.addName(manufacturer);
            sm.addItemName(recipe.getProducts()[0].getId());
            sm.addLong(this._price);
            buyer.sendPacket((IBroadcastPacket)sm);
            sm = new SystemMessagePacket(SystemMsg.YOUR_ATTEMPT_TO_CREATE_S2_FOR_C1_AT_THE_PRICE_OF_S3_ADENA_HAS_FAILED);
            sm.addName(buyer);
            sm.addItemName(recipe.getProducts()[0].getId());
            sm.addLong(this._price);
            manufacturer.sendPacket((IBroadcastPacket)sm);
        }
        buyer.sendChanges();
        buyer.sendPacket((IBroadcastPacket)new RecipeShopItemInfoPacket(buyer, manufacturer, this._recipeId, this._price, success));
    }
}


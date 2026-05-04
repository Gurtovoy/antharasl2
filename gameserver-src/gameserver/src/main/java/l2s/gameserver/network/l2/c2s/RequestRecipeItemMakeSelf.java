package l2s.gameserver.network.l2.c2s;

import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.data.xml.holder.RecipeHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ActionFailPacket;
import l2s.gameserver.network.l2.s2c.RecipeItemMakeInfoPacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.templates.item.EtcItemTemplate;
import l2s.gameserver.templates.item.RecipeTemplate;
import l2s.gameserver.templates.item.data.ChancedItemData;
import l2s.gameserver.templates.item.data.ItemData;
import l2s.gameserver.utils.ItemFunctions;

public class RequestRecipeItemMakeSelf
extends L2GameClientPacket {
    private int _recipeId;

    @Override
    protected boolean readImpl() {
        this._recipeId = this.readD();
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (activeChar.isActionsDisabled()) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isInStoreMode()) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isProcessingRequest()) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isFishing()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_DO_THAT_WHILE_FISHING);
            return;
        }
        if (activeChar.isInTrainingCamp()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_TAKE_OTHER_ACTION_WHILE_ENTERING_THE_TRAINING_CAMP);
            return;
        }
        RecipeTemplate recipe = RecipeHolder.getInstance().getRecipeByRecipeId(this._recipeId);
        if (recipe == null || recipe.getMaterials().length == 0 || recipe.getProducts().length == 0) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THE_RECIPE_IS_INCORRECT);
            return;
        }
        if (recipe.getLevel() > activeChar.getSkillLevel(!recipe.isCommon() ? 172 : 1320)) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.getCurrentMp() < (double)recipe.getMpConsume()) {
            activeChar.sendPacket(SystemMsg.NOT_ENOUGH_MP, new RecipeItemMakeInfoPacket(activeChar, recipe, 0));
            return;
        }
        if (!activeChar.findRecipe(this._recipeId)) {
            activeChar.sendPacket(SystemMsg.PLEASE_REGISTER_A_RECIPE, ActionFailPacket.STATIC);
            return;
        }
        activeChar.getInventory().writeLock();
        try {
            ItemData[] materials;
            for (ItemData material : materials = recipe.getMaterials()) {
                if (material.getCount() == 0L) continue;
                if (Config.ALT_GAME_UNREGISTER_RECIPE && ItemHolder.getInstance().getTemplate(material.getId()).getItemType() == EtcItemTemplate.EtcItemType.RECIPE) {
                    RecipeTemplate rp = RecipeHolder.getInstance().getRecipeByRecipeItem(material.getId());
                    if (activeChar.hasRecipe(rp)) continue;
                    activeChar.sendPacket(SystemMsg.YOU_DO_NOT_HAVE_ENOUGH_MATERIALS_TO_PERFORM_THAT_ACTION, new RecipeItemMakeInfoPacket(activeChar, recipe, 0));
                    return;
                }
                ItemInstance item = activeChar.getInventory().getItemByItemId(material.getId());
                if (item != null && item.getCount() >= material.getCount()) continue;
                activeChar.sendPacket(SystemMsg.YOU_DO_NOT_HAVE_ENOUGH_MATERIALS_TO_PERFORM_THAT_ACTION, new RecipeItemMakeInfoPacket(activeChar, recipe, 0));
                return;
            }
            for (ItemData material : materials) {
                if (material.getCount() == 0L) continue;
                if (Config.ALT_GAME_UNREGISTER_RECIPE && ItemHolder.getInstance().getTemplate(material.getId()).getItemType() == EtcItemTemplate.EtcItemType.RECIPE) {
                    activeChar.unregisterRecipe(RecipeHolder.getInstance().getRecipeByRecipeItem(material.getId()).getId());
                    continue;
                }
                if (!activeChar.getInventory().destroyItemByItemId(material.getId(), material.getCount())) continue;
                activeChar.sendPacket((IBroadcastPacket)SystemMessagePacket.removeItems(material.getId(), material.getCount()));
            }
        }
        finally {
            activeChar.getInventory().writeUnlock();
        }
        activeChar.resetWaitSitTime();
        activeChar.reduceCurrentMp(recipe.getMpConsume(), null);
        double rate = recipe.getSuccessRate();
        rate += activeChar.getPremiumAccount().getCraftChanceBonus();
        rate += activeChar.getVIP().getTemplate().getCraftChanceBonus();
        rate = Math.min(100.0, rate);
        int success = 0;
        ChancedItemData product = recipe.getRandomProduct();
        if (product != null) {
            int itemId = product.getId();
            long itemsCount = product.getCount();
            if (Rnd.chance((double)rate)) {
                ItemFunctions.addItem(activeChar, itemId, itemsCount, true);
                success = 1;
            } else {
                activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOU_FAILED_TO_MANUFACTURE_S1).addItemName(itemId));
            }
        } else {
            activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOU_FAILED_TO_MANUFACTURE_S1).addItemName(recipe.getProducts()[0].getId()));
        }
        activeChar.sendPacket((IBroadcastPacket)new RecipeItemMakeInfoPacket(activeChar, recipe, success));
    }
}


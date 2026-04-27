/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.dao.JdbcEntityState
 *  l2s.commons.util.Rnd
 */
package l2s.gameserver.utils;

import java.util.ArrayList;
import l2s.commons.dao.JdbcEntityState;
import l2s.commons.util.Rnd;
import l2s.gameserver.data.xml.holder.VariationDataHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.ShortCut;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.InventoryUpdatePacket;
import l2s.gameserver.network.l2.s2c.ShortCutRegisterPacket;
import l2s.gameserver.templates.item.support.variation.VariationCategory;
import l2s.gameserver.templates.item.support.variation.VariationFee;
import l2s.gameserver.templates.item.support.variation.VariationGroup;
import l2s.gameserver.templates.item.support.variation.VariationInfo;
import l2s.gameserver.templates.item.support.variation.VariationOption;
import l2s.gameserver.templates.item.support.variation.VariationStone;

public final class VariationUtils {
    public static long getRemovePrice(ItemInstance item) {
        if (item == null) {
            return -1L;
        }
        VariationGroup group = VariationDataHolder.getInstance().getGroup(item.getTemplate().getVariationGroupId());
        if (group == null) {
            return -1L;
        }
        int stoneId = item.getVariationStoneId();
        if (stoneId == -1) {
            return 0L;
        }
        VariationFee fee = group.getFee(stoneId);
        if (fee == null) {
            return -1L;
        }
        return fee.getCancelFee();
    }

    public static VariationFee getVariationFee(ItemInstance item, ItemInstance stone) {
        if (item == null) {
            return null;
        }
        if (stone == null) {
            return null;
        }
        VariationGroup group = VariationDataHolder.getInstance().getGroup(item.getTemplate().getVariationGroupId());
        if (group == null) {
            return null;
        }
        return group.getFee(stone.getItemId());
    }

    public static boolean tryAugmentItem(Player player, ItemInstance targetItem, ItemInstance refinerItem, ItemInstance feeItem, long feeItemCount) {
        if (!targetItem.canBeAugmented(player)) {
            return false;
        }
        if (refinerItem.getTemplate().isBlocked(player, refinerItem)) {
            return false;
        }
        int stoneId = refinerItem.getItemId();
        VariationStone stone = VariationDataHolder.getInstance().getStone(targetItem.getTemplate().getWeaponFightType(), stoneId);
        if (stone == null) {
            return false;
        }
        int variation1Id = VariationUtils.getRandomOptionId(stone.getVariation(1));
        int variation2Id = VariationUtils.getRandomOptionId(stone.getVariation(2));
        if (variation1Id == 0 && variation2Id == 0) {
            return false;
        }
        if (player.getInventory().getCountOf(refinerItem.getItemId()) < 1L) {
            return false;
        }
        if (player.getInventory().getCountOf(feeItem.getItemId()) < feeItemCount) {
            return false;
        }
        if (!player.getInventory().destroyItem(refinerItem, 1L)) {
            return false;
        }
        if (!player.getInventory().destroyItem(feeItem, feeItemCount)) {
            return false;
        }
        VariationUtils.setVariation(player, targetItem, stoneId, variation1Id, variation2Id);
        return true;
    }

    public static void setVariation(Player player, ItemInstance item, int variationStoneId, int variation1Id, int variation2Id) {
        item.setVariationStoneId(variationStoneId);
        item.setVariation1Id(variation1Id);
        item.setVariation2Id(variation2Id);
        player.getInventory().refreshEquip(item);
        item.setJdbcState(JdbcEntityState.UPDATED);
        item.update();
        player.sendPacket((IBroadcastPacket)new InventoryUpdatePacket().addModifiedItem(player, item));
        for (ShortCut sc : player.getAllShortCuts()) {
            if (sc.getId() != item.getObjectId() || sc.getType() != ShortCut.ShortCutType.ITEM) continue;
            player.sendPacket((IBroadcastPacket)new ShortCutRegisterPacket(player, sc));
        }
        player.sendChanges();
    }

    private static int getRandomOptionId(VariationInfo variation) {
        VariationCategory[] categories;
        if (variation == null) {
            return 0;
        }
        double probalityAmount = 0.0;
        for (VariationCategory category : categories = variation.getCategories()) {
            probalityAmount += category.getProbability();
        }
        if (Rnd.chance((double)probalityAmount)) {
            double probalityMod = (100.0 - probalityAmount) / (double)categories.length;
            ArrayList<VariationCategory> successCategories = new ArrayList<VariationCategory>();
            int tryCount = 0;
            while (successCategories.isEmpty()) {
                ++tryCount;
                for (VariationCategory category : categories) {
                    if (tryCount % 10 == 0) {
                        probalityMod += 1.0;
                    }
                    if (!Rnd.chance((double)(category.getProbability() + probalityMod))) continue;
                    successCategories.add(category);
                }
            }
            VariationCategory[] categoriesArray = successCategories.toArray(new VariationCategory[successCategories.size()]);
            return VariationUtils.getRandomOptionId(categoriesArray[Rnd.get((int)categoriesArray.length)]);
        }
        return 0;
    }

    private static int getRandomOptionId(VariationCategory category) {
        VariationOption[] options;
        if (category == null) {
            return 0;
        }
        double chanceAmount = 0.0;
        for (VariationOption option : options = category.getOptions()) {
            chanceAmount += option.getChance();
        }
        if (Rnd.chance((double)chanceAmount)) {
            double chanceMod = (100.0 - chanceAmount) / (double)options.length;
            ArrayList<VariationOption> successOptions = new ArrayList<VariationOption>();
            int tryCount = 0;
            while (successOptions.isEmpty()) {
                ++tryCount;
                for (VariationOption option : options) {
                    if (tryCount % 10 == 0) {
                        chanceMod += 1.0;
                    }
                    if (!Rnd.chance((double)(option.getChance() + chanceMod))) continue;
                    successOptions.add(option);
                }
            }
            VariationOption[] optionsArray = successOptions.toArray(new VariationOption[successOptions.size()]);
            return optionsArray[Rnd.get((int)optionsArray.length)].getId();
        }
        return 0;
    }
}


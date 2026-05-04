package l2s.gameserver.network.l2.c2s;

import l2s.commons.dao.JdbcEntityState;
import l2s.commons.util.Rnd;
import l2s.gameserver.data.xml.holder.EnchantItemHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.PcInventory;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.EnchantResultPacket;
import l2s.gameserver.network.l2.s2c.InventoryUpdatePacket;
import l2s.gameserver.network.l2.s2c.MagicSkillUse;
import l2s.gameserver.network.l2.s2c.SystemMessage;
import l2s.gameserver.templates.item.ItemGrade;
import l2s.gameserver.templates.item.support.EnchantScroll;
import l2s.gameserver.templates.item.support.EnchantStone;
import l2s.gameserver.templates.item.support.EnchantVariation;
import l2s.gameserver.templates.item.support.FailResultType;
import l2s.gameserver.utils.ItemFunctions;
import l2s.gameserver.utils.Log;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RequestEnchantItem
extends L2GameClientPacket {
    private static final int ENCHANT_DELAY = 1500;
    private static final Logger _log = LoggerFactory.getLogger(RequestEnchantItem.class);
    private static final int SUCCESS_VISUAL_EFF_ID = 5965;
    private static final int FAIL_VISUAL_EFF_ID = 5949;
    private int _objectId;
    private int _catalystObjId;

    @Override
    protected boolean readImpl() {
        this._objectId = this.readD();
        this._catalystObjId = this.readD();
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        if (player.isActionsDisabled()) {
            player.setEnchantScroll(null);
            player.sendActionFailed();
            return;
        }
        if (player.isInTrade()) {
            player.setEnchantScroll(null);
            player.sendActionFailed();
            return;
        }
        if (System.currentTimeMillis() <= player.getLastEnchantItemTime() + 1500L) {
            player.setEnchantScroll(null);
            player.sendActionFailed();
            return;
        }
        if (player.isInStoreMode()) {
            player.setEnchantScroll(null);
            player.sendPacket((IBroadcastPacket)EnchantResultPacket.CANCEL);
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_ENCHANT_WHILE_OPERATING_A_PRIVATE_STORE_OR_PRIVATE_WORKSHOP);
            player.sendActionFailed();
            return;
        }
        PcInventory inventory = player.getInventory();
        inventory.writeLock();
        try {
            ItemInstance item = inventory.getItemByObjectId(this._objectId);
            ItemInstance scroll = player.getEnchantScroll();
            ItemInstance catalyst = this._catalystObjId > 0 ? inventory.getItemByObjectId(this._catalystObjId) : null;
            EnchantStone enchantStone = ItemFunctions.getEnchantStone(item, catalyst);
            if (enchantStone == null) {
                catalyst = null;
            }
            if (item == null || scroll == null) {
                player.sendActionFailed();
                return;
            }
            EnchantScroll enchantScroll = EnchantItemHolder.getInstance().getEnchantScroll(scroll.getItemId());
            if (enchantScroll == null) {
                player.sendActionFailed();
                return;
            }
            if (item.getEnchantLevel() < enchantScroll.getMinEnchant() || enchantScroll.getMaxEnchant() != -1 && item.getEnchantLevel() >= enchantScroll.getMaxEnchant()) {
                player.sendPacket((IBroadcastPacket)EnchantResultPacket.CANCEL);
                player.sendPacket((IBroadcastPacket)SystemMsg.INAPPROPRIATE_ENCHANT_CONDITIONS);
                player.sendActionFailed();
                return;
            }
            if (enchantScroll.getItems().size() > 0) {
                if (!enchantScroll.getItems().contains(item.getItemId())) {
                    player.sendPacket((IBroadcastPacket)EnchantResultPacket.CANCEL);
                    player.sendPacket((IBroadcastPacket)SystemMsg.DOES_NOT_FIT_STRENGTHENING_CONDITIONS_OF_THE_SCROLL);
                    player.sendActionFailed();
                    return;
                }
            } else {
                if (!enchantScroll.containsGrade(item.getGrade())) {
                    player.sendPacket((IBroadcastPacket)EnchantResultPacket.CANCEL);
                    player.sendPacket((IBroadcastPacket)SystemMsg.DOES_NOT_FIT_STRENGTHENING_CONDITIONS_OF_THE_SCROLL);
                    player.sendActionFailed();
                    return;
                }
                int itemType = item.getTemplate().getType2();
                switch (enchantScroll.getType()) {
                    case ARMOR: {
                        if (itemType != 0 && !item.getTemplate().isHairAccessory()) break;
                        player.sendPacket((IBroadcastPacket)EnchantResultPacket.CANCEL);
                        player.sendPacket((IBroadcastPacket)SystemMsg.DOES_NOT_FIT_STRENGTHENING_CONDITIONS_OF_THE_SCROLL);
                        player.sendActionFailed();
                        return;
                    }
                    case WEAPON: {
                        if (itemType != 1 && itemType != 2 && !item.getTemplate().isHairAccessory()) break;
                        player.sendPacket((IBroadcastPacket)EnchantResultPacket.CANCEL);
                        player.sendPacket((IBroadcastPacket)SystemMsg.DOES_NOT_FIT_STRENGTHENING_CONDITIONS_OF_THE_SCROLL);
                        player.sendActionFailed();
                        return;
                    }
                    case HAIR_ACCESSORY: {
                        if (item.getTemplate().isHairAccessory()) break;
                        player.sendPacket((IBroadcastPacket)EnchantResultPacket.CANCEL);
                        player.sendPacket((IBroadcastPacket)SystemMsg.DOES_NOT_FIT_STRENGTHENING_CONDITIONS_OF_THE_SCROLL);
                        player.sendActionFailed();
                        return;
                    }
                }
            }
            if (!enchantScroll.getItems().contains(item.getItemId()) && !item.canBeEnchanted()) {
                player.sendPacket((IBroadcastPacket)EnchantResultPacket.CANCEL);
                player.sendPacket((IBroadcastPacket)SystemMsg.INAPPROPRIATE_ENCHANT_CONDITIONS);
                player.sendActionFailed();
                return;
            }
            EnchantVariation variation = EnchantItemHolder.getInstance().getEnchantVariation(enchantScroll.getVariationId());
            if (variation == null) {
                player.sendActionFailed();
                _log.warn("RequestEnchantItem: Cannot find variation ID[" + enchantScroll.getVariationId() + "] for enchant scroll ID[" + enchantScroll.getItemId() + "]!");
                return;
            }
            int minEnchantSteep = enchantScroll.getMinEnchantStep();
            int maxEnchantSteep = enchantScroll.getMaxEnchantStep();
            if (enchantStone != null) {
                minEnchantSteep = Math.max(minEnchantSteep, enchantStone.getMinEnchantStep());
                maxEnchantSteep = Math.max(maxEnchantSteep, enchantStone.getMaxEnchantStep());
            }
            int newEnchantLvl = item.getEnchantLevel() + Rnd.get((int)minEnchantSteep, (int)maxEnchantSteep);
            if ((newEnchantLvl = Math.min(newEnchantLvl, enchantScroll.getMaxEnchant())) < item.getEnchantLevel()) {
                player.sendPacket((IBroadcastPacket)EnchantResultPacket.CANCEL);
                player.sendActionFailed();
                return;
            }
            EnchantVariation.EnchantLevel enchantLevel = variation.getLevel(item.getEnchantLevel() + 1);
            if (enchantLevel == null) {
                player.sendActionFailed();
                _log.warn("RequestEnchantItem: Cannot find variation ID[" + enchantScroll.getVariationId() + "] enchant level[" + (item.getEnchantLevel() + 1) + "] for enchant scroll ID[" + enchantScroll.getItemId() + "]!");
                return;
            }
            if (!inventory.destroyItem(scroll, 1L) || catalyst != null && !inventory.destroyItem(catalyst, 1L)) {
                player.sendPacket((IBroadcastPacket)EnchantResultPacket.CANCEL);
                player.sendActionFailed();
                return;
            }
            double chance = enchantLevel.getBaseChance();
            if (item.getTemplate().getBodyPart() == 32768L) {
                chance = enchantLevel.getFullBodyChance();
            } else if (item.getTemplate().isMagicWeapon()) {
                chance = enchantLevel.getMagicWeaponChance();
            }
            if (enchantStone != null) {
                chance += enchantStone.getChance();
            }
            chance += player.getPremiumAccount().getEnchantChanceBonus();
            chance += player.getVIP().getTemplate().getEnchantChanceBonus();
            if (item.getGrade() != ItemGrade.NONE) {
                chance *= player.getEnchantChanceModifier();
            }
            if (Rnd.chance((double)(chance = Math.min(100.0, chance)))) {
                item.setEnchantLevel(newEnchantLvl);
                item.setJdbcState(JdbcEntityState.UPDATED);
                item.update();
                player.getInventory().refreshEquip(item);
                player.sendPacket((IBroadcastPacket)new InventoryUpdatePacket().addModifiedItem(player, item));
                player.sendPacket((IBroadcastPacket)new EnchantResultPacket(0, 0, 0L, item.getEnchantLevel()));
                if (enchantLevel.haveSuccessVisualEffect()) {
                    player.broadcastPacket(new SystemMessage(3013).addName(player).addNumber(item.getEnchantLevel()).addItemName(item.getItemId()));
                    player.broadcastPacket(new MagicSkillUse(player, player, 5965, 1, 500, 1500L));
                }
                player.getListeners().onEnchantItem(item, true);
            } else {
                FailResultType resultType = enchantScroll.getResultType();
                if (enchantStone != null && enchantStone.getResultType().ordinal() > resultType.ordinal()) {
                    resultType = enchantStone.getResultType();
                }
                switch (resultType) {
                    case CRYSTALS: {
                        if (item.isEquipped()) {
                            player.sendDisarmMessage(item);
                        }
                        Log.LogItem(player, "EnchantFail", item);
                        if (!inventory.destroyItem(item, 1L)) {
                            player.sendActionFailed();
                            return;
                        }
                        int crystalId = item.getGrade().getCrystalId();
                        if (crystalId > 0 && item.getCrystalCountOnEchant() > 0 && !item.isFlagNoCrystallize()) {
                            int crystalAmount = item.getCrystalCountOnEchant();
                            player.sendPacket((IBroadcastPacket)new EnchantResultPacket(1, crystalId, crystalAmount, 0));
                            ItemFunctions.addItem(player, crystalId, crystalAmount, true);
                        } else {
                            player.sendPacket((IBroadcastPacket)EnchantResultPacket.FAILED_NO_CRYSTALS);
                        }
                        if (!enchantScroll.showFailEffect()) break;
                        player.broadcastPacket(new MagicSkillUse(player, player, 5949, 1, 500, 1500L));
                        break;
                    }
                    case DROP_ENCHANT: {
                        int enchantDropCount = enchantScroll.getEnchantDropCount();
                        if (enchantStone != null && enchantStone.getEnchantDropCount() < enchantDropCount) {
                            enchantDropCount = enchantStone.getEnchantDropCount();
                        }
                        item.setEnchantLevel(Math.max(item.getEnchantLevel() - enchantDropCount, 0));
                        item.setJdbcState(JdbcEntityState.UPDATED);
                        item.update();
                        player.getInventory().refreshEquip(item);
                        player.sendPacket((IBroadcastPacket)new InventoryUpdatePacket().addModifiedItem(player, item));
                        player.sendPacket((IBroadcastPacket)SystemMsg.THE_BLESSED_ENCHANT_FAILED);
                        player.sendPacket((IBroadcastPacket)EnchantResultPacket.BLESSED_FAILED);
                        break;
                    }
                    case NOTHING: {
                        player.sendPacket((IBroadcastPacket)EnchantResultPacket.ANCIENT_FAILED);
                    }
                }
                player.getListeners().onEnchantItem(item, false);
            }
        }
        finally {
            inventory.writeUnlock();
            player.updateStats();
        }
        player.setLastEnchantItemTime(System.currentTimeMillis());
    }
}


/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.dao.JdbcEntityState
 *  org.apache.commons.lang3.ArrayUtils
 */
package l2s.gameserver.network.l2.c2s;

import l2s.commons.dao.JdbcEntityState;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.AppearanceStoneHolder;
import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.PcInventory;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExPeriodicItemList;
import l2s.gameserver.network.l2.s2c.ExShape_Shifting_Result;
import l2s.gameserver.network.l2.s2c.InventoryUpdatePacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.templates.item.ExItemType;
import l2s.gameserver.templates.item.ItemGrade;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.item.support.AppearanceStone;
import org.apache.commons.lang3.ArrayUtils;

public class RequestShapeShiftingItem
extends L2GameClientPacket {
    private int _targetItemObjId;

    @Override
    protected boolean readImpl() {
        this._targetItemObjId = this.readD();
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    protected void runImpl() {
        ExItemType[] itemTypes;
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        if (player.isActionsDisabled() || player.isInStoreMode() || player.isInTrade()) {
            player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
            player.setAppearanceStone(null);
            player.setAppearanceExtractItem(null);
            return;
        }
        PcInventory inventory = player.getInventory();
        ItemInstance targetItem = inventory.getItemByObjectId(this._targetItemObjId);
        ItemInstance stone = player.getAppearanceStone();
        if (targetItem == null || stone == null) {
            player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
            player.setAppearanceStone(null);
            player.setAppearanceExtractItem(null);
            return;
        }
        if (stone.getOwnerId() != player.getObjectId()) {
            player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
            player.setAppearanceStone(null);
            player.setAppearanceExtractItem(null);
            return;
        }
        if (!targetItem.canBeAppearance()) {
            player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
            player.setAppearanceStone(null);
            player.setAppearanceExtractItem(null);
            return;
        }
        if ((targetItem.getCustomFlags() & 0x40) == 64) {
            player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
            player.setAppearanceStone(null);
            player.setAppearanceExtractItem(null);
            return;
        }
        if (targetItem.getLocation() != ItemInstance.ItemLocation.INVENTORY && targetItem.getLocation() != ItemInstance.ItemLocation.PAPERDOLL) {
            player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
            player.setAppearanceStone(null);
            player.setAppearanceExtractItem(null);
            return;
        }
        if ((stone = inventory.getItemByObjectId(stone.getObjectId())) == null) {
            player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
            player.setAppearanceStone(null);
            player.setAppearanceExtractItem(null);
            return;
        }
        AppearanceStone appearanceStone = AppearanceStoneHolder.getInstance().getAppearanceStone(stone.getItemId());
        if (appearanceStone == null) {
            player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
            player.setAppearanceStone(null);
            player.setAppearanceExtractItem(null);
            return;
        }
        if (appearanceStone.getType() != AppearanceStone.ShapeType.RESTORE && targetItem.getVisualId() > 0 || appearanceStone.getType() == AppearanceStone.ShapeType.RESTORE && targetItem.getVisualId() == 0) {
            player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
            player.setAppearanceStone(null);
            player.setAppearanceExtractItem(null);
            return;
        }
        if (!targetItem.getTemplate().isHairAccessory() && targetItem.getGrade() == ItemGrade.NONE) {
            player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
            player.setAppearanceStone(null);
            player.setAppearanceExtractItem(null);
            return;
        }
        ItemGrade[] stoneGrades = appearanceStone.getGrades();
        if (stoneGrades != null && stoneGrades.length > 0 && !ArrayUtils.contains((Object[])stoneGrades, (Object)((Object)targetItem.getGrade()))) {
            player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
            player.setAppearanceStone(null);
            player.setAppearanceExtractItem(null);
            return;
        }
        AppearanceStone.ShapeTargetType[] targetTypes = appearanceStone.getTargetTypes();
        if (targetTypes == null || targetTypes.length == 0) {
            player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
            player.setAppearanceStone(null);
            player.setAppearanceExtractItem(null);
            return;
        }
        if (!ArrayUtils.contains((Object[])targetTypes, (Object)((Object)AppearanceStone.ShapeTargetType.ALL))) {
            if (targetItem.isWeapon()) {
                if (!ArrayUtils.contains((Object[])targetTypes, (Object)((Object)AppearanceStone.ShapeTargetType.WEAPON))) {
                    player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
                    player.setAppearanceStone(null);
                    player.setAppearanceExtractItem(null);
                    return;
                }
            } else if (targetItem.isArmor()) {
                if (!ArrayUtils.contains((Object[])targetTypes, (Object)((Object)AppearanceStone.ShapeTargetType.ARMOR))) {
                    player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
                    player.setAppearanceStone(null);
                    player.setAppearanceExtractItem(null);
                    return;
                }
            } else if (!ArrayUtils.contains((Object[])targetTypes, (Object)((Object)AppearanceStone.ShapeTargetType.ACCESSORY))) {
                player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
                player.setAppearanceStone(null);
                player.setAppearanceExtractItem(null);
                return;
            }
        }
        if ((itemTypes = appearanceStone.getItemTypes()) != null && itemTypes.length > 0 && !ArrayUtils.contains((Object[])itemTypes, (Object)((Object)targetItem.getExType()))) {
            player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
            player.setAppearanceStone(null);
            player.setAppearanceExtractItem(null);
            return;
        }
        ItemInstance extracItem = player.getAppearanceExtractItem();
        int extracItemId = 0;
        if (appearanceStone.getType() != AppearanceStone.ShapeType.RESTORE && appearanceStone.getType() != AppearanceStone.ShapeType.FIXED) {
            if (extracItem == null) {
                player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
                player.setAppearanceStone(null);
                player.setAppearanceExtractItem(null);
                return;
            }
            if (!extracItem.canBeAppearance()) {
                player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
                player.setAppearanceStone(null);
                player.setAppearanceExtractItem(null);
                return;
            }
            if (extracItem.getLocation() != ItemInstance.ItemLocation.INVENTORY && extracItem.getLocation() != ItemInstance.ItemLocation.PAPERDOLL) {
                player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
                player.setAppearanceStone(null);
                player.setAppearanceExtractItem(null);
                return;
            }
            if (!extracItem.getTemplate().isHairAccessory() && targetItem.getGrade().ordinal() < extracItem.getGrade().ordinal()) {
                player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
                player.setAppearanceStone(null);
                player.setAppearanceExtractItem(null);
                return;
            }
            if (extracItem.getVisualId() > 0) {
                player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
                player.setAppearanceStone(null);
                player.setAppearanceExtractItem(null);
                return;
            }
            if (targetItem.getExType() != extracItem.getExType() && targetItem.getExType() != ExItemType.UPPER_PIECE && extracItem.getExType() != ExItemType.FULL_BODY) {
                player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
                player.setAppearanceStone(null);
                player.setAppearanceExtractItem(null);
                return;
            }
            if (targetItem.isWeapon() && targetItem.getTemplate().getItemType() != extracItem.getTemplate().getItemType()) {
                player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
                player.setAppearanceStone(null);
                player.setAppearanceExtractItem(null);
                return;
            }
            if (extracItem.getOwnerId() != player.getObjectId()) {
                player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
                player.setAppearanceStone(null);
                player.setAppearanceExtractItem(null);
                return;
            }
            extracItemId = extracItem.getItemId();
        }
        if (Config.APPEARANCE_STONE_CHECK_ARMOR_TYPE && targetItem.isArmor() && (targetItem.getBodyPart() == 1024L || targetItem.getBodyPart() == 32768L || targetItem.getBodyPart() == 2048L)) {
            ItemTemplate extracItemTemplate;
            if (extracItem != null) {
                if (extracItem.getTemplate().isArmor() && (extracItem.getTemplate().getBodyPart() == 1024L || extracItem.getTemplate().getBodyPart() == 32768L || extracItem.getTemplate().getBodyPart() == 2048L) && targetItem.getTemplate().getItemType() != extracItem.getTemplate().getItemType()) {
                    player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
                    player.setAppearanceStone(null);
                    player.setAppearanceExtractItem(null);
                    return;
                }
            } else if (appearanceStone.getType() == AppearanceStone.ShapeType.FIXED && appearanceStone.getExtractItemId() > 0 && (extracItemTemplate = ItemHolder.getInstance().getTemplate(appearanceStone.getExtractItemId())) != null && extracItemTemplate.isArmor() && (extracItemTemplate.getBodyPart() == 1024L || extracItemTemplate.getBodyPart() == 32768L || extracItemTemplate.getBodyPart() == 2048L) && targetItem.getTemplate().getItemType() != extracItemTemplate.getItemType()) {
                player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
                player.setAppearanceStone(null);
                player.setAppearanceExtractItem(null);
                return;
            }
        }
        if (targetItem.getOwnerId() != player.getObjectId()) {
            player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
            player.setAppearanceStone(null);
            player.setAppearanceExtractItem(null);
            return;
        }
        inventory.writeLock();
        try {
            long cost = appearanceStone.getCost();
            if (cost > player.getAdena()) {
                player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_MODIFY_AS_YOU_DO_NOT_HAVE_ENOUGH_ADENA);
                player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
                player.setAppearanceStone(null);
                player.setAppearanceExtractItem(null);
                return;
            }
            if (stone.getCount() < 1L) {
                player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
                player.setAppearanceStone(null);
                player.setAppearanceExtractItem(null);
                return;
            }
            if (appearanceStone.getType() == AppearanceStone.ShapeType.NORMAL && !inventory.destroyItem(extracItem, 1L)) {
                player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
                player.setAppearanceStone(null);
                player.setAppearanceExtractItem(null);
                return;
            }
            inventory.destroyItem(stone, 1L);
            player.reduceAdena(cost);
            switch (appearanceStone.getType()) {
                case RESTORE: {
                    if (targetItem.getLifeTime() >= 0) {
                        targetItem.setLifeTime(-1);
                        player.sendPacket((IBroadcastPacket)new ExPeriodicItemList(1, targetItem.getObjectId(), 0));
                    }
                    targetItem.setVisualId(0);
                    targetItem.setAppearanceStoneId(0);
                    break;
                }
                case NORMAL: 
                case BLESSED: 
                case FIXED: {
                    targetItem.setVisualId(appearanceStone.getType() == AppearanceStone.ShapeType.FIXED ? appearanceStone.getExtractItemId() : extracItem.getItemId());
                    targetItem.setAppearanceStoneId(appearanceStone.getItemId());
                    if (appearanceStone.getPeriod() <= 0) break;
                    targetItem.setLifeTime((int)(System.currentTimeMillis() / 1000L) + appearanceStone.getPeriod());
                    player.sendPacket((IBroadcastPacket)new ExPeriodicItemList(1, targetItem.getObjectId(), appearanceStone.getPeriod()));
                }
            }
            targetItem.setJdbcState(JdbcEntityState.UPDATED);
            targetItem.update();
            player.getInventory().refreshEquip(targetItem);
            if (targetItem.isEquipped()) {
                player.getInventory().sendEquipInfo(targetItem.getEquipSlot());
            }
            player.sendPacket((IBroadcastPacket)new InventoryUpdatePacket().addModifiedItem(player, targetItem));
            player.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOU_HAVE_SPENT_S1_ON_A_SUCCESSFUL_APPEARANCE_MODIFICATION).addLong(cost));
        }
        finally {
            inventory.writeUnlock();
        }
        player.sendPacket((IBroadcastPacket)new ExShape_Shifting_Result(ExShape_Shifting_Result.SUCCESS_RESULT, targetItem.getItemId(), extracItemId, appearanceStone.getPeriod()));
        player.setAppearanceStone(null);
        player.setAppearanceExtractItem(null);
    }
}


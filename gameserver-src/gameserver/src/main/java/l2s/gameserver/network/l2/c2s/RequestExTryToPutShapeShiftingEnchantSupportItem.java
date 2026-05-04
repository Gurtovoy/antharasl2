/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.AppearanceStoneHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.PcInventory;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExPut_Shape_Shifting_Extraction_Item_Result;
import l2s.gameserver.network.l2.s2c.ExShape_Shifting_Result;
import l2s.gameserver.templates.item.ExItemType;
import l2s.gameserver.templates.item.support.AppearanceStone;

public class RequestExTryToPutShapeShiftingEnchantSupportItem
extends L2GameClientPacket {
    private int _targetItemObjId;
    private int _extracItemObjId;

    @Override
    protected boolean readImpl() {
        this._targetItemObjId = this.readD();
        this._extracItemObjId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        if (player.isActionsDisabled() || player.isInStoreMode() || player.isInTrade()) {
            player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
            player.setAppearanceStone(null);
            return;
        }
        PcInventory inventory = player.getInventory();
        ItemInstance targetItem = inventory.getItemByObjectId(this._targetItemObjId);
        ItemInstance extracItem = inventory.getItemByObjectId(this._extracItemObjId);
        ItemInstance stone = player.getAppearanceStone();
        if (targetItem == null || extracItem == null || stone == null) {
            player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
            player.setAppearanceStone(null);
            return;
        }
        if (!extracItem.canBeAppearance()) {
            player.sendPacket((IBroadcastPacket)ExPut_Shape_Shifting_Extraction_Item_Result.FAIL);
            return;
        }
        if (extracItem.getLocation() != ItemInstance.ItemLocation.INVENTORY && extracItem.getLocation() != ItemInstance.ItemLocation.PAPERDOLL) {
            player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
            player.setAppearanceStone(null);
            return;
        }
        if ((stone = inventory.getItemByObjectId(stone.getObjectId())) == null) {
            player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
            player.setAppearanceStone(null);
            return;
        }
        AppearanceStone appearanceStone = AppearanceStoneHolder.getInstance().getAppearanceStone(stone.getItemId());
        if (appearanceStone == null) {
            player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
            player.setAppearanceStone(null);
            return;
        }
        if (appearanceStone.getType() == AppearanceStone.ShapeType.RESTORE || appearanceStone.getType() == AppearanceStone.ShapeType.FIXED) {
            player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
            return;
        }
        if (!extracItem.getTemplate().isHairAccessory() && targetItem.getGrade().ordinal() < extracItem.getGrade().ordinal()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_EXTRACT_FROM_ITEMS_THAT_ARE_HIGHERGRADE_THAN_ITEMS_TO_BE_MODIFIED);
            return;
        }
        if (extracItem.getVisualId() > 0) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_EXTRACT_FROM_A_MODIFIED_ITEM);
            return;
        }
        if (targetItem.getExType() != extracItem.getExType() && targetItem.getExType() != ExItemType.UPPER_PIECE && extracItem.getExType() != ExItemType.FULL_BODY) {
            player.sendPacket((IBroadcastPacket)SystemMsg.THIS_ITEM_DOES_NOT_MEET_REQUIREMENTS);
            return;
        }
        if (targetItem.isWeapon()) {
            if (targetItem.getTemplate().getItemType() != extracItem.getTemplate().getItemType()) {
                player.sendPacket((IBroadcastPacket)SystemMsg.THIS_ITEM_DOES_NOT_MEET_REQUIREMENTS);
                return;
            }
        } else if (targetItem.isArmor() && Config.APPEARANCE_STONE_CHECK_ARMOR_TYPE && (targetItem.getBodyPart() == 1024L || targetItem.getBodyPart() == 32768L || targetItem.getBodyPart() == 2048L) && extracItem.getTemplate().isArmor() && (extracItem.getTemplate().getBodyPart() == 1024L || extracItem.getTemplate().getBodyPart() == 32768L || extracItem.getTemplate().getBodyPart() == 2048L) && targetItem.getTemplate().getItemType() != extracItem.getTemplate().getItemType()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.THIS_ITEM_DOES_NOT_MEET_REQUIREMENTS);
            return;
        }
        if (extracItem.getOwnerId() != player.getObjectId()) {
            player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
            player.setAppearanceStone(null);
            return;
        }
        player.setAppearanceExtractItem(extracItem);
        player.sendPacket((IBroadcastPacket)ExPut_Shape_Shifting_Extraction_Item_Result.SUCCESS);
    }
}


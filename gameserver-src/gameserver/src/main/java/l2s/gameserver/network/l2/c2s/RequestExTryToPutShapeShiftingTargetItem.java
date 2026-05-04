package l2s.gameserver.network.l2.c2s;

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
import l2s.gameserver.network.l2.s2c.ExPut_Shape_Shifting_Target_Item_Result;
import l2s.gameserver.network.l2.s2c.ExShape_Shifting_Result;
import l2s.gameserver.templates.item.ExItemType;
import l2s.gameserver.templates.item.ItemGrade;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.item.support.AppearanceStone;
import org.apache.commons.lang3.ArrayUtils;

public class RequestExTryToPutShapeShiftingTargetItem
extends L2GameClientPacket {
    private int _targetItemObjId;

    @Override
    protected boolean readImpl() {
        this._targetItemObjId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        ItemTemplate extracItemTemplate;
        ExItemType[] itemTypes;
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
        ItemInstance stone = player.getAppearanceStone();
        if (targetItem == null || stone == null) {
            player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
            player.setAppearanceStone(null);
            return;
        }
        if (!targetItem.canBeAppearance()) {
            player.sendPacket((IBroadcastPacket)ExPut_Shape_Shifting_Target_Item_Result.FAIL);
            return;
        }
        if (targetItem.getLocation() != ItemInstance.ItemLocation.INVENTORY && targetItem.getLocation() != ItemInstance.ItemLocation.PAPERDOLL) {
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
        if (appearanceStone.getType() != AppearanceStone.ShapeType.RESTORE && targetItem.getVisualId() > 0 || appearanceStone.getType() == AppearanceStone.ShapeType.RESTORE && targetItem.getVisualId() == 0) {
            player.sendPacket((IBroadcastPacket)ExPut_Shape_Shifting_Target_Item_Result.FAIL);
            return;
        }
        if (!targetItem.getTemplate().isHairAccessory() && targetItem.getGrade() == ItemGrade.NONE) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_MODIFY_OR_RESTORE_NOGRADE_ITEMS);
            return;
        }
        ItemGrade[] stoneGrades = appearanceStone.getGrades();
        if (stoneGrades != null && stoneGrades.length > 0 && !ArrayUtils.contains((Object[])stoneGrades, (Object)((Object)targetItem.getGrade()))) {
            player.sendPacket((IBroadcastPacket)SystemMsg.ITEM_GRADES_DO_NOT_MATCH);
            return;
        }
        AppearanceStone.ShapeTargetType[] targetTypes = appearanceStone.getTargetTypes();
        if (targetTypes == null || targetTypes.length == 0) {
            player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
            player.setAppearanceStone(null);
            return;
        }
        if (!ArrayUtils.contains((Object[])targetTypes, (Object)((Object)AppearanceStone.ShapeTargetType.ALL))) {
            if (targetItem.isWeapon()) {
                if (!ArrayUtils.contains((Object[])targetTypes, (Object)((Object)AppearanceStone.ShapeTargetType.WEAPON))) {
                    player.sendPacket((IBroadcastPacket)SystemMsg.WEAPONS_ONLY);
                    return;
                }
            } else if (targetItem.isArmor()) {
                if (!ArrayUtils.contains((Object[])targetTypes, (Object)((Object)AppearanceStone.ShapeTargetType.ARMOR))) {
                    player.sendPacket((IBroadcastPacket)SystemMsg.ARMOR_ONLY);
                    return;
                }
            } else if (!ArrayUtils.contains((Object[])targetTypes, (Object)((Object)AppearanceStone.ShapeTargetType.ACCESSORY))) {
                player.sendPacket((IBroadcastPacket)SystemMsg.THIS_ITEM_DOES_NOT_MEET_REQUIREMENTS);
                return;
            }
        }
        if ((itemTypes = appearanceStone.getItemTypes()) != null && itemTypes.length > 0 && !ArrayUtils.contains((Object[])itemTypes, (Object)((Object)targetItem.getExType()))) {
            player.sendPacket((IBroadcastPacket)SystemMsg.THIS_ITEM_DOES_NOT_MEET_REQUIREMENTS);
            return;
        }
        if (Config.APPEARANCE_STONE_CHECK_ARMOR_TYPE && appearanceStone.getType() == AppearanceStone.ShapeType.FIXED && appearanceStone.getExtractItemId() > 0 && targetItem.isArmor() && (targetItem.getBodyPart() == 1024L || targetItem.getBodyPart() == 32768L || targetItem.getBodyPart() == 2048L) && (extracItemTemplate = ItemHolder.getInstance().getTemplate(appearanceStone.getExtractItemId())) != null && extracItemTemplate.isArmor() && (extracItemTemplate.getBodyPart() == 1024L || extracItemTemplate.getBodyPart() == 32768L || extracItemTemplate.getBodyPart() == 2048L) && targetItem.getTemplate().getItemType() != extracItemTemplate.getItemType()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.THIS_ITEM_DOES_NOT_MEET_REQUIREMENTS);
            return;
        }
        if (targetItem.getOwnerId() != player.getObjectId()) {
            player.sendPacket((IBroadcastPacket)ExShape_Shifting_Result.FAIL);
            player.setAppearanceStone(null);
            return;
        }
        player.sendPacket((IBroadcastPacket)new ExPut_Shape_Shifting_Target_Item_Result(ExPut_Shape_Shifting_Target_Item_Result.SUCCESS_RESULT, appearanceStone.getCost()));
    }
}


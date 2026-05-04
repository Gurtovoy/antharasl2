package l2s.gameserver.utils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import l2s.gameserver.dao.ItemsDAO;
import l2s.gameserver.data.xml.holder.EnchantStoneHolder;
import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.data.xml.holder.PetDataHolder;
import l2s.gameserver.handler.items.IItemHandler;
import l2s.gameserver.idfactory.IdFactory;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.instances.PetInstance;
import l2s.gameserver.model.items.Inventory;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.PcInventory;
import l2s.gameserver.model.items.attachment.PickableAttachment;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.templates.item.EtcItemTemplate;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.item.WeaponTemplate;
import l2s.gameserver.templates.item.support.EnchantStone;

public final class ItemFunctions {
    private ItemFunctions() {
    }

    public static ItemInstance createItem(int itemId) {
        ItemInstance item = new ItemInstance(IdFactory.getInstance().getNextId(), itemId);
        item.setLocation(ItemInstance.ItemLocation.VOID);
        item.setCount(1L);
        return item;
    }

    public static List<ItemInstance> addItem(Playable playable, int itemId, long count) {
        return ItemFunctions.addItem(playable, itemId, count, 0, true);
    }

    public static List<ItemInstance> addItem(Playable playable, int itemId, long count, boolean notify) {
        return ItemFunctions.addItem(playable, itemId, count, 0, notify);
    }

    public static List<ItemInstance> addItem(Playable playable, int itemId, long count, int enchantLevel, boolean notify) {
        if (playable == null || count < 1L) {
            return Collections.emptyList();
        }
        Playable player = playable.isSummon() ? playable.getPlayer() : playable;
        if (itemId > 0) {
            ArrayList<ItemInstance> items = new ArrayList<ItemInstance>();
            ItemTemplate t = ItemHolder.getInstance().getTemplate(itemId);
            if (t.isStackable()) {
                items.add(player.getInventory().addItem(itemId, count));
                if (notify) {
                    player.sendPacket((IBroadcastPacket)SystemMessagePacket.obtainItems(itemId, count, 0));
                }
            } else {
                for (long i = 0L; i < count; ++i) {
                    ItemInstance item = player.getInventory().addItem(itemId, 1L, enchantLevel);
                    items.add(item);
                    if (!notify) continue;
                    player.sendPacket((IBroadcastPacket)SystemMessagePacket.obtainItems(item));
                }
            }
            return items;
        }
        if (itemId == -100) {
            player.getPlayer().addPcBangPoints((int)count, false, notify);
        } else if (itemId == -200) {
            if (player.getPlayer().getClan() != null) {
                player.getPlayer().getClan().incReputation((int)count, false, "itemFunction");
                if (notify) {
                    // empty if block
                }
            }
        } else if (itemId == -300) {
            player.getPlayer().setFame((int)count + player.getPlayer().getFame(), "itemFunction", notify);
        }
        return Collections.emptyList();
    }

    public static long getItemCount(Playable playable, int itemId) {
        if (playable == null) {
            return 0L;
        }
        Player player = playable.getPlayer();
        if (itemId > 0) {
            return player.getInventory().getCountOf(itemId);
        }
        if (itemId == -100) {
            return player.getPcBangPoints();
        }
        if (itemId == -200) {
            if (player.getClan() != null) {
                return player.getClan().getReputationScore();
            }
            return 0L;
        }
        if (itemId == -300) {
            return player.getFame();
        }
        return 0L;
    }

    public static boolean haveItem(Playable playable, int itemId, long count) {
        return ItemFunctions.getItemCount(playable, itemId) >= count;
    }

    public static boolean deleteItem(Playable playable, int itemId, long count) {
        return ItemFunctions.deleteItem(playable, itemId, count, true);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public static boolean deleteItem(Playable playable, int itemId, long count, boolean notify) {
        if (playable == null || count < 1L) {
            return false;
        }
        Player player = playable.getPlayer();
        if (itemId > 0) {
            playable.getInventory().writeLock();
            try {
                ItemTemplate t = ItemHolder.getInstance().getTemplate(itemId);
                if (t == null) {
                    boolean bl = false;
                    return bl;
                }
                if (t.isStackable()) {
                    if (!playable.getInventory().destroyItemByItemId(itemId, count)) {
                        boolean bl = false;
                        return bl;
                    }
                } else {
                    if (playable.getInventory().getCountOf(itemId) < count) {
                        boolean bl = false;
                        return bl;
                    }
                    for (long i = 0L; i < count; ++i) {
                        if (playable.getInventory().destroyItemByItemId(itemId, 1L)) continue;
                        boolean bl = false;
                        return bl;
                    }
                }
            }
            finally {
                playable.getInventory().writeUnlock();
            }
            if (notify) {
                playable.sendPacket((IBroadcastPacket)SystemMessagePacket.removeItems(itemId, count));
            }
        } else if (itemId == -100) {
            player.reducePcBangPoints((int)count, notify);
        } else if (itemId == -200) {
            Clan clan = player.getClan();
            if (clan == null) {
                return false;
            }
            if ((long)clan.getReputationScore() < count) {
                return false;
            }
            clan.incReputation((int)(-count), false, "itemFunction");
            if (notify) {
                player.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_POINTS_HAVE_BEEN_DEDUCTED_FROM_THE_CLANS_REPUTATION).addLong(count));
            }
        } else if (itemId == -300) {
            if ((long)player.getFame() < count) {
                return false;
            }
            player.setFame((int)((long)player.getFame() - count), "itemFunction", notify);
        }
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public static void deleteItemsEverywhere(Playable playable, int itemId) {
        if (playable == null) {
            return;
        }
        Player player = playable.getPlayer();
        if (itemId > 0) {
            ItemInstance item;
            player.getInventory().writeLock();
            try {
                item = player.getInventory().getItemByItemId(itemId);
                while (item != null) {
                    player.getInventory().destroyItem(item);
                    item = player.getInventory().getItemByItemId(itemId);
                }
            }
            finally {
                player.getInventory().writeUnlock();
            }
            player.getWarehouse().writeLock();
            try {
                item = player.getWarehouse().getItemByItemId(itemId);
                while (item != null) {
                    player.getWarehouse().destroyItem(item);
                    item = player.getWarehouse().getItemByItemId(itemId);
                }
            }
            finally {
                player.getWarehouse().writeUnlock();
            }
            player.getFreight().writeLock();
            try {
                item = player.getFreight().getItemByItemId(itemId);
                while (item != null) {
                    player.getFreight().destroyItem(item);
                    item = player.getFreight().getItemByItemId(itemId);
                }
            }
            finally {
                player.getFreight().writeUnlock();
            }
            player.getRefund().writeLock();
            try {
                item = player.getRefund().getItemByItemId(itemId);
                while (item != null) {
                    player.getRefund().destroyItem(item);
                    item = player.getRefund().getItemByItemId(itemId);
                }
            }
            finally {
                player.getRefund().writeUnlock();
            }
            PetInstance pet = player.getPet();
            if (pet != null) {
                pet.getInventory().writeLock();
                try {
                    ItemInstance item2 = pet.getInventory().getItemByItemId(itemId);
                    while (item2 != null) {
                        pet.getInventory().destroyItem(item2);
                        item2 = pet.getInventory().getItemByItemId(itemId);
                    }
                }
                finally {
                    pet.getInventory().writeUnlock();
                }
            } else {
                ArrayList<ItemInstance> items = new ArrayList<ItemInstance>();
                items.addAll(ItemsDAO.getInstance().getItemsByOwnerIdAndLoc(player.getObjectId(), ItemInstance.ItemLocation.PET_INVENTORY));
                items.addAll(ItemsDAO.getInstance().getItemsByOwnerIdAndLoc(player.getObjectId(), ItemInstance.ItemLocation.PET_PAPERDOLL));
                for (ItemInstance item3 : items) {
                    if (item3.getItemId() != itemId) continue;
                    item3.setLocData(-1);
                    item3.setCount(0L);
                    item3.delete();
                }
            }
        }
    }

    public static boolean deleteItem(Playable playable, ItemInstance item, long count) {
        return ItemFunctions.deleteItem(playable, item, count, true);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public static boolean deleteItem(Playable playable, ItemInstance item, long count, boolean notify) {
        if (playable == null || count < 1L) {
            return false;
        }
        if (item.getCount() < count) {
            return false;
        }
        playable.getInventory().writeLock();
        try {
            if (!playable.getInventory().destroyItem(item, count)) {
                boolean bl = false;
                return bl;
            }
        }
        finally {
            playable.getInventory().writeUnlock();
        }
        if (notify) {
            playable.sendPacket((IBroadcastPacket)SystemMessagePacket.removeItems(item.getItemId(), count));
        }
        return true;
    }

    public static final IBroadcastPacket checkIfCanEquip(PetInstance pet, ItemInstance item) {
        if (!item.isEquipable()) {
            return SystemMsg.YOUR_PET_CANNOT_CARRY_THIS_ITEM;
        }
        int petId = pet.getNpcId();
        if (item.getTemplate().isPetPendant() || PetDataHolder.isWolf(petId) && item.getTemplate().isForWolf() || PetDataHolder.isHatchling(petId) && item.getTemplate().isForHatchling() || PetDataHolder.isStrider(petId) && item.getTemplate().isForStrider() || PetDataHolder.isGreatWolf(petId) && item.getTemplate().isForGWolf() || PetDataHolder.isBabyPet(petId) && item.getTemplate().isForPetBaby() || PetDataHolder.isImprovedBabyPet(petId) && item.getTemplate().isForPetBaby()) {
            return null;
        }
        return SystemMsg.YOUR_PET_CANNOT_CARRY_THIS_ITEM;
    }

    public static final IBroadcastPacket checkIfCanEquip(Player player, ItemInstance item) {
        block21: {
            int paperdoll;
            ItemInstance bracelet;
            long targetSlot;
            int itemId;
            block22: {
                int count;
                block20: {
                    itemId = item.getItemId();
                    targetSlot = item.getTemplate().getBodyPart();
                    Clan clan = player.getClan();
                    if (item.getItemType() == WeaponTemplate.WeaponType.CROSSBOW || item.getItemType() == WeaponTemplate.WeaponType.RAPIER || item.getItemType() == WeaponTemplate.WeaponType.ANCIENTSWORD) {
                        return SystemMsg.YOU_DO_NOT_MEET_THE_REQUIRED_CONDITION_TO_EQUIP_THAT_ITEM;
                    }
                    if (item.getItemType() == WeaponTemplate.WeaponType.DUALDAGGER && player.getSkillLevel(923) < 1) {
                        return SystemMsg.YOU_DO_NOT_MEET_THE_REQUIRED_CONDITION_TO_EQUIP_THAT_ITEM;
                    }
                    if (!(itemId != 6841 || clan != null && player.isClanLeader() && clan.getCastle() != 0)) {
                        return SystemMsg.YOU_DO_NOT_MEET_THE_REQUIRED_CONDITION_TO_EQUIP_THAT_ITEM;
                    }
                    if (item.isEquipped()) {
                        int[] paperdolls = Inventory.getPaperdollIndexes(targetSlot);
                        boolean success = false;
                        for (int paperdoll2 : paperdolls) {
                            if (paperdoll2 != item.getEquipSlot()) continue;
                            success = true;
                            break;
                        }
                        if (!success) {
                            return SystemMsg.YOU_DO_NOT_MEET_THE_REQUIRED_CONDITION_TO_EQUIP_THAT_ITEM;
                        }
                    }
                    if (targetSlot != 0x400000L) break block20;
                    bracelet = player.getInventory().getPaperdollItem(17);
                    if (bracelet == null) {
                        return new SystemMessagePacket(SystemMsg.YOU_CANNOT_WEAR_S1_BECAUSE_YOU_ARE_NOT_WEARING_A_BRACELET).addItemName(itemId);
                    }
                    count = player.getTalismanCount();
                    if (count <= 0) {
                        return new SystemMessagePacket(SystemMsg.YOU_CANNOT_EQUIP_S1_BECAUSE_YOU_DO_NOT_HAVE_ANY_AVAILABLE_SLOTS).addItemName(itemId);
                    }
                    for (paperdoll = 24; paperdoll <= 29; ++paperdoll) {
                        ItemInstance deco = player.getInventory().getPaperdollItem(paperdoll);
                        if (deco == null) continue;
                        if (deco == item) {
                            return null;
                        }
                        if (--count > 0) continue;
                        return new SystemMessagePacket(SystemMsg.YOU_CANNOT_EQUIP_S1_BECAUSE_YOU_DO_NOT_HAVE_ANY_AVAILABLE_SLOTS).addItemName(itemId);
                    }
                    break block21;
                }
                if (targetSlot != 0x40000000L) break block22;
                ItemInstance brooch = player.getInventory().getPaperdollItem(31);
                if (brooch == null) {
                    return new SystemMessagePacket(SystemMsg.YOU_CANNOT_EQUIP_S1_WITHOUT_EQUIPPING_A_BROOCH).addItemName(itemId);
                }
                count = player.getJewelsLimit();
                if (count <= 0) {
                    return new SystemMessagePacket(SystemMsg.YOU_CANNOT_EQUIP_S1_BECAUSE_YOU_DO_NOT_HAVE_ANY_AVAILABLE_SLOTS).addItemName(itemId);
                }
                for (paperdoll = 32; paperdoll <= 37; ++paperdoll) {
                    ItemInstance jewel = player.getInventory().getPaperdollItem(paperdoll);
                    if (jewel == null) continue;
                    if (jewel == item) {
                        return null;
                    }
                    if (--count > 0) continue;
                    return new SystemMessagePacket(SystemMsg.YOU_CANNOT_EQUIP_S1_BECAUSE_YOU_DO_NOT_HAVE_ANY_AVAILABLE_SLOTS).addItemName(itemId);
                }
                break block21;
            }
            if (targetSlot != 0x3000000000L) break block21;
            bracelet = player.getInventory().getPaperdollItem(18);
            if (bracelet == null) {
                return SystemMsg.YOU_CANNOT_USE_THE_AGATHIONS_POWER_BECAUSE_YOU_ARE_NOT_WEARING_THE_LEFT_BRACELET;
            }
            if (!player.isActiveMainAgathionSlot()) {
                return new SystemMessagePacket(SystemMsg.YOU_CANNOT_EQUIP_S1_BECAUSE_YOU_DO_NOT_HAVE_ANY_AVAILABLE_SLOTS).addItemName(itemId);
            }
            ItemInstance agathion = player.getInventory().getPaperdollItem(19);
            if (agathion == null || agathion != null && agathion == item) {
                return null;
            }
            int count = player.getSubAgathionsLimit();
            if (count <= 0) {
                return new SystemMessagePacket(SystemMsg.YOU_CANNOT_EQUIP_S1_BECAUSE_YOU_DO_NOT_HAVE_ANY_AVAILABLE_SLOTS).addItemName(itemId);
            }
            for (paperdoll = 20; paperdoll <= 23; ++paperdoll) {
                agathion = player.getInventory().getPaperdollItem(paperdoll);
                if (agathion == null) continue;
                if (agathion == item) {
                    return null;
                }
                if (--count > 0) continue;
                return new SystemMessagePacket(SystemMsg.YOU_CANNOT_EQUIP_S1_BECAUSE_YOU_DO_NOT_HAVE_ANY_AVAILABLE_SLOTS).addItemName(itemId);
            }
        }
        return null;
    }

    public static boolean checkIfCanPickup(Playable playable, ItemInstance item) {
        Player player = playable.getPlayer();
        return item.getDropTimeOwner() <= System.currentTimeMillis() || item.getDropPlayers().contains(player.getObjectId());
    }

    public static boolean canAddItem(Player player, ItemInstance item) {
        PickableAttachment attachment;
        if (!player.getInventory().validateWeight(item)) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_EXCEEDED_THE_WEIGHT_LIMIT);
            return false;
        }
        if (!player.getInventory().validateCapacity(item)) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOUR_INVENTORY_IS_FULL);
            return false;
        }
        IItemHandler handler = item.getTemplate().getHandler();
        if (handler != null && !handler.pickupItem(player, item)) {
            return false;
        }
        PickableAttachment pickableAttachment = attachment = item.getAttachment() instanceof PickableAttachment ? (PickableAttachment)item.getAttachment() : null;
        return attachment == null || attachment.canPickUp(player);
    }

    public static final boolean checkIfCanDiscard(Player player, ItemInstance item) {
        if (item.isHeroItem()) {
            return false;
        }
        if (player.getMountControlItemObjId() == item.getObjectId()) {
            return false;
        }
        if (player.getPetControlItem() == item) {
            return false;
        }
        if (player.getEnchantScroll() == item) {
            return false;
        }
        return !item.getTemplate().isQuest();
    }

    public static final EnchantStone getEnchantStone(ItemInstance item, ItemInstance catalyst) {
        if (item == null || catalyst == null) {
            return null;
        }
        EnchantStone enchantStone = EnchantStoneHolder.getInstance().getEnchantStone(catalyst.getItemId());
        if (enchantStone == null) {
            return null;
        }
        int current = item.getEnchantLevel();
        double d = current;
        double d2 = item.getTemplate().getBodyPart() == 32768L ? enchantStone.getMinFullbodyEnchantLevel() : enchantStone.getMinEnchantLevel();
        if (d < d2) {
            return null;
        }
        if ((double)current > enchantStone.getMaxEnchantLevel()) {
            return null;
        }
        if (!enchantStone.containsGrade(item.getGrade())) {
            return null;
        }
        int itemType = item.getTemplate().getType2();
        switch (enchantStone.getType()) {
            case ARMOR: {
                if (itemType != 0 && !item.getTemplate().isHairAccessory()) break;
                return null;
            }
            case WEAPON: {
                if (itemType != 1 && itemType != 2 && !item.getTemplate().isHairAccessory()) break;
                return null;
            }
            case HAIR_ACCESSORY: {
                if (item.getTemplate().isHairAccessory()) break;
                return null;
            }
        }
        return enchantStone;
    }

    public static int getCrystallizeCrystalAdd(ItemInstance item) {
        int result = 0;
        int crystalsAdd = 0;
        if (item.isWeapon()) {
            switch (item.getGrade()) {
                case D: {
                    crystalsAdd = 90;
                    break;
                }
                case C: {
                    crystalsAdd = 45;
                    break;
                }
                case B: {
                    crystalsAdd = 67;
                    break;
                }
                case A: {
                    crystalsAdd = 145;
                    break;
                }
                case S: 
                case S80: 
                case S84: {
                    crystalsAdd = 250;
                    break;
                }
                case R: 
                case R95: 
                case R99: {
                    crystalsAdd = 500;
                }
            }
        } else {
            switch (item.getGrade()) {
                case D: {
                    crystalsAdd = 11;
                    break;
                }
                case C: {
                    crystalsAdd = 6;
                    break;
                }
                case B: {
                    crystalsAdd = 11;
                    break;
                }
                case A: {
                    crystalsAdd = 20;
                    break;
                }
                case S: 
                case S80: 
                case S84: {
                    crystalsAdd = 25;
                    break;
                }
                case R: 
                case R95: 
                case R99: {
                    crystalsAdd = 30;
                }
            }
        }
        if (item.getEnchantLevel() > 3) {
            result = crystalsAdd * 3;
            crystalsAdd = item.isWeapon() ? (crystalsAdd *= 2) : (crystalsAdd *= 3);
            result += crystalsAdd * (item.getEnchantLevel() - 3);
        } else {
            result = crystalsAdd * item.getEnchantLevel();
        }
        return result;
    }

    public static boolean checkIsEquipped(Player player, int slot, int itemId, int enchant) {
        PcInventory inv = player.getInventory();
        if (slot >= 0) {
            ItemInstance item = inv.getPaperdollItem(slot);
            if (item == null) {
                return itemId == 0;
            }
            return item.getItemId() == itemId && item.getFixedEnchantLevel(player) >= enchant;
        }
        for (int s : Inventory.PAPERDOLL_ORDER) {
            ItemInstance item = inv.getPaperdollItem(s);
            if (item == null || item.getItemId() != itemId || item.getFixedEnchantLevel(player) < enchant) continue;
            return true;
        }
        return false;
    }

    public static boolean checkForceUseItem(Player player, ItemInstance item, boolean sendMsg) {
        if (player.isOutOfControl()) {
            if (sendMsg) {
                player.sendActionFailed();
            }
            return false;
        }
        if (player.isStunned() || player.isDecontrolled() || player.isSleeping() || player.isAfraid() || player.isAlikeDead()) {
            if (sendMsg) {
                player.sendActionFailed();
            }
            return false;
        }
        if (item.getTemplate().isQuest()) {
            if (sendMsg) {
                player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_USE_QUEST_ITEMS);
            }
            return false;
        }
        return true;
    }

    public static boolean checkUseItem(Player player, ItemInstance item, boolean sendMsg) {
        if (player.isInTrainingCamp()) {
            return false;
        }
        if (player.isInStoreMode()) {
            if (sendMsg) {
                player.sendPacket((IBroadcastPacket)SystemMsg.YOU_MAY_NOT_USE_ITEMS_IN_A_PRIVATE_STORE_OR_PRIVATE_WORK_SHOP);
            }
            return false;
        }
        int itemId = item.getItemId();
        if (player.isFishing() && item.getTemplate().getItemType() != EtcItemTemplate.EtcItemType.FISHSHOT) {
            if (sendMsg) {
                player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_DO_THAT_WHILE_FISHING_2);
            }
            return false;
        }
        if (player.isSharedGroupDisabled(item.getTemplate().getReuseGroup())) {
            if (sendMsg) {
                player.sendReuseMessage(item);
            }
            return false;
        }
        if (!item.isEquipped() && !item.getTemplate().testCondition(player, item, sendMsg)) {
            return false;
        }
        if (player.getInventory().isLockedItem(item)) {
            return false;
        }
        for (Event e : player.getEvents()) {
            SystemMsg result = e.canUseItem(player, item);
            if (result == null) continue;
            if (sendMsg) {
                player.sendPacket((IBroadcastPacket)result);
            }
            return false;
        }
        if (item.getTemplate().isForPet()) {
            if (sendMsg) {
                player.sendPacket((IBroadcastPacket)SystemMsg.YOU_MAY_NOT_EQUIP_A_PET_ITEM);
            }
            return false;
        }
        if (player.isUseItemDisabled()) {
            if (sendMsg) {
                player.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addItemName(item.getItemId()));
            }
            return false;
        }
        if (player.isOutOfControl()) {
            if (sendMsg) {
                player.sendActionFailed();
            }
            return false;
        }
        return true;
    }
}


/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.math.SafeMath
 *  l2s.commons.util.Rnd
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.network.l2.c2s;

import java.util.ArrayList;
import java.util.List;
import l2s.commons.math.SafeMath;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.data.xml.holder.MultiSellHolder;
import l2s.gameserver.model.MultiSellListContainer;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.MultiSellEntry;
import l2s.gameserver.model.base.MultiSellIngredient;
import l2s.gameserver.model.entity.residence.Castle;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.PcInventory;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExMultiSellResult;
import l2s.gameserver.network.l2.s2c.SystemMessage;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.item.support.Ensoul;
import l2s.gameserver.utils.ItemFunctions;
import l2s.gameserver.utils.Log;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RequestMultiSellChoose
extends L2GameClientPacket {
    private static final int BUY_DELAY = 200;
    private static final Logger _log = LoggerFactory.getLogger(RequestMultiSellChoose.class);
    private int _listId;
    private int _entryId;
    private long _amount;

    @Override
    protected boolean readImpl() {
        this._listId = this.readD();
        this._entryId = this.readD();
        this._amount = this.readQ();
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null || this._amount < 1L) {
            return;
        }
        MultiSellListContainer list1 = activeChar.getMultisell();
        if (list1 == null) {
            activeChar.sendActionFailed();
            activeChar.setMultisell(null);
            return;
        }
        if (list1.getListId() != this._listId) {
            activeChar.sendActionFailed();
            activeChar.setMultisell(null);
            return;
        }
        if (activeChar.isActionsDisabled()) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isInStoreMode()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.WHILE_OPERATING_A_PRIVATE_STORE_OR_WORKSHOP_YOU_CANNOT_DISCARD_DESTROY_OR_TRADE_AN_ITEM);
            return;
        }
        if (activeChar.isInTrade()) {
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
        if (!Config.ALT_GAME_KARMA_PLAYER_CAN_SHOP && activeChar.isPK() && !activeChar.isGM()) {
            activeChar.sendActionFailed();
            return;
        }
        if (System.currentTimeMillis() <= activeChar.getLastMultisellBuyTime() + 200L) {
            activeChar.sendActionFailed();
            return;
        }
        MultiSellEntry entry = null;
        for (MultiSellEntry $entry : list1.getEntries()) {
            if ($entry.getEntryId() != this._entryId) continue;
            entry = $entry;
            break;
        }
        if (entry == null) {
            return;
        }
        boolean keepenchant = list1.isKeepEnchant();
        boolean notax = list1.isNoTax();
        ArrayList<ItemData> items = new ArrayList<ItemData>();
        PcInventory inventory = activeChar.getInventory();
        long totalPrice = 0L;
        NpcInstance merchant = activeChar.getLastNpc();
        Castle castle = merchant != null ? merchant.getCastle(activeChar) : null;
        inventory.writeLock();
        try {
            long tax = SafeMath.mulAndCheck((long)entry.getTax(), (long)this._amount);
            long slots = 0L;
            long weight = 0L;
            for (MultiSellIngredient i : entry.getProduction()) {
                if (i.getItemId() <= 0) continue;
                ItemTemplate item = ItemHolder.getInstance().getTemplate(i.getItemId());
                if (item == null) {
                    _log.warn("Cannot find production item template ID[" + i.getItemId() + "] in multisell list ID[" + this._listId + "]!");
                    return;
                }
                weight = SafeMath.addAndCheck((long)weight, (long)SafeMath.mulAndCheck((long)SafeMath.mulAndCheck((long)i.getItemCount(), (long)this._amount), (long)item.getWeight()));
                if (item.isStackable()) {
                    if (inventory.getItemByItemId(i.getItemId()) != null) continue;
                    ++slots;
                    continue;
                }
                slots = SafeMath.addAndCheck((long)slots, (long)this._amount);
            }
            if (!inventory.validateWeight(weight)) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_EXCEEDED_THE_WEIGHT_LIMIT);
                activeChar.sendActionFailed();
                return;
            }
            if (!inventory.validateCapacity(slots)) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOUR_INVENTORY_IS_FULL);
                activeChar.sendActionFailed();
                return;
            }
            if (entry.getIngredients().size() == 0) {
                activeChar.sendActionFailed();
                activeChar.setMultisell(null);
                return;
            }
            int customFlags = 0;
            int lifeTime = 0;
            for (MultiSellIngredient ingridient : entry.getIngredients()) {
                long totalAmount;
                int ingridientItemId = ingridient.getItemId();
                long ingridientItemCount = ingridient.getItemCount();
                int ingridientEnchant = ingridient.getItemEnchant();
                long l = totalAmount = !ingridient.getMantainIngredient() ? SafeMath.mulAndCheck((long)ingridientItemCount, (long)this._amount) : ingridientItemCount;
                if (ingridientItemId == -200) {
                    if (activeChar.getClan() == null) {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_ARE_NOT_A_CLAN_MEMBER_AND_CANNOT_PERFORM_THIS_ACTION);
                        return;
                    }
                    if ((long)activeChar.getClan().getReputationScore() < totalAmount) {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.THE_CLAN_REPUTATION_SCORE_IS_TOO_LOW);
                        return;
                    }
                    if (activeChar.getClan().getLeaderId() != activeChar.getObjectId()) {
                        activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_IS_NOT_A_CLAN_LEADER).addName(activeChar));
                        return;
                    }
                    if (!ingridient.getMantainIngredient()) {
                        items.add(new ItemData(ingridientItemId, totalAmount, null));
                    }
                } else if (ingridientItemId == -100) {
                    if ((long)activeChar.getPcBangPoints() < totalAmount) {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_ARE_SHORT_OF_ACCUMULATED_POINTS);
                        return;
                    }
                    if (!ingridient.getMantainIngredient()) {
                        items.add(new ItemData(ingridientItemId, totalAmount, null));
                    }
                } else if (ingridientItemId == -300) {
                    if ((long)activeChar.getFame() < totalAmount) {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_DONT_HAVE_ENOUGH_REPUTATION_TO_DO_THAT);
                        return;
                    }
                    if (!ingridient.getMantainIngredient()) {
                        items.add(new ItemData(ingridientItemId, totalAmount, null));
                    }
                } else {
                    ItemTemplate template = ItemHolder.getInstance().getTemplate(ingridientItemId);
                    if (template == null) {
                        _log.warn("Cannot find ingridient item template ID[" + ingridientItemId + "] in multisell list ID[" + this._listId + "]!");
                        return;
                    }
                    if (!template.isStackable()) {
                        int i = 0;
                        while ((long)i < ingridientItemCount * this._amount) {
                            Object itemToTake;
                            List<ItemInstance> list = inventory.getItemsByItemId(ingridientItemId);
                            if (keepenchant) {
                                itemToTake = null;
                                for (ItemInstance item : list) {
                                    ItemData itmd = new ItemData(item.getItemId(), item.getCount(), item);
                                    if (item.getEnchantLevel() != ingridientEnchant && item.getTemplate().isEquipment() || items.contains(itmd) || item.isShadowItem() || item.isTemporalItem() || !ItemFunctions.checkIfCanDiscard(activeChar, item)) continue;
                                    itemToTake = item;
                                    break;
                                }
                                if (itemToTake == null) {
                                    activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_ENOUGH_REQUIRED_ITEMS);
                                    return;
                                }
                                if (!ingridient.getMantainIngredient()) {
                                    items.add(new ItemData(((ItemInstance)itemToTake).getItemId(), 1L, (ItemInstance)itemToTake));
                                }
                            } else {
                                itemToTake = null;
                                for (ItemInstance item : list) {
                                    if (!(items.contains(new ItemData(item.getItemId(), item.getCount(), item)) || itemToTake != null && item.getEnchantLevel() >= ((ItemInstance)itemToTake).getEnchantLevel() || item.isShadowItem() || item.isTemporalItem() || item.isAugmented() && !Config.ALT_ALLOW_DROP_AUGMENTED || !ItemFunctions.checkIfCanDiscard(activeChar, item) || ((ItemInstance)(itemToTake = item)).getEnchantLevel() != 0)) break;
                                }
                                if (itemToTake == null) {
                                    activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_ENOUGH_REQUIRED_ITEMS);
                                    return;
                                }
                                if (!ingridient.getMantainIngredient()) {
                                    items.add(new ItemData(((ItemInstance)itemToTake).getItemId(), 1L, (ItemInstance)itemToTake));
                                }
                            }
                            ++i;
                        }
                    } else {
                        ItemInstance item;
                        if (ingridientItemId == 57) {
                            totalPrice = SafeMath.addAndCheck((long)totalPrice, (long)SafeMath.mulAndCheck((long)ingridientItemCount, (long)this._amount));
                        }
                        if ((item = inventory.getItemByItemId(ingridientItemId)) == null || item.getCount() < totalAmount) {
                            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_ENOUGH_REQUIRED_ITEMS);
                            return;
                        }
                        if (!ingridient.getMantainIngredient()) {
                            items.add(new ItemData(item.getItemId(), totalAmount, item));
                        }
                    }
                }
                if (activeChar.getAdena() >= totalPrice) continue;
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_ENOUGH_ADENA);
                return;
            }
            int enchantLevel = 0;
            int variationStoneId = 0;
            int variation1Id = 0;
            int variation2Id = 0;
            int visualId = 0;
            int appearanceStoneId = 0;
            Ensoul[] normalEnsouls = ItemInstance.EMPTY_ENSOULS_ARRAY;
            Ensoul[] specialEnsouls = ItemInstance.EMPTY_ENSOULS_ARRAY;
            for (ItemData id : items) {
                long count = id.getCount();
                if (count <= 0L) continue;
                if (id.getId() == -200) {
                    activeChar.getClan().incReputation((int)(-count), false, "MultiSell");
                    activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_POINTS_HAVE_BEEN_DEDUCTED_FROM_THE_CLANS_REPUTATION).addLong(count));
                    continue;
                }
                if (id.getId() == -100) {
                    activeChar.reducePcBangPoints((int)count, true);
                    continue;
                }
                if (id.getId() == -300) {
                    activeChar.setFame(activeChar.getFame() - (int)count, "MultiSell", true);
                    activeChar.sendPacket((IBroadcastPacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.S2_S1_HAS_DISAPPEARED).addLong(count)).addString("Fame"));
                    continue;
                }
                if (inventory.destroyItem(id.getItem(), count)) {
                    if (keepenchant) {
                        if (id.getItem().canBeEnchanted()) {
                            enchantLevel = id.getItem().getEnchantLevel();
                        }
                        if (id.getItem().canBeAugmented(activeChar)) {
                            variationStoneId = id.getItem().getVariationStoneId();
                            variation1Id = id.getItem().getVariation1Id();
                            variation2Id = id.getItem().getVariation2Id();
                        }
                        if (id.getItem().canBeAppearance()) {
                            visualId = id.getItem().getVisualId();
                            appearanceStoneId = id.getItem().getAppearanceStoneId();
                        }
                        normalEnsouls = id.getItem().getNormalEnsouls();
                        specialEnsouls = id.getItem().getSpecialEnsouls();
                    } else if (!Config.RETAIL_MULTISELL_ENCHANT_TRANSFER && id.getItem().canBeEnchanted()) {
                        if (id.getItem().getEnchantLevel() > 0) {
                            enchantLevel = id.getItem().getEnchantLevel();
                        }
                        if (id.getItem().getVariationStoneId() > 0) {
                            variationStoneId = id.getItem().getVariationStoneId();
                        }
                        if (id.getItem().getVariation1Id() > 0) {
                            variation1Id = id.getItem().getVariation1Id();
                        }
                        if (id.getItem().getVariation2Id() > 0) {
                            variation2Id = id.getItem().getVariation2Id();
                        }
                        if (id.getItem().getVisualId() > 0) {
                            visualId = id.getItem().getVisualId();
                        }
                        if (id.getItem().getAppearanceStoneId() > 0) {
                            appearanceStoneId = id.getItem().getAppearanceStoneId();
                        }
                        if (id.getItem().getNormalEnsouls().length > 0) {
                            normalEnsouls = id.getItem().getNormalEnsouls();
                        }
                        if (id.getItem().getSpecialEnsouls().length > 0) {
                            specialEnsouls = id.getItem().getSpecialEnsouls();
                        }
                    }
                    if (id.getItem().isWeapon() || id.getItem().isArmor() || id.getItem().isAccessory()) {
                        customFlags = id.getItem().getCustomFlags();
                        lifeTime = id.getItem().getTemporalLifeTime();
                    }
                    activeChar.sendPacket((IBroadcastPacket)SystemMessagePacket.removeItems(id.getId(), count));
                    continue;
                }
                return;
            }
            if (tax > 0L && !notax && castle != null && merchant != null && merchant.getReflection().isMain()) {
                castle.addToTreasury(tax, true);
            }
            List<MultiSellIngredient> products = entry.getProduction();
            if (list1.getType() == MultiSellListContainer.MultisellType.CHANCED) {
                int chancesAmount = 0;
                ArrayList<MultiSellIngredient> productsTemp = new ArrayList<MultiSellIngredient>();
                for (MultiSellIngredient in : products) {
                    int chance = in.getChance();
                    if (chance <= 0) continue;
                    chancesAmount += chance;
                    productsTemp.add(in);
                }
                if (Rnd.chance((int)chancesAmount)) {
                    double chanceMod = (100.0 - (double)chancesAmount) / (double)productsTemp.size();
                    ArrayList<MultiSellIngredient> successProducts = new ArrayList<MultiSellIngredient>();
                    int tryCount = 0;
                    while (successProducts.isEmpty()) {
                        ++tryCount;
                        for (MultiSellIngredient in : productsTemp) {
                            if (tryCount % 10 == 0) {
                                chanceMod += 1.0;
                            }
                            if (!Rnd.chance((double)((double)in.getChance() + chanceMod))) continue;
                            successProducts.add(in);
                        }
                    }
                    MultiSellIngredient[] productionsArray = successProducts.toArray(new MultiSellIngredient[successProducts.size()]);
                    products = new ArrayList<MultiSellIngredient>(1);
                    products.add(productionsArray[Rnd.get((int)productionsArray.length)]);
                }
            }
            for (MultiSellIngredient in : products) {
                if (in.getItemId() <= 0) {
                    if (in.getItemId() == -200) {
                        activeChar.getClan().incReputation((int)(in.getItemCount() * this._amount), false, "MultiSell");
                        activeChar.sendPacket((IBroadcastPacket)new SystemMessage(1781).addNumber(in.getItemCount() * this._amount));
                        continue;
                    }
                    if (in.getItemId() == -100) {
                        activeChar.addPcBangPoints((int)(in.getItemCount() * this._amount), false, true);
                        continue;
                    }
                    if (in.getItemId() != -300) continue;
                    activeChar.setFame(activeChar.getFame() + (int)(in.getItemCount() * this._amount), "MultiSell", true);
                    continue;
                }
                if (ItemHolder.getInstance().getTemplate(in.getItemId()).isStackable()) {
                    long total = SafeMath.mulAndLimit((long)in.getItemCount(), (long)this._amount);
                    ItemFunctions.addItem(activeChar, in.getItemId(), total, true);
                    Log.LogMultisell("Character " + activeChar.getName() + " bought " + total + " of " + in.getItemId() + " ingridients: ID: " + in.getItemId() + " count: " + in.getItemCount());
                    continue;
                }
                int i = 0;
                while ((long)i < this._amount) {
                    ItemInstance product = ItemFunctions.createItem(in.getItemId());
                    if (keepenchant) {
                        if (product.canBeEnchanted()) {
                            product.setEnchantLevel(enchantLevel);
                        }
                        if (product.canBeAugmented(activeChar)) {
                            if (variationStoneId > 0) {
                                product.setVariationStoneId(variationStoneId);
                            }
                            if (variation1Id != 0) {
                                product.setVariation1Id(variation1Id);
                            }
                            if (variation2Id != 0) {
                                product.setVariation2Id(variation2Id);
                            }
                        }
                        if (product.canBeAppearance()) {
                            if (visualId != 0) {
                                product.setVisualId(visualId);
                            }
                            if (appearanceStoneId != 0) {
                                product.setAppearanceStoneId(appearanceStoneId);
                            }
                        }
                        enchantLevel = 0;
                        variationStoneId = 0;
                        variation1Id = 0;
                        variation2Id = 0;
                        visualId = 0;
                        appearanceStoneId = 0;
                    } else {
                        product.setEnchantLevel(in.getItemEnchant());
                        product.setAttributes(in.getItemAttributes().clone());
                        if (in.getFlags() >= 0) {
                            customFlags = in.getFlags();
                        }
                        if (in.getDurability() >= 0) {
                            lifeTime = in.getDurability();
                        }
                    }
                    if (customFlags > 0) {
                        product.setCustomFlags(customFlags);
                        if (lifeTime > 0) {
                            product.setLifeTime((int)(System.currentTimeMillis() / 1000L) + lifeTime);
                        }
                        customFlags = 0;
                        lifeTime = 0;
                    }
                    activeChar.sendPacket((IBroadcastPacket)SystemMessagePacket.obtainItems(product));
                    inventory.addItem(product);
                    if (keepenchant) {
                        int id;
                        for (id = 1; id <= normalEnsouls.length; ++id) {
                            Ensoul ensoul = normalEnsouls[id - 1];
                            product.addEnsoul(1, id, ensoul, true);
                        }
                        for (id = 1; id <= specialEnsouls.length; ++id) {
                            Ensoul ensoul = specialEnsouls[id - 1];
                            product.addEnsoul(2, id, ensoul, true);
                        }
                        normalEnsouls = ItemInstance.EMPTY_ENSOULS_ARRAY;
                        specialEnsouls = ItemInstance.EMPTY_ENSOULS_ARRAY;
                    }
                    Log.LogMultisell("Character " + activeChar.getName() + " bought 1 of " + product.getItemId() + " igridients: Id: " + in.getItemId() + " count: " + in.getItemCount() + "");
                    ++i;
                }
            }
            activeChar.sendPacket((IBroadcastPacket)ExMultiSellResult.SUCCESS);
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THE_TRADE_WAS_SUCCESSFUL);
        }
        catch (ArithmeticException ae) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_EXCEEDED_THE_QUANTITY_THAT_CAN_BE_INPUTTED);
            return;
        }
        finally {
            inventory.writeUnlock();
        }
        activeChar.sendChanges();
        if (!list1.isShowAll()) {
            MultiSellHolder.getInstance().SeparateAndSend(list1, activeChar, castle == null ? 0.0 : castle.getSellTaxRate());
        }
        activeChar.setLastMultisellBuyTime(System.currentTimeMillis());
    }

    private class ItemData {
        private final int _id;
        private final long _count;
        private final ItemInstance _item;

        public ItemData(int id, long count, ItemInstance item) {
            this._id = id;
            this._count = count;
            this._item = item;
        }

        public int getId() {
            return this._id;
        }

        public long getCount() {
            return this._count;
        }

        public ItemInstance getItem() {
            return this._item;
        }

        public boolean equals(Object obj) {
            if (!(obj instanceof ItemData)) {
                return false;
            }
            ItemData i = (ItemData)obj;
            return this._id == i._id && this._count == i._count && this._item == i._item;
        }

        public int hashCode() {
            int hash = this._item.hashCode();
            hash = 76 * hash + this._id;
            hash = 76 * hash + (int)(this._count / 1757L);
            return hash;
        }
    }
}


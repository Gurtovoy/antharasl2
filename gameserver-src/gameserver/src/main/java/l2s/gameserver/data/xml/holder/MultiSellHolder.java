/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.holder;

import gnu.trove.map.hash.TIntObjectHashMap;
import java.io.File;
import java.util.ArrayList;
import java.util.List;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.model.MultiSellListContainer;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.MultiSellEntry;
import l2s.gameserver.model.base.MultiSellIngredient;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.MultiSellListPacket;
import l2s.gameserver.templates.item.ItemTemplate;

public class MultiSellHolder
extends AbstractHolder {
    private static MultiSellHolder _instance = new MultiSellHolder();
    private TIntObjectHashMap<MultiSellListContainer> _entries = new TIntObjectHashMap();

    public static MultiSellHolder getInstance() {
        return _instance;
    }

    public MultiSellListContainer getList(int id) {
        return (MultiSellListContainer)this._entries.get(id);
    }

    public void addMultiSellListContainer(int id, MultiSellListContainer list) {
        if (this._entries.containsKey(id)) {
            this._log.warn("MultiSell redefined: " + id);
        }
        list.setListId(id);
        this._entries.put(id, list);
    }

    public MultiSellListContainer remove(String s) {
        return this.remove(new File(s));
    }

    public MultiSellListContainer remove(File f) {
        return this.remove(Integer.parseInt(f.getName().replaceAll(".xml", "")));
    }

    public MultiSellListContainer remove(int id) {
        return (MultiSellListContainer)this._entries.remove(id);
    }

    private long[] parseItemIdAndCount(String s) {
        if (s == null || s.isEmpty()) {
            return null;
        }
        String[] a = s.split(":");
        try {
            long id = Integer.parseInt(a[0]);
            long count = a.length > 1 ? Long.parseLong(a[1]) : 1L;
            return new long[]{id, count};
        }
        catch (Exception e) {
            this.error("", e);
            return null;
        }
    }

    public MultiSellEntry parseEntryFromStr(String s) {
        long[] production;
        if (s == null || s.isEmpty()) {
            return null;
        }
        String[] a = s.split("->");
        if (a.length != 2) {
            return null;
        }
        long[] ingredient = this.parseItemIdAndCount(a[0]);
        if (ingredient == null || (production = this.parseItemIdAndCount(a[1])) == null) {
            return null;
        }
        MultiSellEntry entry = new MultiSellEntry();
        entry.addIngredient(new MultiSellIngredient((int)ingredient[0], ingredient[1]));
        entry.addProduct(new MultiSellIngredient((int)production[0], production[1]));
        return entry;
    }

    public void SeparateAndSend(int listId, Player player, double taxRate) {
        for (int i : Config.ALT_DISABLED_MULTISELL) {
            if (i != listId) continue;
            player.sendMessage(new CustomMessage("common.Disabled"));
            return;
        }
        MultiSellListContainer list = this.getList(listId);
        if (list == null) {
            player.sendMessage(new CustomMessage("common.Disabled"));
            return;
        }
        this.SeparateAndSend(list, player, taxRate);
    }

    public void SeparateAndSend(MultiSellListContainer list, Player player, double taxRate) {
        list = this.generateMultiSell(list, player, taxRate);
        MultiSellListContainer temp = new MultiSellListContainer();
        int page = 1;
        temp.setListId(list.getListId());
        temp.setType(list.getType());
        player.setMultisell(list);
        for (MultiSellEntry e : list.getEntries()) {
            if (temp.getEntries().size() == Config.MULTISELL_SIZE) {
                player.sendPacket((IBroadcastPacket)new MultiSellListPacket(temp, page, 0));
                ++page;
                temp = new MultiSellListContainer();
                temp.setListId(list.getListId());
                temp.setType(list.getType());
            }
            temp.addEntry(e);
        }
        player.sendPacket((IBroadcastPacket)new MultiSellListPacket(temp, page, 1));
    }

    private MultiSellListContainer generateMultiSell(MultiSellListContainer container, Player player, double taxRate) {
        MultiSellListContainer list = new MultiSellListContainer();
        list.setListId(container.getListId());
        list.setType(container.getType());
        boolean enchant = container.isKeepEnchant();
        boolean notax = container.isNoTax();
        boolean showall = container.isShowAll();
        boolean nokey = container.isNoKey();
        list.setShowAll(showall);
        list.setKeepEnchant(enchant);
        list.setNoTax(notax);
        list.setNoKey(nokey);
        ItemInstance[] items = player.getInventory().getItems();
        for (MultiSellEntry origEntry : container.getEntries()) {
            List<MultiSellIngredient> ingridients;
            MultiSellEntry ent = origEntry.clone();
            if (!notax && taxRate > 0.0) {
                double tax = 0.0;
                long adena = 0L;
                ingridients = new ArrayList<MultiSellIngredient>(ent.getIngredients().size() + 1);
                for (MultiSellIngredient i : ent.getIngredients()) {
                    ItemTemplate item;
                    if (i.getItemId() == 57) {
                        adena += i.getItemCount();
                        tax += (double)i.getItemCount() * taxRate;
                        continue;
                    }
                    ingridients.add(i);
                    if (i.getItemId() == -200) {
                        tax += (double)(i.getItemCount() / 120L * 1000L) * taxRate * 100.0;
                    }
                    if (i.getItemId() < 1 || !(item = ItemHolder.getInstance().getTemplate(i.getItemId())).isStackable()) continue;
                    tax += (double)((long)item.getReferencePrice() * i.getItemCount()) * taxRate;
                }
                if ((adena = Math.round((double)adena + tax)) > 0L) {
                    ingridients.add(new MultiSellIngredient(57, adena));
                }
                ent.setTax(Math.round(tax));
                ent.getIngredients().clear();
                ent.getIngredients().addAll(ingridients);
            } else {
                ingridients = ent.getIngredients();
            }
            if (showall) {
                list.addEntry(ent);
                continue;
            }
            ArrayList<Integer> itms = new ArrayList<Integer>();
            block2: for (MultiSellIngredient ingredient : ingridients) {
                ItemTemplate template;
                ItemTemplate itemTemplate = template = ingredient.getItemId() <= 0 ? null : ItemHolder.getInstance().getTemplate(ingredient.getItemId());
                if (ingredient.getItemId() > 0 && !nokey && !template.isEquipment() || ingredient.getItemId() == 12374) continue;
                if (ingredient.getItemId() == -200) {
                    if (itms.contains(ingredient.getItemId()) || player.getClan() == null || (long)player.getClan().getReputationScore() < ingredient.getItemCount()) continue;
                    itms.add(ingredient.getItemId());
                    continue;
                }
                if (ingredient.getItemId() == -100) {
                    if (itms.contains(ingredient.getItemId()) || (long)player.getPcBangPoints() < ingredient.getItemCount()) continue;
                    itms.add(ingredient.getItemId());
                    continue;
                }
                if (ingredient.getItemId() == -300) {
                    if (itms.contains(ingredient.getItemId()) || (long)player.getFame() < ingredient.getItemCount()) continue;
                    itms.add(ingredient.getItemId());
                    continue;
                }
                for (ItemInstance item : items) {
                    if (item.getItemId() != ingredient.getItemId() || itms.contains(enchant ? (long)ingredient.getItemId() + (long)ingredient.getItemEnchant() * 100000L : (long)ingredient.getItemId()) || item.getEnchantLevel() < ingredient.getItemEnchant()) continue;
                    if (item.isStackable() && item.getCount() < ingredient.getItemCount()) continue block2;
                    itms.add(enchant ? ingredient.getItemId() + ingredient.getItemEnchant() * 100000 : ingredient.getItemId());
                    MultiSellEntry possibleEntry = new MultiSellEntry(enchant ? ent.getEntryId() + item.getEnchantLevel() * 100000 : ent.getEntryId());
                    for (MultiSellIngredient p : ent.getProduction()) {
                        if (enchant && template.canBeEnchanted()) {
                            p.setItemEnchant(item.getEnchantLevel());
                            p.setItemAttributes(item.getAttributes().clone());
                        }
                        possibleEntry.addProduct(p);
                    }
                    for (MultiSellIngredient ig : ingridients) {
                        if (enchant && ig.getItemId() > 0 && ItemHolder.getInstance().getTemplate(ig.getItemId()).canBeEnchanted()) {
                            ig.setItemEnchant(item.getEnchantLevel());
                            ig.setItemAttributes(item.getAttributes().clone());
                        }
                        possibleEntry.addIngredient(ig);
                    }
                    list.addEntry(possibleEntry);
                    continue block2;
                }
            }
        }
        return list;
    }

    public int size() {
        return this._entries.size();
    }

    public void clear() {
        this._entries.clear();
    }
}


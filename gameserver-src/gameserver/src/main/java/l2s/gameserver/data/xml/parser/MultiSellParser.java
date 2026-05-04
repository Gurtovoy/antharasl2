/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.data.xml.holder.MultiSellHolder;
import l2s.gameserver.model.MultiSellListContainer;
import l2s.gameserver.model.base.MultiSellEntry;
import l2s.gameserver.model.base.MultiSellIngredient;
import l2s.gameserver.templates.item.ItemTemplate;
import org.dom4j.Element;

public class MultiSellParser
extends AbstractParser<MultiSellHolder> {
    private static final MultiSellParser _instance = new MultiSellParser();

    public static MultiSellParser getInstance() {
        return _instance;
    }

    protected MultiSellParser() {
        super(MultiSellHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/multisell");
    }

    public File getCustomXMLPath() {
        return new File(Config.DATAPACK_ROOT, "custom/multisell");
    }

    public String getDTDFileName() {
        return "multisell.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        int listId = Integer.parseInt(this._currentFile.replace(".xml", ""));
        boolean showAll = true;
        boolean keepEnchanted = false;
        boolean noTax = false;
        boolean noKey = false;
        MultiSellListContainer.MultisellType type = MultiSellListContainer.MultisellType.NORMAL;
        Element configElement = rootElement.element("config");
        if (configElement != null) {
            if (configElement.attributeValue("show_all") != null) {
                showAll = Boolean.parseBoolean(configElement.attributeValue("show_all"));
            }
            if (configElement.attributeValue("keep_enchanted") != null) {
                keepEnchanted = Boolean.parseBoolean(configElement.attributeValue("keep_enchanted"));
            }
            if (configElement.attributeValue("no_tax") != null) {
                noTax = Boolean.parseBoolean(configElement.attributeValue("no_tax"));
            }
            if (configElement.attributeValue("no_key") != null) {
                noKey = Boolean.parseBoolean(configElement.attributeValue("no_key"));
            }
            if (configElement.attributeValue("type") != null) {
                type = MultiSellListContainer.MultisellType.valueOf(configElement.attributeValue("type").toUpperCase());
            }
        }
        MultiSellListContainer list = new MultiSellListContainer();
        list.setShowAll(showAll);
        list.setNoTax(noTax);
        list.setKeepEnchant(keepEnchanted);
        list.setNoKey(noKey);
        list.setType(type);
        int entryId = 0;
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            MultiSellEntry e;
            Element element = (Element)iterator.next();
            if (!"item".equalsIgnoreCase(element.getName()) || (e = this.parseEntry(element, listId)) == null) continue;
            e.setEntryId(entryId++);
            list.addEntry(e);
        }
        ((MultiSellHolder)this.getHolder()).addMultiSellListContainer(listId, list);
    }

    protected MultiSellEntry parseEntry(Element n, int multiSellId) {
        ItemTemplate item;
        MultiSellEntry entry = new MultiSellEntry();
        Iterator iterator = n.elementIterator();
        while (iterator.hasNext()) {
            String[] flagsArray;
            long count;
            int id;
            Element d = (Element)iterator.next();
            if ("ingredient".equalsIgnoreCase(d.getName())) {
                id = Integer.parseInt(d.attributeValue("id"));
                count = Long.parseLong(d.attributeValue("count"));
                entry.addIngredient(new MultiSellIngredient(id, count));
                continue;
            }
            if (!"production".equalsIgnoreCase(d.getName())) continue;
            id = Integer.parseInt(d.attributeValue("id"));
            count = Long.parseLong(d.attributeValue("count"));
            int chance = d.attributeValue("chance") == null ? 0 : Integer.parseInt(d.attributeValue("chance"));
            int flags = 0;
            String[] stringArray = flagsArray = d.attributeValue("flags") == null ? null : d.attributeValue("flags").split(";");
            if (flagsArray != null) {
                String[] stringArray2 = flagsArray;
                int n2 = stringArray2.length;
                block13: for (int i = 0; i < n2; ++i) {
                    String flag;
                    switch (flag = stringArray2[i]) {
                        case "FLAG_NO_DROP": {
                            flags |= 1;
                            continue block13;
                        }
                        case "FLAG_NO_TRADE": {
                            flags |= 2;
                            continue block13;
                        }
                        case "FLAG_NO_TRANSFER": {
                            flags |= 4;
                            continue block13;
                        }
                        case "FLAG_NO_CRYSTALLIZE": {
                            flags |= 8;
                        }
                    }
                }
            }
            int durablity = d.attributeValue("durablity") == null ? -1 : Integer.parseInt(d.attributeValue("durablity"));
            int enchant = d.attributeValue("enchant") == null ? 0 : Integer.parseInt(d.attributeValue("enchant"));
            entry.addProduct(new MultiSellIngredient(id, count, chance, flags, durablity, enchant));
        }
        if (entry.getIngredients().isEmpty() || entry.getProduction().isEmpty()) {
            this._log.warn("MultiSell [" + multiSellId + "] is empty!");
            return null;
        }
        for (MultiSellIngredient ingridient : entry.getIngredients()) {
            if (ingridient.getItemId() == 57 && ingridient.getItemCount() == -1L) {
                long price = 0L;
                for (MultiSellIngredient product : entry.getProduction()) {
                    ItemTemplate item2 = ItemHolder.getInstance().getTemplate(product.getItemId());
                    if (item2 == null) continue;
                    price += (long)item2.getReferencePrice() * product.getItemCount();
                }
                if (price <= 0L) {
                    return null;
                }
                ingridient.setItemCount(price);
            }
            if (ingridient.getItemCount() > 0L) continue;
            this._log.warn("MultiSell [" + multiSellId + "] ingridient ID[" + ingridient.getItemId() + "] has negative item count!");
            return null;
        }
        if (entry.getIngredients().size() == 1 && entry.getProduction().size() == 1 && entry.getIngredients().get(0).getItemId() == 57 && (item = ItemHolder.getInstance().getTemplate(entry.getProduction().get(0).getItemId())) == null) {
            this._log.warn("MultiSell [" + multiSellId + "] Production [" + entry.getProduction().get(0).getItemId() + "] not found!");
            return null;
        }
        return entry;
    }
}


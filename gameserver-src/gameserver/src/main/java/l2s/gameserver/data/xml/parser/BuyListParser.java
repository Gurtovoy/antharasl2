/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.data.xml.AbstractHolder
 *  l2s.commons.data.xml.AbstractParser
 *  org.dom4j.Element
 */
package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.BuyListHolder;
import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.model.items.TradeItem;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.npc.BuyListTemplate;
import org.dom4j.Element;

public final class BuyListParser
extends AbstractParser<BuyListHolder> {
    private static BuyListParser _instance = new BuyListParser();

    public static BuyListParser getInstance() {
        return _instance;
    }

    private BuyListParser() {
        super(BuyListHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/buylists/");
    }

    public String getDTDFileName() {
        return "buylist.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator("npc");
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            int npcId = Integer.parseInt(element.attributeValue("id"));
            Iterator buylistIterator = element.elementIterator("buylist");
            while (buylistIterator.hasNext()) {
                Element buylistElement = (Element)buylistIterator.next();
                int buylistId = Integer.parseInt(buylistElement.attributeValue("id"));
                int baseMarkup = buylistElement.attributeValue("base_markup") == null ? 0 : Integer.parseInt(buylistElement.attributeValue("base_markup"));
                BuyListTemplate buyList = new BuyListTemplate(npcId, buylistId, baseMarkup);
                Iterator itemIterator = buylistElement.elementIterator("item");
                while (itemIterator.hasNext()) {
                    Element itemElement = (Element)itemIterator.next();
                    int itemId = Integer.parseInt(itemElement.attributeValue("id"));
                    ItemTemplate template = ItemHolder.getInstance().getTemplate(itemId);
                    if (template == null) {
                        this._log.warn("Template not found for item ID: " + itemId + " for npc ID: " + npcId + " for buylist ID: " + buylistId);
                        continue;
                    }
                    if (!BuyListParser.checkItem(template)) continue;
                    double itemMarkup = (double)(itemElement.attributeValue("markup") == null ? baseMarkup : Integer.parseInt(itemElement.attributeValue("markup"))) / 100.0 + 1.0;
                    long itemPrice = npcId > 0 ? (itemElement.attributeValue("price") == null ? Math.round((double)template.getReferencePrice() * itemMarkup) : Long.parseLong(itemElement.attributeValue("price"))) : 0L;
                    long itemCount = itemElement.attributeValue("count") == null ? 0L : Long.parseLong(itemElement.attributeValue("count"));
                    int itemRechargeTime = itemElement.attributeValue("time") == null ? 0 : Integer.parseInt(itemElement.attributeValue("time"));
                    TradeItem item = new TradeItem();
                    item.setItemId(itemId);
                    item.setOwnersPrice(itemPrice);
                    item.setCount(itemCount);
                    item.setCurrentValue(itemCount);
                    item.setLastRechargeTime((int)(System.currentTimeMillis() / 60000L));
                    item.setRechargeTime(itemRechargeTime);
                    buyList.addItem(item);
                }
                ((BuyListHolder)this.getHolder()).addBuyList(buyList);
            }
        }
    }

    private static boolean checkItem(ItemTemplate template) {
        if (template.isEquipment() && !template.isForPet() && Config.ALT_SHOP_PRICE_LIMITS.length > 0) {
            for (int i = 0; i < Config.ALT_SHOP_PRICE_LIMITS.length; i += 2) {
                if (template.getBodyPart() != (long)Config.ALT_SHOP_PRICE_LIMITS[i]) continue;
                if (template.getReferencePrice() <= Config.ALT_SHOP_PRICE_LIMITS[i + 1]) break;
                return false;
            }
        }
        if (Config.ALT_SHOP_UNALLOWED_ITEMS.length > 0) {
            for (int i : Config.ALT_SHOP_UNALLOWED_ITEMS) {
                if (template.getItemId() != i) continue;
                return false;
            }
        }
        return true;
    }
}


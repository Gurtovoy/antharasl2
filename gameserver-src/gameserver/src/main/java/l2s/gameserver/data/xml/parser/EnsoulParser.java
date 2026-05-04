package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.EnsoulHolder;
import l2s.gameserver.templates.item.ItemGrade;
import l2s.gameserver.templates.item.support.Ensoul;
import l2s.gameserver.templates.item.support.EnsoulFee;
import org.dom4j.Element;

public final class EnsoulParser
extends AbstractParser<EnsoulHolder> {
    private static final EnsoulParser _instance = new EnsoulParser();

    public static EnsoulParser getInstance() {
        return _instance;
    }

    private EnsoulParser() {
        super(EnsoulHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/ensoul_data.xml");
    }

    public String getDTDFileName() {
        return "ensoul_data.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Element element;
        Iterator iterator = rootElement.elementIterator("ensoul_fee_data");
        while (iterator.hasNext()) {
            element = (Element)iterator.next();
            Iterator feeIterator = element.elementIterator("ensoul_fee");
            while (feeIterator.hasNext()) {
                Element feeElement = (Element)feeIterator.next();
                ItemGrade grade = ItemGrade.valueOf(feeElement.attributeValue("grade").toUpperCase());
                EnsoulFee ensoulFee = new EnsoulFee();
                Iterator feeInfoIterator = feeElement.elementIterator("ensoul_fee_info");
                while (feeInfoIterator.hasNext()) {
                    Element feeInfoElement = (Element)feeInfoIterator.next();
                    int type = Integer.parseInt(feeInfoElement.attributeValue("type"));
                    Iterator feeItemsIterator = feeInfoElement.elementIterator("ensoul_fee_items");
                    while (feeItemsIterator.hasNext()) {
                        Element feeItemsElement = (Element)feeItemsIterator.next();
                        int id = Integer.parseInt(feeItemsElement.attributeValue("id"));
                        ensoulFee.addFeeInfo(type, id, EnsoulParser.parseFeeInfo(feeItemsElement));
                    }
                }
                ((EnsoulHolder)this.getHolder()).addEnsoulFee(grade, ensoulFee);
            }
        }
        iterator = rootElement.elementIterator("ensoul_data");
        while (iterator.hasNext()) {
            element = (Element)iterator.next();
            Iterator ensoulIterator = element.elementIterator("ensoul");
            while (ensoulIterator.hasNext()) {
                Element ensoulElement = (Element)ensoulIterator.next();
                int id = Integer.parseInt(ensoulElement.attributeValue("id"));
                int itemId = ensoulElement.attributeValue("item_id") == null ? 0 : Integer.parseInt(ensoulElement.attributeValue("item_id"));
                int extractionItemId = ensoulElement.attributeValue("extraction_item_id") == null ? 0 : Integer.parseInt(ensoulElement.attributeValue("extraction_item_id"));
                Ensoul ensoul = new Ensoul(id, itemId, extractionItemId);
                Iterator skillIterator = ensoulElement.elementIterator("skill");
                while (skillIterator.hasNext()) {
                    Element skillElement = (Element)skillIterator.next();
                    int skillId = Integer.parseInt(skillElement.attributeValue("id"));
                    int skillLevel = Integer.parseInt(skillElement.attributeValue("level"));
                    ensoul.addSkill(skillId, skillLevel);
                }
                ((EnsoulHolder)this.getHolder()).addEnsoul(ensoul);
            }
        }
    }

    private static EnsoulFee.EnsoulFeeInfo parseFeeInfo(Element rootElement) {
        EnsoulFee.EnsoulFeeInfo feeInfo = new EnsoulFee.EnsoulFeeInfo();
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            if (element.getName().equals("insert")) {
                feeInfo.setInsertFee(EnsoulParser.parseFeeItems(element));
                continue;
            }
            if (element.getName().equals("change")) {
                feeInfo.setChangeFee(EnsoulParser.parseFeeItems(element));
                continue;
            }
            if (!element.getName().equals("remove")) continue;
            feeInfo.setRemoveFee(EnsoulParser.parseFeeItems(element));
        }
        return feeInfo;
    }

    private static List<EnsoulFee.EnsoulFeeItem> parseFeeItems(Element rootElement) {
        ArrayList<EnsoulFee.EnsoulFeeItem> items = new ArrayList<EnsoulFee.EnsoulFeeItem>();
        Iterator iterator = rootElement.elementIterator("item");
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            int itemId = Integer.parseInt(element.attributeValue("id"));
            long itemCount = Long.parseLong(element.attributeValue("count"));
            items.add(new EnsoulFee.EnsoulFeeItem(itemId, itemCount));
        }
        return items;
    }
}


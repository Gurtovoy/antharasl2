package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.OptionDataHolder;
import l2s.gameserver.data.xml.holder.VariationDataHolder;
import l2s.gameserver.templates.item.WeaponFightType;
import l2s.gameserver.templates.item.support.variation.VariationCategory;
import l2s.gameserver.templates.item.support.variation.VariationFee;
import l2s.gameserver.templates.item.support.variation.VariationGroup;
import l2s.gameserver.templates.item.support.variation.VariationInfo;
import l2s.gameserver.templates.item.support.variation.VariationOption;
import l2s.gameserver.templates.item.support.variation.VariationStone;
import org.dom4j.Element;

public final class VariationDataParser
extends AbstractParser<VariationDataHolder> {
    private static VariationDataParser _instance = new VariationDataParser();

    public static VariationDataParser getInstance() {
        return _instance;
    }

    private VariationDataParser() {
        super(VariationDataHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/variationdata/");
    }

    public String getDTDFileName() {
        return "variationdata.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Element element;
        if (!Config.ALLOW_AUGMENTATION) {
            return;
        }
        Iterator iterator = rootElement.elementIterator("weapon");
        while (iterator.hasNext()) {
            element = (Element)iterator.next();
            WeaponFightType type = WeaponFightType.valueOf(element.attributeValue("type").toUpperCase());
            Iterator stoneIterator = element.elementIterator("stone");
            while (stoneIterator.hasNext()) {
                Element stoneElement = (Element)stoneIterator.next();
                int stoneId = Integer.parseInt(stoneElement.attributeValue("id"));
                VariationStone stone = new VariationStone(stoneId);
                Iterator variationIterator = stoneElement.elementIterator("variation");
                while (variationIterator.hasNext()) {
                    Element variationElement = (Element)variationIterator.next();
                    int variationId = Integer.parseInt(variationElement.attributeValue("id"));
                    VariationInfo variation = new VariationInfo(variationId);
                    Iterator categoryIterator = variationElement.elementIterator("category");
                    while (categoryIterator.hasNext()) {
                        Element categoryElement = (Element)categoryIterator.next();
                        double probability = Double.parseDouble(categoryElement.attributeValue("probability"));
                        VariationCategory category = new VariationCategory(probability);
                        Iterator optionIterator = categoryElement.elementIterator("option");
                        while (optionIterator.hasNext()) {
                            Element optionElement = (Element)optionIterator.next();
                            int optionId = Integer.parseInt(optionElement.attributeValue("id"));
                            if (OptionDataHolder.getInstance().getTemplate(optionId) == null) {
                                this.warn("Cannot find option ID: " + optionId + " for variation ID: " + variationId);
                                continue;
                            }
                            double chance = Double.parseDouble(optionElement.attributeValue("chance"));
                            category.addOption(new VariationOption(optionId, chance));
                        }
                        variation.addCategory(category);
                    }
                    stone.addVariation(variation);
                }
                ((VariationDataHolder)this.getHolder()).addStone(type, stone);
            }
        }
        iterator = rootElement.elementIterator("group");
        while (iterator.hasNext()) {
            element = (Element)iterator.next();
            int groupId = Integer.parseInt(element.attributeValue("id"));
            VariationGroup group = new VariationGroup(groupId);
            Iterator feeIterator = element.elementIterator("fee");
            while (feeIterator.hasNext()) {
                Element feeElement = (Element)feeIterator.next();
                int stoneId = Integer.parseInt(feeElement.attributeValue("stone_id"));
                int feeItemId = Integer.parseInt(feeElement.attributeValue("fee_item_id"));
                long feeItemCount = Long.parseLong(feeElement.attributeValue("fee_item_count"));
                long cancelFee = Long.parseLong(feeElement.attributeValue("cancel_fee"));
                group.addFee(new VariationFee(stoneId, feeItemId, feeItemCount, cancelFee));
            }
            ((VariationDataHolder)this.getHolder()).addGroup(group);
        }
    }
}


package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.HashSet;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.commons.string.StringArrayUtils;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.EnchantItemHolder;
import l2s.gameserver.templates.item.ItemGrade;
import l2s.gameserver.templates.item.support.EnchantScroll;
import l2s.gameserver.templates.item.support.EnchantType;
import l2s.gameserver.templates.item.support.EnchantVariation;
import l2s.gameserver.templates.item.support.FailResultType;
import org.dom4j.Element;

public class EnchantItemParser
extends AbstractParser<EnchantItemHolder> {
    private static EnchantItemParser _instance = new EnchantItemParser();

    public static EnchantItemParser getInstance() {
        return _instance;
    }

    private EnchantItemParser() {
        super(EnchantItemHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/enchant_items.xml");
    }

    public String getDTDFileName() {
        return "enchant_items.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        int defaultMaxEnchant = 0;
        boolean defaultFailEffect = false;
        Element defaultElement = rootElement.element("default");
        if (defaultElement != null) {
            defaultMaxEnchant = Integer.parseInt(defaultElement.attributeValue("max_enchant"));
            defaultFailEffect = Boolean.parseBoolean(defaultElement.attributeValue("show_fail_effect"));
        }
        Iterator iterator1 = rootElement.elementIterator("chance_variations");
        while (iterator1.hasNext()) {
            Element element1 = (Element)iterator1.next();
            Iterator iterator2 = element1.elementIterator("variation");
            while (iterator2.hasNext()) {
                Element element2 = (Element)iterator2.next();
                EnchantVariation variation = new EnchantVariation(Integer.parseInt(element2.attributeValue("id")));
                Iterator iterator3 = element2.elementIterator("enchant");
                while (iterator3.hasNext()) {
                    boolean succVisualEffect;
                    Element element3 = (Element)iterator3.next();
                    int[] enchantLvl = StringArrayUtils.stringToIntArray((String)element3.attributeValue("level"), (String)"-");
                    double baseChance = Double.parseDouble(element3.attributeValue("base_chance"));
                    double magicWeaponChance = element3.attributeValue("magic_weapon_chance") == null ? baseChance : Double.parseDouble(element3.attributeValue("magic_weapon_chance"));
                    double fullBodyChance = element3.attributeValue("full_body_armor_chance") == null ? baseChance : Double.parseDouble(element3.attributeValue("full_body_armor_chance"));
                    boolean bl = succVisualEffect = element3.attributeValue("success_visual_effect") == null ? false : Boolean.parseBoolean(element3.attributeValue("success_visual_effect"));
                    if (enchantLvl.length == 2) {
                        for (int i = enchantLvl[0]; i <= enchantLvl[1]; ++i) {
                            variation.addLevel(new EnchantVariation.EnchantLevel(i, baseChance, magicWeaponChance, fullBodyChance, succVisualEffect));
                        }
                        continue;
                    }
                    variation.addLevel(new EnchantVariation.EnchantLevel(enchantLvl[0], baseChance, magicWeaponChance, fullBodyChance, succVisualEffect));
                }
                ((EnchantItemHolder)this.getHolder()).addEnchantVariation(variation);
            }
        }
        Iterator iterator = rootElement.elementIterator("enchant_scroll");
        while (iterator.hasNext()) {
            String[] grades;
            String[] stringArray;
            Element enchantItemElement = (Element)iterator.next();
            int itemId = Integer.parseInt(enchantItemElement.attributeValue("id"));
            int variation = Integer.parseInt(enchantItemElement.attributeValue("variation"));
            int minEnchant = enchantItemElement.attributeValue("min_enchant") == null ? 0 : Integer.parseInt(enchantItemElement.attributeValue("min_enchant"));
            int maxEnchant = enchantItemElement.attributeValue("max_enchant") == null ? defaultMaxEnchant : Integer.parseInt(enchantItemElement.attributeValue("max_enchant"));
            FailResultType resultType = FailResultType.valueOf(enchantItemElement.attributeValue("on_fail"));
            int enchantDropCount = enchantItemElement.attributeValue("enchant_drop_count") == null ? Integer.MAX_VALUE : Integer.parseInt(enchantItemElement.attributeValue("enchant_drop_count"));
            EnchantType enchantType = enchantItemElement.attributeValue("type") == null ? EnchantType.ALL : EnchantType.valueOf(enchantItemElement.attributeValue("type"));
            HashSet<ItemGrade> gradesSet = new HashSet<ItemGrade>();
            if (enchantItemElement.attributeValue("grade") == null) {
                String[] stringArray2 = new String[1];
                stringArray = stringArray2;
                stringArray2[0] = "NONE";
            } else {
                stringArray = enchantItemElement.attributeValue("grade").split(";");
            }
            for (String grade : grades = stringArray) {
                gradesSet.add(ItemGrade.valueOf(grade.toUpperCase()));
            }
            boolean failEffect = enchantItemElement.attributeValue("show_fail_effect") == null ? defaultFailEffect : Boolean.parseBoolean(enchantItemElement.attributeValue("show_fail_effect"));
            int minEnchantStep = enchantItemElement.attributeValue("min_enchant_step") == null ? 1 : Integer.parseInt(enchantItemElement.attributeValue("min_enchant_step"));
            int maxEnchantStep = enchantItemElement.attributeValue("max_enchant_step") == null ? 1 : Integer.parseInt(enchantItemElement.attributeValue("max_enchant_step"));
            EnchantScroll item = new EnchantScroll(itemId, variation, minEnchant, maxEnchant, enchantType, gradesSet, resultType, enchantDropCount, failEffect, minEnchantStep, maxEnchantStep);
            Iterator iterator2 = enchantItemElement.elementIterator();
            while (iterator2.hasNext()) {
                Element element2 = (Element)iterator2.next();
                if (!element2.getName().equals("item_list")) continue;
                for (Element e : element2.elements()) {
                    item.addItemId(Integer.parseInt(e.attributeValue("id")));
                }
            }
            ((EnchantItemHolder)this.getHolder()).addEnchantScroll(item);
        }
    }
}


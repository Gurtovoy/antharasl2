package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.HashSet;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.EnchantStoneHolder;
import l2s.gameserver.templates.item.ItemGrade;
import l2s.gameserver.templates.item.support.EnchantStone;
import l2s.gameserver.templates.item.support.EnchantType;
import l2s.gameserver.templates.item.support.FailResultType;
import org.dom4j.Element;

public class EnchantStoneParser
extends AbstractParser<EnchantStoneHolder> {
    private static EnchantStoneParser _instance = new EnchantStoneParser();

    public static EnchantStoneParser getInstance() {
        return _instance;
    }

    private EnchantStoneParser() {
        super(EnchantStoneHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/enchant_stones.xml");
    }

    public String getDTDFileName() {
        return "enchant_stones.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        int defaultMinEnchantLevel = 0;
        int defaultMinFullbodyEnchantLevel = 0;
        int defaultMaxEnchantLevel = 0;
        FailResultType defaultResultType = FailResultType.CRYSTALS;
        Element defaultElement = rootElement.element("default");
        if (defaultElement != null) {
            defaultResultType = FailResultType.valueOf(defaultElement.attributeValue("on_fail"));
            defaultMinEnchantLevel = Integer.parseInt(defaultElement.attributeValue("min_enchant_level"));
            defaultMinFullbodyEnchantLevel = Integer.parseInt(defaultElement.attributeValue("min_fullbody_enchant_level"));
            defaultMaxEnchantLevel = Integer.parseInt(defaultElement.attributeValue("max_enchant_level"));
        }
        Iterator iterator = rootElement.elementIterator("enchant_stone");
        while (iterator.hasNext()) {
            String[] grades;
            String[] stringArray;
            Element enchantStoneElement = (Element)iterator.next();
            int itemId = Integer.parseInt(enchantStoneElement.attributeValue("id"));
            double chance = Integer.parseInt(enchantStoneElement.attributeValue("chance"));
            HashSet<ItemGrade> gradesSet = new HashSet<ItemGrade>();
            if (enchantStoneElement.attributeValue("grade") == null) {
                String[] stringArray2 = new String[1];
                stringArray = stringArray2;
                stringArray2[0] = "NONE";
            } else {
                stringArray = enchantStoneElement.attributeValue("grade").split(";");
            }
            for (String grade : grades = stringArray) {
                gradesSet.add(ItemGrade.valueOf(grade.toUpperCase()));
            }
            EnchantType type = enchantStoneElement.attributeValue("type") == null ? EnchantType.ALL : EnchantType.valueOf(enchantStoneElement.attributeValue("type"));
            FailResultType resultType = enchantStoneElement.attributeValue("on_fail") == null ? defaultResultType : FailResultType.valueOf(enchantStoneElement.attributeValue("on_fail"));
            int enchantDropCount = enchantStoneElement.attributeValue("enchant_drop_count") == null ? Integer.MAX_VALUE : Integer.parseInt(enchantStoneElement.attributeValue("enchant_drop_count"));
            int minEnchantLevel = enchantStoneElement.attributeValue("min_enchant_level") == null ? defaultMinEnchantLevel : Integer.parseInt(enchantStoneElement.attributeValue("min_enchant_level"));
            int minFullbodyEnchantLevel = enchantStoneElement.attributeValue("min_fullbody_enchant_level") == null ? Math.max(minEnchantLevel, defaultMinFullbodyEnchantLevel) : Integer.parseInt(enchantStoneElement.attributeValue("min_fullbody_enchant_level"));
            int maxEnchantLevel = enchantStoneElement.attributeValue("max_enchant_level") == null ? defaultMaxEnchantLevel : Integer.parseInt(enchantStoneElement.attributeValue("max_enchant_level"));
            int minEnchantStep = enchantStoneElement.attributeValue("min_enchant_step") == null ? 1 : Integer.parseInt(enchantStoneElement.attributeValue("min_enchant_step"));
            int maxEnchantStep = enchantStoneElement.attributeValue("max_enchant_step") == null ? 1 : Integer.parseInt(enchantStoneElement.attributeValue("max_enchant_step"));
            ((EnchantStoneHolder)this.getHolder()).addEnchantStone(new EnchantStone(itemId, chance, type, gradesSet, resultType, enchantDropCount, minEnchantLevel, minFullbodyEnchantLevel, maxEnchantLevel, minEnchantStep, maxEnchantStep));
        }
    }
}


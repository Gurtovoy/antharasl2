package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.AppearanceStoneHolder;
import l2s.gameserver.templates.item.ExItemType;
import l2s.gameserver.templates.item.ItemGrade;
import l2s.gameserver.templates.item.support.AppearanceStone;
import org.dom4j.Element;

public class AppearanceStoneParser
extends AbstractParser<AppearanceStoneHolder> {
    private static AppearanceStoneParser _instance = new AppearanceStoneParser();

    public static AppearanceStoneParser getInstance() {
        return _instance;
    }

    private AppearanceStoneParser() {
        super(AppearanceStoneHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/appearance_stones.xml");
    }

    public String getDTDFileName() {
        return "appearance_stones.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Element stoneElement;
        Iterator iterator = rootElement.elementIterator("config");
        while (iterator.hasNext()) {
            stoneElement = (Element)iterator.next();
            Config.APPEARANCE_STONE_CHECK_ARMOR_TYPE = Boolean.parseBoolean(stoneElement.attributeValue("check_armor_type"));
        }
        iterator = rootElement.elementIterator("stone");
        while (iterator.hasNext()) {
            stoneElement = (Element)iterator.next();
            int itemId = Integer.parseInt(stoneElement.attributeValue("id"));
            String[] targetTypesStr = stoneElement.attributeValue("target_type").split(",");
            AppearanceStone.ShapeTargetType[] targetTypes = new AppearanceStone.ShapeTargetType[targetTypesStr.length];
            for (int i = 0; i < targetTypesStr.length; ++i) {
                targetTypes[i] = AppearanceStone.ShapeTargetType.valueOf(targetTypesStr[i].toUpperCase());
            }
            AppearanceStone.ShapeType type = AppearanceStone.ShapeType.valueOf(stoneElement.attributeValue("shifting_type").toUpperCase());
            String[] gradesStr = stoneElement.attributeValue("grade") == null ? new String[]{} : stoneElement.attributeValue("grade").split(",");
            ItemGrade[] grades = new ItemGrade[gradesStr.length];
            for (int i = 0; i < gradesStr.length; ++i) {
                grades[i] = ItemGrade.valueOf(gradesStr[i].toUpperCase());
            }
            long cost = stoneElement.attributeValue("cost") == null ? 0L : Long.parseLong(stoneElement.attributeValue("cost"));
            int extractItemId = stoneElement.attributeValue("extract_id") == null ? 0 : Integer.parseInt(stoneElement.attributeValue("extract_id"));
            String[] itemTypesStr = stoneElement.attributeValue("item_type") == null ? new String[]{} : stoneElement.attributeValue("item_type").split(",");
            ExItemType[] itemTypes = new ExItemType[itemTypesStr.length];
            for (int i = 0; i < itemTypesStr.length; ++i) {
                itemTypes[i] = ExItemType.valueOf(itemTypesStr[i].toUpperCase());
            }
            int period = stoneElement.attributeValue("period") == null ? -1 : Integer.parseInt(stoneElement.attributeValue("period"));
            AppearanceStone stone = new AppearanceStone(itemId, targetTypes, type, grades, cost, extractItemId, itemTypes, period);
            Iterator skillIterator = stoneElement.elementIterator("skill");
            while (skillIterator.hasNext()) {
                Element skillElement = (Element)skillIterator.next();
                int skillId = Integer.parseInt(skillElement.attributeValue("id"));
                int skillLevel = Integer.parseInt(skillElement.attributeValue("level"));
                stone.addSkill(skillId, skillLevel);
            }
            ((AppearanceStoneHolder)this.getHolder()).addAppearanceStone(stone);
        }
    }
}


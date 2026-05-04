package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.FakeItemHolder;
import l2s.gameserver.templates.item.ArmorTemplate;
import l2s.gameserver.templates.item.ItemGrade;
import org.dom4j.Element;
import org.napile.primitive.lists.IntList;
import org.napile.primitive.lists.impl.ArrayIntList;

public class FakeItemParser
extends AbstractParser<FakeItemHolder> {
    private static FakeItemParser ourInstance = new FakeItemParser();

    public static FakeItemParser getInstance() {
        return ourInstance;
    }

    private FakeItemParser() {
        super(FakeItemHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/fake_players/fake_item.xml");
    }

    public String getDTDFileName() {
        return "fake_item.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            if ("category".equalsIgnoreCase(element.getName())) {
                ItemGrade grade = ItemGrade.valueOf(element.attributeValue("grade"));
                Iterator subIterator = element.elementIterator();
                while (subIterator.hasNext()) {
                    Element subElement = (Element)subIterator.next();
                    if ("weapons".equalsIgnoreCase(subElement.getName())) {
                        ((FakeItemHolder)this.getHolder()).addWeapons(grade, FakeItemParser.parseItems(subElement));
                        continue;
                    }
                    if ("armors".equalsIgnoreCase(subElement.getName())) {
                        ((FakeItemHolder)this.getHolder()).addArmors(grade, FakeItemParser.parsePackArmors(subElement));
                        continue;
                    }
                    if (!"accessorys".equalsIgnoreCase(subElement.getName())) continue;
                    ((FakeItemHolder)this.getHolder()).addAccessorys(grade, FakeItemParser.parsePackAccessorys(subElement));
                }
                continue;
            }
            if ("classes".equalsIgnoreCase(element.getName())) {
                Iterator subIterator = element.elementIterator();
                while (subIterator.hasNext()) {
                    Element subElement = (Element)subIterator.next();
                    if (!"class".equalsIgnoreCase(subElement.getName())) continue;
                    int classId = Integer.parseInt(subElement.attributeValue("id"));
                    String weaponTypes = subElement.attributeValue("weaponTypes");
                    String armorTypes = subElement.attributeValue("armorTypes");
                    ((FakeItemHolder)this.getHolder()).addClassWeaponAndArmors(classId, weaponTypes, armorTypes);
                }
                continue;
            }
            if ("hair_accessories".equalsIgnoreCase(element.getName())) {
                ((FakeItemHolder)this.getHolder()).addHairAccessories(FakeItemParser.parseItems(element));
                continue;
            }
            if (!"cloaks".equalsIgnoreCase(element.getName())) continue;
            ((FakeItemHolder)this.getHolder()).addCloaks(FakeItemParser.parseItems(element));
        }
    }

    private static IntList parseItems(Element rootElement) {
        ArrayIntList list = new ArrayIntList();
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            if (!element.getName().equals("item")) continue;
            int itemId = Integer.parseInt(element.attributeValue("id"));
            list.add(itemId);
        }
        return list;
    }

    private static Map<ArmorTemplate.ArmorType, List<IntList>> parsePackArmors(Element rootElement) {
        HashMap<ArmorTemplate.ArmorType, List<IntList>> map = new HashMap<ArmorTemplate.ArmorType, List<IntList>>();
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            if (!element.getName().equals("pack")) continue;
            ArmorTemplate.ArmorType type = ArmorTemplate.ArmorType.valueOf(element.attributeValue("type"));
            map.computeIfAbsent(type, k -> new ArrayList()).add(FakeItemParser.parseItems(element));
        }
        return map;
    }

    private static List<IntList> parsePackAccessorys(Element rootElement) {
        ArrayList<IntList> list = new ArrayList<IntList>();
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            if (!element.getName().equals("pack")) continue;
            list.add(FakeItemParser.parseItems(element));
        }
        return list;
    }
}


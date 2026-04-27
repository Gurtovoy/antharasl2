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
import java.util.StringTokenizer;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.PlayerTemplateHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.base.ClassType;
import l2s.gameserver.model.base.Race;
import l2s.gameserver.model.base.Sex;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.item.StartItem;
import l2s.gameserver.templates.player.HpMpCpData;
import l2s.gameserver.templates.player.PlayerTemplate;
import org.dom4j.Element;

public final class PlayerTemplateParser
extends AbstractParser<PlayerTemplateHolder> {
    private static final PlayerTemplateParser _instance = new PlayerTemplateParser();

    public static PlayerTemplateParser getInstance() {
        return _instance;
    }

    private PlayerTemplateParser() {
        super(PlayerTemplateHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/pc_parameters/template_data/");
    }

    public String getDTDFileName() {
        return "template_data.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            Race race = Race.valueOf(element.attributeValue("race").toUpperCase());
            Sex sex = Sex.valueOf(element.attributeValue("sex").toUpperCase());
            ClassType classtype = ClassType.valueOf(element.attributeValue("type").toUpperCase());
            StatsSet set = new StatsSet();
            Iterator subIterator = element.elementIterator();
            while (subIterator.hasNext()) {
                Element subElement = (Element)subIterator.next();
                if (!"stats_data".equalsIgnoreCase(subElement.getName())) continue;
                for (Element e : subElement.elements()) {
                    if ("min_attributes".equalsIgnoreCase(e.getName()) || "max_attributes".equalsIgnoreCase(e.getName()) || "base_attributes".equalsIgnoreCase(e.getName())) {
                        int _int = Integer.parseInt(e.attributeValue("int"));
                        int str = Integer.parseInt(e.attributeValue("str"));
                        int con = Integer.parseInt(e.attributeValue("con"));
                        int men = Integer.parseInt(e.attributeValue("men"));
                        int dex = Integer.parseInt(e.attributeValue("dex"));
                        int wit = Integer.parseInt(e.attributeValue("wit"));
                        if ("min_attributes".equalsIgnoreCase(e.getName())) {
                            set.set("minINT", _int);
                            set.set("minSTR", str);
                            set.set("minCON", con);
                            set.set("minMEN", men);
                            set.set("minDEX", dex);
                            set.set("minWIT", wit);
                            continue;
                        }
                        if ("max_attributes".equalsIgnoreCase(e.getName())) {
                            set.set("maxINT", _int);
                            set.set("maxSTR", str);
                            set.set("maxCON", con);
                            set.set("maxMEN", men);
                            set.set("maxDEX", dex);
                            set.set("maxWIT", wit);
                            continue;
                        }
                        if (!"base_attributes".equalsIgnoreCase(e.getName())) continue;
                        set.set("baseINT", _int);
                        set.set("baseSTR", str);
                        set.set("baseCON", con);
                        set.set("baseMEN", men);
                        set.set("baseDEX", dex);
                        set.set("baseWIT", wit);
                        continue;
                    }
                    if ("armor_defence".equalsIgnoreCase(e.getName())) {
                        set.set("baseChestDef", e.attributeValue("chest"));
                        set.set("baseLegsDef", e.attributeValue("legs"));
                        set.set("baseHelmetDef", e.attributeValue("helmet"));
                        set.set("baseBootsDef", e.attributeValue("boots"));
                        set.set("baseGlovesDef", e.attributeValue("gloves"));
                        set.set("basePendantDef", e.attributeValue("pendant"));
                        set.set("baseCloakDef", e.attributeValue("cloak"));
                        continue;
                    }
                    if ("jewel_defence".equalsIgnoreCase(e.getName())) {
                        set.set("baseREarDef", e.attributeValue("r_earring"));
                        set.set("baseLEarDef", e.attributeValue("l_earring"));
                        set.set("baseRRingDef", e.attributeValue("r_ring"));
                        set.set("baseLRingDef", e.attributeValue("l_ring"));
                        set.set("baseNecklaceDef", e.attributeValue("necklace"));
                        continue;
                    }
                    if (!"base_stats".equalsIgnoreCase(e.getName())) continue;
                    for (Element e2 : e.elements()) {
                        if (!"set".equalsIgnoreCase(e2.getName())) continue;
                        set.set(e2.attributeValue("name"), e2.attributeValue("value"));
                    }
                }
            }
            PlayerTemplate template = new PlayerTemplate(set, race, sex);
            Iterator subIterator2 = element.elementIterator();
            while (subIterator2.hasNext()) {
                Element subElement = (Element)subIterator2.next();
                if ("creation_data".equalsIgnoreCase(subElement.getName())) {
                    for (Element e : subElement.elements()) {
                        if ("start_equipments".equalsIgnoreCase(e.getName())) {
                            for (Element e2 : e.elements()) {
                                if (!"equipment".equalsIgnoreCase(e2.getName())) continue;
                                int item_id = Integer.parseInt(e2.attributeValue("item_id"));
                                long count = Long.parseLong(e2.attributeValue("count"));
                                boolean equiped = Boolean.parseBoolean(e2.attributeValue("equiped"));
                                int enchant_level = e2.attributeValue("enchant_level") == null ? 0 : Integer.parseInt(e2.attributeValue("enchant_level"));
                                template.addStartItem(new StartItem(item_id, count, equiped, enchant_level));
                            }
                            continue;
                        }
                        if (!"start_points".equalsIgnoreCase(e.getName())) continue;
                        for (Element e2 : e.elements()) {
                            if (!"point".equalsIgnoreCase(e2.getName())) continue;
                            template.addStartLocation(Location.parse(e2));
                        }
                    }
                    continue;
                }
                if (!"stats_data".equalsIgnoreCase(subElement.getName())) continue;
                for (Element e : subElement.elements()) {
                    if (!"base_stats".equalsIgnoreCase(e.getName())) continue;
                    for (Element e2 : e.elements()) {
                        if (!"regen_data".equalsIgnoreCase(e2.getName())) continue;
                        for (Element e3 : e2.elements()) {
                            int minLevel;
                            if (!"regen".equalsIgnoreCase(e3.getName())) continue;
                            StringTokenizer st = new StringTokenizer(e3.attributeValue("level"), "-");
                            int maxLevel = minLevel = Integer.parseInt(st.nextToken());
                            if (st.hasMoreTokens()) {
                                maxLevel = Integer.parseInt(st.nextToken());
                            }
                            double hp = Double.parseDouble(e3.attributeValue("hp"));
                            double mp = Double.parseDouble(e3.attributeValue("mp"));
                            double cp = Double.parseDouble(e3.attributeValue("cp"));
                            for (int i = minLevel; i <= maxLevel; ++i) {
                                template.addRegenData(i, new HpMpCpData(hp, mp, cp));
                            }
                        }
                    }
                }
            }
            ((PlayerTemplateHolder)this.getHolder()).addPlayerTemplate(race, classtype, sex, template);
        }
    }
}


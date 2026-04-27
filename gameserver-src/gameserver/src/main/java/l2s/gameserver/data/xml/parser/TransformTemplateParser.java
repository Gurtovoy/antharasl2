/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.data.xml.AbstractHolder
 *  l2s.commons.data.xml.AbstractParser
 *  l2s.commons.string.StringArrayUtils
 *  org.dom4j.Element
 */
package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.commons.string.StringArrayUtils;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.TransformTemplateHolder;
import l2s.gameserver.model.SkillLearn;
import l2s.gameserver.model.base.Sex;
import l2s.gameserver.model.base.TransformType;
import l2s.gameserver.model.items.LockType;
import l2s.gameserver.templates.BaseStatsBonus;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.player.HpMpCpData;
import l2s.gameserver.templates.player.transform.TransformTemplate;
import org.dom4j.Element;

public final class TransformTemplateParser
extends AbstractParser<TransformTemplateHolder> {
    private static final TransformTemplateParser _instance = new TransformTemplateParser();

    public static TransformTemplateParser getInstance() {
        return _instance;
    }

    private TransformTemplateParser() {
        super(TransformTemplateHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/pc_parameters/transform_data/");
    }

    public String getDTDFileName() {
        return "transform_data.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            int id = Integer.parseInt(element.attributeValue("id"));
            TransformType type = TransformType.valueOf(element.attributeValue("type").toUpperCase());
            boolean can_swim = Boolean.parseBoolean(element.attributeValue("can_swim"));
            int spawn_height = element.attributeValue("spawn_height") == null ? 0 : Integer.parseInt(element.attributeValue("spawn_height"));
            boolean normal_attackable = Boolean.parseBoolean(element.attributeValue("normal_attackable"));
            Iterator sexIterator = element.elementIterator();
            while (sexIterator.hasNext()) {
                Element sexElement = (Element)sexIterator.next();
                if (!"male".equalsIgnoreCase(sexElement.getName()) && !"female".equalsIgnoreCase(sexElement.getName())) continue;
                StatsSet set = TransformTemplate.getEmptyStatsSet();
                Sex sex = Sex.valueOf(sexElement.getName().toUpperCase());
                set.set("id", id);
                set.set("type", type);
                set.set("can_swim", can_swim);
                set.set("spawn_height", spawn_height);
                set.set("normal_attackable", normal_attackable);
                set.set("sex", sex);
                for (Element e : sexElement.elements()) {
                    if ("base_attributes".equalsIgnoreCase(e.getName())) {
                        set.set("baseINT", Integer.parseInt(e.attributeValue("int")));
                        set.set("baseSTR", Integer.parseInt(e.attributeValue("str")));
                        set.set("baseCON", Integer.parseInt(e.attributeValue("con")));
                        set.set("baseMEN", Integer.parseInt(e.attributeValue("men")));
                        set.set("baseDEX", Integer.parseInt(e.attributeValue("dex")));
                        set.set("baseWIT", Integer.parseInt(e.attributeValue("wit")));
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
                    if (!"set".equalsIgnoreCase(e.getName())) continue;
                    set.set(e.attributeValue("name"), e.attributeValue("value"));
                }
                TransformTemplate template = new TransformTemplate(set);
                for (Element e : sexElement.elements()) {
                    int value;
                    int skill_level;
                    int skill_id;
                    Element skillElement;
                    Iterator skillIterator;
                    if ("actions".equalsIgnoreCase(e.getName())) {
                        String[] actions;
                        for (String action : actions = e.getText().split(" ")) {
                            template.addAction(Integer.parseInt(action));
                        }
                        continue;
                    }
                    if ("item_check".equalsIgnoreCase(e.getName())) {
                        LockType check_action = LockType.valueOf(e.attributeValue("action").toUpperCase());
                        int[] check_items = StringArrayUtils.stringToIntArray((String)e.getText(), (String)" ");
                        template.setItemCheck(check_action, check_items);
                        continue;
                    }
                    if ("skills".equalsIgnoreCase(e.getName())) {
                        skillIterator = e.elementIterator("skill");
                        while (skillIterator.hasNext()) {
                            skillElement = (Element)skillIterator.next();
                            skill_id = Integer.parseInt(skillElement.attributeValue("id"));
                            skill_level = skillElement.attributeValue("level") == null ? 1 : Integer.parseInt(skillElement.attributeValue("level"));
                            template.addSkill(new SkillLearn(skill_id, skill_level, 0, 0, 0, 0L, false, null));
                        }
                        continue;
                    }
                    if ("additional_skills".equalsIgnoreCase(e.getName())) {
                        skillIterator = e.elementIterator("skill");
                        while (skillIterator.hasNext()) {
                            skillElement = (Element)skillIterator.next();
                            skill_id = Integer.parseInt(skillElement.attributeValue("id"));
                            skill_level = skillElement.attributeValue("level") == null ? 1 : Integer.parseInt(skillElement.attributeValue("level"));
                            int skill_min_level = skillElement.attributeValue("min_level") == null ? 1 : Integer.parseInt(skillElement.attributeValue("min_level"));
                            template.addAddtionalSkill(new SkillLearn(skill_id, skill_level, skill_min_level, 0, 0, 0L, false, null));
                        }
                        continue;
                    }
                    if ("base_stats_bonus".equalsIgnoreCase(e.getName())) {
                        for (Element e2 : e.elements()) {
                            if (!"bonus".equalsIgnoreCase(e2.getName())) continue;
                            value = Integer.parseInt(e2.attributeValue("value"));
                            int str = Integer.parseInt(e2.attributeValue("str"));
                            int dex = Integer.parseInt(e2.attributeValue("dex"));
                            int con = Integer.parseInt(e2.attributeValue("con"));
                            int _int = Integer.parseInt(e2.attributeValue("int"));
                            int men = Integer.parseInt(e2.attributeValue("men"));
                            int wit = Integer.parseInt(e2.attributeValue("wit"));
                            template.addBaseStatsBonus(value, new BaseStatsBonus(_int, str, con, men, dex, wit));
                        }
                        continue;
                    }
                    if (!"level_data".equalsIgnoreCase(e.getName())) continue;
                    for (Element e2 : e.elements()) {
                        if (!"level".equalsIgnoreCase(e2.getName())) continue;
                        value = Integer.parseInt(e2.attributeValue("value"));
                        double mod = Double.parseDouble(e2.attributeValue("mod"));
                        double hp = Double.parseDouble(e2.attributeValue("hp"));
                        double mp = Double.parseDouble(e2.attributeValue("mp"));
                        double cp = Double.parseDouble(e2.attributeValue("cp"));
                        double hp_regen = Double.parseDouble(e2.attributeValue("hp_regen"));
                        double mp_regen = Double.parseDouble(e2.attributeValue("mp_regen"));
                        double cp_regen = Double.parseDouble(e2.attributeValue("cp_regen"));
                        template.addLevelBonus(value, mod);
                        template.addHpMpCpData(value, new HpMpCpData(hp, mp, cp));
                        template.addRegenData(value, new HpMpCpData(hp_regen, mp_regen, cp_regen));
                    }
                }
                ((TransformTemplateHolder)this.getHolder()).addTemplate(sex, template);
            }
        }
    }
}


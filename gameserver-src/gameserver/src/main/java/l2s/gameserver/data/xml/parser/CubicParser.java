/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.CubicHolder;
import l2s.gameserver.templates.cubic.CubicSkillInfo;
import l2s.gameserver.templates.cubic.CubicTargetType;
import l2s.gameserver.templates.cubic.CubicTemplate;
import l2s.gameserver.templates.cubic.CubicUseUpType;
import org.dom4j.Element;

public final class CubicParser
extends AbstractParser<CubicHolder> {
    private static CubicParser _instance = new CubicParser();

    public static CubicParser getInstance() {
        return _instance;
    }

    protected CubicParser() {
        super(CubicHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/cubics.xml");
    }

    public String getDTDFileName() {
        return "cubics.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            int id = Integer.parseInt(element.attributeValue("id"));
            int level = Integer.parseInt(element.attributeValue("level"));
            int slot = element.attributeValue("slot") == null ? id : Integer.parseInt(element.attributeValue("slot"));
            int duration = element.attributeValue("duration") == null ? -1 : Integer.parseInt(element.attributeValue("duration"));
            int delay = element.attributeValue("delay") == null ? 0 : Integer.parseInt(element.attributeValue("delay"));
            int max_count = element.attributeValue("max_count") == null ? Integer.MAX_VALUE : Integer.parseInt(element.attributeValue("max_count"));
            CubicUseUpType use_up = element.attributeValue("use_up") == null ? CubicUseUpType.INCREASE_DELAY : CubicUseUpType.valueOf(element.attributeValue("use_up").toUpperCase());
            double power = element.attributeValue("power") == null ? 0.0 : Double.parseDouble(element.attributeValue("power"));
            CubicTargetType target_type = element.attributeValue("target_type") == null ? CubicTargetType.BY_SKILL : CubicTargetType.valueOf(element.attributeValue("target_type").toUpperCase());
            CubicTemplate template = new CubicTemplate(id, level, slot, duration, delay, max_count, use_up, power, target_type);
            CubicParser.parseSkills(this, template, element);
            ((CubicHolder)this.getHolder()).addCubicTemplate(template);
        }
    }

    public static void parseSkills(AbstractParser<?> parser, CubicTemplate template, Element element) {
        Element skillElement;
        Iterator skillIterator = element.elementIterator("skill");
        while (skillIterator.hasNext()) {
            CubicSkillInfo skillInfo;
            int skillChance;
            skillElement = (Element)skillIterator.next();
            int n = skillChance = skillElement.attributeValue("chance") == null ? 100 : Integer.parseInt(skillElement.attributeValue("chance"));
            if (skillChance <= 0) {
                parser.warn("Wrong skill chance. Cubic: " + template.getId() + "/" + template.getLevel());
            }
            if ((skillInfo = CubicSkillInfo.parse(skillElement)) == null) continue;
            if (skillInfo.getChance() <= 0 && skillInfo.getChances().isEmpty()) {
                parser.warn("Wrong skill use chance. Cubic: " + template.getId() + "/" + template.getLevel());
            }
            template.putSkill(skillInfo, skillChance);
        }
        skillIterator = element.elementIterator("time_skill");
        while (skillIterator.hasNext()) {
            skillElement = (Element)skillIterator.next();
            CubicSkillInfo skillInfo = CubicSkillInfo.parse(skillElement);
            if (skillInfo == null) continue;
            if (skillInfo.getChance() <= 0 && skillInfo.getChances().isEmpty()) {
                parser.warn("Wrong time skill use chance. Cubic: " + template.getId() + "/" + template.getLevel());
            }
            template.putTimeSkill(skillInfo);
        }
    }
}


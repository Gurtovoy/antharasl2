/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.SkillAcquireHolder;
import l2s.gameserver.data.xml.parser.StatParser;
import l2s.gameserver.model.SkillLearn;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.model.base.ClassLevel;
import l2s.gameserver.model.base.Race;
import l2s.gameserver.stats.conditions.Condition;
import org.dom4j.Element;

public final class SkillAcquireParser
extends StatParser<SkillAcquireHolder> {
    private static final SkillAcquireParser _instance = new SkillAcquireParser();

    public static SkillAcquireParser getInstance() {
        return _instance;
    }

    protected SkillAcquireParser() {
        super(SkillAcquireHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/skill_tree/");
    }

    public String getDTDFileName() {
        return "tree.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Set<SkillLearn> learns;
        Element classElement;
        Iterator classIterator;
        Element nxt;
        Iterator iterator = rootElement.elementIterator("sub_unit_skill_tree");
        while (iterator.hasNext()) {
            ((SkillAcquireHolder)this.getHolder()).addAllSubUnitLearns(this.parseSkillLearn((Element)iterator.next()));
        }
        iterator = rootElement.elementIterator("pledge_skill_tree");
        while (iterator.hasNext()) {
            ((SkillAcquireHolder)this.getHolder()).addAllPledgeLearns(this.parseSkillLearn((Element)iterator.next()));
        }
        iterator = rootElement.elementIterator("fishing_skill_tree");
        while (iterator.hasNext()) {
            ((SkillAcquireHolder)this.getHolder()).addAllFishingLearns(this.parseSkillLearn((Element)iterator.next()));
        }
        iterator = rootElement.elementIterator("hero_skill_tree");
        while (iterator.hasNext()) {
            ((SkillAcquireHolder)this.getHolder()).addAllHeroLearns(this.parseSkillLearn((Element)iterator.next()));
        }
        iterator = rootElement.elementIterator("gm_skill_tree");
        while (iterator.hasNext()) {
            ((SkillAcquireHolder)this.getHolder()).addAllGMLearns(this.parseSkillLearn((Element)iterator.next()));
        }
        iterator = rootElement.elementIterator("custom_skill_tree");
        while (iterator.hasNext()) {
            ((SkillAcquireHolder)this.getHolder()).addAllCustomLearns(this.parseSkillLearn((Element)iterator.next()));
        }
        iterator = rootElement.elementIterator("normal_skill_tree");
        while (iterator.hasNext()) {
            nxt = (Element)iterator.next();
            classIterator = nxt.elementIterator("class");
            while (classIterator.hasNext()) {
                classElement = (Element)classIterator.next();
                if (classElement.attributeValue("id") != null) {
                    int classId = Integer.parseInt(classElement.attributeValue("id"));
                    learns = this.parseSkillLearn(classElement, ClassId.VALUES[classId].getClassLevel());
                    ((SkillAcquireHolder)this.getHolder()).addAllNormalSkillLearns(classId, learns);
                }
                if (classElement.attributeValue("level") == null) continue;
                ClassLevel classLevel = ClassLevel.valueOf(classElement.attributeValue("level").toUpperCase());
                learns = this.parseSkillLearn(classElement, classLevel);
                for (ClassId classId : ClassId.VALUES) {
                    if (!classId.isOfLevel(classLevel)) continue;
                    ((SkillAcquireHolder)this.getHolder()).addAllNormalSkillLearns(classId.getId(), learns);
                }
            }
        }
        iterator = rootElement.elementIterator("general_skill_tree");
        while (iterator.hasNext()) {
            nxt = (Element)iterator.next();
            ((SkillAcquireHolder)this.getHolder()).addAllGeneralSkillLearns(-1, this.parseSkillLearn(nxt));
            classIterator = nxt.elementIterator("class");
            while (classIterator.hasNext()) {
                classElement = (Element)classIterator.next();
                if (classElement.attributeValue("id") != null) {
                    int classId = Integer.parseInt(classElement.attributeValue("id"));
                    learns = this.parseSkillLearn(classElement, ClassId.VALUES[classId].getClassLevel());
                    ((SkillAcquireHolder)this.getHolder()).addAllGeneralSkillLearns(classId, learns);
                }
                if (classElement.attributeValue("level") == null) continue;
                ClassLevel classLevel = ClassLevel.valueOf(classElement.attributeValue("level").toUpperCase());
                learns = this.parseSkillLearn(classElement, classLevel);
                for (ClassId classId : ClassId.VALUES) {
                    if (!classId.isOfLevel(classLevel)) continue;
                    ((SkillAcquireHolder)this.getHolder()).addAllGeneralSkillLearns(classId.getId(), learns);
                }
            }
        }
    }

    protected void onParsed() {
        ((SkillAcquireHolder)this.getHolder()).initNormalSkillLearns();
        ((SkillAcquireHolder)this.getHolder()).initGeneralSkillLearns();
    }

    private Set<SkillLearn> parseSkillLearn(Element tree, ClassLevel classLevel) {
        HashSet<SkillLearn> skillLearns = new HashSet<SkillLearn>();
        Iterator iterator = tree.elementIterator("skill");
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            int id = Integer.parseInt(element.attributeValue("id"));
            int level = element.attributeValue("level") == null ? 1 : Integer.parseInt(element.attributeValue("level"));
            int cost = element.attributeValue("cost") == null ? 0 : Integer.parseInt(element.attributeValue("cost"));
            int min_level = element.attributeValue("min_level") == null ? 1 : Integer.parseInt(element.attributeValue("min_level"));
            int item_id = element.attributeValue("item_id") == null ? 0 : Integer.parseInt(element.attributeValue("item_id"));
            long item_count = element.attributeValue("item_count") == null ? 1L : Long.parseLong(element.attributeValue("item_count"));
            boolean auto_get = element.attributeValue("auto_get") == null ? true : Boolean.parseBoolean(element.attributeValue("auto_get"));
            Race race = element.attributeValue("race") == null ? null : Race.valueOf(element.attributeValue("race"));
            SkillLearn skillLearn = new SkillLearn(id, level, min_level, cost, item_id, item_count, auto_get, race, classLevel);
            Condition condition = this.parseFirstCond(element, new int[0]);
            if (condition != null) {
                skillLearn.addCondition(condition);
            }
            skillLearns.add(skillLearn);
        }
        return skillLearns;
    }

    private Set<SkillLearn> parseSkillLearn(Element tree) {
        return this.parseSkillLearn(tree, ClassLevel.NONE);
    }

    @Override
    protected Object getTableValue(String name, int ... arg) {
        return null;
    }
}


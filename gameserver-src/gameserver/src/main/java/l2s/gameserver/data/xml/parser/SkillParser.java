/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Map;
import java.util.StringTokenizer;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.data.xml.parser.StatParser;
import l2s.gameserver.model.Skill;
import l2s.gameserver.skills.EffectTargetType;
import l2s.gameserver.skills.EffectUseType;
import l2s.gameserver.stats.StatTemplate;
import l2s.gameserver.stats.conditions.Condition;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.skill.EffectTemplate;
import l2s.gameserver.templates.skill.restoration.RestorationGroup;
import l2s.gameserver.templates.skill.restoration.RestorationInfo;
import l2s.gameserver.templates.skill.restoration.RestorationItem;
import org.dom4j.Element;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.TreeIntObjectMap;

public final class SkillParser
extends StatParser<SkillHolder> {
    private static final SkillParser _instance = new SkillParser();
    private final IntObjectMap<IntObjectMap<StatsSet>> _skillsTables = new TreeIntObjectMap();

    public static SkillParser getInstance() {
        return _instance;
    }

    protected SkillParser() {
        super(SkillHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/skills/");
    }

    public File getCustomXMLPath() {
        return new File(Config.DATAPACK_ROOT, "custom/skills/");
    }

    public String getDTDFileName() {
        return "skill.dtd";
    }

    protected void onParsed() {
        this._skillsTables.clear();
        ((SkillHolder)this.getHolder()).callInit();
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator itemIterator = rootElement.elementIterator();
        while (itemIterator.hasNext()) {
            Element skillElement = (Element)itemIterator.next();
            int skillId = Integer.parseInt(skillElement.attributeValue("id"));
            int levels = Integer.parseInt(skillElement.attributeValue("levels"));
            if (levels > 100) {
                this.warn("Error while parse skill[" + skillId + "] (Max level should be less than or equal to 100)!");
                continue;
            }
            this._skillsTables.remove(skillId);
            StatsSet set = new StatsSet();
            set.set("skill_id", skillId);
            set.set("max_level", levels);
            set.set("name", skillElement.attributeValue("name"));
            TreeIntObjectMap restorations = new TreeIntObjectMap();
            Iterator subIterator = skillElement.elementIterator();
            while (subIterator.hasNext()) {
                Element subElement = (Element)subIterator.next();
                String subName = subElement.getName();
                if (subName.equalsIgnoreCase("set")) {
                    set.set(subElement.attributeValue("name"), subElement.attributeValue("value"));
                    continue;
                }
                if (subName.equalsIgnoreCase("table")) {
                    this.parseTable(subElement, skillId, 1, levels);
                    continue;
                }
                if (!subName.equalsIgnoreCase("restoration")) continue;
                this.parseRestoration(subElement, (IntObjectMap<RestorationInfo>)restorations);
            }
            for (int skillLevel = 1; skillLevel <= levels; ++skillLevel) {
                StatsSet currentSet = set.clone();
                for (Map.Entry<String, Object> entry : currentSet.entrySet()) {
                    currentSet.set(entry.getKey(), this.parseTableValue(entry.getValue(), skillId, skillLevel, levels));
                }
                currentSet.set("level", skillLevel);
                currentSet.set("restoration", restorations.get(skillLevel));
                Skill skill = ((Skill.SkillType)currentSet.getEnum("skillType", Skill.SkillType.class, Skill.SkillType.EFFECT)).makeSkill(currentSet);
                Iterator subIterator2 = skillElement.elementIterator();
                while (subIterator2.hasNext()) {
                    Element subElement = (Element)subIterator2.next();
                    String subName = subElement.getName();
                    if (subName.equalsIgnoreCase("for")) {
                        this.parseFor(subElement, skill, skillId, skillLevel, levels);
                        continue;
                    }
                    if (subName.equalsIgnoreCase("cond")) {
                        Condition condition = this.parseFirstCond(subElement, skillId, skillLevel, levels);
                        if (condition == null) continue;
                        if (subElement.attributeValue("msgId") != null) {
                            int msgId = this.parseTableNumber(subElement.attributeValue("msgId"), new int[0]).intValue();
                            condition.setSystemMsg(msgId);
                        }
                        skill.attachCondition(condition);
                        continue;
                    }
                    if (!subName.equalsIgnoreCase("triggers")) continue;
                    this.parseTriggers(subElement, skill, skillId, skillLevel, levels);
                }
                ((SkillHolder)this.getHolder()).addSkill(skill);
            }
        }
    }

    @Override
    protected Object getTableValue(String name, int ... arg) {
        if (arg.length < 3) {
            this.warn("Error while read table[" + name + "] value for skill (Bad arg's length)!", new Exception());
            return null;
        }
        int skillId = arg[0];
        int skillLevel = arg[1];
        int skillMaxLevel = arg[2];
        Object result = null;
        IntObjectMap tables = (IntObjectMap)this._skillsTables.get(skillId);
        if (tables == null) {
            this.warn("Error while read table[" + name + "] value for skill ID[" + skillId + "], LEVEL[" + skillLevel + "] (Cannot find tables)!");
            return null;
        }
        StatsSet set = (StatsSet)((Object)tables.get(skillLevel));
        if (set != null) {
            result = set.get(name);
        }
        if (result != null) {
            String value = String.valueOf(result);
            if (value.isEmpty()) {
                this.warn("Error in table[" + name + "] value[" + value + "] for skill ID[" + skillId + "], LEVEL[" + skillLevel + "] (Empty value)!");
            }
            return result;
        }
        this.warn("Error while read table[" + name + "] value for skill ID[" + skillId + "], LEVEL[" + skillLevel + "] (Cannot find table set)!");
        return null;
    }

    @Override
    protected void parseFor(Element forElement, StatTemplate template, int ... arg) {
        super.parseFor(forElement, template, arg);
        if (!(template instanceof Skill)) {
            return;
        }
        Skill skill = (Skill)template;
        Iterator iterator = forElement.elementIterator();
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            String elementName = element.getName();
            if (elementName.equalsIgnoreCase("start_effect")) {
                this.attachEffect(element, skill, EffectUseType.START, EffectTargetType.NORMAL, arg);
                continue;
            }
            if (elementName.equalsIgnoreCase("tick_effect")) {
                this.attachEffect(element, skill, EffectUseType.TICK, EffectTargetType.NORMAL, arg);
                continue;
            }
            if (elementName.equalsIgnoreCase("self_effect")) {
                this.attachEffect(element, skill, EffectUseType.SELF, EffectTargetType.NORMAL, arg);
                continue;
            }
            if (elementName.equalsIgnoreCase("effect")) {
                this.attachEffect(element, skill, EffectUseType.NORMAL, EffectTargetType.NORMAL, arg);
                continue;
            }
            if (elementName.equalsIgnoreCase("pvp_effect")) {
                this.attachEffect(element, skill, EffectUseType.NORMAL, EffectTargetType.PVP, arg);
                continue;
            }
            if (elementName.equalsIgnoreCase("pve_effect")) {
                this.attachEffect(element, skill, EffectUseType.NORMAL, EffectTargetType.PVE, arg);
                continue;
            }
            if (!elementName.equalsIgnoreCase("end_effect")) continue;
            this.attachEffect(element, skill, EffectUseType.END, EffectTargetType.NORMAL, arg);
        }
    }

    private void attachEffect(Element element, Skill skill, EffectUseType useType, EffectTargetType targetType, int ... arg) {
        if (element.attributeValue("enabled") != null && !this.parseTableBoolean(element.attributeValue("enabled"), arg)) {
            return;
        }
        StatsSet set = new StatsSet();
        if (element.attributeValue("chance") != null) {
            int chance = this.parseTableNumber(element.attributeValue("chance"), arg).intValue();
            if (chance <= 0) {
                return;
            }
            set.set("chance", chance);
        }
        if (element.attributeValue("name") != null) {
            set.set("name", this.parseTableString(element.attributeValue("name"), arg));
        }
        if (element.attributeValue("value") != null) {
            set.set("value", this.parseTableNumber(element.attributeValue("value"), arg).doubleValue());
        }
        if (element.attributeValue("interval") != null) {
            set.set("interval", this.parseTableNumber(element.attributeValue("interval"), arg).doubleValue());
        }
        if (element.attributeValue("instant") != null) {
            set.set("instant", this.parseTableBoolean(element.attributeValue("instant"), arg));
        }
        if (element.attributeValue("type") != null) {
            set.set("type", this.parseTableValue(element.attributeValue("type"), arg));
        }
        EffectTemplate effectTemplate = new EffectTemplate(skill, set, useType, targetType);
        this.parseFor(element, effectTemplate, arg);
        Iterator subIterator = element.elementIterator();
        while (subIterator.hasNext()) {
            Element subElement = (Element)subIterator.next();
            String subElementName = subElement.getName();
            if (subElementName.equalsIgnoreCase("def")) {
                set.set(subElement.attributeValue("name"), this.parseTableValue(subElement.attributeValue("value"), arg));
                continue;
            }
            if (subElementName.equalsIgnoreCase("triggers")) {
                this.parseTriggers(subElement, effectTemplate, arg);
                continue;
            }
            Condition condition = this.parseCond(subElement, arg);
            if (condition == null) continue;
            effectTemplate.attachCond(condition);
        }
        skill.attachEffect(effectTemplate);
    }

    private void parseRestoration(Element element, IntObjectMap<RestorationInfo> map) {
        int skillLevel = Integer.parseInt(element.attributeValue("level"));
        int consumeItemId = element.attributeValue("consume_item_id") == null ? -1 : Integer.parseInt(element.attributeValue("consume_item_id"));
        int consumeItemCount = element.attributeValue("consume_item_count") == null ? 1 : Integer.parseInt(element.attributeValue("consume_item_count"));
        int onFailMessage = element.attributeValue("on_fail_message") == null ? -1 : Integer.parseInt(element.attributeValue("on_fail_message"));
        RestorationInfo restorationInfo = new RestorationInfo(consumeItemId, consumeItemCount, onFailMessage);
        Iterator groupIterator = element.elementIterator();
        while (groupIterator.hasNext()) {
            Element groupElement = (Element)groupIterator.next();
            double chance = Double.parseDouble(groupElement.attributeValue("chance"));
            RestorationGroup restorationGroup = new RestorationGroup(chance);
            Iterator itemIterator = groupElement.elementIterator();
            while (itemIterator.hasNext()) {
                Element itemElement = (Element)itemIterator.next();
                int id = Integer.parseInt(itemElement.attributeValue("id"));
                int minCount = Integer.parseInt(itemElement.attributeValue("min_count"));
                int maxCount = itemElement.attributeValue("max_count") == null ? minCount : Integer.parseInt(itemElement.attributeValue("max_count"));
                int enchantLevel = itemElement.attributeValue("enchant_level") == null ? 0 : Integer.parseInt(itemElement.attributeValue("enchant_level"));
                restorationGroup.addRestorationItem(new RestorationItem(id, minCount, maxCount, enchantLevel));
            }
            restorationInfo.addRestorationGroup(restorationGroup);
        }
        map.put(skillLevel, restorationInfo);
    }

    private void parseTable(Element element, int skillId, int firstLevel, int lastLevel) {
        String name = element.attributeValue("name");
        if (name.charAt(0) != '#') {
            this.warn("Error while parse table[" + name + "] value for skill ID[" + skillId + "] (Table name must start with #)!");
            return;
        }
        if (name.lastIndexOf(35) != 0) {
            this.warn("Error while parse table[" + name + "] value for skill ID[" + skillId + "] (Table name should not contain # character, but only start with #)!");
            return;
        }
        if (name.contains(";") || name.contains(":") || name.contains(" ") || name.contains("-")) {
            this.warn("Error while parse table[" + name + "] value for skill ID[" + skillId + "] (Table name should not contain characters: ';' ':' '-' or space)!");
            return;
        }
        StringTokenizer data = new StringTokenizer(element.getText());
        ArrayList<String> values = new ArrayList<String>();
        while (data.hasMoreTokens()) {
            values.add(data.nextToken());
        }
        IntObjectMap tables = (IntObjectMap)this._skillsTables.get(skillId);
        if (tables == null) {
            tables = new TreeIntObjectMap();
            this._skillsTables.put(skillId, tables);
        }
        int i = 0;
        for (int lvl = firstLevel; lvl <= lastLevel; ++lvl) {
            StatsSet set = (StatsSet)((Object)tables.get(lvl));
            if (set == null) {
                set = new StatsSet();
                tables.put(lvl, set);
            } else if (set.containsKey(name)) {
                this.warn("Error while parse table[" + name + "] value for skill ID[" + skillId + "] (Skill have tables with the same name)!");
                return;
            }
            set.set(name, (String)values.get(Math.min(i, values.size() - 1)));
            ++i;
        }
    }
}


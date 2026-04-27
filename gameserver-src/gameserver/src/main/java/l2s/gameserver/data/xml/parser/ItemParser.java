/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.dom4j.Element
 */
package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.Iterator;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.data.xml.holder.OptionDataHolder;
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.data.xml.parser.StatParser;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.base.Element;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.stats.conditions.Condition;
import l2s.gameserver.templates.OptionDataTemplate;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.agathion.AgathionData;
import l2s.gameserver.templates.agathion.AgathionEnchantData;
import l2s.gameserver.templates.item.ArmorTemplate;
import l2s.gameserver.templates.item.Bodypart;
import l2s.gameserver.templates.item.EtcItemTemplate;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.item.WeaponTemplate;
import l2s.gameserver.templates.item.data.CapsuledItemData;

public final class ItemParser
extends StatParser<ItemHolder> {
    private static final ItemParser _instance = new ItemParser();

    public static ItemParser getInstance() {
        return _instance;
    }

    protected ItemParser() {
        super(ItemHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/items/");
    }

    public File getCustomXMLPath() {
        return new File(Config.DATAPACK_ROOT, "custom/items/");
    }

    public String getDTDFileName() {
        return "item.dtd";
    }

    protected void readData(org.dom4j.Element rootElement) throws Exception {
        Iterator itemIterator = rootElement.elementIterator();
        while (itemIterator.hasNext()) {
            org.dom4j.Element itemElement = (org.dom4j.Element)itemIterator.next();
            StatsSet set = new StatsSet();
            set.set("item_id", itemElement.attributeValue("id"));
            set.set("name", itemElement.attributeValue("name"));
            set.set("add_name", itemElement.attributeValue("add_name", ""));
            long slot = 0L;
            Iterator subIterator = itemElement.elementIterator();
            while (subIterator.hasNext()) {
                org.dom4j.Element subElement = (org.dom4j.Element)subIterator.next();
                String subName = subElement.getName();
                if (subName.equalsIgnoreCase("set")) {
                    set.set(subElement.attributeValue("name"), subElement.attributeValue("value"));
                    continue;
                }
                if (!subName.equalsIgnoreCase("equip")) continue;
                Iterator slotIterator = subElement.elementIterator();
                while (slotIterator.hasNext()) {
                    org.dom4j.Element slotElement = (org.dom4j.Element)slotIterator.next();
                    Bodypart bodypart = Bodypart.valueOf(slotElement.attributeValue("id"));
                    if (bodypart.getReal() != null) {
                        slot = bodypart.mask();
                        continue;
                    }
                    slot |= bodypart.mask();
                }
            }
            set.set("bodypart", slot);
            ItemTemplate template = null;
            try {
                template = itemElement.getName().equalsIgnoreCase("weapon") ? new WeaponTemplate(set) : (itemElement.getName().equalsIgnoreCase("armor") ? new ArmorTemplate(set) : new EtcItemTemplate(set));
            }
            catch (Exception e) {
                this.warn("Fail create item: " + set.get("item_id"), e);
                continue;
            }
            Iterator subIterator2 = itemElement.elementIterator();
            while (subIterator2.hasNext()) {
                Iterator nextIterator;
                org.dom4j.Element subElement = (org.dom4j.Element)subIterator2.next();
                String subName = subElement.getName();
                if (subName.equalsIgnoreCase("for")) {
                    this.parseFor(subElement, template, new int[0]);
                    continue;
                }
                if (subName.equalsIgnoreCase("triggers")) {
                    this.parseTriggers(subElement, template, new int[0]);
                    continue;
                }
                if (subName.equalsIgnoreCase("skills")) {
                    int level;
                    int id;
                    nextIterator = subElement.elementIterator("skill");
                    while (nextIterator.hasNext()) {
                        org.dom4j.Element nextElement = (org.dom4j.Element)nextIterator.next();
                        id = Integer.parseInt(nextElement.attributeValue("id"));
                        level = Integer.parseInt(nextElement.attributeValue("level"));
                        Skill skill = SkillHolder.getInstance().getSkill(id, level);
                        if (skill != null) {
                            template.attachSkill(skill);
                            continue;
                        }
                        this.warn("Skill not found(" + id + "," + level + ") for item:" + set.getObject("item_id") + "; file:" + this.getCurrentFileName());
                    }
                    nextIterator = subElement.elementIterator("enchant_skill");
                    while (nextIterator.hasNext()) {
                        org.dom4j.Element nextElement = (org.dom4j.Element)nextIterator.next();
                        id = Integer.parseInt(nextElement.attributeValue("id"));
                        level = Integer.parseInt(nextElement.attributeValue("level"));
                        int enchant = Integer.parseInt(nextElement.attributeValue("enchant"));
                        Skill skill = SkillHolder.getInstance().getSkill(id, level);
                        if (skill != null) {
                            template.addEnchantSkill(enchant, skill);
                            continue;
                        }
                        this.warn("Skill not found(" + id + "," + level + ") for item:" + set.getObject("item_id") + "; file:" + this.getCurrentFileName());
                    }
                    continue;
                }
                if (subName.equalsIgnoreCase("cond")) {
                    Condition condition = this.parseFirstCond(subElement, new int[0]);
                    if (condition == null) continue;
                    if (subElement.attributeValue("msgId") != null) {
                        int msgId = this.parseTableNumber(subElement.attributeValue("msgId"), new int[0]).intValue();
                        condition.setSystemMsg(msgId);
                    }
                    template.addCondition(condition);
                    continue;
                }
                if (subName.equalsIgnoreCase("attributes")) {
                    int[] attributes = new int[6];
                    Iterator nextIterator2 = subElement.elementIterator();
                    while (nextIterator2.hasNext()) {
                        org.dom4j.Element nextElement = (org.dom4j.Element)nextIterator2.next();
                        if (!nextElement.getName().equalsIgnoreCase("attribute")) continue;
                        Element element = Element.getElementByName(nextElement.attributeValue("element"));
                        attributes[element.getId()] = Integer.parseInt(nextElement.attributeValue("value"));
                    }
                    template.setBaseAtributeElements(attributes);
                    continue;
                }
                if (subName.equalsIgnoreCase("capsuled_items")) {
                    nextIterator = subElement.elementIterator();
                    while (nextIterator.hasNext()) {
                        org.dom4j.Element nextElement = (org.dom4j.Element)nextIterator.next();
                        if (!nextElement.getName().equalsIgnoreCase("capsuled_item")) continue;
                        int c_item_id = Integer.parseInt(nextElement.attributeValue("id"));
                        long c_min_count = Long.parseLong(nextElement.attributeValue("min_count"));
                        long c_max_count = Long.parseLong(nextElement.attributeValue("max_count"));
                        double c_chance = nextElement.attributeValue("chance") == null ? 100.0 : Double.parseDouble(nextElement.attributeValue("chance"));
                        int enchant_level = nextElement.attributeValue("enchant_level") == null ? 0 : Integer.parseInt(nextElement.attributeValue("enchant_level"));
                        template.addCapsuledItem(new CapsuledItemData(c_item_id, c_min_count, c_max_count, c_chance, enchant_level));
                    }
                    continue;
                }
                if (subName.equalsIgnoreCase("enchant_options")) {
                    nextIterator = subElement.elementIterator();
                    while (nextIterator.hasNext()) {
                        org.dom4j.Element nextElement = (org.dom4j.Element)nextIterator.next();
                        if (!nextElement.getName().equalsIgnoreCase("level")) continue;
                        int val = Integer.parseInt(nextElement.attributeValue("value"));
                        int i = 0;
                        int[] options = new int[3];
                        for (org.dom4j.Element optionElement : nextElement.elements()) {
                            OptionDataTemplate optionData = OptionDataHolder.getInstance().getTemplate(Integer.parseInt(optionElement.attributeValue("id")));
                            if (optionData == null) {
                                this.error("Not found option_data for id: " + optionElement.attributeValue("id") + "; item_id: " + set.get("item_id"));
                                continue;
                            }
                            options[i++] = optionData.getId();
                        }
                        template.addEnchantOptions(val, options);
                    }
                    continue;
                }
                if (!subName.equalsIgnoreCase("agathion_data")) continue;
                AgathionData agathionData = new AgathionData();
                for (org.dom4j.Element element2 : subElement.elements("enchant")) {
                    AgathionEnchantData itemEnchant = new AgathionEnchantData(this.parseInt(element2, "level"));
                    for (org.dom4j.Element element3 : element2.elements("main_skills")) {
                        for (org.dom4j.Element element4 : element3.elements("skill")) {
                            itemEnchant.getMainSkills().add(SkillEntry.makeSkillEntry(SkillEntryType.ITEM, this.parseInt(element4, "id"), this.parseInt(element4, "level")));
                        }
                    }
                    for (org.dom4j.Element element3 : element2.elements("sub_skills")) {
                        for (org.dom4j.Element element4 : element3.elements("skill")) {
                            itemEnchant.getSubSkills().add(SkillEntry.makeSkillEntry(SkillEntryType.ITEM, this.parseInt(element4, "id"), this.parseInt(element4, "level")));
                        }
                    }
                    agathionData.addEnchant(itemEnchant);
                }
                template.setAgathionData(agathionData);
            }
            ((ItemHolder)this.getHolder()).addItem(template);
        }
    }

    @Override
    protected Object getTableValue(String name, int ... arg) {
        return null;
    }
}


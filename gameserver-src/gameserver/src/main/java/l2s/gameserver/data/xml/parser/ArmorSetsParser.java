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
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.ArmorSetsHolder;
import l2s.gameserver.model.ArmorSet;
import org.dom4j.Element;

public final class ArmorSetsParser
extends AbstractParser<ArmorSetsHolder> {
    private static final ArmorSetsParser _instance = new ArmorSetsParser();

    public static ArmorSetsParser getInstance() {
        return _instance;
    }

    private ArmorSetsParser() {
        super(ArmorSetsHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/armor_sets.xml");
    }

    public String getDTDFileName() {
        return "armor_sets.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            if (!"set".equalsIgnoreCase(element.getName())) continue;
            String[] chests = null;
            String[] legs = null;
            String[] head = null;
            String[] gloves = null;
            String[] feet = null;
            String[] shield = null;
            String[] shield_skills = null;
            String[] enchant6skills = null;
            String[] enchant7skills = null;
            String[] enchant8skills = null;
            String[] enchant9skills = null;
            String[] enchant10skills = null;
            if (element.attributeValue("chests") != null) {
                chests = element.attributeValue("chests").split(";");
            }
            if (element.attributeValue("legs") != null) {
                legs = element.attributeValue("legs").split(";");
            }
            if (element.attributeValue("head") != null) {
                head = element.attributeValue("head").split(";");
            }
            if (element.attributeValue("gloves") != null) {
                gloves = element.attributeValue("gloves").split(";");
            }
            if (element.attributeValue("feet") != null) {
                feet = element.attributeValue("feet").split(";");
            }
            if (element.attributeValue("shield") != null) {
                shield = element.attributeValue("shield").split(";");
            }
            if (element.attributeValue("shield_skills") != null) {
                shield_skills = element.attributeValue("shield_skills").split(";");
            }
            if (element.attributeValue("enchant6skills") != null) {
                enchant6skills = element.attributeValue("enchant6skills").split(";");
            }
            if (element.attributeValue("enchant7skills") != null) {
                enchant7skills = element.attributeValue("enchant7skills").split(";");
            }
            if (element.attributeValue("enchant8skills") != null) {
                enchant8skills = element.attributeValue("enchant8skills").split(";");
            }
            if (element.attributeValue("enchant9skills") != null) {
                enchant9skills = element.attributeValue("enchant9skills").split(";");
            }
            if (element.attributeValue("enchant10skills") != null) {
                enchant10skills = element.attributeValue("enchant10skills").split(";");
            }
            ArmorSet armorSet = new ArmorSet(chests, legs, head, gloves, feet, shield, shield_skills, enchant6skills, enchant7skills, enchant8skills, enchant9skills, enchant10skills);
            Iterator subIterator = element.elementIterator();
            while (subIterator.hasNext()) {
                Element subElement = (Element)subIterator.next();
                if (!"set_skills".equalsIgnoreCase(subElement.getName())) continue;
                int partsCount = Integer.parseInt(subElement.attributeValue("parts"));
                String[] skills = subElement.attributeValue("skills").split(";");
                armorSet.addSkills(partsCount, skills);
            }
            ((ArmorSetsHolder)this.getHolder()).addArmorSet(armorSet);
        }
    }
}


/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.lang.reflect.Constructor;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.ResidenceFunctionsHolder;
import l2s.gameserver.data.xml.holder.ResidenceHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.base.ResidenceFunctionType;
import l2s.gameserver.model.entity.residence.Castle;
import l2s.gameserver.model.entity.residence.Residence;
import l2s.gameserver.model.entity.residence.ResidenceFunction;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.item.support.MerchantGuard;
import l2s.gameserver.templates.residence.ResidenceFunctionTemplate;
import org.dom4j.Attribute;
import org.dom4j.Element;

public final class ResidenceParser
extends AbstractParser<ResidenceHolder> {
    private static ResidenceParser _instance = new ResidenceParser();

    public static ResidenceParser getInstance() {
        return _instance;
    }

    private ResidenceParser() {
        super(ResidenceHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/residences/");
    }

    public String getDTDFileName() {
        return "residence.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            int level;
            ResidenceFunctionType type;
            Element nextElement;
            Iterator nextIterator;
            String nodeName;
            Element subElement;
            Iterator subIterator;
            Element element = (Element)iterator.next();
            String impl = element.attributeValue("impl");
            Class<?> clazz = null;
            StatsSet set = new StatsSet();
            Iterator subIterator2 = element.attributeIterator();
            while (subIterator2.hasNext()) {
                Attribute subElement2 = (Attribute)subIterator2.next();
                set.set(subElement2.getName(), subElement2.getValue());
            }
            Residence residence = null;
            try {
                clazz = Class.forName("l2s.gameserver.model.entity.residence." + impl);
                Constructor<?> constructor = clazz.getConstructor(StatsSet.class);
                residence = (Residence)constructor.newInstance(new Object[]{set});
                ((ResidenceHolder)this.getHolder()).addResidence(residence);
            }
            catch (Exception e) {
                this.error("fail to init: " + this.getCurrentFileName(), e);
                return;
            }
            if (element.getName().equalsIgnoreCase("residence")) {
                subIterator = element.elementIterator();
                while (subIterator.hasNext()) {
                    Location loc;
                    subElement = (Element)subIterator.next();
                    nodeName = subElement.getName();
                    if (nodeName.equalsIgnoreCase("available_functions")) {
                        nextIterator = subElement.elementIterator();
                        while (nextIterator.hasNext()) {
                            nextElement = (Element)nextIterator.next();
                            type = ResidenceFunctionType.valueOf(nextElement.attributeValue("type").toUpperCase());
                            level = Integer.parseInt(nextElement.attributeValue("level"));
                            ResidenceFunctionTemplate template = ResidenceFunctionsHolder.getInstance().getTemplate(type, level);
                            if (template == null) continue;
                            residence.addAvailableFunction(template.getId());
                        }
                        continue;
                    }
                    if (nodeName.equalsIgnoreCase("skills")) {
                        nextIterator = subElement.elementIterator();
                        while (nextIterator.hasNext()) {
                            int level2;
                            nextElement = (Element)nextIterator.next();
                            int id2 = Integer.parseInt(nextElement.attributeValue("id"));
                            SkillEntry skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, id2, level2 = Integer.parseInt(nextElement.attributeValue("level")));
                            if (skillEntry == null) continue;
                            residence.addSkill(skillEntry);
                        }
                        continue;
                    }
                    if (nodeName.equalsIgnoreCase("banish_points")) {
                        Iterator banishPointsIterator = subElement.elementIterator();
                        while (banishPointsIterator.hasNext()) {
                            loc = Location.parse((Element)banishPointsIterator.next());
                            residence.addBanishPoint(loc);
                        }
                        continue;
                    }
                    if (nodeName.equalsIgnoreCase("owner_restart_points")) {
                        Iterator ownerRestartPointsIterator = subElement.elementIterator();
                        while (ownerRestartPointsIterator.hasNext()) {
                            loc = Location.parse((Element)ownerRestartPointsIterator.next());
                            residence.addOwnerRestartPoint(loc);
                        }
                        continue;
                    }
                    if (nodeName.equalsIgnoreCase("other_restart_points")) {
                        Iterator otherRestartPointsIterator = subElement.elementIterator();
                        while (otherRestartPointsIterator.hasNext()) {
                            loc = Location.parse((Element)otherRestartPointsIterator.next());
                            residence.addOtherRestartPoint(loc);
                        }
                        continue;
                    }
                    if (nodeName.equalsIgnoreCase("chaos_restart_points")) {
                        Iterator chaosRestartPointsIterator = subElement.elementIterator();
                        while (chaosRestartPointsIterator.hasNext()) {
                            loc = Location.parse((Element)chaosRestartPointsIterator.next());
                            residence.addChaosRestartPoint(loc);
                        }
                        continue;
                    }
                    if (!nodeName.equalsIgnoreCase("merchant_guards")) continue;
                    Iterator thirdElementIterator = subElement.elementIterator();
                    while (thirdElementIterator.hasNext()) {
                        Element thirdElement = (Element)thirdElementIterator.next();
                        int itemId = Integer.parseInt(thirdElement.attributeValue("item_id"));
                        int npcId2 = Integer.parseInt(thirdElement.attributeValue("npc_id"));
                        int maxGuard = Integer.parseInt(thirdElement.attributeValue("max"));
                        ((Castle)residence).addMerchantGuard(new MerchantGuard(itemId, npcId2, maxGuard));
                    }
                }
                continue;
            }
            if (!element.getName().equalsIgnoreCase("instant_residence")) continue;
            subIterator = element.elementIterator();
            while (subIterator.hasNext()) {
                subElement = (Element)subIterator.next();
                nodeName = subElement.getName();
                if (!nodeName.equalsIgnoreCase("functions")) continue;
                nextIterator = subElement.elementIterator("function");
                while (nextIterator.hasNext()) {
                    nextElement = (Element)nextIterator.next();
                    type = ResidenceFunctionType.valueOf(nextElement.attributeValue("type").toUpperCase());
                    level = Integer.parseInt(nextElement.attributeValue("level"));
                    ResidenceFunctionTemplate template = ResidenceFunctionsHolder.getInstance().getTemplate(type, level);
                    if (template == null) continue;
                    residence.addActiveFunction(new ResidenceFunction(template, residence.getId()));
                }
            }
        }
    }
}


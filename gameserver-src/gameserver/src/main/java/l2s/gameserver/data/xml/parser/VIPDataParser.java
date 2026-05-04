/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.Iterator;
import java.util.concurrent.TimeUnit;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.VIPDataHolder;
import l2s.gameserver.data.xml.parser.StatParser;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.VIPTemplate;
import l2s.gameserver.templates.item.data.RewardItemData;
import org.dom4j.Element;

public final class VIPDataParser
extends StatParser<VIPDataHolder> {
    private static final VIPDataParser _instance = new VIPDataParser();

    public static VIPDataParser getInstance() {
        return _instance;
    }

    private VIPDataParser() {
        super(VIPDataHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/vip_data.xml");
    }

    public String getDTDFileName() {
        return "vip_data.dtd";
    }

    public boolean isDisabled() {
        return !Config.EX_USE_PRIME_SHOP;
    }

    protected void readData(Element rootElement) throws Exception {
        Element element;
        Iterator iterator = rootElement.elementIterator("default");
        while (iterator.hasNext()) {
            element = (Element)iterator.next();
            VIPTemplate.DEFAULT_VIP_TEMPLATE.setPointsRefillPercent(element.attributeValue("points_refill_percent") == null ? 0.0 : Double.parseDouble(element.attributeValue("points_refill_percent")));
            VIPTemplate.DEFAULT_VIP_TEMPLATE.setPointsConsumeCount(element.attributeValue("points_consume_count") == null ? 0L : Long.parseLong(element.attributeValue("points_consume_count")));
            VIPTemplate.DEFAULT_VIP_TEMPLATE.setPointsConsumeDelay(element.attributeValue("points_consume_delay") == null ? 0 : Integer.parseInt(element.attributeValue("points_consume_delay")));
        }
        iterator = rootElement.elementIterator("vip");
        while (iterator.hasNext()) {
            element = (Element)iterator.next();
            StatsSet set = new StatsSet();
            Iterator subIterator = element.elementIterator("set");
            while (subIterator.hasNext()) {
                Element subElement = (Element)subIterator.next();
                set.set(subElement.attributeValue("name"), subElement.attributeValue("value"));
            }
            int vip_level = Integer.parseInt(element.attributeValue("level"));
            long points = Long.parseLong(element.attributeValue("points"));
            double points_refill_percent = element.attributeValue("points_refill_percent") == null ? VIPTemplate.DEFAULT_VIP_TEMPLATE.getPointsRefillPercent() : Double.parseDouble(element.attributeValue("points_refill_percent"));
            long points_consume_count = element.attributeValue("points_consume_count") == null ? VIPTemplate.DEFAULT_VIP_TEMPLATE.getPointsConsumeCount() : Long.parseLong(element.attributeValue("points_consume_count"));
            int points_consume_delay = element.attributeValue("points_consume_delay") == null ? (int)VIPTemplate.DEFAULT_VIP_TEMPLATE.getPointsConsumeDelay(TimeUnit.HOURS) : Integer.parseInt(element.attributeValue("points_consume_delay"));
            VIPTemplate template = new VIPTemplate(vip_level, points, points_refill_percent, points_consume_count, points_consume_delay, set);
            Iterator subIterator2 = element.elementIterator();
            while (subIterator2.hasNext()) {
                Element subElement = (Element)subIterator2.next();
                if ("stats".equalsIgnoreCase(subElement.getName())) {
                    this.parseFor(subElement, template, new int[0]);
                    continue;
                }
                if ("triggers".equalsIgnoreCase(subElement.getName())) {
                    this.parseTriggers(subElement, template, new int[0]);
                    continue;
                }
                if ("skills".equalsIgnoreCase(subElement.getName())) {
                    Iterator nextIterator = subElement.elementIterator("skill");
                    while (nextIterator.hasNext()) {
                        Element nextElement = (Element)nextIterator.next();
                        int id = Integer.parseInt(nextElement.attributeValue("id"));
                        int level = Integer.parseInt(nextElement.attributeValue("level"));
                        template.attachSkill(SkillEntry.makeSkillEntry(SkillEntryType.NONE, id, level));
                    }
                    continue;
                }
                if (!"rewards".equalsIgnoreCase(subElement.getName())) continue;
                for (Element e : subElement.elements()) {
                    int itemId = Integer.parseInt(e.attributeValue("id"));
                    long minItemCount = Long.parseLong(e.attributeValue("min_count"));
                    long maxItemCount = Long.parseLong(e.attributeValue("max_count"));
                    double itemChance = Double.parseDouble(e.attributeValue("chance"));
                    template.addReward(new RewardItemData(itemId, minItemCount, maxItemCount, itemChance));
                }
            }
            ((VIPDataHolder)this.getHolder()).addVIPTemplate(template);
        }
    }

    @Override
    protected Object getTableValue(String name, int ... arg) {
        return null;
    }
}


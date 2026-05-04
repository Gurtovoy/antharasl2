package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.Iterator;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.PremiumAccountHolder;
import l2s.gameserver.data.xml.parser.StatParser;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.templates.PremiumAccountTemplate;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.item.data.ItemData;
import l2s.gameserver.templates.item.data.RewardItemData;
import l2s.gameserver.utils.Language;
import org.dom4j.Element;

public final class PremiumAccountParser
extends StatParser<PremiumAccountHolder> {
    private static final PremiumAccountParser _instance = new PremiumAccountParser();

    public static PremiumAccountParser getInstance() {
        return _instance;
    }

    private PremiumAccountParser() {
        super(PremiumAccountHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/premium_accounts.xml");
    }

    public String getDTDFileName() {
        return "premium_accounts.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Element element;
        Iterator iterator = rootElement.elementIterator("config");
        while (iterator.hasNext()) {
            element = (Element)iterator.next();
            Config.PREMIUM_ACCOUNT_ENABLED = Boolean.parseBoolean(element.attributeValue("enabled"));
            Config.PREMIUM_ACCOUNT_BASED_ON_GAMESERVER = Boolean.parseBoolean(element.attributeValue("based_on_gameserver"));
            Config.FREE_PA_TYPE = element.attributeValue("free_type") == null ? 0 : Integer.parseInt(element.attributeValue("free_type"));
            Config.FREE_PA_DELAY = element.attributeValue("free_delay") == null ? 0 : Integer.parseInt(element.attributeValue("free_delay"));
            Config.ENABLE_FREE_PA_NOTIFICATION = element.attributeValue("notify_free") == null ? false : Boolean.parseBoolean(element.attributeValue("notify_free"));
        }
        if (!Config.PREMIUM_ACCOUNT_ENABLED) {
            return;
        }
        iterator = rootElement.elementIterator("account");
        while (iterator.hasNext()) {
            element = (Element)iterator.next();
            StatsSet set = new StatsSet();
            Iterator subIterator = element.elementIterator("set");
            while (subIterator.hasNext()) {
                Element subElement = (Element)subIterator.next();
                set.set(subElement.attributeValue("name"), subElement.attributeValue("value"));
            }
            int type = Integer.parseInt(element.attributeValue("type"));
            PremiumAccountTemplate template = new PremiumAccountTemplate(type, set);
            Iterator subIterator2 = element.elementIterator();
            while (subIterator2.hasNext()) {
                Element subElement = (Element)subIterator2.next();
                if ("name".equalsIgnoreCase(subElement.getName())) {
                    for (Element e : (java.util.List<Element>)subElement.elements()) {
                        Language lang = Language.getLanguage(e.getName(), null);
                        if (lang == null) continue;
                        template.addName(lang, e.getTextTrim());
                    }
                    continue;
                }
                if ("give_items_on_start".equalsIgnoreCase(subElement.getName())) {
                    for (Element e : (java.util.List<Element>)subElement.elements()) {
                        int itemId = Integer.parseInt(e.attributeValue("id"));
                        long itemCount = Long.parseLong(e.attributeValue("count"));
                        template.addGiveItemOnStart(new ItemData(itemId, itemCount));
                    }
                    continue;
                }
                if ("take_items_on_end".equalsIgnoreCase(subElement.getName())) {
                    for (Element e : (java.util.List<Element>)subElement.elements()) {
                        int itemId = Integer.parseInt(e.attributeValue("id"));
                        long itemCount = Long.parseLong(e.attributeValue("count"));
                        template.addTakeItemOnEnd(new ItemData(itemId, itemCount));
                    }
                    continue;
                }
                if ("fee".equalsIgnoreCase(subElement.getName())) {
                    Object e;
                    int delay = subElement.attributeValue("delay") == null ? -1 : Integer.parseInt(subElement.attributeValue("delay"));
                    Iterator e2 = subElement.elements().iterator();
                    while (e2.hasNext()) {
                        Element e3 = (Element)e2.next();
                        int itemId = Integer.parseInt(e3.attributeValue("id"));
                        long itemCount = Long.parseLong(e3.attributeValue("count"));
                        template.addFee(delay, new ItemData(itemId, itemCount));
                    }
                    continue;
                }
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
                for (Element e : (java.util.List<Element>)subElement.elements()) {
                    int itemId = Integer.parseInt(e.attributeValue("id"));
                    long minItemCount = Long.parseLong(e.attributeValue("min_count"));
                    long maxItemCount = Long.parseLong(e.attributeValue("max_count"));
                    double itemChance = Double.parseDouble(e.attributeValue("chance"));
                    template.addReward(new RewardItemData(itemId, minItemCount, maxItemCount, itemChance));
                }
            }
            ((PremiumAccountHolder)this.getHolder()).addPremiumAccount(template);
        }
    }

    protected void onParsed() {
        if (((PremiumAccountHolder)this.getHolder()).size() == 0) {
            Config.PREMIUM_ACCOUNT_ENABLED = false;
        }
    }

    @Override
    protected Object getTableValue(String name, int ... arg) {
        return null;
    }
}


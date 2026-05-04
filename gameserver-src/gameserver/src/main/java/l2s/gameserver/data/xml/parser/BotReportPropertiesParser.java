package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.BotReportPropertiesHolder;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.templates.BotPunishment;
import org.dom4j.Element;

public class BotReportPropertiesParser
extends AbstractParser<BotReportPropertiesHolder> {
    private static BotReportPropertiesParser _instance = new BotReportPropertiesParser();

    public static BotReportPropertiesParser getInstance() {
        return _instance;
    }

    private BotReportPropertiesParser() {
        super(BotReportPropertiesHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/bot_report_properties.xml");
    }

    public String getDTDFileName() {
        return "bot_report_properties.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Config.BOTREPORT_ENABLED = false;
        Config.BOTREPORT_REPORT_DELAY = 1800000;
        Config.BOTREPORT_REPORTS_RESET_TIME = "00 00 * * *";
        Config.BOTREPORT_ALLOW_REPORTS_FROM_SAME_CLAN_MEMBERS = false;
        Iterator iterator = rootElement.elementIterator("config");
        while (iterator.hasNext()) {
            Element configElement = (Element)iterator.next();
            String attributeValue = configElement.attributeValue("enabled");
            if (attributeValue != null) {
                Config.BOTREPORT_ENABLED = Boolean.parseBoolean(attributeValue);
            }
            if ((attributeValue = configElement.attributeValue("report_delay")) != null) {
                Config.BOTREPORT_REPORT_DELAY = Integer.parseInt(attributeValue);
            }
            if ((attributeValue = configElement.attributeValue("reports_reset_time")) != null) {
                Config.BOTREPORT_REPORTS_RESET_TIME = attributeValue;
            }
            if ((attributeValue = configElement.attributeValue("allow_reports_from_same_clan")) == null) continue;
            Config.BOTREPORT_ALLOW_REPORTS_FROM_SAME_CLAN_MEMBERS = Boolean.parseBoolean(attributeValue);
        }
        if (!Config.BOTREPORT_ENABLED) {
            return;
        }
        iterator = rootElement.elementIterator("punishments");
        while (iterator.hasNext()) {
            Element punishmentsElement = (Element)iterator.next();
            Iterator punishmentsIterator = punishmentsElement.elementIterator("punishment");
            while (punishmentsIterator.hasNext()) {
                Element punishmentElement = (Element)punishmentsIterator.next();
                int need_report_count = Integer.parseInt(punishmentElement.attributeValue("need_report_count"));
                int skill_id = Integer.parseInt(punishmentElement.attributeValue("skill_id"));
                int skill_level = Integer.parseInt(punishmentElement.attributeValue("skill_level"));
                SystemMsg message = punishmentElement.attributeValue("message_id") == null ? null : SystemMsg.valueOf(Integer.parseInt(punishmentElement.attributeValue("message_id")));
                ((BotReportPropertiesHolder)this.getHolder()).addBotPunishment(new BotPunishment(need_report_count, skill_id, skill_level, message));
            }
        }
    }
}


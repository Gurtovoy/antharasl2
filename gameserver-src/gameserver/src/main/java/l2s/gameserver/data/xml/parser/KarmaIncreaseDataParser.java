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
import l2s.gameserver.data.xml.holder.KarmaIncreaseDataHolder;
import org.dom4j.Element;

public final class KarmaIncreaseDataParser
extends AbstractParser<KarmaIncreaseDataHolder> {
    private static final KarmaIncreaseDataParser _instance = new KarmaIncreaseDataParser();

    public static KarmaIncreaseDataParser getInstance() {
        return _instance;
    }

    private KarmaIncreaseDataParser() {
        super(KarmaIncreaseDataHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/pc_parameters/pc_karma_increase_data.xml");
    }

    public String getDTDFileName() {
        return "pc_karma_increase_data.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            if ("parameters".equalsIgnoreCase(element.getName())) {
                Config.KARMA_PENALTY_START_KARMA = Integer.parseInt(element.attributeValue("penalty_start_karma"));
                Config.KARMA_PENALTY_DURATION_DEFAULT = Integer.parseInt(element.attributeValue("penalty_duration_default"));
                Config.KARMA_PENALTY_DURATION_INCREASE = Double.parseDouble(element.attributeValue("penalty_duration_increase"));
                Config.KARMA_DOWN_TIME_MULTIPLE = Integer.parseInt(element.attributeValue("down_time_multiple"));
                Config.KARMA_CRIMINAL_DURATION_MULTIPLE = Integer.parseInt(element.attributeValue("criminal_duration_multiple"));
                continue;
            }
            if (!"table".equalsIgnoreCase(element.getName())) continue;
            for (Element e : element.elements()) {
                int lvl = Integer.parseInt(e.attributeValue("lvl"));
                double value = Double.parseDouble(e.attributeValue("value"));
                ((KarmaIncreaseDataHolder)this.getHolder()).addData(lvl, value);
            }
        }
    }
}


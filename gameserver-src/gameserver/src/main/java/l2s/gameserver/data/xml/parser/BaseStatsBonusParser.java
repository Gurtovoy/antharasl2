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
import l2s.gameserver.data.xml.holder.BaseStatsBonusHolder;
import l2s.gameserver.templates.BaseStatsBonus;
import org.dom4j.Element;

public final class BaseStatsBonusParser
extends AbstractParser<BaseStatsBonusHolder> {
    private static final BaseStatsBonusParser _instance = new BaseStatsBonusParser();

    public static BaseStatsBonusParser getInstance() {
        return _instance;
    }

    private BaseStatsBonusParser() {
        super(BaseStatsBonusHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/pc_parameters/base_stats_bonus_data.xml");
    }

    public String getDTDFileName() {
        return "base_stats_bonus_data.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            if (!"base_stats_bonus".equalsIgnoreCase(element.getName())) continue;
            for (Element e : element.elements()) {
                int value = Integer.parseInt(e.attributeValue("value"));
                double str = (100.0 + (double)Integer.parseInt(e.attributeValue("str"))) / 100.0;
                double _int = (100.0 + (double)Integer.parseInt(e.attributeValue("int"))) / 100.0;
                double dex = (100.0 + (double)Integer.parseInt(e.attributeValue("dex"))) / 100.0;
                double wit = (100.0 + (double)Integer.parseInt(e.attributeValue("wit"))) / 100.0;
                double con = (100.0 + (double)Integer.parseInt(e.attributeValue("con"))) / 100.0;
                double men = (100.0 + (double)Integer.parseInt(e.attributeValue("men"))) / 100.0;
                ((BaseStatsBonusHolder)this.getHolder()).addBaseStatsBonus(value, new BaseStatsBonus(_int, str, con, men, dex, wit));
            }
        }
    }
}


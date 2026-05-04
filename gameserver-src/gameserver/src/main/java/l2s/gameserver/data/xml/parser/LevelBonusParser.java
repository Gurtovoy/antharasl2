/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.LevelBonusHolder;
import org.dom4j.Element;

public final class LevelBonusParser
extends AbstractParser<LevelBonusHolder> {
    private static final LevelBonusParser _instance = new LevelBonusParser();

    public static LevelBonusParser getInstance() {
        return _instance;
    }

    private LevelBonusParser() {
        super(LevelBonusHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/pc_parameters/lvl_bonus_data.xml");
    }

    public String getDTDFileName() {
        return "lvl_bonus_data.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            if (!"lvl_bonus".equalsIgnoreCase(element.getName())) continue;
            for (Element e : element.elements()) {
                int lvl = Integer.parseInt(e.attributeValue("lvl"));
                double bonusMod = Double.parseDouble(e.attributeValue("value"));
                ((LevelBonusHolder)this.getHolder()).addLevelBonus(lvl, bonusMod);
            }
        }
    }
}


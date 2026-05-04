/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.parser;

import gnu.trove.map.TIntLongMap;
import gnu.trove.map.hash.TIntLongHashMap;
import java.io.File;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.LevelUpRewardHolder;
import org.dom4j.Element;

public final class LevelUpRewardParser
extends AbstractParser<LevelUpRewardHolder> {
    private static final LevelUpRewardParser _instance = new LevelUpRewardParser();

    public static LevelUpRewardParser getInstance() {
        return _instance;
    }

    private LevelUpRewardParser() {
        super(LevelUpRewardHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/pc_parameters/lvl_up_reward_data.xml");
    }

    public String getDTDFileName() {
        return "lvl_up_reward_data.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            if (!"reward".equalsIgnoreCase(element.getName())) continue;
            int level = Integer.parseInt(element.attributeValue("level"));
            TIntLongHashMap items = new TIntLongHashMap();
            for (Element e : element.elements()) {
                int id = Integer.parseInt(e.attributeValue("id"));
                long count = Long.parseLong(e.attributeValue("count"));
                items.put(id, count);
            }
            ((LevelUpRewardHolder)this.getHolder()).addRewardData(level, (TIntLongMap)items);
        }
    }
}


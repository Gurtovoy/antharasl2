/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.commons.string.StringArrayUtils;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.AgathionHolder;
import l2s.gameserver.data.xml.parser.CubicParser;
import l2s.gameserver.templates.agathion.AgathionTemplate;
import l2s.gameserver.templates.cubic.CubicTargetType;
import l2s.gameserver.templates.cubic.CubicUseUpType;
import org.dom4j.Element;

public final class AgathionParser
extends AbstractParser<AgathionHolder> {
    private static AgathionParser _instance = new AgathionParser();

    public static AgathionParser getInstance() {
        return _instance;
    }

    protected AgathionParser() {
        super(AgathionHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/agathions.xml");
    }

    public String getDTDFileName() {
        return "agathions.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator("agathion");
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            int npc_id = this.parseInt(element, "npc_id");
            int id = this.parseInt(element, "id");
            int duration = this.parseInt(element, "duration", -1);
            int delay = this.parseInt(element, "delay", 0);
            int max_count = this.parseInt(element, "max_count", Integer.MAX_VALUE);
            CubicUseUpType use_up = CubicUseUpType.valueOf(this.parseString(element, "use_up", "INCREASE_DELAY").toUpperCase());
            double power = this.parseDouble(element, "power", 0.0);
            CubicTargetType target_type = CubicTargetType.valueOf(this.parseString(element, "target_type", "BY_SKILL").toUpperCase());
            int[] item_ids = StringArrayUtils.stringToIntArray((String)this.parseString(element, "item_ids", ""), (String)";");
            int energy = this.parseInt(element, "energy", 0);
            int max_energy = this.parseInt(element, "max_energy", 0);
            AgathionTemplate template = new AgathionTemplate(npc_id, id, duration, delay, max_count, use_up, power, target_type, item_ids, energy, max_energy);
            CubicParser.parseSkills(this, template, element);
            ((AgathionHolder)this.getHolder()).addAgathionTemplate(template);
        }
    }
}


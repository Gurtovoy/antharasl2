package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.StaticObjectHolder;
import l2s.gameserver.templates.StaticObjectTemplate;
import l2s.gameserver.templates.StatsSet;
import org.dom4j.Element;

public final class StaticObjectParser
extends AbstractParser<StaticObjectHolder> {
    private static StaticObjectParser _instance = new StaticObjectParser();

    public static StaticObjectParser getInstance() {
        return _instance;
    }

    private StaticObjectParser() {
        super(StaticObjectHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/staticobjects.xml");
    }

    public String getDTDFileName() {
        return "staticobjects.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            Element staticObjectElement = (Element)iterator.next();
            StatsSet set = new StatsSet();
            set.set("uid", staticObjectElement.attributeValue("id"));
            set.set("stype", staticObjectElement.attributeValue("stype"));
            set.set("path", staticObjectElement.attributeValue("path"));
            set.set("map_x", staticObjectElement.attributeValue("map_x"));
            set.set("map_y", staticObjectElement.attributeValue("map_y"));
            set.set("name", staticObjectElement.attributeValue("name"));
            set.set("x", staticObjectElement.attributeValue("x"));
            set.set("y", staticObjectElement.attributeValue("y"));
            set.set("z", staticObjectElement.attributeValue("z"));
            set.set("spawn", staticObjectElement.attributeValue("spawn"));
            ((StaticObjectHolder)this.getHolder()).addTemplate(new StaticObjectTemplate(set));
        }
    }
}


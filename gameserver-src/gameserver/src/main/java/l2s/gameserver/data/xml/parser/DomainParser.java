package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.commons.geometry.Polygon;
import l2s.commons.geometry.Shape;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.parser.ZoneParser;
import l2s.gameserver.geometry.Territory;
import l2s.gameserver.instancemanager.MapRegionManager;
import l2s.gameserver.templates.mapregion.DomainArea;
import org.dom4j.Element;

public class DomainParser
extends AbstractParser<MapRegionManager> {
    private static final DomainParser _instance = new DomainParser();

    public static DomainParser getInstance() {
        return _instance;
    }

    protected DomainParser() {
        super(MapRegionManager.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/mapregion/domains.xml");
    }

    public String getDTDFileName() {
        return "domains.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            Element listElement = (Element)iterator.next();
            if (!"domain".equals(listElement.getName())) continue;
            int id = Integer.parseInt(listElement.attributeValue("id"));
            Territory territory = null;
            Iterator i = listElement.elementIterator();
            while (i.hasNext()) {
                Element n = (Element)i.next();
                if (!"polygon".equalsIgnoreCase(n.getName())) continue;
                Polygon shape = ZoneParser.parsePolygon(n);
                if (!shape.validate()) {
                    this.error("DomainParser: invalid territory data : " + shape + "!");
                }
                if (territory == null) {
                    territory = new Territory();
                }
                territory.add((Shape)shape);
            }
            if (territory == null) {
                throw new RuntimeException("DomainParser: empty territory!");
            }
            ((MapRegionManager)this.getHolder()).addRegionData(new DomainArea(id, territory));
        }
    }
}


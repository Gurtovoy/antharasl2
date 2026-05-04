package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.ShuttleTemplateHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.templates.ShuttleTemplate;
import org.dom4j.Element;

public final class ShuttleTemplateParser
extends AbstractParser<ShuttleTemplateHolder> {
    private static final ShuttleTemplateParser _instance = new ShuttleTemplateParser();

    public static ShuttleTemplateParser getInstance() {
        return _instance;
    }

    protected ShuttleTemplateParser() {
        super(ShuttleTemplateHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/shuttle_data.xml");
    }

    public String getDTDFileName() {
        return "shuttle_data.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            Element shuttleElement = (Element)iterator.next();
            int shuttleId = Integer.parseInt(shuttleElement.attributeValue("id"));
            ShuttleTemplate template = new ShuttleTemplate(shuttleId);
            Iterator doorsIterator = shuttleElement.elementIterator("stops");
            while (doorsIterator.hasNext()) {
                Element doorsElement = (Element)doorsIterator.next();
                Iterator doorIterator = doorsElement.elementIterator("stop");
                while (doorIterator.hasNext()) {
                    Element doorElement = (Element)doorIterator.next();
                    int doorId = Integer.parseInt(doorElement.attributeValue("id"));
                    ShuttleTemplate.ShuttleStop shuttleStop = new ShuttleTemplate.ShuttleStop(doorId);
                    Iterator dimensionIterator = doorElement.elementIterator("dimension");
                    while (dimensionIterator.hasNext()) {
                        Element dimensionElement = (Element)dimensionIterator.next();
                        shuttleStop.getDimensions().add(Location.parse(dimensionElement));
                    }
                    template.addStop(shuttleStop);
                }
            }
            ((ShuttleTemplateHolder)this.getHolder()).addTemplate(template);
        }
    }
}


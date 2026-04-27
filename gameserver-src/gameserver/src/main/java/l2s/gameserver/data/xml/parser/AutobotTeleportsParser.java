package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.AutobotDataHolder;
import l2s.gameserver.data.xml.holder.AutobotDataHolder.TeleportLocation;
import org.dom4j.Element;

public final class AutobotTeleportsParser extends AbstractParser<AutobotDataHolder> {
    private static final AutobotTeleportsParser _instance = new AutobotTeleportsParser();

    public static AutobotTeleportsParser getInstance() {
        return _instance;
    }

    private AutobotTeleportsParser() {
        super(AutobotDataHolder.getInstance());
        this._reader.setValidation(false);
    }

    @Override
    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/autobots/teleports.xml");
    }

    @Override
    public String getDTDFileName() {
        return "autobot_teleports.dtd";
    }

    @Override
    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator("location");
        while (iterator.hasNext()) {
            Element element = (Element) iterator.next();
            String name = this.parseString(element, "name", "Unknown");
            int x = this.parseInt(element, "x");
            int y = this.parseInt(element, "y");
            int z = this.parseInt(element, "z");
            String type = this.parseString(element, "type", "town");
            ((AutobotDataHolder) this.getHolder()).addTeleportLocation(new TeleportLocation(name, x, y, z, type));
        }
    }
}

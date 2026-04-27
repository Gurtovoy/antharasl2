package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.AutobotDataHolder;
import l2s.gameserver.data.xml.holder.AutobotDataHolder.EquipmentSet;
import org.dom4j.Element;

public final class AutobotEquipmentParser extends AbstractParser<AutobotDataHolder> {
    private static final AutobotEquipmentParser _instance = new AutobotEquipmentParser();

    public static AutobotEquipmentParser getInstance() {
        return _instance;
    }

    private AutobotEquipmentParser() {
        super(AutobotDataHolder.getInstance());
        this._reader.setValidation(false);
    }

    @Override
    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/autobots/equipment.xml");
    }

    @Override
    public String getDTDFileName() {
        return "autobot_equipment.dtd";
    }

    @Override
    protected void readData(Element rootElement) throws Exception {
        Iterator classIterator = rootElement.elementIterator("class_equipment");
        while (classIterator.hasNext()) {
            Element classElement = (Element) classIterator.next();
            int classId = this.parseInt(classElement, "classId");
            int minLevel = this.parseInt(classElement, "minLevel", 1);
            int maxLevel = this.parseInt(classElement, "maxLevel", 85);
            Map<String, Integer> slotToItemId = new HashMap<String, Integer>();
            Iterator itemIterator = classElement.elementIterator("item");
            while (itemIterator.hasNext()) {
                Element itemElement = (Element) itemIterator.next();
                String slot = this.parseString(itemElement, "slot");
                int itemId = this.parseInt(itemElement, "itemId");
                slotToItemId.put(slot, itemId);
            }
            ((AutobotDataHolder) this.getHolder()).addEquipmentSet(new EquipmentSet(classId, minLevel, maxLevel, slotToItemId));
        }
    }
}

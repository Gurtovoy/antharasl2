package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.AutobotDataHolder;
import l2s.gameserver.data.xml.holder.AutobotDataHolder.BuffInfo;
import org.dom4j.Element;

public final class AutobotBuffsParser extends AbstractParser<AutobotDataHolder> {
    private static final AutobotBuffsParser _instance = new AutobotBuffsParser();

    public static AutobotBuffsParser getInstance() {
        return _instance;
    }

    private AutobotBuffsParser() {
        super(AutobotDataHolder.getInstance());
        this._reader.setValidation(false);
    }

    @Override
    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/autobots/buffs.xml");
    }

    @Override
    public String getDTDFileName() {
        return "autobot_buffs.dtd";
    }

    @Override
    protected void readData(Element rootElement) throws Exception {
        Iterator classIterator = rootElement.elementIterator("class_buffs");
        while (classIterator.hasNext()) {
            Element classElement = (Element) classIterator.next();
            int classId = this.parseInt(classElement, "classId");
            List<BuffInfo> buffList = new ArrayList<BuffInfo>();
            Iterator buffIterator = classElement.elementIterator("buff");
            while (buffIterator.hasNext()) {
                Element buffElement = (Element) buffIterator.next();
                int skillId = this.parseInt(buffElement, "skillId");
                int skillLevel = this.parseInt(buffElement, "skillLevel", 1);
                buffList.add(new BuffInfo(skillId, skillLevel));
            }
            ((AutobotDataHolder) this.getHolder()).addClassBuffs(classId, buffList);
        }
    }
}

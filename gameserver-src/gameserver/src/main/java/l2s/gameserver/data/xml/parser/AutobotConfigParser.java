package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.AutobotDataHolder;
import l2s.gameserver.data.xml.holder.AutobotDataHolder.AutobotConfig;
import org.dom4j.Element;

public final class AutobotConfigParser extends AbstractParser<AutobotDataHolder> {
    private static final AutobotConfigParser _instance = new AutobotConfigParser();

    public static AutobotConfigParser getInstance() {
        return _instance;
    }

    private AutobotConfigParser() {
        super(AutobotDataHolder.getInstance());
        this._reader.setValidation(false);
    }

    @Override
    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/autobots/config.xml");
    }

    @Override
    public String getDTDFileName() {
        return "autobots_config.dtd";
    }

    @Override
    protected void readData(Element rootElement) throws Exception {
        AutobotConfig config = new AutobotConfig();
        Iterator iterator = rootElement.elementIterator("setting");
        while (iterator.hasNext()) {
            Element element = (Element) iterator.next();
            String name = element.attributeValue("name");
            String value = element.attributeValue("value");
            if (name == null || value == null) {
                continue;
            }
            switch (name) {
                case "thinkIterationMs":
                    config.setThinkIterationMs(Integer.parseInt(value));
                    break;
                case "defaultTitle":
                    config.setDefaultTitle(value);
                    break;
                case "defaultTargetingRange":
                    config.setDefaultTargetingRange(Integer.parseInt(value));
                    break;
                case "defaultAttackPlayerType":
                    config.setDefaultAttackPlayerType(value);
                    break;
                case "defaultTargetingPreference":
                    config.setDefaultTargetingPreference(value);
                    break;
                case "useManaPots":
                    config.setUseManaPots(Boolean.parseBoolean(value));
                    break;
                case "useHealingPots":
                    config.setUseHealingPots(Boolean.parseBoolean(value));
                    break;
                case "useCpPots":
                    config.setUseCpPots(Boolean.parseBoolean(value));
                    break;
                case "manaPotThreshold":
                    config.setManaPotThreshold(Double.parseDouble(value));
                    break;
                case "healingPotThreshold":
                    config.setHealingPotThreshold(Double.parseDouble(value));
                    break;
                case "cpPotThreshold":
                    config.setCpPotThreshold(Double.parseDouble(value));
                    break;
                case "maxActiveBots":
                    config.setMaxActiveBots(Integer.parseInt(value));
                    break;
                case "spawnDelayMs":
                    config.setSpawnDelayMs(Integer.parseInt(value));
                    break;
                default:
                    this.warn("Unknown autobot config setting: " + name);
                    break;
            }
        }
        ((AutobotDataHolder) this.getHolder()).setConfig(config);
    }
}

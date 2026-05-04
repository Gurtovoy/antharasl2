/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.ExperienceDataHolder;
import l2s.gameserver.model.base.Experience;
import l2s.gameserver.templates.ExperienceData;
import org.dom4j.Element;

public final class ExperienceDataParser
extends AbstractParser<ExperienceDataHolder> {
    private static final ExperienceDataParser _instance = new ExperienceDataParser();

    public static ExperienceDataParser getInstance() {
        return _instance;
    }

    private ExperienceDataParser() {
        super(ExperienceDataHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/pc_parameters/experience.xml");
    }

    public String getDTDFileName() {
        return "experience.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator("experience");
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            int level = Integer.parseInt(element.attributeValue("level")) + 1;
            long exp = Long.parseLong(element.attributeValue("exp"));
            double training_rate = Double.parseDouble(element.attributeValue("training_rate"));
            ((ExperienceDataHolder)this.getHolder()).addData(new ExperienceData(level, exp, training_rate));
        }
    }

    protected void onParsed() {
        for (int level = 1; level < Math.max(((ExperienceDataHolder)this.getHolder()).getMaxLevel(), Math.max(Experience.getMaxLevel(), Experience.getMaxSubLevel())); ++level) {
            if (((ExperienceDataHolder)this.getHolder()).containsData(level)) continue;
            this.error("Not found experience data for " + level + " level!");
            Runtime.getRuntime().exit(0);
        }
    }
}


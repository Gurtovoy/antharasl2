/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.dom4j.Element
 */
package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.Iterator;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.OptionDataHolder;
import l2s.gameserver.data.xml.parser.StatParser;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.templates.OptionDataTemplate;
import org.dom4j.Element;

public final class OptionDataParser
extends StatParser<OptionDataHolder> {
    private static final OptionDataParser _instance = new OptionDataParser();

    public static OptionDataParser getInstance() {
        return _instance;
    }

    protected OptionDataParser() {
        super(OptionDataHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/option_data");
    }

    public String getDTDFileName() {
        return "option_data.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator itemIterator = rootElement.elementIterator();
        while (itemIterator.hasNext()) {
            Element optionDataElement = (Element)itemIterator.next();
            OptionDataTemplate template = new OptionDataTemplate(Integer.parseInt(optionDataElement.attributeValue("id")));
            Iterator subIterator = optionDataElement.elementIterator();
            while (subIterator.hasNext()) {
                Element subElement = (Element)subIterator.next();
                String subName = subElement.getName();
                if (subName.equalsIgnoreCase("for")) {
                    this.parseFor(subElement, template, new int[0]);
                    continue;
                }
                if (subName.equalsIgnoreCase("triggers")) {
                    this.parseTriggers(subElement, template, new int[0]);
                    continue;
                }
                if (!subName.equalsIgnoreCase("skills")) continue;
                Iterator nextIterator = subElement.elementIterator();
                while (nextIterator.hasNext()) {
                    int level;
                    Element nextElement = (Element)nextIterator.next();
                    int id = Integer.parseInt(nextElement.attributeValue("id"));
                    SkillEntry skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, id, level = Integer.parseInt(nextElement.attributeValue("level")));
                    if (skillEntry != null) {
                        template.addSkill(skillEntry);
                        continue;
                    }
                    this.warn("Skill not found(" + id + "," + level + ") for option data:" + template.getId() + "; file:" + this.getCurrentFileName());
                }
            }
            ((OptionDataHolder)this.getHolder()).addTemplate(template);
        }
    }

    @Override
    protected Object getTableValue(String name, int ... arg) {
        return null;
    }
}


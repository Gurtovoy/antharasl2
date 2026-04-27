/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.data.xml.AbstractHolder
 *  l2s.commons.data.xml.AbstractParser
 *  org.dom4j.Element
 */
package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.PetitionGroupHolder;
import l2s.gameserver.model.petition.PetitionMainGroup;
import l2s.gameserver.model.petition.PetitionSubGroup;
import l2s.gameserver.utils.Language;
import org.dom4j.Element;

public class PetitionGroupParser
extends AbstractParser<PetitionGroupHolder> {
    private static PetitionGroupParser _instance = new PetitionGroupParser();

    public static PetitionGroupParser getInstance() {
        return _instance;
    }

    private PetitionGroupParser() {
        super(PetitionGroupHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/petition_group.xml");
    }

    public String getDTDFileName() {
        return "petition_group.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            Element groupElement = (Element)iterator.next();
            PetitionMainGroup group = new PetitionMainGroup(Integer.parseInt(groupElement.attributeValue("id")));
            ((PetitionGroupHolder)this.getHolder()).addPetitionGroup(group);
            Iterator subIterator = groupElement.elementIterator();
            while (subIterator.hasNext()) {
                Element subElement = (Element)subIterator.next();
                if ("name".equals(subElement.getName())) {
                    group.setName(Language.valueOf(subElement.attributeValue("lang")), subElement.getText());
                    continue;
                }
                if ("description".equals(subElement.getName())) {
                    group.setDescription(Language.valueOf(subElement.attributeValue("lang")), subElement.getText());
                    continue;
                }
                if (!"sub_group".equals(subElement.getName())) continue;
                PetitionSubGroup subGroup = new PetitionSubGroup(Integer.parseInt(subElement.attributeValue("id")), subElement.attributeValue("handler"));
                group.addSubGroup(subGroup);
                Iterator sub2Iterator = subElement.elementIterator();
                while (sub2Iterator.hasNext()) {
                    Element sub2Element = (Element)sub2Iterator.next();
                    if ("name".equals(sub2Element.getName())) {
                        subGroup.setName(Language.valueOf(sub2Element.attributeValue("lang")), sub2Element.getText());
                        continue;
                    }
                    if (!"description".equals(sub2Element.getName())) continue;
                    subGroup.setDescription(Language.valueOf(sub2Element.attributeValue("lang")), sub2Element.getText());
                }
            }
        }
    }
}


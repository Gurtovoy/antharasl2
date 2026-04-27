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
import l2s.gameserver.data.xml.holder.ClassDataHolder;
import l2s.gameserver.templates.player.ClassData;
import org.dom4j.Element;

public final class ClassDataParser
extends AbstractParser<ClassDataHolder> {
    private static final ClassDataParser _instance = new ClassDataParser();

    public static ClassDataParser getInstance() {
        return _instance;
    }

    private ClassDataParser() {
        super(ClassDataHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/pc_parameters/class_data/");
    }

    public String getDTDFileName() {
        return "class_data.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            int classId = Integer.parseInt(element.attributeValue("class_id"));
            ClassData template = new ClassData(classId);
            Iterator subIterator = element.elementIterator();
            while (subIterator.hasNext()) {
                Element subElement = (Element)subIterator.next();
                if (!"hp_mp_cp_data".equalsIgnoreCase(subElement.getName())) continue;
                for (Element e : subElement.elements()) {
                    int lvl = Integer.parseInt(e.attributeValue("lvl"));
                    double hp = Double.parseDouble(e.attributeValue("hp"));
                    double mp = Double.parseDouble(e.attributeValue("mp"));
                    double cp = Double.parseDouble(e.attributeValue("cp"));
                    template.addHpMpCpData(lvl, hp, mp, cp);
                }
            }
            ((ClassDataHolder)this.getHolder()).addClassData(template);
        }
    }
}


/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.parser;

import gnu.trove.map.TIntIntMap;
import gnu.trove.map.hash.TIntIntHashMap;
import gnu.trove.set.TIntSet;
import gnu.trove.set.hash.TIntHashSet;
import java.io.File;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.HennaHolder;
import l2s.gameserver.templates.HennaTemplate;
import org.dom4j.Element;

public final class HennaParser
extends AbstractParser<HennaHolder> {
    private static final HennaParser _instance = new HennaParser();

    public static HennaParser getInstance() {
        return _instance;
    }

    protected HennaParser() {
        super(HennaHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/hennas.xml");
    }

    public String getDTDFileName() {
        return "hennas.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            Element hennaElement = (Element)iterator.next();
            int symbolId = Integer.parseInt(hennaElement.attributeValue("dye_id"));
            int dyeId = Integer.parseInt(hennaElement.attributeValue("dye_item_id"));
            int dyeLvl = Integer.parseInt(hennaElement.attributeValue("dye_level"));
            long drawPrice = Integer.parseInt(hennaElement.attributeValue("wear_fee"));
            long drawCount = Integer.parseInt(hennaElement.attributeValue("need_count"));
            long removePrice = Integer.parseInt(hennaElement.attributeValue("cancel_fee"));
            long removeCount = Integer.parseInt(hennaElement.attributeValue("cancel_count"));
            int period = hennaElement.attributeValue("period") == null ? 0 : Integer.parseInt(hennaElement.attributeValue("period"));
            int wit = hennaElement.attributeValue("wit") == null ? 0 : Integer.parseInt(hennaElement.attributeValue("wit"));
            int str = hennaElement.attributeValue("str") == null ? 0 : Integer.parseInt(hennaElement.attributeValue("str"));
            int _int = hennaElement.attributeValue("int") == null ? 0 : Integer.parseInt(hennaElement.attributeValue("int"));
            int con = hennaElement.attributeValue("con") == null ? 0 : Integer.parseInt(hennaElement.attributeValue("con"));
            int dex = hennaElement.attributeValue("dex") == null ? 0 : Integer.parseInt(hennaElement.attributeValue("dex"));
            int men = hennaElement.attributeValue("men") == null ? 0 : Integer.parseInt(hennaElement.attributeValue("men"));
            TIntHashSet list = new TIntHashSet();
            Iterator classIterator = hennaElement.elementIterator("class");
            while (classIterator.hasNext()) {
                Element classElement = (Element)classIterator.next();
                list.add(Integer.parseInt(classElement.attributeValue("id")));
            }
            TIntIntHashMap skills = new TIntIntHashMap();
            Iterator skillsIterator = hennaElement.elementIterator("skills");
            while (skillsIterator.hasNext()) {
                Element skillsElement = (Element)skillsIterator.next();
                Iterator skillIterator = skillsElement.elementIterator("skill");
                while (skillIterator.hasNext()) {
                    Element skillElement = (Element)skillIterator.next();
                    int skillId = Integer.parseInt(skillElement.attributeValue("id"));
                    int skillLvl = Integer.parseInt(skillElement.attributeValue("level"));
                    skills.put(skillId, skillLvl);
                }
            }
            HennaTemplate henna = new HennaTemplate(symbolId, dyeId, dyeLvl, drawPrice, drawCount, removePrice, removeCount, wit, _int, con, str, dex, men, (TIntSet)list, (TIntIntMap)skills, period);
            ((HennaHolder)this.getHolder()).addHenna(henna);
        }
    }
}


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
import l2s.gameserver.data.xml.holder.HitCondBonusHolder;
import l2s.gameserver.model.base.HitCondBonusType;
import org.dom4j.Element;

public final class HitCondBonusParser
extends AbstractParser<HitCondBonusHolder> {
    private static final HitCondBonusParser _instance = new HitCondBonusParser();

    public static HitCondBonusParser getInstance() {
        return _instance;
    }

    private HitCondBonusParser() {
        super(HitCondBonusHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/pc_parameters/hit_cond_bonus.xml");
    }

    public String getDTDFileName() {
        return "hit_cond_bonus.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            HitCondBonusType type = HitCondBonusType.valueOf(element.attributeValue("type"));
            double value = Double.parseDouble(element.attributeValue("value"));
            ((HitCondBonusHolder)this.getHolder()).addHitCondBonus(type, value);
        }
    }
}


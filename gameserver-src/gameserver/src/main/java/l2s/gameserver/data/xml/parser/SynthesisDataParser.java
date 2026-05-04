/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.commons.string.StringArrayUtils;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.SynthesisDataHolder;
import l2s.gameserver.templates.item.data.ItemData;
import l2s.gameserver.templates.item.support.SynthesisData;
import org.dom4j.Element;

public class SynthesisDataParser
extends AbstractParser<SynthesisDataHolder> {
    private static SynthesisDataParser _instance = new SynthesisDataParser();

    public static SynthesisDataParser getInstance() {
        return _instance;
    }

    private SynthesisDataParser() {
        super(SynthesisDataHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/synthesis_data.xml");
    }

    public String getDTDFileName() {
        return "synthesis_data.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator("synthesis");
        while (iterator.hasNext()) {
            Element synthesisElement = (Element)iterator.next();
            int itemId1 = this.parseInt(synthesisElement, "item_1_id");
            int itemId2 = this.parseInt(synthesisElement, "item_2_id");
            double chance = this.parseDouble(synthesisElement, "chance");
            int[] successItemInfo = StringArrayUtils.stringToIntArray((String)this.parseString(synthesisElement, "success_item"), (String)"-");
            ItemData successItemData = new ItemData(successItemInfo[0], successItemInfo.length > 1 ? (long)successItemInfo[1] : 1L);
            int[] failItemInfo = StringArrayUtils.stringToIntArray((String)this.parseString(synthesisElement, "fail_item"), (String)"-");
            ItemData failItemData = new ItemData(failItemInfo[0], failItemInfo.length > 1 ? (long)failItemInfo[1] : 1L);
            int resultEffecttype = this.parseInt(synthesisElement, "result_effecttype", 0);
            int[] locationIds = StringArrayUtils.stringToIntArray((String)this.parseString(synthesisElement, "location_id", "-1"), (String)";");
            ((SynthesisDataHolder)this.getHolder()).addData(new SynthesisData(itemId1, itemId2, chance, successItemData, failItemData, resultEffecttype, locationIds));
        }
    }
}


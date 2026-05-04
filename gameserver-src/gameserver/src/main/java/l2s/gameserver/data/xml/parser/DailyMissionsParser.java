/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.parser;

import gnu.trove.set.TIntSet;
import gnu.trove.set.hash.TIntHashSet;
import java.io.File;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.commons.string.StringArrayUtils;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.DailyMissionsHolder;
import l2s.gameserver.templates.dailymissions.DailyMissionTemplate;
import l2s.gameserver.templates.dailymissions.DailyRewardTemplate;
import l2s.gameserver.templates.item.data.ItemData;
import org.dom4j.Element;

public final class DailyMissionsParser
extends AbstractParser<DailyMissionsHolder> {
    private static final DailyMissionsParser _instance = new DailyMissionsParser();

    public static DailyMissionsParser getInstance() {
        return _instance;
    }

    private DailyMissionsParser() {
        super(DailyMissionsHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/daily_missions.xml");
    }

    public String getDTDFileName() {
        return "daily_missions.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            int id = this.parseInt(element, "id");
            String handler = this.parseString(element, "handler");
            int value = this.parseInt(element, "value", 1);
            int minLevel = this.parseInt(element, "min_level", 1);
            int maxLevel = this.parseInt(element, "max_level", Integer.MAX_VALUE);
            DailyMissionTemplate mission = new DailyMissionTemplate(id, handler, value, minLevel, maxLevel);
            Iterator rewardsIterator = element.elementIterator("rewards");
            while (rewardsIterator.hasNext()) {
                Element rewardsElement = (Element)rewardsIterator.next();
                String classes = this.parseString(rewardsElement, "classes", null);
                TIntHashSet classIds = classes == null ? null : new TIntHashSet(StringArrayUtils.stringToIntArray((String)rewardsElement.attributeValue("classes"), (String)","));
                DailyRewardTemplate reward = new DailyRewardTemplate((TIntSet)classIds);
                Iterator rewardIterator = rewardsElement.elementIterator("reward");
                while (rewardIterator.hasNext()) {
                    Element rewardElement = (Element)rewardIterator.next();
                    int rewardId = this.parseInt(rewardElement, "id");
                    long rewardCount = this.parseLong(rewardElement, "count");
                    reward.addRewardItem(new ItemData(rewardId, rewardCount));
                }
                mission.addReward(reward);
            }
            ((DailyMissionsHolder)this.getHolder()).addMission(mission);
        }
    }
}


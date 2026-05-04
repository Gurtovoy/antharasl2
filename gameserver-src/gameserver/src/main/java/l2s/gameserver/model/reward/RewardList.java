package l2s.gameserver.model.reward;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.reward.RewardData;
import l2s.gameserver.model.reward.RewardGroup;
import l2s.gameserver.model.reward.RewardItem;
import l2s.gameserver.model.reward.RewardType;
import org.dom4j.Element;
import org.slf4j.Logger;

public class RewardList
extends ArrayList<RewardGroup> {
    public static final int MAX_CHANCE = 1000000;
    private final RewardType _type;
    private final boolean _autoLoot;

    public RewardList(RewardType rewardType, boolean a) {
        super(5);
        this._type = rewardType;
        this._autoLoot = a;
    }

    public List<RewardItem> roll(Player player) {
        return this.roll(player, 1.0, null);
    }

    public List<RewardItem> roll(Player player, double penaltyMod) {
        return this.roll(player, penaltyMod, null);
    }

    public List<RewardItem> roll(Player player, double penaltyMod, NpcInstance npc) {
        ArrayList<RewardItem> temp = new ArrayList<RewardItem>();
        for (RewardGroup g : this) {
            temp.addAll(g.roll(this._type, player, penaltyMod, npc));
        }
        return temp;
    }

    public boolean isAutoLoot() {
        return this._autoLoot;
    }

    public RewardType getType() {
        return this._type;
    }

    public static RewardList parseRewardList(Logger logger, Element element, RewardType type, String debugString) {
        boolean autoLoot = element.attributeValue("auto_loot") != null && Boolean.parseBoolean(element.attributeValue("auto_loot"));
        RewardList list = new RewardList(type, autoLoot);
        Iterator nextIterator = element.elementIterator();
        while (nextIterator.hasNext()) {
            boolean notGroupType;
            Element nextElement = (Element)nextIterator.next();
            String nextName = nextElement.getName();
            boolean bl = notGroupType = type == RewardType.SWEEP || type == RewardType.NOT_RATED_NOT_GROUPED;
            if (nextName.equalsIgnoreCase("group")) {
                double enterChance = nextElement.attributeValue("chance") == null ? 1000000.0 : Double.parseDouble(nextElement.attributeValue("chance")) * 10000.0;
                String time = nextElement.attributeValue("time");
                RewardGroup group = notGroupType ? null : new RewardGroup(enterChance, time);
                Iterator rewardIterator = nextElement.elementIterator();
                while (rewardIterator.hasNext()) {
                    Element rewardElement = (Element)rewardIterator.next();
                    RewardData data = RewardData.parseReward(rewardElement);
                    if (!Config.DISABLE_DROP_EXCEPT_ITEM_IDS.isEmpty() && !Config.DISABLE_DROP_EXCEPT_ITEM_IDS.contains(data.getItemId())) continue;
                    if (notGroupType) {
                        logger.warn("Can't load rewardlist from group: " + debugString + "; type: " + (Object)((Object)type));
                        continue;
                    }
                    group.addData(data);
                }
                if (group == null || group.getItems().isEmpty()) continue;
                list.add(group);
                continue;
            }
            if (!nextName.equalsIgnoreCase("reward")) continue;
            if (!notGroupType) {
                logger.warn("Reward can't be without group(and not grouped): " + debugString + "; type: " + (Object)((Object)type));
                continue;
            }
            RewardData data = RewardData.parseReward(nextElement);
            if (!Config.DISABLE_DROP_EXCEPT_ITEM_IDS.isEmpty() && !Config.DISABLE_DROP_EXCEPT_ITEM_IDS.contains(data.getItemId())) continue;
            RewardGroup g = new RewardGroup(1000000.0, null);
            g.addData(data);
            list.add(g);
        }
        return list;
    }
}


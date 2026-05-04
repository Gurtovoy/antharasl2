/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.FishDataHolder;
import l2s.gameserver.templates.fish.FishRewardTemplate;
import l2s.gameserver.templates.fish.FishRewardsTemplate;
import l2s.gameserver.templates.fish.FishTemplate;
import l2s.gameserver.templates.fish.LureTemplate;
import l2s.gameserver.templates.fish.RodTemplate;
import org.dom4j.Element;

public class FishDataParser
extends AbstractParser<FishDataHolder> {
    private static final FishDataParser _instance = new FishDataParser();

    public static FishDataParser getInstance() {
        return _instance;
    }

    private FishDataParser() {
        super(FishDataHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/fishdata.xml");
    }

    public String getDTDFileName() {
        return "fishdata.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            int id;
            Element element = (Element)iterator.next();
            if ("config".equals(element.getName())) {
                Config.FISHING_ONLY_PREMIUM_ACCOUNTS = Boolean.parseBoolean(element.attributeValue("only_premium_accounts"));
                Config.FISHING_MINIMUM_LEVEL = Integer.parseInt(element.attributeValue("minimum_level"));
                Config.RATE_FISH_DROP_COUNT = Integer.parseInt(element.attributeValue("fish_drop_count_rate"));
                continue;
            }
            if ("lure".equals(element.getName())) {
                id = Integer.parseInt(element.attributeValue("id"));
                double fail_chance = element.attributeValue("fail_chance") == null ? 0.0 : Double.parseDouble(element.attributeValue("fail_chance"));
                int fail_duration = element.attributeValue("fail_duration") == null ? 0 : Integer.parseInt(element.attributeValue("fail_duration"));
                LureTemplate lure = new LureTemplate(id, fail_chance, fail_duration);
                Iterator fishIterator = element.elementIterator("fish");
                while (fishIterator.hasNext()) {
                    int fish_reward_type;
                    Element fishElement = (Element)fishIterator.next();
                    int fish_id = Integer.parseInt(fishElement.attributeValue("id"));
                    double fish_chance = Double.parseDouble(fishElement.attributeValue("chance"));
                    int fish_duration = Integer.parseInt(fishElement.attributeValue("duration"));
                    int n = fish_reward_type = fishElement.attributeValue("reward_type") == null ? 0 : Integer.parseInt(fishElement.attributeValue("reward_type"));
                    if (fish_chance <= 0.0) {
                        this.warn("Fish ID[" + fish_id + "] in lure ID[" + id + "] have wrong chance (chance <= 0)!");
                        continue;
                    }
                    if (fish_duration <= 0) {
                        this.warn("Fish ID[" + fish_id + "] in lure ID[" + id + "] have wrong duration (duration <= 0)!");
                        continue;
                    }
                    lure.addFish(new FishTemplate(fish_id, fish_chance, fish_duration, fish_reward_type));
                }
                ((FishDataHolder)this.getHolder()).addLure(lure);
                continue;
            }
            if ("rewards".equals(element.getName())) {
                int type = Integer.parseInt(element.attributeValue("type"));
                FishRewardsTemplate rewards = new FishRewardsTemplate(type);
                Iterator rewardIterator = element.elementIterator("reward");
                while (rewardIterator.hasNext()) {
                    Element rewardElement = (Element)rewardIterator.next();
                    int reward_min_level = Integer.parseInt(rewardElement.attributeValue("min_level"));
                    int reward_max_level = rewardElement.attributeValue("max_level") == null ? Config.ALT_MAX_LEVEL : Integer.parseInt(rewardElement.attributeValue("max_level"));
                    long reward_exp = Long.parseLong(rewardElement.attributeValue("exp"));
                    long reward_sp = Long.parseLong(rewardElement.attributeValue("sp"));
                    rewards.addReward(new FishRewardTemplate(reward_min_level, reward_max_level, reward_exp, reward_sp));
                }
                ((FishDataHolder)this.getHolder()).addRewards(rewards);
                continue;
            }
            if (!"rod".equals(element.getName())) continue;
            id = Integer.parseInt(element.attributeValue("id"));
            double duration_modifier = Double.parseDouble(element.attributeValue("duration_modifier"));
            double reward_modifier = Double.parseDouble(element.attributeValue("reward_modifier"));
            int shot_consume_count = Integer.parseInt(element.attributeValue("shot_consume_count"));
            ((FishDataHolder)this.getHolder()).addRod(new RodTemplate(id, duration_modifier, reward_modifier, shot_consume_count));
        }
    }
}


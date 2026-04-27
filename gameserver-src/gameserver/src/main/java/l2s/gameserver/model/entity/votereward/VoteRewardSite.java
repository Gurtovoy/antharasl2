/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.collections.MultiValueSet
 *  l2s.commons.logging.LoggerObject
 *  org.napile.primitive.maps.impl.HashIntLongMap
 *  org.napile.primitive.pair.IntLongPair
 */
package l2s.gameserver.model.entity.votereward;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import l2s.commons.collections.MultiValueSet;
import l2s.commons.logging.LoggerObject;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.dao.VoteRewardRecordsDAO;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.votereward.VoteRewardRecord;
import l2s.gameserver.model.reward.RewardItem;
import l2s.gameserver.model.reward.RewardList;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.utils.ItemFunctions;
import org.napile.primitive.maps.impl.HashIntLongMap;
import org.napile.primitive.pair.IntLongPair;

public abstract class VoteRewardSite
extends LoggerObject
implements Runnable {
    private final String name;
    private final boolean enabled;
    private final int runDelay;
    private final List<RewardList> rewardLists = new ArrayList<RewardList>();
    private final Map<String, VoteRewardRecord> records = new ConcurrentHashMap<String, VoteRewardRecord>();
    private final Lock lock = new ReentrantLock();

    public VoteRewardSite(MultiValueSet<String> parameters) {
        this.name = parameters.getString("name");
        this.enabled = parameters.getBool("enabled");
        this.runDelay = parameters.getInteger("run_delay", 0);
    }

    @Override
    public void run() {
        throw new UnsupportedOperationException(this.getClass().getName() + " not implemented run");
    }

    public final String getName() {
        return this.name;
    }

    public boolean isEnabled() {
        return this.enabled;
    }

    public final void addRewardList(RewardList rewardList) {
        this.rewardLists.add(rewardList);
    }

    public final VoteRewardRecord getRecord(String identifier) {
        VoteRewardRecord record = this.records.get(identifier);
        if (record == null) {
            record = new VoteRewardRecord(this.getName(), identifier, 0, -1);
            record.save();
            this.records.put(record.getIdentifier(), record);
        }
        return record;
    }

    public final Lock getLock() {
        return this.lock;
    }

    public void init() {
        VoteRewardRecordsDAO.getInstance().restore(this.records, this.getName());
        if (this.runDelay > 0 && this.isEnabled()) {
            ThreadPoolManager.getInstance().scheduleAtFixedRate(this, this.runDelay, this.runDelay, TimeUnit.SECONDS);
        }
    }

    public boolean tryGiveRewards(Player player) {
        return false;
    }

    protected void giveRewards(Player player, int count) {
        ArrayList<RewardItem> rolledItems = new ArrayList<RewardItem>();
        for (RewardList rewardList : this.rewardLists) {
            for (int i = 0; i < count; ++i) {
                rolledItems.addAll(rewardList.roll(player));
            }
        }
        if (rolledItems.isEmpty()) {
            player.sendMessage(new CustomMessage("votereward.reward_not_received." + this.getName()));
            return;
        }
        player.sendMessage(new CustomMessage("votereward.reward_received." + this.getName()));
        HashIntLongMap rewards = new HashIntLongMap();
        for (RewardItem rewardItem : rolledItems) {
            rewards.put(rewardItem.itemId, rewards.get(rewardItem.itemId) + rewardItem.count);
        }
        for (IntLongPair pair : rewards.entrySet()) {
            ItemFunctions.addItem(player, pair.getKey(), pair.getValue(), true);
        }
    }
}


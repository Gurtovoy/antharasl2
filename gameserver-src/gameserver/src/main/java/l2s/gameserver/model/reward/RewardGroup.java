/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.string.StringArrayUtils
 *  l2s.commons.util.Rnd
 */
package l2s.gameserver.model.reward;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.List;
import l2s.commons.string.StringArrayUtils;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.reward.RewardData;
import l2s.gameserver.model.reward.RewardItem;
import l2s.gameserver.model.reward.RewardType;
import l2s.gameserver.stats.Stats;

public class RewardGroup
implements Cloneable {
    private double _chance;
    private final String _time;
    private final int _startHour;
    private final int _startMinute;
    private final int _endHour;
    private final int _endMinute;
    private boolean _isAdena = true;
    private boolean _notRate = false;
    private List<RewardData> _items = new ArrayList<RewardData>();

    public RewardGroup(double chance, String time) {
        this.setChance(chance);
        this._time = time;
        if (this._time != null) {
            int[][] timeArr = StringArrayUtils.stringToIntArray2X((String)this._time, (String)"-", (String)":");
            if (timeArr.length > 0) {
                this._startHour = timeArr[0].length > 0 ? timeArr[0][0] : 0;
                this._startMinute = timeArr[0].length > 1 ? timeArr[0][1] : 0;
            } else {
                this._startHour = 0;
                this._startMinute = 0;
            }
            if (timeArr.length > 1) {
                this._endHour = timeArr[1].length > 0 ? timeArr[1][0] : 23;
                this._endMinute = timeArr[1].length > 1 ? timeArr[1][1] : 59;
            } else {
                this._endHour = 23;
                this._endMinute = 59;
            }
        } else {
            this._startHour = 0;
            this._startMinute = 0;
            this._endHour = 23;
            this._endMinute = 59;
        }
    }

    public boolean notRate() {
        return this._notRate;
    }

    public void setNotRate(boolean notRate) {
        this._notRate = notRate;
    }

    public double getChance() {
        return this._chance;
    }

    public void setChance(double chance) {
        this._chance = Math.min(chance, 1000000.0);
    }

    public boolean checkTime(long timeInMillis) {
        Calendar c = Calendar.getInstance();
        c.setTimeInMillis(timeInMillis);
        int hour = c.get(11);
        int minute = c.get(12);
        if (this._startHour <= this._endHour) {
            return RewardGroup.checkTime(this._startHour, this._startMinute, this._endHour, this._endMinute, hour, minute);
        }
        if (RewardGroup.checkTime(this._startHour, this._startMinute, 23, 59, hour, minute)) {
            return true;
        }
        return RewardGroup.checkTime(0, 0, this._endHour, this._endMinute, hour, minute);
    }

    private static boolean checkTime(int minHour, int minMinute, int maxHour, int maxMinute, int currentHour, int currentMinute) {
        if (currentHour > minHour && currentHour < maxHour) {
            return true;
        }
        if (currentHour == minHour && currentMinute >= minMinute && (currentHour < maxHour || currentMinute <= maxMinute)) {
            return true;
        }
        return (currentHour > minHour || currentMinute >= minMinute) && currentHour == maxHour && currentMinute <= maxMinute;
    }

    public boolean isAdena() {
        return this._isAdena;
    }

    public void setIsAdena(boolean isAdena) {
        this._isAdena = isAdena;
    }

    public void addData(RewardData item) {
        if (!item.getItem().isAdena()) {
            this._isAdena = false;
        }
        this._items.add(item);
    }

    public List<RewardData> getItems() {
        return this._items;
    }

    public RewardGroup clone() {
        RewardGroup ret = new RewardGroup(this._chance, this._time);
        for (RewardData i : this._items) {
            ret.addData(i.clone());
        }
        return ret;
    }

    public List<RewardItem> roll(RewardType type, Player player, double penaltyMod, NpcInstance npc) {
        if (!this.checkTime(System.currentTimeMillis())) {
            return Collections.emptyList();
        }
        switch (type) {
            case NOT_RATED_GROUPED: 
            case NOT_RATED_NOT_GROUPED: {
                return this.rollItems(penaltyMod, 1.0, 1.0);
            }
            case EVENT_GROUPED: {
                if (!(npc == null || !npc.getReflection().isDefault() || npc.isRaid() || npc.getLeader() != null && npc.getLeader().isRaid())) {
                    return this.rollItems(penaltyMod * player.getDropChanceMod() / Config.DROP_CHANCE_MODIFIER, player.getRateItems() / Config.RATE_DROP_ITEMS_BY_LVL[player.getLevel()], player.getDropCountMod() / Config.DROP_COUNT_MODIFIER);
                }
                return Collections.emptyList();
            }
            case SWEEP: {
                return this.rollItems(penaltyMod * player.getSpoilChanceMod(), player.getRateSpoil() * (npc != null ? npc.getStat().calc(Stats.SPOIL_RATE_MULTIPLIER, 1.0, player, null) : 1.0), player.getSpoilCountMod());
            }
            case RATED_GROUPED: {
                if (this.isAdena()) {
                    return this.rollAdena(penaltyMod, player.getRateAdena() * (npc != null ? npc.getStat().calc(Stats.ADENA_RATE_MULTIPLIER, 1.0, player, null) : 1.0));
                }
                return this.rollItems(penaltyMod * npc.getDropChanceMod(player), npc != null ? npc.getRewardRate(player) * npc.getStat().calc(Stats.DROP_RATE_MULTIPLIER, 1.0, player, null) : player.getRateItems(), npc.getDropCountMod(player));
            }
        }
        return Collections.emptyList();
    }

    private List<RewardItem> rollAdena(double mod, double rate) {
        if (this.notRate()) {
            mod = Math.min(mod, 1.0);
            rate = 1.0;
        }
        if (mod > 0.0 && rate > 0.0 && this.getChance() > (double)Rnd.get((int)1000000)) {
            ArrayList<RewardItem> rolledItems = new ArrayList<RewardItem>();
            for (RewardData data : this.getItems()) {
                RewardItem item = data.rollAdena(mod, rate);
                if (item == null) continue;
                rolledItems.add(item);
            }
            if (rolledItems.isEmpty()) {
                return Collections.emptyList();
            }
            ArrayList<RewardItem> result = new ArrayList<RewardItem>();
            for (int i = 0; i < Config.MAX_DROP_ITEMS_FROM_ONE_GROUP; ++i) {
                RewardItem rolledItem = (RewardItem)Rnd.get(rolledItems);
                if (rolledItems.remove(rolledItem)) {
                    result.add(rolledItem);
                }
                if (rolledItems.isEmpty()) break;
            }
            return result;
        }
        return Collections.emptyList();
    }

    private List<RewardItem> rollItems(double mod, double rate, double countMod) {
        if (this.notRate()) {
            mod = Math.min(mod, 1.0);
            rate = 1.0;
        }
        if (mod > 0.0 && rate > 0.0) {
            double chance = this.getChance() * mod;
            if (chance > 1000000.0) {
                mod = (chance - 1000000.0) / this.getChance() + 1.0;
                chance = 1000000.0;
            } else {
                mod = 1.0;
            }
            if (chance > 0.0) {
                int rolledCount = 0;
                int mult = (int)Math.ceil(rate);
                if (chance >= 1000000.0) {
                    rolledCount = (int)rate;
                    if ((double)mult > rate && chance * (rate - (double)(mult - 1)) > (double)Rnd.get((int)1000000)) {
                        ++rolledCount;
                    }
                } else {
                    for (int n = 0; n < mult; ++n) {
                        if (!(chance * Math.min(rate - (double)n, 1.0) > (double)Rnd.get((int)1000000))) continue;
                        ++rolledCount;
                    }
                }
                if (rolledCount > 0) {
                    ArrayList<RewardItem> rolledItems = new ArrayList<RewardItem>();
                    for (RewardData data : this.getItems()) {
                        RewardItem item = data.rollItem(mod, rolledCount, countMod);
                        if (item == null) continue;
                        rolledItems.add(item);
                    }
                    if (rolledItems.isEmpty()) {
                        return Collections.emptyList();
                    }
                    ArrayList<RewardItem> result = new ArrayList<RewardItem>();
                    for (int i = 0; i < Config.MAX_DROP_ITEMS_FROM_ONE_GROUP; ++i) {
                        RewardItem rolledItem = (RewardItem)Rnd.get(rolledItems);
                        if (rolledItems.remove(rolledItem)) {
                            result.add(rolledItem);
                        }
                        if (rolledItems.isEmpty()) break;
                    }
                    return result;
                }
            }
        }
        return Collections.emptyList();
    }
}


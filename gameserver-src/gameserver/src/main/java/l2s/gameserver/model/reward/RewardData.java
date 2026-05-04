package l2s.gameserver.model.reward;

import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.reward.RewardItem;
import l2s.gameserver.templates.item.ItemTemplate;
import org.apache.commons.lang3.ArrayUtils;
import org.dom4j.Element;

public class RewardData
implements Cloneable {
    private ItemTemplate _item;
    private boolean _notRate = false;
    private long _mindrop;
    private long _maxdrop;
    private double _chance;

    public RewardData(int itemId) {
        this._item = ItemHolder.getInstance().getTemplate(itemId);
        if (this._item.isArrow() || this._item.isBolt() || Config.NO_RATE_EQUIPMENT && this._item.isEquipment() || Config.NO_RATE_KEY_MATERIAL && this._item.isKeyMatherial() || Config.NO_RATE_RECIPES && this._item.isRecipe() || ArrayUtils.contains((int[])Config.NO_RATE_ITEMS, (int)itemId)) {
            this._notRate = true;
        }
    }

    public RewardData(int itemId, long min, long max, double chance) {
        this(itemId);
        this._mindrop = min;
        this._maxdrop = max;
        this.setChance(chance);
    }

    public boolean notRate() {
        return this._notRate;
    }

    public void setNotRate(boolean notRate) {
        this._notRate = notRate;
    }

    public int getItemId() {
        return this._item.getItemId();
    }

    public ItemTemplate getItem() {
        return this._item;
    }

    public long getMinDrop() {
        return this._mindrop;
    }

    public long getMaxDrop() {
        return this._maxdrop;
    }

    public double getChance() {
        return this._chance;
    }

    public void setMinDrop(long mindrop) {
        this._mindrop = mindrop;
    }

    public void setMaxDrop(long maxdrop) {
        this._maxdrop = maxdrop;
    }

    public void setChance(double chance) {
        this._chance = Math.min(chance, 1000000.0);
    }

    public String toString() {
        return "ItemID: " + this.getItem() + " Min: " + this.getMinDrop() + " Max: " + this.getMaxDrop() + " Chance: " + this.getChance() / 10000.0 + "%";
    }

    public RewardData clone() {
        return new RewardData(this.getItemId(), this.getMinDrop(), this.getMaxDrop(), this.getChance());
    }

    public boolean equals(Object o) {
        if (o instanceof RewardData) {
            RewardData drop = (RewardData)o;
            return drop.getItemId() == this.getItemId();
        }
        return false;
    }

    public int hashCode() {
        return 18 * this.getItemId() + 184140;
    }

    public RewardItem roll(Player player, double mod) {
        if (this._item.isAdena()) {
            return this.rollAdena(mod, player.getRateAdena());
        }
        return this.rollItem(mod, player.getRateItems(), 1.0);
    }

    public RewardItem roll(double mod) {
        if (this._item.isAdena()) {
            return this.rollAdena(mod, 1.0);
        }
        return this.rollItem(mod, 1.0, 1.0);
    }

    protected RewardItem rollAdena(double mod, double rate) {
        double chance;
        if (this.notRate()) {
            mod = Math.min(mod, 1.0);
            rate = 1.0;
        }
        if (mod > 0.0 && rate > 0.0 && (chance = this.getChance() * mod) > (double)Rnd.get((int)1000000)) {
            RewardItem t = new RewardItem(this._item.getItemId());
            t.count = this.getMinDrop() >= this.getMaxDrop() ? (long)(rate * (double)this.getMinDrop()) : (long)(rate * (double)Rnd.get((long)this.getMinDrop(), (long)this.getMaxDrop()));
            return t;
        }
        return null;
    }

    protected RewardItem rollItem(double mod, double rate, double countMod) {
        double chance;
        if (this.notRate()) {
            mod = Math.min(mod, 1.0);
            rate = 1.0;
        }
        if (mod > 0.0 && rate > 0.0 && (chance = Math.min(1000000.0, this.getChance() * mod)) > 0.0) {
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
                RewardItem t = new RewardItem(this._item.getItemId());
                if (this._item.isStackable()) {
                    t.count = this.getMinDrop() >= this.getMaxDrop() ? (long)((double)((long)rolledCount * this.getMinDrop()) * countMod) : (long)((double)((long)rolledCount * Rnd.get((long)this.getMinDrop(), (long)this.getMaxDrop())) * countMod);
                }
                if (t.count > 0L) {
                    return t;
                }
            }
        }
        return null;
    }

    public static RewardData parseReward(Element rewardElement) {
        int itemId = Integer.parseInt(rewardElement.attributeValue("item_id"));
        int min = Integer.parseInt(rewardElement.attributeValue("min"));
        int max = Integer.parseInt(rewardElement.attributeValue("max"));
        int chance = (int)(Double.parseDouble(rewardElement.attributeValue("chance")) * 10000.0);
        RewardData data = new RewardData(itemId);
        data.setChance(chance);
        data.setMinDrop(min);
        data.setMaxDrop(max);
        return data;
    }
}


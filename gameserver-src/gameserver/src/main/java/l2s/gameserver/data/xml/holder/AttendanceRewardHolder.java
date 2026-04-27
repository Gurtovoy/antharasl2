/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.data.xml.AbstractHolder
 *  org.napile.primitive.maps.IntObjectMap
 *  org.napile.primitive.maps.impl.TreeIntObjectMap
 */
package l2s.gameserver.data.xml.holder;

import java.util.Collection;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.templates.item.data.AttendanceRewardData;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.TreeIntObjectMap;

public final class AttendanceRewardHolder
extends AbstractHolder {
    private static final AttendanceRewardHolder _instance = new AttendanceRewardHolder();
    private final IntObjectMap<AttendanceRewardData> _normalRewards = new TreeIntObjectMap();
    private final IntObjectMap<AttendanceRewardData> _premiumRewards = new TreeIntObjectMap();

    public static AttendanceRewardHolder getInstance() {
        return _instance;
    }

    public void addNormalReward(AttendanceRewardData reward) {
        this._normalRewards.put(this._normalRewards.size() + 1, reward);
    }

    public void addPremiumReward(AttendanceRewardData reward) {
        this._premiumRewards.put(this._premiumRewards.size() + 1, reward);
    }

    public Collection<AttendanceRewardData> getRewards(boolean premium) {
        return premium ? this._premiumRewards.valueCollection() : this._normalRewards.valueCollection();
    }

    public AttendanceRewardData getReward(int index, boolean premium) {
        return premium ? (AttendanceRewardData)this._premiumRewards.get(index) : (AttendanceRewardData)this._normalRewards.get(index);
    }

    public int size() {
        return this._normalRewards.size() + this._premiumRewards.size();
    }

    public void clear() {
        this._normalRewards.clear();
        this._premiumRewards.clear();
    }
}


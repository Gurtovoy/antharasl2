/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.templates.dailymissions;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.handler.dailymissions.DailyMissionHandlerHolder;
import l2s.gameserver.handler.dailymissions.IDailyMissionHandler;
import l2s.gameserver.templates.dailymissions.DailyRewardTemplate;

public class DailyMissionTemplate {
    private final int _id;
    private final IDailyMissionHandler _handler;
    private final int _value;
    private final int _minLevel;
    private final int _maxLevel;
    private final List<DailyRewardTemplate> _rewards = new ArrayList<DailyRewardTemplate>();

    public DailyMissionTemplate(int id, String handler, int value, int minLevel, int maxLevel) {
        this._id = id;
        this._handler = DailyMissionHandlerHolder.getInstance().getHandler(handler);
        this._value = value;
        this._minLevel = minLevel;
        this._maxLevel = maxLevel;
    }

    public int getId() {
        return this._id;
    }

    public IDailyMissionHandler getHandler() {
        return this._handler;
    }

    public int getValue() {
        return this._value;
    }

    public int getMinLevel() {
        return this._minLevel;
    }

    public int getMaxLevel() {
        return this._maxLevel;
    }

    public void addReward(DailyRewardTemplate reward) {
        this._rewards.add(reward);
    }

    public DailyRewardTemplate[] getRewards() {
        return this._rewards.toArray(new DailyRewardTemplate[this._rewards.size()]);
    }
}


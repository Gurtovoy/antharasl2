/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.entity.events.actions;

import java.util.List;
import l2s.gameserver.data.xml.holder.NpcHolder;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.EventAction;
import l2s.gameserver.model.reward.RewardGroup;
import l2s.gameserver.model.reward.RewardList;
import l2s.gameserver.templates.npc.NpcTemplate;

public class GlobalRewardListAction
implements EventAction {
    private final boolean _add;
    private final String _name;
    private final int _minLevel;
    private final int _maxLevel;

    public GlobalRewardListAction(boolean add, String name, int minLevel, int maxLevel) {
        this._add = add;
        this._name = name;
        this._minLevel = minLevel;
        this._maxLevel = maxLevel;
    }

    @Override
    public void call(Event event) {
        List list = event.getObjects(this._name);
        block0: for (NpcTemplate npc : NpcHolder.getInstance().getAll()) {
            if (npc == null || npc.isRaid || npc.getRewards().isEmpty() || npc.level < this._minLevel || npc.level > this._maxLevel) continue;
            for (RewardList rl : npc.getRewards()) {
                for (RewardGroup rg : rl) {
                    if (rg.isAdena()) continue;
                    for (Object o : list) {
                        if (!(o instanceof RewardList)) continue;
                        if (this._add) {
                            npc.addRewardList((RewardList)o);
                            continue;
                        }
                        npc.removeRewardList((RewardList)o);
                    }
                    continue block0;
                }
            }
        }
    }
}


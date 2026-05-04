package l2s.gameserver.model.entity.events.actions;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.EventAction;

public class GiveItemAction
implements EventAction {
    private int _itemId;
    private long _count;

    public GiveItemAction(int itemId, long count) {
        this._itemId = itemId;
        this._count = count;
    }

    @Override
    public void call(Event event) {
        for (Player player : event.itemObtainPlayers()) {
            event.giveItem(player, this._itemId, this._count);
        }
    }
}


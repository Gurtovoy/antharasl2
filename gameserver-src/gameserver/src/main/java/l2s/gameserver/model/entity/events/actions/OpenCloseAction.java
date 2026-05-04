package l2s.gameserver.model.entity.events.actions;

import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.EventAction;

public class OpenCloseAction
implements EventAction {
    private final boolean _open;
    private final String _name;

    public OpenCloseAction(boolean open, String name) {
        this._open = open;
        this._name = name;
    }

    @Override
    public void call(Event event) {
        event.openAction(this._name, this._open);
    }
}


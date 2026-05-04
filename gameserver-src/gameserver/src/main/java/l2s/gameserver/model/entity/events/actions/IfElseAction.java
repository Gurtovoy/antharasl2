/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity.events.actions;

import java.util.Collections;
import java.util.List;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.EventAction;

public class IfElseAction
implements EventAction {
    private String _name;
    private boolean _reverse;
    private List<EventAction> _ifList = Collections.emptyList();
    private List<EventAction> _elseList = Collections.emptyList();

    public IfElseAction(String name, boolean reverse) {
        this._name = name;
        this._reverse = reverse;
    }

    @Override
    public void call(Event event) {
        List<EventAction> list = (this._reverse ? !event.ifVar(this._name) : event.ifVar(this._name)) ? this._ifList : this._elseList;
        for (EventAction action : list) {
            action.call(event);
        }
    }

    public void setIfList(List<EventAction> ifList) {
        this._ifList = ifList;
    }

    public void setElseList(List<EventAction> elseList) {
        this._elseList = elseList;
    }
}


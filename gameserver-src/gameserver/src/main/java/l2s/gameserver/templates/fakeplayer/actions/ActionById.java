package l2s.gameserver.templates.fakeplayer.actions;

import java.util.Collections;
import java.util.List;
import l2s.gameserver.templates.fakeplayer.FakePlayerActionsHolder;
import l2s.gameserver.templates.fakeplayer.actions.AbstractAction;
import l2s.gameserver.templates.fakeplayer.actions.OrdinaryActions;
import org.dom4j.Element;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ActionById
extends AbstractAction {
    private static final Logger _log = LoggerFactory.getLogger(ActionById.class);
    private final FakePlayerActionsHolder _actionsHolder;
    private final int _actionId;

    public ActionById(FakePlayerActionsHolder actionsHolder, int actionId, double chance) {
        super(chance);
        this._actionsHolder = actionsHolder;
        this._actionId = actionId;
    }

    @Override
    public List<AbstractAction> makeActionsList() {
        OrdinaryActions action = this._actionsHolder.getAction(this._actionId);
        if (action == null) {
            _log.warn("Cannot find action by ID[" + this._actionId + "]!");
            return Collections.emptyList();
        }
        return action.makeActionsList();
    }

    public static ActionById parse(FakePlayerActionsHolder actionsHolder, Element element) {
        int actionId = Integer.parseInt(element.attributeValue("id"));
        double chance = element.attributeValue("chance") == null ? 100.0 : Double.parseDouble(element.attributeValue("chance"));
        return new ActionById(actionsHolder, actionId, chance);
    }
}


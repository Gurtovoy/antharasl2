package l2s.gameserver.model.entity.events.actions;

import l2s.gameserver.dao.AccountVariablesDAO;
import l2s.gameserver.dao.CharacterVariablesDAO;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.EventAction;

public class GlobalRemoveVariablesAction
implements EventAction {
    private final String _name;
    private final VariableType _type;

    public GlobalRemoveVariablesAction(String name, VariableType type) {
        this._name = name;
        this._type = type;
    }

    @Override
    public void call(Event event) {
        if (this._type == VariableType.PERSONAL) {
            for (Player player : GameObjectsStorage.getPlayers(true, true)) {
                player.unsetVar(this._name);
            }
            CharacterVariablesDAO.getInstance().delete(this._name);
        } else if (this._type == VariableType.ACCOUNT) {
            AccountVariablesDAO.getInstance().delete(this._name);
        }
    }

    public static enum VariableType {
        PERSONAL,
        ACCOUNT;

    }
}


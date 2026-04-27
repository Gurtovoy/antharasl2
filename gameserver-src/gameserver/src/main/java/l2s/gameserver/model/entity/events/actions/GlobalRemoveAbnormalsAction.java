/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.entity.events.actions;

import l2s.gameserver.dao.EffectsDAO;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.EventAction;

public class GlobalRemoveAbnormalsAction
implements EventAction {
    private final int _skillId;

    public GlobalRemoveAbnormalsAction(int skillId) {
        this._skillId = skillId;
    }

    @Override
    public void call(Event event) {
        if (this._skillId <= 0) {
            return;
        }
        for (Player player : GameObjectsStorage.getPlayers(true, true)) {
            player.getAbnormalList().stop(this._skillId);
        }
        EffectsDAO.getInstance().deleteBySkillId(this._skillId);
    }
}


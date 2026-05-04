package l2s.gameserver.templates.fakeplayer.actions;

import l2s.gameserver.ai.FakeAI;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.RestartType;
import l2s.gameserver.network.l2.c2s.RequestRestartPoint;
import l2s.gameserver.templates.fakeplayer.actions.AbstractAction;

public class ReviveAction
extends AbstractAction {
    public ReviveAction() {
        super(100.0);
    }

    @Override
    public boolean performAction(FakeAI ai) {
        Player player = ai.getActor();
        if (player.isDead()) {
            RequestRestartPoint.requestRestart(player, RestartType.TO_VILLAGE);
        }
        return true;
    }
}


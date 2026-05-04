/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.fakeplayer.actions;

import l2s.gameserver.ai.FakeAI;
import l2s.gameserver.templates.fakeplayer.actions.MoveAction;

public class StopFarmAction
extends MoveAction {
    public StopFarmAction(double chance) {
        super(chance);
    }

    @Override
    public boolean performAction(FakeAI ai) {
        return ai.clearCurrentFarmZone();
    }
}


/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.dom4j.Element
 */
package l2s.gameserver.templates.fakeplayer.actions;

import l2s.gameserver.ai.FakeAI;
import l2s.gameserver.model.Player;
import l2s.gameserver.templates.fakeplayer.actions.AbstractAction;
import org.dom4j.Element;

public class WaitAction
extends AbstractAction {
    private final int _minDelay;
    private final int _maxDelay;

    public WaitAction(int minDelay, int maxDelay, double chance) {
        super(chance);
        this._minDelay = minDelay;
        this._maxDelay = maxDelay;
    }

    @Override
    public boolean performAction(FakeAI ai) {
        ai.startWait(this._minDelay, this._maxDelay);
        return true;
    }

    @Override
    public boolean checkCondition(FakeAI ai, boolean force) {
        Player player = ai.getActor();
        if (player.isAttackingNow() || player.isCastingNow()) {
            return false;
        }
        return force || !player.getMovement().isMoving();
    }

    public static WaitAction parse(Element element) {
        int minDelay = element.attributeValue("delay") != null ? Integer.parseInt(element.attributeValue("delay")) : Integer.parseInt(element.attributeValue("min_delay"));
        int maxDelay = element.attributeValue("max_delay") == null ? minDelay : Integer.parseInt(element.attributeValue("max_delay"));
        double chance = element.attributeValue("chance") == null ? 100.0 : Double.parseDouble(element.attributeValue("chance"));
        return new WaitAction(minDelay, maxDelay, chance);
    }
}


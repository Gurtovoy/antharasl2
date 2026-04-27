/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.util.Rnd
 *  org.dom4j.Element
 */
package l2s.gameserver.templates.fakeplayer.actions;

import l2s.commons.util.Rnd;
import l2s.gameserver.ai.FakeAI;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.Experience;
import l2s.gameserver.templates.fakeplayer.actions.AbstractAction;
import org.dom4j.Element;

public class AddLevelAction
extends AbstractAction {
    private final int _minCount;
    private final int _maxCount;

    public AddLevelAction(int minCount, int maxCount, double chance) {
        super(chance);
        this._minCount = minCount;
        this._maxCount = maxCount;
    }

    @Override
    public boolean performAction(FakeAI ai) {
        Player player = ai.getActor();
        long exp_add = Experience.getExpForLevel(player.getLevel() + Rnd.get((int)this._minCount, (int)this._maxCount)) - player.getExp();
        player.addExpAndSp(exp_add, 0L, true);
        return true;
    }

    public static AddLevelAction parse(Element element) {
        int minCount = element.attributeValue("count") != null ? Integer.parseInt(element.attributeValue("count")) : Integer.parseInt(element.attributeValue("min_count"));
        int maxCount = element.attributeValue("max_count") == null ? minCount : Integer.parseInt(element.attributeValue("max_count"));
        double chance = element.attributeValue("chance") == null ? 100.0 : Double.parseDouble(element.attributeValue("chance"));
        return new AddLevelAction(minCount, maxCount, chance);
    }
}


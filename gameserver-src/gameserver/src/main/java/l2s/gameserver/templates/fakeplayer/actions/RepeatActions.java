/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.util.Rnd
 *  org.dom4j.Element
 */
package l2s.gameserver.templates.fakeplayer.actions;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import l2s.commons.util.Rnd;
import l2s.gameserver.templates.fakeplayer.FakePlayerActionsHolder;
import l2s.gameserver.templates.fakeplayer.actions.AbstractAction;
import l2s.gameserver.templates.fakeplayer.actions.OrdinaryActions;
import org.dom4j.Element;

public class RepeatActions
extends OrdinaryActions {
    private final int _minCount;
    private final int _maxCount;

    public RepeatActions(List<AbstractAction> actions, int minCount, int maxCount, double chance) {
        super(actions, chance);
        this._minCount = minCount;
        this._maxCount = maxCount;
    }

    @Override
    public List<AbstractAction> makeActionsList() {
        int count = Rnd.get((int)this._minCount, (int)this._maxCount);
        if (count == 1) {
            return super.makeActionsList();
        }
        if (count <= 0) {
            return Collections.emptyList();
        }
        ArrayList<AbstractAction> actions = new ArrayList<AbstractAction>();
        for (int i = 0; i < count; ++i) {
            actions.addAll(super.makeActionsList());
        }
        return actions;
    }

    public static RepeatActions parse(FakePlayerActionsHolder actionsHolder, Element element) {
        List<AbstractAction> actions = RepeatActions.parseActions(actionsHolder, element);
        int minCount = element.attributeValue("count") != null ? Integer.parseInt(element.attributeValue("count")) : Integer.parseInt(element.attributeValue("min_count"));
        int maxCount = element.attributeValue("max_count") == null ? minCount : Integer.parseInt(element.attributeValue("max_count"));
        double chance = element.attributeValue("chance") == null ? 100.0 : Double.parseDouble(element.attributeValue("chance"));
        return new RepeatActions(actions, minCount, maxCount, chance);
    }
}


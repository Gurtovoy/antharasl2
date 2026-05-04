/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.fakeplayer.actions;

import java.util.List;
import l2s.gameserver.templates.fakeplayer.FakePlayerActionsHolder;
import l2s.gameserver.templates.fakeplayer.actions.AbstractAction;
import l2s.gameserver.templates.fakeplayer.actions.OrdinaryActions;
import org.dom4j.Element;

public class GoToTownActions
extends OrdinaryActions {
    private final int _minFarmTime;
    private final int _maxFarmTime;

    public GoToTownActions(List<AbstractAction> actions, int minFarmTime, int maxFarmTime, double chance) {
        super(actions, chance);
        this._minFarmTime = minFarmTime;
        this._maxFarmTime = maxFarmTime;
    }

    public int getMinFarmTime() {
        return this._minFarmTime;
    }

    public int getMaxFarmTime() {
        return this._maxFarmTime;
    }

    public static GoToTownActions parse(FakePlayerActionsHolder actionsHolder, Element element) {
        List<AbstractAction> actions = GoToTownActions.parseActions(actionsHolder, element);
        int minFarmTime = element.attributeValue("farm_time") != null ? Integer.parseInt(element.attributeValue("farm_time")) : Integer.parseInt(element.attributeValue("min_farm_time"));
        int maxFarmTime = element.attributeValue("max_farm_time") == null ? minFarmTime : Integer.parseInt(element.attributeValue("max_farm_time"));
        double chance = element.attributeValue("chance") == null ? 100.0 : Double.parseDouble(element.attributeValue("chance"));
        return new GoToTownActions(actions, minFarmTime, maxFarmTime, chance);
    }
}


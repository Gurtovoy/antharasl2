/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.dom4j.Element
 */
package l2s.gameserver.templates.fakeplayer.actions;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import l2s.gameserver.templates.fakeplayer.FakePlayerActionsHolder;
import l2s.gameserver.templates.fakeplayer.actions.AbstractAction;
import l2s.gameserver.templates.fakeplayer.actions.ActionById;
import l2s.gameserver.templates.fakeplayer.actions.AddItemAction;
import l2s.gameserver.templates.fakeplayer.actions.AddLevelAction;
import l2s.gameserver.templates.fakeplayer.actions.FarmAction;
import l2s.gameserver.templates.fakeplayer.actions.MoveToNpcAction;
import l2s.gameserver.templates.fakeplayer.actions.MoveToPointAction;
import l2s.gameserver.templates.fakeplayer.actions.RandomAction;
import l2s.gameserver.templates.fakeplayer.actions.RepeatActions;
import l2s.gameserver.templates.fakeplayer.actions.SpeakWithNpcAction;
import l2s.gameserver.templates.fakeplayer.actions.TeleportToClosestTownAction;
import l2s.gameserver.templates.fakeplayer.actions.TeleportToPointAction;
import l2s.gameserver.templates.fakeplayer.actions.UseCommunityAction;
import l2s.gameserver.templates.fakeplayer.actions.UseItemAction;
import l2s.gameserver.templates.fakeplayer.actions.WaitAction;
import org.dom4j.Element;

public class OrdinaryActions
extends AbstractAction {
    private final List<AbstractAction> _actions;

    public OrdinaryActions(List<AbstractAction> actions, double chance) {
        super(chance);
        this._actions = actions;
    }

    @Override
    public List<AbstractAction> makeActionsList() {
        return this._actions;
    }

    public static List<AbstractAction> parseActions(FakePlayerActionsHolder actionsHolder, Element element) {
        ArrayList<AbstractAction> actions = new ArrayList<AbstractAction>();
        Iterator iterator = element.elementIterator();
        while (iterator.hasNext()) {
            Element actionElement = (Element)iterator.next();
            String actionElementName = actionElement.getName();
            if (actionElementName.equals("action")) {
                actions.add(ActionById.parse(actionsHolder, actionElement));
                continue;
            }
            if (actionElementName.equals("add_item")) {
                actions.add(AddItemAction.parse(actionElement));
                continue;
            }
            if (actionElementName.equals("add_level")) {
                actions.add(AddLevelAction.parse(actionElement));
                continue;
            }
            if (actionElementName.equals("farm")) {
                actions.add(FarmAction.parse(actionElement));
                continue;
            }
            if (actionElementName.equals("move_to_npc")) {
                actions.add(MoveToNpcAction.parse(actionElement));
                continue;
            }
            if (actionElementName.equals("move_to_point")) {
                actions.add(MoveToPointAction.parse(actionElement));
                continue;
            }
            if (actionElementName.equals("ordinary_actions")) {
                actions.add(OrdinaryActions.parse(actionsHolder, actionElement));
                continue;
            }
            if (actionElementName.equals("random_action")) {
                actions.add(RandomAction.parse(actionsHolder, actionElement));
                continue;
            }
            if (actionElementName.equals("repeat_actions")) {
                actions.add(RepeatActions.parse(actionsHolder, actionElement));
                continue;
            }
            if (actionElementName.equals("speak_with_npc")) {
                actions.add(SpeakWithNpcAction.parse(actionElement));
                continue;
            }
            if (actionElementName.equals("teleport_to_closest_town")) {
                actions.add(TeleportToClosestTownAction.parse(actionElement));
                continue;
            }
            if (actionElementName.equals("teleport_to_point")) {
                actions.add(TeleportToPointAction.parse(actionElement));
                continue;
            }
            if (actionElementName.equals("use_community")) {
                actions.add(UseCommunityAction.parse(actionElement));
                continue;
            }
            if (actionElementName.equals("use_item")) {
                actions.add(UseItemAction.parse(actionElement));
                continue;
            }
            if (!actionElementName.equals("wait")) continue;
            actions.add(WaitAction.parse(actionElement));
        }
        return actions;
    }

    public static OrdinaryActions parse(FakePlayerActionsHolder actionsHolder, Element element) {
        List<AbstractAction> actions = OrdinaryActions.parseActions(actionsHolder, element);
        double chance = element.attributeValue("chance") == null ? 100.0 : Double.parseDouble(element.attributeValue("chance"));
        return new OrdinaryActions(actions, chance);
    }
}


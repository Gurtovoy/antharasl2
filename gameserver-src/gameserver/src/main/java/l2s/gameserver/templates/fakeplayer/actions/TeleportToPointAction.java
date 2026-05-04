/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.fakeplayer.actions;

import l2s.gameserver.ai.FakeAI;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.templates.fakeplayer.actions.AbstractAction;
import org.dom4j.Element;

public class TeleportToPointAction
extends AbstractAction {
    private final Location _loc;
    private final int _minRange;
    private final int _maxRange;

    public TeleportToPointAction(Location loc, int minRange, int maxRange, double chance) {
        super(chance);
        this._loc = loc;
        this._minRange = minRange;
        this._maxRange = maxRange;
    }

    @Override
    public boolean performAction(FakeAI ai) {
        ai.getActor().teleToLocation(Location.coordsRandomize(this._loc, this._minRange, this._maxRange));
        return true;
    }

    public static TeleportToPointAction parse(Element element) {
        Location loc = Location.parse(element);
        int minRange = element.attributeValue("range") != null ? Integer.parseInt(element.attributeValue("range")) : Integer.parseInt(element.attributeValue("min_range"));
        int maxRange = element.attributeValue("max_range") == null ? minRange : Integer.parseInt(element.attributeValue("max_range"));
        double chance = element.attributeValue("chance") == null ? 100.0 : Double.parseDouble(element.attributeValue("chance"));
        return new TeleportToPointAction(loc, minRange, maxRange, chance);
    }
}


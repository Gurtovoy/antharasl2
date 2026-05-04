/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity.events.objects;

import java.util.List;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.objects.InitableObject;

public class ZoneObject
implements InitableObject {
    private String _name;
    private Zone _zone;

    public ZoneObject(String name) {
        this._name = name;
    }

    @Override
    public void initObject(Event e) {
        Reflection r = e.getReflection();
        this._zone = r.getZone(this._name);
    }

    public void setActive(boolean a) {
        this._zone.setActive(a);
    }

    public void setActive(boolean a, Event event) {
        this.setActive(a);
        if (a) {
            this._zone.addEvent(event);
        } else {
            this._zone.removeEvent(event);
        }
    }

    public String getName() {
        return this._name;
    }

    public Zone getZone() {
        return this._zone;
    }

    public List<Player> getInsidePlayers() {
        return this._zone.getInsidePlayers();
    }

    public boolean checkIfInZone(Creature c) {
        return this._zone.checkIfInZone(c);
    }
}


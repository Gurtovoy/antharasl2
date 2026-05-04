/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.holder;

import java.util.HashMap;
import java.util.Map;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.util.Rnd;
import l2s.gameserver.model.Zone;
import l2s.gameserver.templates.ZoneTemplate;
import l2s.gameserver.utils.ReflectionUtils;

public class ZoneHolder
extends AbstractHolder {
    private static final ZoneHolder _instance = new ZoneHolder();
    private final Map<String, ZoneTemplate> _zones = new HashMap<String, ZoneTemplate>();

    public static ZoneHolder getInstance() {
        return _instance;
    }

    public void addTemplate(ZoneTemplate zone) {
        this._zones.put(zone.getName(), zone);
    }

    public ZoneTemplate getTemplate(String name) {
        return this._zones.get(name);
    }

    public Map<String, ZoneTemplate> getZones() {
        return this._zones;
    }

    public Zone getRandomZone() {
        Zone zone;
        String _zoneName = "";
        int index = Rnd.get((int)1, (int)(this.getZones().size() - 1));
        int inx = 0;
        for (String tmp : this.getZones().keySet()) {
            if (index == inx) {
                _zoneName = tmp;
                break;
            }
            ++inx;
        }
        if ((zone = ReflectionUtils.getZone(_zoneName)) == null) {
            System.out.println("null zone randomized");
            return this.getRandomZone();
        }
        return zone;
    }

    public int size() {
        return this._zones.size();
    }

    public void clear() {
        this._zones.clear();
    }
}


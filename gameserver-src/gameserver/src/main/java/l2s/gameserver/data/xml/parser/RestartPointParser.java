package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.commons.geometry.Polygon;
import l2s.commons.geometry.Rectangle;
import l2s.commons.geometry.Shape;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.parser.ZoneParser;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.geometry.Territory;
import l2s.gameserver.instancemanager.MapRegionManager;
import l2s.gameserver.model.World;
import l2s.gameserver.model.base.Race;
import l2s.gameserver.templates.mapregion.RestartArea;
import l2s.gameserver.templates.mapregion.RestartPoint;
import org.apache.commons.lang3.tuple.ImmutablePair;
import org.apache.commons.lang3.tuple.Pair;
import org.dom4j.Attribute;
import org.dom4j.Element;

public class RestartPointParser
extends AbstractParser<MapRegionManager> {
    private static final RestartPointParser _instance = new RestartPointParser();

    public static RestartPointParser getInstance() {
        return _instance;
    }

    private RestartPointParser() {
        super(MapRegionManager.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/mapregion/restart_points.xml");
    }

    public String getDTDFileName() {
        return "restart_points.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        ArrayList<ImmutablePair> restartArea = new ArrayList<ImmutablePair>();
        HashMap<String, RestartPoint> restartPoint = new HashMap<String, RestartPoint>();
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            if ("restart_area".equals(element.getName())) {
                Territory territory = null;
                HashMap<Race, String> restarts = new HashMap<Race, String>();
                Iterator i = element.elementIterator();
                while (i.hasNext()) {
                    Shape shape;
                    Element n = (Element)i.next();
                    if ("region".equalsIgnoreCase(n.getName())) {
                        Attribute map = n.attribute("map");
                        String s = map.getValue();
                        String[] val = s.split("_");
                        int rx = Integer.parseInt(val[0]);
                        int ry = Integer.parseInt(val[1]);
                        int x1 = World.MAP_MIN_X + (rx - Config.GEO_X_FIRST << 15);
                        int y1 = World.MAP_MIN_Y + (ry - Config.GEO_Y_FIRST << 15);
                        int x2 = x1 + 32768 - 1;
                        int y2 = y1 + 32768 - 1;
                        shape = new Rectangle(x1, y1, x2, y2);
                        ((Rectangle)shape).setZmin(World.MAP_MIN_Z);
                        ((Rectangle)shape).setZmax(World.MAP_MAX_Z);
                        if (territory == null) {
                            territory = new Territory();
                        }
                        territory.add((Shape)shape);
                        continue;
                    }
                    if ("polygon".equalsIgnoreCase(n.getName())) {
                        shape = ZoneParser.parsePolygon(n);
                        if (!((Polygon)shape).validate()) {
                            this.error("RestartPointParser: invalid territory data : " + shape + "!");
                        }
                        if (territory == null) {
                            territory = new Territory();
                        }
                        territory.add((Shape)shape);
                        continue;
                    }
                    if (!"restart".equalsIgnoreCase(n.getName())) continue;
                    Race race = Race.valueOf(n.attributeValue("race").toUpperCase());
                    String locName = n.attributeValue("loc");
                    restarts.put(race, locName);
                }
                if (territory == null) {
                    throw new RuntimeException("RestartPointParser: empty territory!");
                }
                if (restarts.isEmpty()) {
                    throw new RuntimeException("RestartPointParser: restarts not defined!");
                }
                restartArea.add(new ImmutablePair(territory, restarts));
                continue;
            }
            if (!"restart_loc".equals(element.getName())) continue;
            String name = element.attributeValue("name");
            int bbs = Integer.parseInt(element.attributeValue("bbs", "0"));
            int msgId = Integer.parseInt(element.attributeValue("msg_id", "0"));
            ArrayList<Location> restartPoints = new ArrayList<Location>();
            ArrayList<Location> PKrestartPoints = new ArrayList<Location>();
            Iterator i = element.elementIterator();
            while (i.hasNext()) {
                Location loc;
                Element d;
                Iterator ii;
                Element n = (Element)i.next();
                if ("restart_point".equals(n.getName())) {
                    ii = n.elementIterator();
                    while (ii.hasNext()) {
                        d = (Element)ii.next();
                        if (!"coords".equalsIgnoreCase(d.getName())) continue;
                        loc = Location.parseLoc(d.attribute("loc").getValue());
                        restartPoints.add(loc);
                    }
                    continue;
                }
                if (!"PKrestart_point".equals(n.getName())) continue;
                ii = n.elementIterator();
                while (ii.hasNext()) {
                    d = (Element)ii.next();
                    if (!"coords".equalsIgnoreCase(d.getName())) continue;
                    loc = Location.parseLoc(d.attribute("loc").getValue());
                    PKrestartPoints.add(loc);
                }
            }
            if (restartPoints.isEmpty()) {
                throw new RuntimeException("RestartPointParser: restart_points not defined for restart_loc : " + name + "!");
            }
            if (PKrestartPoints.isEmpty()) {
                PKrestartPoints = restartPoints;
            }
            RestartPoint rp = new RestartPoint(name, bbs, msgId, restartPoints, PKrestartPoints);
            restartPoint.put(name, rp);
        }
        for (Pair pair : restartArea) {
            HashMap<Race, RestartPoint> restarts = new HashMap<Race, RestartPoint>();
            for (Map.Entry<Race, String> e : ((Map<Race, String>)pair.getValue()).entrySet()) {
                RestartPoint rp = (RestartPoint)restartPoint.get(e.getValue());
                if (rp == null) {
                    throw new RuntimeException("RestartPointParser: restart_loc not found : " + e.getValue() + "!");
                }
                restarts.put(e.getKey(), rp);
                ((MapRegionManager)this.getHolder()).addRegionData(new RestartArea((Territory)pair.getKey(), restarts));
            }
        }
    }
}


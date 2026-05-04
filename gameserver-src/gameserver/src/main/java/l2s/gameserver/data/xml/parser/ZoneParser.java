package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;
import l2s.commons.geometry.Circle;
import l2s.commons.geometry.Polygon;
import l2s.commons.geometry.Rectangle;
import l2s.commons.geometry.Shape;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.ZoneHolder;
import l2s.gameserver.data.xml.parser.StatParser;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.geometry.Territory;
import l2s.gameserver.model.World;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.ZoneTemplate;
import org.dom4j.Element;

public class ZoneParser
extends StatParser<ZoneHolder> {
    private static final ZoneParser _instance = new ZoneParser();

    public static ZoneParser getInstance() {
        return _instance;
    }

    protected ZoneParser() {
        super(ZoneHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/zone/");
    }

    public File getCustomXMLPath() {
        return new File(Config.DATAPACK_ROOT, "custom/zone/");
    }

    public String getDTDFileName() {
        return "zone.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator("zone");
        while (iterator.hasNext()) {
            Element zoneElement = (Element)iterator.next();
            StatsSet zoneDat = new StatsSet();
            zoneDat.set("name", zoneElement.attributeValue("name"));
            zoneDat.set("type", zoneElement.attributeValue("type"));
            ZoneTemplate template = ZoneParser.parseZone(zoneElement, zoneDat);
            if (template == null) continue;
            ((ZoneHolder)this.getHolder()).addTemplate(template);
        }
    }

    public static ZoneTemplate parseZone(Element zoneElement, StatsSet zoneDat) throws Exception {
        Territory territory = null;
        Iterator i = zoneElement.elementIterator();
        while (i.hasNext()) {
            Shape shape;
            Location loc;
            Element d;
            Iterator ii;
            Element n = (Element)i.next();
            if ("set".equals(n.getName())) {
                zoneDat.set(n.attributeValue("name"), n.attributeValue("value"));
                continue;
            }
            if ("restart_point".equals(n.getName())) {
                ArrayList<Location> restartPoints = new ArrayList<Location>();
                ii = n.elementIterator();
                while (ii.hasNext()) {
                    d = (Element)ii.next();
                    if (!"coords".equalsIgnoreCase(d.getName())) continue;
                    loc = Location.parseLoc(d.attribute("loc").getValue());
                    restartPoints.add(loc);
                }
                zoneDat.set("restart_points", restartPoints);
                continue;
            }
            if ("PKrestart_point".equals(n.getName())) {
                ArrayList<Location> PKrestartPoints = new ArrayList<Location>();
                ii = n.elementIterator();
                while (ii.hasNext()) {
                    d = (Element)ii.next();
                    if (!"coords".equalsIgnoreCase(d.getName())) continue;
                    loc = Location.parseLoc(d.attribute("loc").getValue());
                    PKrestartPoints.add(loc);
                }
                zoneDat.set("PKrestart_points", PKrestartPoints);
                continue;
            }
            boolean isShape = "rectangle".equalsIgnoreCase(n.getName());
            if (isShape || "banned_rectangle".equalsIgnoreCase(n.getName())) {
                shape = ZoneParser.parseRectangle(n);
                if (territory == null) {
                    territory = new Territory();
                    zoneDat.set("territory", territory);
                }
                if (isShape) {
                    territory.add((Shape)shape);
                    continue;
                }
                territory.addBanned((Shape)shape);
                continue;
            }
            isShape = "circle".equalsIgnoreCase(n.getName());
            if (isShape || "banned_cicrcle".equalsIgnoreCase(n.getName())) {
                shape = ZoneParser.parseCircle(n);
                if (territory == null) {
                    territory = new Territory();
                    zoneDat.set("territory", territory);
                }
                if (isShape) {
                    territory.add((Shape)shape);
                    continue;
                }
                territory.addBanned((Shape)shape);
                continue;
            }
            isShape = "polygon".equalsIgnoreCase(n.getName());
            if (isShape || "banned_polygon".equalsIgnoreCase(n.getName())) {
                shape = ZoneParser.parsePolygon(n);
                if (!((Polygon)shape).validate()) {
                    ZoneParser.getInstance().error("ZoneParser: invalid territory data : " + shape + ", zone: " + zoneDat.getString("name") + "!");
                }
                if (territory == null) {
                    territory = new Territory();
                    zoneDat.set("territory", territory);
                }
                if (isShape) {
                    territory.add((Shape)shape);
                    continue;
                }
                territory.addBanned((Shape)shape);
                continue;
            }
            isShape = "map".equalsIgnoreCase(n.getName());
            if (!isShape && !"banned_map".equalsIgnoreCase(n.getName())) continue;
            shape = ZoneParser.parseMap(n);
            if (territory == null) {
                territory = new Territory();
                zoneDat.set("territory", territory);
            }
            if (isShape) {
                territory.add((Shape)shape);
                continue;
            }
            territory.addBanned((Shape)shape);
        }
        if (territory == null || territory.getTerritories().isEmpty()) {
            ZoneParser.getInstance().error("Empty territory for zone: " + zoneDat.get("name"));
            return null;
        }
        ZoneTemplate template = new ZoneTemplate(zoneDat);
        Iterator i2 = zoneElement.elementIterator("for");
        while (i2.hasNext()) {
            ZoneParser.getInstance().parseFor((Element)i2.next(), template, new int[0]);
        }
        return template;
    }

    public static Rectangle parseRectangle(Element n) throws Exception {
        int zmin = World.MAP_MIN_Z;
        int zmax = World.MAP_MAX_Z;
        Iterator i = n.elementIterator();
        Element d = (Element)i.next();
        String[] coord = d.attributeValue("loc").split("[\\s,;]+");
        int x1 = Integer.parseInt(coord[0]);
        int y1 = Integer.parseInt(coord[1]);
        if (coord.length > 2) {
            zmin = Integer.parseInt(coord[2]);
            zmax = Integer.parseInt(coord[3]);
        }
        d = (Element)i.next();
        coord = d.attributeValue("loc").split("[\\s,;]+");
        int x2 = Integer.parseInt(coord[0]);
        int y2 = Integer.parseInt(coord[1]);
        if (coord.length > 2) {
            zmin = Integer.parseInt(coord[2]);
            zmax = Integer.parseInt(coord[3]);
        }
        Rectangle rectangle = new Rectangle(x1, y1, x2, y2);
        rectangle.setZmin(zmin);
        rectangle.setZmax(zmax);
        return rectangle;
    }

    public static Polygon parsePolygon(Element shape) throws Exception {
        Polygon poly = new Polygon();
        Iterator i = shape.elementIterator();
        while (i.hasNext()) {
            Element d = (Element)i.next();
            if (!"coords".equals(d.getName())) continue;
            String[] coord = d.attributeValue("loc").split("[\\s,;]+");
            if (coord.length < 3) {
                poly.add(Integer.parseInt(coord[0]), Integer.parseInt(coord[1])).setZmin(World.MAP_MIN_Z).setZmax(World.MAP_MAX_Z);
                continue;
            }
            if (coord.length < 4) {
                poly.add(Integer.parseInt(coord[0]), Integer.parseInt(coord[1])).setZmin(Integer.parseInt(coord[2])).setZmax(World.MAP_MAX_Z);
                continue;
            }
            poly.add(Integer.parseInt(coord[0]), Integer.parseInt(coord[1])).setZmin(Integer.parseInt(coord[2])).setZmax(Integer.parseInt(coord[3]));
        }
        return poly;
    }

    public static Circle parseCircle(Element shape) throws Exception {
        String[] coord = shape.attribute("loc").getValue().split("[\\s,;]+");
        Circle circle = coord.length < 4 ? new Circle(Integer.parseInt(coord[0]), Integer.parseInt(coord[1]), Integer.parseInt(coord[2])).setZmin(World.MAP_MIN_Z).setZmax(World.MAP_MAX_Z) : (coord.length < 5 ? new Circle(Integer.parseInt(coord[0]), Integer.parseInt(coord[1]), Integer.parseInt(coord[2])).setZmin(Integer.parseInt(coord[3])).setZmax(World.MAP_MAX_Z) : new Circle(Integer.parseInt(coord[0]), Integer.parseInt(coord[1]), Integer.parseInt(coord[2])).setZmin(Integer.parseInt(coord[3])).setZmax(Integer.parseInt(coord[4])));
        return circle;
    }

    public static Rectangle parseMap(Element n) throws Exception {
        String[] map = n.attributeValue("value").split("_");
        int rx = Integer.parseInt(map[0]);
        int ry = Integer.parseInt(map[1]);
        int x1 = World.MAP_MIN_X + (rx - Config.GEO_X_FIRST << 15);
        int y1 = World.MAP_MIN_Y + (ry - Config.GEO_Y_FIRST << 15);
        int x2 = x1 + 32768 - 1;
        int y2 = y1 + 32768 - 1;
        Rectangle rectangle = new Rectangle(x1, y1, x2, y2);
        rectangle.setZmin(World.MAP_MIN_Z);
        rectangle.setZmax(World.MAP_MAX_Z);
        return rectangle;
    }

    @Override
    protected Object getTableValue(String name, int ... arg) {
        return null;
    }
}


package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.StringTokenizer;
import l2s.commons.collections.MultiValueSet;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.commons.geometry.Circle;
import l2s.commons.geometry.Point2D;
import l2s.commons.geometry.Polygon;
import l2s.commons.geometry.Rectangle;
import l2s.commons.geometry.Shape;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.SpawnHolder;
import l2s.gameserver.geometry.Territory;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.npc.MinionData;
import l2s.gameserver.templates.spawn.PeriodOfDay;
import l2s.gameserver.templates.spawn.SpawnNpcInfo;
import l2s.gameserver.templates.spawn.SpawnPoint;
import l2s.gameserver.templates.spawn.SpawnTemplate;
import org.dom4j.Element;

public final class SpawnParser
extends AbstractParser<SpawnHolder> {
    private static final SpawnParser _instance = new SpawnParser();

    public static SpawnParser getInstance() {
        return _instance;
    }

    protected SpawnParser() {
        super(SpawnHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/spawn/");
    }

    public File getCustomXMLPath() {
        return new File(Config.DATAPACK_ROOT, "custom/spawn/");
    }

    public String getDTDFileName() {
        return "spawn.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        HashMap<String, Territory> territories = new HashMap<String, Territory>();
        Iterator spawnIterator = rootElement.elementIterator();
        while (spawnIterator.hasNext()) {
            PeriodOfDay periodOfDay;
            Element spawnElement = (Element)spawnIterator.next();
            if (spawnElement.getName().equalsIgnoreCase("territory")) {
                String terName = spawnElement.attributeValue("name");
                Territory territory = this.parseTerritory(terName, spawnElement);
                territories.put(terName, territory);
                continue;
            }
            if (!spawnElement.getName().equalsIgnoreCase("spawn")) continue;
            String group = spawnElement.attributeValue("group");
            String name = spawnElement.attributeValue("name") == null ? (group == null ? "" : group) : spawnElement.attributeValue("name");
            int respawn = spawnElement.attributeValue("respawn") == null ? 60 : Integer.parseInt(spawnElement.attributeValue("respawn"));
            int respawnRandom = spawnElement.attributeValue("respawn_random") == null ? 0 : Integer.parseInt(spawnElement.attributeValue("respawn_random"));
            String respawnPattern = spawnElement.attributeValue("respawn_pattern");
            int count = spawnElement.attributeValue("count") == null ? 1 : Integer.parseInt(spawnElement.attributeValue("count"));
            PeriodOfDay periodOfDay2 = periodOfDay = spawnElement.attributeValue("period_of_day") == null ? PeriodOfDay.NONE : PeriodOfDay.valueOf(spawnElement.attributeValue("period_of_day").toUpperCase());
            if (group == null) {
                group = periodOfDay.name();
            }
            SpawnTemplate template = new SpawnTemplate(name, periodOfDay, count, respawn, respawnRandom, respawnPattern);
            String territory = spawnElement.attributeValue("territory");
            if (territory != null) {
                StringTokenizer st = new StringTokenizer(territory, ";");
                while (st.hasMoreTokens()) {
                    String terName = st.nextToken().trim();
                    Territory t = (Territory)territories.get(terName);
                    if (t == null) {
                        this.error("Invalid territory name: " + terName + "; " + this.getCurrentFileName());
                        continue;
                    }
                    template.addTerritory(terName, t);
                }
            }
            Iterator subIterator = spawnElement.elementIterator();
            while (subIterator.hasNext()) {
                Territory t;
                Element subElement = (Element)subIterator.next();
                if (subElement.getName().equalsIgnoreCase("point")) {
                    int x = Integer.parseInt(subElement.attributeValue("x"));
                    int y = Integer.parseInt(subElement.attributeValue("y"));
                    int z = Integer.parseInt(subElement.attributeValue("z"));
                    int h = subElement.attributeValue("h") == null ? -1 : Integer.parseInt(subElement.attributeValue("h"));
                    double chance = subElement.attributeValue("chance") == null ? 100.0 : Double.parseDouble(subElement.attributeValue("chance"));
                    template.addSpawnPoint(new SpawnPoint(x, y, z, h, chance));
                    continue;
                }
                if (subElement.getName().equalsIgnoreCase("rectangle")) {
                    int x1 = Integer.parseInt(subElement.attributeValue("x1"));
                    int y1 = Integer.parseInt(subElement.attributeValue("y1"));
                    int x2 = Integer.parseInt(subElement.attributeValue("x2"));
                    int y2 = Integer.parseInt(subElement.attributeValue("y2"));
                    int zmin = Integer.parseInt(subElement.attributeValue("zmin"));
                    int zmax = Integer.parseInt(subElement.attributeValue("zmax"));
                    Rectangle rectangle = new Rectangle(x1, y1, x2, y2);
                    rectangle.setZmin(zmin);
                    rectangle.setZmax(zmax);
                    t = new Territory();
                    t.add((Shape)rectangle);
                    template.addTerritory("rectangle: " + x1 + " " + y1 + " " + x2 + " " + y2 + " " + zmin + " " + zmax, t);
                    continue;
                }
                if (subElement.getName().equalsIgnoreCase("circle")) {
                    int x = Integer.parseInt(subElement.attributeValue("x"));
                    int y = Integer.parseInt(subElement.attributeValue("y"));
                    int zmin = Integer.parseInt(subElement.attributeValue("zmin"));
                    int zmax = Integer.parseInt(subElement.attributeValue("zmax"));
                    int radius = Integer.parseInt(subElement.attributeValue("radius"));
                    Circle circle = new Circle(x, y, radius);
                    circle.setZmin(zmin);
                    circle.setZmax(zmax);
                    Territory t2 = new Territory();
                    t2.add((Shape)circle);
                    template.addTerritory("circle: " + x + " " + y + " " + zmin + " " + zmax + " " + radius, t2);
                    continue;
                }
                if (subElement.getName().equalsIgnoreCase("territory")) {
                    String terName = subElement.attributeValue("name");
                    if (terName != null) {
                        Territory t3 = (Territory)territories.get(terName);
                        if (t3 == null) {
                            this.error("Invalid territory name: " + terName + "; " + this.getCurrentFileName());
                            continue;
                        }
                        template.addTerritory(terName, t3);
                        continue;
                    }
                    Territory temp = this.parseTerritory(null, subElement);
                    Point2D[] points = temp.getPoints();
                    Point2D firstPoint = points[0];
                    Point2D lastPoint = points[points.length - 1];
                    template.addTerritory("territory: [" + firstPoint.getX() + " " + firstPoint.getY() + "] [" + lastPoint.getX() + " " + lastPoint.getY() + "]", temp);
                    continue;
                }
                if (!subElement.getName().equalsIgnoreCase("npc")) continue;
                int npcId = Integer.parseInt(subElement.attributeValue("id"));
                int max = subElement.attributeValue("max") == null ? 0 : Integer.parseInt(subElement.attributeValue("max"));
                StatsSet parameters = StatsSet.EMPTY;
                List<MinionData> minions = Collections.emptyList();
                String ai = subElement.attributeValue("ai");
                if (ai != null) {
                    if (parameters.isEmpty()) {
                        parameters = new StatsSet();
                    }
                    parameters.set("ai_type", ai);
                }
                Iterator npcIterator = subElement.elementIterator();
                while (npcIterator.hasNext()) {
                    Element npcElement = (Element)npcIterator.next();
                    if (npcElement.getName().equalsIgnoreCase("set")) {
                        if (parameters.isEmpty()) {
                            parameters = new StatsSet();
                        }
                        parameters.set(npcElement.attributeValue("name"), npcElement.attributeValue("value"));
                        continue;
                    }
                    if (!npcElement.getName().equalsIgnoreCase("minions")) continue;
                    t = null;
                    String terName = npcElement.attributeValue("spawn_by_territory");
                    if (terName != null && (t = (Territory)territories.get(terName)) == null) {
                        this.error("Invalid territory name: " + terName + "; " + this.getCurrentFileName());
                        continue;
                    }
                    Iterator nextIterator = npcElement.elementIterator();
                    while (nextIterator.hasNext()) {
                        int minionRespawn;
                        Element nextElement = (Element)nextIterator.next();
                        int minionId = Integer.parseInt(nextElement.attributeValue("npc_id"));
                        String minionAi = nextElement.attributeValue("ai");
                        int minionCount = Integer.parseInt(nextElement.attributeValue("count"));
                        int n = minionRespawn = nextElement.attributeValue("respawn") == null ? -1 : Integer.parseInt(nextElement.attributeValue("respawn"));
                        if (minions.isEmpty()) {
                            minions = new ArrayList<MinionData>();
                        }
                        minions.add(new MinionData(minionId, minionAi, minionCount, minionRespawn, t));
                    }
                }
                template.addNpc(new SpawnNpcInfo(npcId, max, parameters, minions));
            }
            if (template.getNpcList().isEmpty()) {
                this.warn("Npc id is zero! File: " + this.getCurrentFileName());
                continue;
            }
            if (template.getSpawnPointList().isEmpty() && template.getTerritoryList().isEmpty()) {
                this.warn("No points to spawn! File: " + this.getCurrentFileName());
                continue;
            }
            ((SpawnHolder)this.getHolder()).addSpawn(group, template);
        }
    }

    private Territory parseTerritory(String name, Element e) {
        Territory t = new Territory();
        t.add((Shape)this.parsePolygon0(name, e));
        Iterator iterator = e.elementIterator("banned_territory");
        while (iterator.hasNext()) {
            t.addBanned((Shape)this.parsePolygon0(name, (Element)iterator.next()));
        }
        return t;
    }

    private Polygon parsePolygon0(String name, Element e) {
        Polygon temp = new Polygon();
        Iterator addIterator = e.elementIterator("add");
        while (addIterator.hasNext()) {
            Element addElement = (Element)addIterator.next();
            int x = Integer.parseInt(addElement.attributeValue("x"));
            int y = Integer.parseInt(addElement.attributeValue("y"));
            int zmin = Integer.parseInt(addElement.attributeValue("zmin"));
            int zmax = Integer.parseInt(addElement.attributeValue("zmax"));
            temp.add(x, y).setZmin(zmin).setZmax(zmax);
        }
        if (!temp.validate()) {
            this.error("Invalid polygon: " + name + "{" + temp + "}. File: " + this.getCurrentFileName());
        }
        return temp;
    }
}


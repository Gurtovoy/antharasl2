/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.commons.geometry.Polygon;
import l2s.commons.geometry.Shape;
import l2s.commons.time.cron.SchedulingPattern;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.DoorHolder;
import l2s.gameserver.data.xml.holder.InstantZoneHolder;
import l2s.gameserver.data.xml.holder.SpawnHolder;
import l2s.gameserver.data.xml.holder.ZoneHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.geometry.Territory;
import l2s.gameserver.model.Party;
import l2s.gameserver.templates.DoorTemplate;
import l2s.gameserver.templates.InstantZone;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.ZoneTemplate;
import l2s.gameserver.templates.spawn.SpawnTemplate;
import l2s.gameserver.utils.TimeUtils;
import org.dom4j.Element;
import org.napile.primitive.Containers;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.HashIntObjectMap;

public class InstantZoneParser
extends AbstractParser<InstantZoneHolder> {
    private static InstantZoneParser _instance = new InstantZoneParser();

    public static InstantZoneParser getInstance() {
        return _instance;
    }

    public InstantZoneParser() {
        super(InstantZoneHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/instances/");
    }

    public String getDTDFileName() {
        return "instances.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            SchedulingPattern resetReuse = TimeUtils.DAILY_DATE_PATTERN;
            int timelimit = -1;
            int timer = 60;
            boolean dispelBuffs = false;
            boolean onPartyDismiss = true;
            int sharedReuseGroup = 0;
            int collapseIfEmpty = 0;
            int spawnType = 0;
            InstantZone.SpawnInfo spawnDat = null;
            int removedItemId = 0;
            int removedItemCount = 0;
            int giveItemId = 0;
            int givedItemCount = 0;
            int requiredQuestId = 0;
            int maxChannels = 20;
            boolean removedItemNecessity = false;
            boolean setReuseUponEntry = true;
            boolean notifyOnSetReuse = true;
            StatsSet params = new StatsSet();
            ArrayList<InstantZone.SpawnInfo> spawns = new ArrayList<InstantZone.SpawnInfo>();
            IntObjectMap doors = Containers.emptyIntObjectMap();
            Map<String, InstantZone.ZoneInfo> zones = Collections.emptyMap();
            Map<String, InstantZone.SpawnInfo2> spawns2 = Collections.emptyMap();
            int instanceId = Integer.parseInt(element.attributeValue("id"));
            String name = element.attributeValue("name");
            String n = element.attributeValue("timelimit");
            if (n != null) {
                timelimit = Integer.parseInt(n);
            }
            n = element.attributeValue("collapseIfEmpty");
            collapseIfEmpty = Integer.parseInt(n);
            n = element.attributeValue("maxChannels");
            maxChannels = Integer.parseInt(n);
            n = element.attributeValue("dispelBuffs");
            dispelBuffs = n != null && Boolean.parseBoolean(n);
            int minLevel = 0;
            int maxLevel = 0;
            int minParty = 1;
            int maxParty = Party.MAX_SIZE;
            List<Location> teleportLocs = Collections.emptyList();
            Location ret = null;
            Iterator subIterator = element.elementIterator();
            while (subIterator.hasNext()) {
                Element subElement = (Element)subIterator.next();
                if ("level".equalsIgnoreCase(subElement.getName())) {
                    minLevel = subElement.attributeValue("min") == null ? 1 : Integer.parseInt(subElement.attributeValue("min"));
                    maxLevel = subElement.attributeValue("max") == null ? Integer.MAX_VALUE : Integer.parseInt(subElement.attributeValue("max"));
                    continue;
                }
                if ("collapse".equalsIgnoreCase(subElement.getName())) {
                    onPartyDismiss = Boolean.parseBoolean(subElement.attributeValue("on-party-dismiss"));
                    timer = Integer.parseInt(subElement.attributeValue("timer"));
                    continue;
                }
                if ("party".equalsIgnoreCase(subElement.getName())) {
                    minParty = Integer.parseInt(subElement.attributeValue("min"));
                    maxParty = Integer.parseInt(subElement.attributeValue("max"));
                    continue;
                }
                if ("return".equalsIgnoreCase(subElement.getName())) {
                    ret = Location.parseLoc(subElement.attributeValue("loc"));
                    continue;
                }
                if ("teleport".equalsIgnoreCase(subElement.getName())) {
                    if (teleportLocs.isEmpty()) {
                        teleportLocs = new ArrayList<Location>(1);
                    }
                    teleportLocs.add(Location.parseLoc(subElement.attributeValue("loc")));
                    continue;
                }
                if ("remove".equalsIgnoreCase(subElement.getName())) {
                    removedItemId = Integer.parseInt(subElement.attributeValue("itemId"));
                    removedItemCount = Integer.parseInt(subElement.attributeValue("count"));
                    removedItemNecessity = Boolean.parseBoolean(subElement.attributeValue("necessary"));
                    continue;
                }
                if ("give".equalsIgnoreCase(subElement.getName())) {
                    giveItemId = Integer.parseInt(subElement.attributeValue("itemId"));
                    givedItemCount = Integer.parseInt(subElement.attributeValue("count"));
                    continue;
                }
                if ("quest".equalsIgnoreCase(subElement.getName())) {
                    requiredQuestId = Integer.parseInt(subElement.attributeValue("id"));
                    continue;
                }
                if ("reuse".equalsIgnoreCase(subElement.getName())) {
                    resetReuse = new SchedulingPattern(subElement.attributeValue("resetReuse"));
                    if (subElement.attributeValue("sharedReuseGroup") != null) {
                        sharedReuseGroup = Integer.parseInt(subElement.attributeValue("sharedReuseGroup"));
                    }
                    if (subElement.attributeValue("setUponEntry") != null) {
                        setReuseUponEntry = Boolean.parseBoolean(subElement.attributeValue("setUponEntry"));
                    }
                    if (subElement.attributeValue("notify_on_set_reuse") == null) continue;
                    notifyOnSetReuse = Boolean.parseBoolean(subElement.attributeValue("notify_on_set_reuse"));
                    continue;
                }
                if ("doors".equalsIgnoreCase(subElement.getName())) {
                    for (Element e : subElement.elements()) {
                        if (doors.isEmpty()) {
                            doors = new HashIntObjectMap();
                        }
                        boolean opened = e.attributeValue("opened") != null && Boolean.parseBoolean(e.attributeValue("opened"));
                        boolean invul = e.attributeValue("invul") == null || Boolean.parseBoolean(e.attributeValue("invul"));
                        DoorTemplate template = DoorHolder.getInstance().getTemplate(Integer.parseInt(e.attributeValue("id")));
                        doors.put(template.getId(), new InstantZone.DoorInfo(template, opened, invul));
                    }
                    continue;
                }
                if ("zones".equalsIgnoreCase(subElement.getName())) {
                    for (Element e : subElement.elements()) {
                        if (zones.isEmpty()) {
                            zones = new HashMap<String, InstantZone.ZoneInfo>();
                        }
                        boolean active = e.attributeValue("active") != null && Boolean.parseBoolean(e.attributeValue("active"));
                        ZoneTemplate template = ZoneHolder.getInstance().getTemplate(e.attributeValue("name"));
                        if (template == null) {
                            this.error("Zone: " + e.attributeValue("name") + " not found; file: " + this.getCurrentFileName());
                            continue;
                        }
                        zones.put(template.getName(), new InstantZone.ZoneInfo(template, active));
                    }
                    continue;
                }
                if ("add_parameters".equalsIgnoreCase(subElement.getName())) {
                    for (Element e : subElement.elements()) {
                        if (!"param".equalsIgnoreCase(e.getName())) continue;
                        params.set(e.attributeValue("name"), e.attributeValue("value"));
                    }
                    continue;
                }
                if (!"spawns".equalsIgnoreCase(subElement.getName())) continue;
                for (Element e : subElement.elements()) {
                    if ("group".equalsIgnoreCase(e.getName())) {
                        String group = e.attributeValue("name");
                        boolean spawned = e.attributeValue("spawned") != null && Boolean.parseBoolean(e.attributeValue("spawned"));
                        List<SpawnTemplate> templates = SpawnHolder.getInstance().getSpawn(group);
                        if (templates == null) {
                            this.info("not find spawn group: " + group + " in file: " + this.getCurrentFileName());
                            continue;
                        }
                        if (spawns2.isEmpty()) {
                            spawns2 = new Hashtable<String, InstantZone.SpawnInfo2>();
                        }
                        spawns2.put(group, new InstantZone.SpawnInfo2(templates, spawned));
                        continue;
                    }
                    if (!"spawn".equalsIgnoreCase(e.getName())) continue;
                    String[] mobs = e.attributeValue("mobId").split(" ");
                    String respawnNode = e.attributeValue("respawn");
                    int respawn = respawnNode != null ? Integer.parseInt(respawnNode) : 0;
                    String respawnRndNode = e.attributeValue("respawnRnd");
                    int respawnRnd = respawnRndNode != null ? Integer.parseInt(respawnRndNode) : 0;
                    String countNode = e.attributeValue("count");
                    int count = countNode != null ? Integer.parseInt(countNode) : 1;
                    ArrayList<Location> coords = new ArrayList<Location>();
                    spawnType = 0;
                    String spawnTypeNode = e.attributeValue("type");
                    if (spawnTypeNode == null || spawnTypeNode.equalsIgnoreCase("point")) {
                        spawnType = 0;
                    } else if (spawnTypeNode.equalsIgnoreCase("rnd")) {
                        spawnType = 1;
                    } else if (spawnTypeNode.equalsIgnoreCase("loc")) {
                        spawnType = 2;
                    } else {
                        this.error("Spawn type  '" + spawnTypeNode + "' is unknown!");
                    }
                    for (Element e2 : e.elements()) {
                        if (!"coords".equalsIgnoreCase(e2.getName())) continue;
                        coords.add(Location.parseLoc(e2.attributeValue("loc")));
                    }
                    Territory territory = null;
                    if (spawnType == 2) {
                        Polygon poly = new Polygon();
                        for (Location loc : coords) {
                            poly.add(loc.x, loc.y).setZmin(loc.z).setZmax(loc.z);
                        }
                        if (!poly.validate()) {
                            this.error("invalid spawn territory for instance id : " + instanceId + " - " + poly + "!");
                        }
                        territory = new Territory().add((Shape)poly);
                    }
                    for (String mob : mobs) {
                        int mobId = Integer.parseInt(mob);
                        spawnDat = new InstantZone.SpawnInfo(spawnType, mobId, count, respawn, respawnRnd, coords, territory);
                        spawns.add(spawnDat);
                    }
                }
            }
            InstantZone instancedZone = new InstantZone(instanceId, name, resetReuse, sharedReuseGroup, timelimit, dispelBuffs, minLevel, maxLevel, minParty, maxParty, timer, onPartyDismiss, teleportLocs, ret, (IntObjectMap<InstantZone.DoorInfo>)doors, zones, spawns2, spawns, collapseIfEmpty, maxChannels, removedItemId, removedItemCount, removedItemNecessity, giveItemId, givedItemCount, requiredQuestId, setReuseUponEntry, notifyOnSetReuse, params);
            ((InstantZoneHolder)this.getHolder()).addInstantZone(instancedZone);
        }
    }
}


/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.fakeplayer;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.ZoneHolder;
import l2s.gameserver.data.xml.parser.ZoneParser;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.model.base.ClassType;
import l2s.gameserver.model.base.Race;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.ZoneTemplate;
import l2s.gameserver.templates.fakeplayer.FakePlayerAITemplate;
import l2s.gameserver.templates.fakeplayer.FakePlayerActionsHolder;
import l2s.gameserver.templates.fakeplayer.actions.GoToTownActions;
import l2s.gameserver.templates.fakeplayer.actions.OrdinaryActions;
import org.dom4j.Element;
import org.napile.primitive.sets.IntSet;
import org.napile.primitive.sets.impl.HashIntSet;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class FarmZoneTemplate {
    private static final Logger _log = LoggerFactory.getLogger(FakePlayerAITemplate.class);
    private final int _minLevel;
    private final int _maxLevel;
    private final List<ZoneTemplate> _zoneTemplates;
    private final List<Location> _spawnPoints;
    private final OrdinaryActions _onObtainMaxLevelAction;
    private final GoToTownActions _goToTownAction;
    private final Set<ClassId> _availableClasses;
    private final Set<ClassType> _availableTypes;
    private final Set<Race> _availableRaces;
    private final IntSet _farmMonsters;
    private final IntSet _ignoredMonsters;
    private List<Zone> zones = null;

    public FarmZoneTemplate(int minLevel, int maxLevel, List<ZoneTemplate> zoneTemplates, List<Location> spawnPoints, OrdinaryActions onObtainMaxLevelAction, GoToTownActions goToTownAction, Set<ClassId> availableClasses, Set<ClassType> availableTypes, Set<Race> availableRaces, IntSet farmMonsters, IntSet ignoredMonsters) {
        this._minLevel = minLevel;
        this._maxLevel = maxLevel;
        this._zoneTemplates = zoneTemplates;
        this._spawnPoints = spawnPoints;
        this._onObtainMaxLevelAction = onObtainMaxLevelAction;
        this._goToTownAction = goToTownAction;
        this._availableClasses = availableClasses;
        this._availableRaces = availableRaces;
        this._availableTypes = availableTypes;
        this._farmMonsters = farmMonsters;
        this._ignoredMonsters = ignoredMonsters;
    }

    public int getMinLevel() {
        return this._minLevel;
    }

    public int getMaxLevel() {
        return this._maxLevel;
    }

    public boolean checkCondition(Player player) {
        if (player.getLevel() < this._minLevel) {
            return false;
        }
        if (player.getLevel() >= this._maxLevel) {
            return false;
        }
        if (this._availableClasses != null && !this._availableClasses.isEmpty() && !this._availableClasses.contains(player.getClassId())) {
            return false;
        }
        if (this._availableRaces != null && !this._availableRaces.isEmpty() && !this._availableRaces.contains(player.getRace())) {
            return false;
        }
        return this._availableTypes == null || this._availableTypes.isEmpty() || this._availableTypes.contains(player.getRace());
    }

    public synchronized List<Zone> getZones() {
        if (this.zones == null) {
            this.zones = new ArrayList<Zone>(this._zoneTemplates.size());
            for (ZoneTemplate zoneTemplate : this._zoneTemplates) {
                Zone zone = new Zone(zoneTemplate);
                zone.setReflection(ReflectionManager.MAIN);
                zone.setActive(true);
                ReflectionManager.MAIN.addZone(zone);
                this.zones.add(zone);
            }
        }
        return this.zones;
    }

    public List<Location> getSpawnPoints() {
        return this._spawnPoints;
    }

    public OrdinaryActions getOnObtainMaxLevelAction() {
        return this._onObtainMaxLevelAction;
    }

    public GoToTownActions getGoToTownActions() {
        return this._goToTownAction;
    }

    public IntSet getFarmMonsters() {
        return this._farmMonsters;
    }

    public boolean isIgnoredMonster(int npcId) {
        return this._ignoredMonsters.contains(npcId);
    }

    public static FarmZoneTemplate parse(FakePlayerActionsHolder actionsHolder, Element element) {
        Element tempElement = element.element("zones");
        if (tempElement == null) {
            _log.warn("Cannot find \"zones\" element!");
            return null;
        }
        String name = element.attributeValue("name");
        int minLevel = element.attributeValue("min_level") == null ? 1 : Integer.parseInt(element.attributeValue("min_level"));
        int maxLevel = element.attributeValue("max_level") == null ? Config.ALT_MAX_LEVEL + 1 : Integer.parseInt(element.attributeValue("max_level"));
        HashSet<ClassId> availableClasses = null;
        String classes = element.attributeValue("classes");
        if (classes != null) {
            availableClasses = new HashSet<ClassId>();
            for (String c : classes.split("[\\s,;]+")) {
                availableClasses.add(ClassId.valueOf(c.toUpperCase()));
            }
        }
        HashSet<ClassType> availableTypes = null;
        String types = element.attributeValue("types");
        if (types != null) {
            availableTypes = new HashSet<ClassType>();
            for (String t : types.split("[\\s,;]+")) {
                availableTypes.add(ClassType.valueOf(t.toUpperCase()));
            }
        }
        HashSet<Race> availableRaces = null;
        String races = element.attributeValue("races");
        if (races != null) {
            availableRaces = new HashSet<Race>();
            for (String r : races.split("[\\s,;]+")) {
                availableRaces.add(Race.valueOf(r.toUpperCase()));
            }
        }
        OrdinaryActions onObtainMaxLevelAction = null;
        GoToTownActions goToTownAction = null;
        ArrayList<ZoneTemplate> zoneTemplates = new ArrayList<ZoneTemplate>();
        Iterator i1 = tempElement.elementIterator("zone");
        while (i1.hasNext()) {
            Element e1 = (Element)i1.next();
            try {
                ZoneTemplate zoneTemplate;
                String zoneName = e1.attributeValue("name");
                if (zoneName != null) {
                    zoneTemplate = ZoneHolder.getInstance().getTemplate(zoneName);
                } else {
                    StatsSet zoneDat = new StatsSet();
                    zoneDat.set("name", name);
                    zoneDat.set("type", Zone.ZoneType.dummy.toString());
                    zoneTemplate = ZoneParser.parseZone(e1, zoneDat);
                }
                if (zoneTemplate == null) continue;
                zoneTemplates.add(zoneTemplate);
            }
            catch (Exception e) {
                _log.error("Error while parse zone: ", (Throwable)e);
                return null;
            }
        }
        if (zoneTemplates.isEmpty()) {
            _log.warn("Zones is empty! Please add one or more zones for farm zone.");
            return null;
        }
        ArrayList<Location> spawnPoints = new ArrayList<Location>();
        Iterator i12 = tempElement.elementIterator("spawn_points");
        while (i12.hasNext()) {
            Element e1 = (Element)i12.next();
            Iterator i2 = e1.elementIterator("coords");
            while (i2.hasNext()) {
                Element e2 = (Element)i2.next();
                spawnPoints.add(Location.parseLoc(e2.attribute("loc").getValue()));
            }
        }
        if (spawnPoints.isEmpty()) {
            _log.warn("Spawn points for zones is empty! Please add one or more spawn points for farm zone.");
            return null;
        }
        if (actionsHolder == null) {
            actionsHolder = new FakePlayerActionsHolder();
        }
        if ((tempElement = element.element("on_obtain_max_level")) != null) {
            onObtainMaxLevelAction = OrdinaryActions.parse(actionsHolder, tempElement);
        }
        if ((tempElement = element.element("go_to_town")) != null) {
            goToTownAction = GoToTownActions.parse(actionsHolder, tempElement);
        }
        HashIntSet farmMonsters = new HashIntSet();
        Iterator i13 = element.elementIterator("farm_monsters");
        while (i13.hasNext()) {
            Element e1 = (Element)i13.next();
            Iterator i2 = e1.elementIterator("npc");
            while (i2.hasNext()) {
                Element e2 = (Element)i2.next();
                farmMonsters.add(Integer.parseInt(e2.attributeValue("id")));
            }
        }
        HashIntSet ignoredMonsters = new HashIntSet();
        Iterator i14 = element.elementIterator("ignored_monsters");
        while (i14.hasNext()) {
            Element e1 = (Element)i14.next();
            Iterator i2 = e1.elementIterator("npc");
            while (i2.hasNext()) {
                Element e2 = (Element)i2.next();
                ignoredMonsters.add(Integer.parseInt(e2.attributeValue("id")));
            }
        }
        FarmZoneTemplate template = new FarmZoneTemplate(minLevel, maxLevel, zoneTemplates, spawnPoints, onObtainMaxLevelAction, goToTownAction, availableClasses, availableTypes, availableRaces, (IntSet)farmMonsters, (IntSet)ignoredMonsters);
        Iterator iterator = element.elementIterator("action");
        while (iterator.hasNext()) {
            Element e = (Element)iterator.next();
            int actionId = Integer.parseInt(e.attributeValue("id"));
            OrdinaryActions action = OrdinaryActions.parse(actionsHolder, e);
            actionsHolder.addAction(actionId, action);
        }
        return template;
    }
}


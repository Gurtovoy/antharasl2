/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.dom4j.Element
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.templates.fakeplayer;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import l2s.gameserver.data.xml.holder.ZoneHolder;
import l2s.gameserver.data.xml.parser.ZoneParser;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.model.Zone;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.ZoneTemplate;
import l2s.gameserver.templates.fakeplayer.FakePlayerAITemplate;
import l2s.gameserver.templates.fakeplayer.FakePlayerActionsHolder;
import l2s.gameserver.templates.fakeplayer.actions.OrdinaryActions;
import org.dom4j.Element;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TownZoneTemplate {
    private static final Logger _log = LoggerFactory.getLogger(FakePlayerAITemplate.class);
    private final List<ZoneTemplate> _zoneTemplates;
    private final OrdinaryActions _actions;
    private List<Zone> zones = null;

    public TownZoneTemplate(List<ZoneTemplate> zoneTemplates, OrdinaryActions actions) {
        this._zoneTemplates = zoneTemplates;
        this._actions = actions;
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

    public OrdinaryActions getActions() {
        return this._actions;
    }

    public static TownZoneTemplate parse(Element element) {
        Element tempElement = element.element("zones");
        if (tempElement == null) {
            _log.warn("Cannot find \"zones\" element!");
            return null;
        }
        String name = element.attributeValue("name");
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
            _log.warn("Zones is empty! Please add one or more zones for town zone.");
            return null;
        }
        tempElement = element.element("actions");
        if (tempElement == null) {
            _log.warn("Cannot find \"actions\" element!");
            return null;
        }
        FakePlayerActionsHolder actionsHolder = new FakePlayerActionsHolder();
        OrdinaryActions actions = OrdinaryActions.parse(actionsHolder, tempElement);
        TownZoneTemplate template = new TownZoneTemplate(zoneTemplates, actions);
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


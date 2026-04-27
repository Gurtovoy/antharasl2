/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.data.xml.AbstractHolder
 *  org.napile.primitive.maps.IntObjectMap
 *  org.napile.primitive.maps.impl.HashIntObjectMap
 */
package l2s.gameserver.data.xml.holder;

import java.util.Collection;
import java.util.HashSet;
import java.util.Set;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.model.base.ClassType;
import l2s.gameserver.model.base.Race;
import l2s.gameserver.templates.fakeplayer.FakePlayerAITemplate;
import l2s.gameserver.templates.fakeplayer.FarmZoneTemplate;
import l2s.gameserver.templates.fakeplayer.TownZoneTemplate;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.HashIntObjectMap;

public final class FakePlayersHolder
extends AbstractHolder {
    private static final FakePlayersHolder _instance = new FakePlayersHolder();
    private final IntObjectMap<FakePlayerAITemplate> _aiTemplates = new HashIntObjectMap();
    private final Set<FarmZoneTemplate> _farmZoneTemplates = new HashSet<FarmZoneTemplate>();
    private final Set<TownZoneTemplate> _townZoneTemplates = new HashSet<TownZoneTemplate>();

    public static FakePlayersHolder getInstance() {
        return _instance;
    }

    public void addAITemplate(FakePlayerAITemplate template) {
        this._aiTemplates.put(FakePlayersHolder.makeHashCode(template.getRace(), template.getType()), template);
    }

    public Collection<FakePlayerAITemplate> getAITemplates() {
        return this._aiTemplates.valueCollection();
    }

    public FakePlayerAITemplate getAITemplate(Race race, ClassType type) {
        return (FakePlayerAITemplate)this._aiTemplates.get(FakePlayersHolder.makeHashCode(race, type));
    }

    public void addFarmZone(FarmZoneTemplate template) {
        this._farmZoneTemplates.add(template);
    }

    public Collection<FarmZoneTemplate> getFarmZones() {
        return this._farmZoneTemplates;
    }

    public void addTownZone(TownZoneTemplate template) {
        this._townZoneTemplates.add(template);
    }

    public Collection<TownZoneTemplate> getTownZones() {
        return this._townZoneTemplates;
    }

    private static int makeHashCode(Race race, ClassType type) {
        return race.ordinal() * 100000 + type.ordinal() * 1000;
    }

    public void log() {
        this.info("loaded " + this._aiTemplates.size() + " fake players ai(s) count.");
        this.info("loaded " + this._farmZoneTemplates.size() + " fake players farm zone(s) count.");
        this.info("loaded " + this._townZoneTemplates.size() + " fake players town zone(s) count.");
    }

    @Deprecated
    public int size() {
        return 0;
    }

    public void clear() {
        this._aiTemplates.clear();
        this._farmZoneTemplates.clear();
        this._townZoneTemplates.clear();
    }
}


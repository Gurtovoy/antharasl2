/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.geometry.Polygon
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.templates;

import java.lang.reflect.Constructor;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import l2s.commons.geometry.Polygon;
import l2s.gameserver.ai.CharacterAI;
import l2s.gameserver.ai.DoorAI;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.instances.DoorInstance;
import l2s.gameserver.scripts.Scripts;
import l2s.gameserver.templates.CreatureTemplate;
import l2s.gameserver.templates.StatsSet;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DoorTemplate
extends CreatureTemplate {
    private static final Logger _log = LoggerFactory.getLogger(DoorTemplate.class);
    private static final Pattern MAP_X_Y_FROM_ID_PATTERN = Pattern.compile("([0-9]{2})([0-9]{2})[0-9]*", 32);
    @SuppressWarnings("unchecked")
    public static final Constructor<DoorAI> DEFAULT_AI_CONSTRUCTOR = (Constructor<DoorAI>)(Constructor<?>)CharacterAI.class.getConstructors()[0];
    private final int _id;
    private final String _name;
    private final DoorType _doorType;
    private final boolean _unlockable;
    private final boolean _isHPVisible;
    private final boolean _opened;
    private final boolean _targetable;
    private final Polygon _polygon;
    private final Location _loc;
    private final int _key;
    private final int _openTime;
    private final int _rndTime;
    private final int _closeTime;
    private final int _masterDoor;
    private final int _mapX;
    private final int _mapY;
    private StatsSet _aiParams;
    private Class<DoorAI> _classAI = DoorAI.class;
    private Constructor<DoorAI> _constructorAI = DEFAULT_AI_CONSTRUCTOR;

    public DoorTemplate(StatsSet set) {
        super(set);
        this._id = set.getInteger("uid");
        this._name = set.getString("name");
        this._doorType = (DoorType)set.getEnum("door_type", DoorType.class, DoorType.DOOR);
        this._unlockable = set.getBool("unlockable", false);
        this._isHPVisible = set.getBool("show_hp", false);
        this._opened = set.getBool("opened", false);
        this._targetable = set.getBool("targetable", true);
        this._loc = (Location)set.get("pos");
        this._polygon = (Polygon)set.get("shape");
        this._key = set.getInteger("key", 0);
        this._openTime = set.getInteger("open_time", 0);
        this._rndTime = set.getInteger("random_time", 0);
        this._closeTime = set.getInteger("close_time", 0);
        this._masterDoor = set.getInteger("master_door", 0);
        this._aiParams = (StatsSet)((Object)set.getObject("ai_params", (Object)StatsSet.EMPTY));
        Matcher mapMatcher = MAP_X_Y_FROM_ID_PATTERN.matcher(String.valueOf(this._id));
        mapMatcher.find();
        this._mapX = Integer.parseInt(mapMatcher.group(1));
        this._mapY = Integer.parseInt(mapMatcher.group(2));
        this.setAI(set.getString("ai", "DoorAI"));
    }

    private void setAI(String ai) {
        Class<?> classAI = null;
        try {
            classAI = Class.forName("l2s.gameserver.ai." + ai);
        }
        catch (ClassNotFoundException e) {
            classAI = Scripts.getInstance().getClasses().get("ai.door." + ai);
        }
        if (classAI == null) {
            _log.error("Not found ai class for ai: " + ai + ". DoorId: " + this._id);
        } else {
            this._classAI = (Class<DoorAI>) classAI;
            this._constructorAI = (Constructor<DoorAI>)(Constructor<?>) this._classAI.getConstructors()[0];
        }
        if (this._classAI.isAnnotationPresent(Deprecated.class)) {
            _log.error("Ai type: " + ai + ", is deprecated. DoorId: " + this._id);
        }
    }

    public CharacterAI getNewAI(DoorInstance door) {
        try {
            return this._constructorAI.newInstance(door);
        }
        catch (Exception e) {
            _log.error("Unable to create ai of doorId " + this._id, (Throwable)e);
            return new DoorAI(door);
        }
    }

    @Override
    public int getId() {
        return this._id;
    }

    public String getName() {
        return this._name;
    }

    public DoorType getDoorType() {
        return this._doorType;
    }

    public boolean isUnlockable() {
        return this._unlockable;
    }

    public boolean isHPVisible() {
        return this._isHPVisible;
    }

    public Polygon getPolygon() {
        return this._polygon;
    }

    public int getKey() {
        return this._key;
    }

    public boolean isOpened() {
        return this._opened;
    }

    public Location getLoc() {
        return this._loc;
    }

    public int getOpenTime() {
        return this._openTime;
    }

    public int getRandomTime() {
        return this._rndTime;
    }

    public int getCloseTime() {
        return this._closeTime;
    }

    public boolean isTargetable() {
        return this._targetable;
    }

    public int getMasterDoor() {
        return this._masterDoor;
    }

    public StatsSet getAIParams() {
        return this._aiParams;
    }

    public int getMapX() {
        return this._mapX;
    }

    public int getMapY() {
        return this._mapY;
    }

    public static enum DoorType {
        DOOR,
        WALL;

    }
}


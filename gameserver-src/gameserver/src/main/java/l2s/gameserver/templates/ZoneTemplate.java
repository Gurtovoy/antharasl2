/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates;

import java.util.List;
import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.geometry.Territory;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.base.Race;
import l2s.gameserver.network.l2.components.SceneMovie;
import l2s.gameserver.stats.StatTemplate;
import l2s.gameserver.templates.StatsSet;

public class ZoneTemplate
extends StatTemplate {
    public static final String NON_PVP_PARAM = "non_pvp";
    public static final String NOT_LOST_EXP_PARAM = "not_lost_exp";
    public static final String NOT_LOST_ITEMS_PARAM = "not_lost_items";
    private final String _name;
    private final Zone.ZoneType _type;
    private final Territory _territory;
    private final boolean _isEnabled;
    private final List<Location> _restartPoints;
    private final List<Location> _PKrestartPoints;
    private final long _restartTime;
    private final int _enteringMessageId;
    private final int _leavingMessageId;
    private final Race _affectRace;
    private final Zone.ZoneTarget _target;
    private Skill _skill;
    private final int _skillProb;
    private final int _initialDelay;
    private final int _unitTick;
    private final int _randomTick;
    private final int _damageMessageId;
    private final int _damageOnHP;
    private final int _damageOnMP;
    private final double _moveBonus;
    private final double _regenBonusHP;
    private final double _regenBonusMP;
    private final int _eventTriggerId;
    private final String[] _blockedActions;
    private final int _index;
    private final int _taxById;
    private final int _jumpingTrackId;
    private final StatsSet _params;
    private final SceneMovie _presentSceneMovie;
    private final boolean _showDangerzone;
    private final Location _teleportLocation;

    public ZoneTemplate(StatsSet set) {
        this._name = set.getString("name");
        this._type = Zone.ZoneType.valueOf(set.getString("type"));
        this._territory = (Territory)set.get("territory");
        this._enteringMessageId = set.getInteger("entering_message_no", 0);
        this._leavingMessageId = set.getInteger("leaving_message_no", 0);
        this._target = Zone.ZoneTarget.valueOf(set.getString("target", "pc"));
        this._affectRace = set.getString("affect_race", "all").equals("all") ? null : Race.valueOf(set.getString("affect_race").toUpperCase());
        String s = set.getString("skill_name", null);
        Skill skill = null;
        if (s != null) {
            String[] sk = s.split("[\\s,;]+");
            skill = SkillHolder.getInstance().getSkill(Integer.parseInt(sk[0]), Integer.parseInt(sk[1]));
        }
        this._skill = skill;
        this._skillProb = set.getInteger("skill_prob", 100);
        this._initialDelay = set.getInteger("initial_delay", 1);
        this._unitTick = set.getInteger("unit_tick", 1);
        this._randomTick = set.getInteger("random_time", 0);
        this._moveBonus = set.getDouble("move_bonus", 0.0);
        this._regenBonusHP = set.getDouble("hp_regen_bonus", 0.0);
        this._regenBonusMP = set.getDouble("mp_regen_bonus", 0.0);
        this._damageOnHP = set.getInteger("damage_on_hp", 0);
        this._damageOnMP = set.getInteger("damage_on_mp", 0);
        this._damageMessageId = set.getInteger("message_no", 0);
        this._eventTriggerId = set.getInteger("event_trigger_id", 0);
        this._isEnabled = set.getBool("enabled", true);
        this._restartPoints = (List)set.get("restart_points");
        this._PKrestartPoints = (List)set.get("PKrestart_points");
        this._restartTime = set.getLong("restart_time", 0L);
        s = (String)set.get("blocked_actions");
        this._blockedActions = s != null ? s.split("[\\s,;]+") : null;
        this._index = set.getInteger("index", 0);
        this._taxById = set.getInteger("taxById", 0);
        this._jumpingTrackId = set.getInteger("jumping_track", -1);
        String sceneMovie = set.getString("present_scene_movie", null);
        this._presentSceneMovie = sceneMovie == null ? null : SceneMovie.valueOf(sceneMovie.toUpperCase());
        this._showDangerzone = set.getBool("show_dangerzone", this._type == Zone.ZoneType.damage || this._type == Zone.ZoneType.swamp || this._type == Zone.ZoneType.poison || this._type == Zone.ZoneType.instant_skill);
        String teleportCords = set.getString("teleport_location", null);
        this._teleportLocation = teleportCords == null ? null : Location.parseLoc(teleportCords);
        this._params = set;
    }

    public boolean isEnabled() {
        return this._isEnabled;
    }

    public String getName() {
        return this._name;
    }

    public Zone.ZoneType getType() {
        return this._type;
    }

    public Territory getTerritory() {
        return this._territory;
    }

    public int getEnteringMessageId() {
        return this._enteringMessageId;
    }

    public int getLeavingMessageId() {
        return this._leavingMessageId;
    }

    public Skill getZoneSkill() {
        return this._skill;
    }

    public void setZoneSkill(Skill skill) {
        this._skill = skill;
    }

    public int getSkillProb() {
        return this._skillProb;
    }

    public int getInitialDelay() {
        return this._initialDelay;
    }

    public int getUnitTick() {
        return this._unitTick;
    }

    public int getRandomTick() {
        return this._randomTick;
    }

    public Zone.ZoneTarget getZoneTarget() {
        return this._target;
    }

    public Race getAffectRace() {
        return this._affectRace;
    }

    public String[] getBlockedActions() {
        return this._blockedActions;
    }

    public int getDamageMessageId() {
        return this._damageMessageId;
    }

    public int getDamageOnHP() {
        return this._damageOnHP;
    }

    public int getDamageOnMP() {
        return this._damageOnMP;
    }

    public double getMoveBonus() {
        return this._moveBonus;
    }

    public double getRegenBonusHP() {
        return this._regenBonusHP;
    }

    public double getRegenBonusMP() {
        return this._regenBonusMP;
    }

    public long getRestartTime() {
        return this._restartTime;
    }

    public List<Location> getRestartPoints() {
        return this._restartPoints;
    }

    public List<Location> getPKRestartPoints() {
        return this._PKrestartPoints;
    }

    public int getIndex() {
        return this._index;
    }

    public int getTaxById() {
        return this._taxById;
    }

    public int getEventTriggerId() {
        return this._eventTriggerId;
    }

    public int getJumpTrackId() {
        return this._jumpingTrackId;
    }

    public SceneMovie getPresentSceneMovie() {
        return this._presentSceneMovie;
    }

    public boolean isShowDangerzone() {
        return this._showDangerzone;
    }

    public Location getTeleportLocation() {
        return this._teleportLocation;
    }

    public MultiValueSet<String> getParams() {
        return this._params.clone();
    }
}


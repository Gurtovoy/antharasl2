package l2s.gameserver.model;

import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Future;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import l2s.commons.collections.LazyArrayList;
import l2s.commons.collections.MultiValueSet;
import l2s.commons.listener.Listener;
import l2s.commons.listener.ListenerList;
import l2s.commons.util.Rnd;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.geometry.Territory;
import l2s.gameserver.listener.zone.OnZoneEnterLeaveListener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.World;
import l2s.gameserver.model.base.Race;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.events.EventOwner;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.SystemMessage;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.stats.funcs.Func;
import l2s.gameserver.stats.funcs.FuncAdd;
import l2s.gameserver.taskmanager.EffectTaskManager;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.ZoneTemplate;
import l2s.gameserver.utils.PositionUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Zone
extends EventOwner {
    private static final Logger _log = LoggerFactory.getLogger(Zone.class);
    public static final Zone[] EMPTY_L2ZONE_ARRAY = new Zone[0];
    public static final String BLOCKED_ACTION_PRIVATE_STORE = "open_private_store";
    public static final String BLOCKED_ACTION_PRIVATE_WORKSHOP = "open_private_workshop";
    public static final String BLOCKED_ACTION_DROP_MERCHANT_GUARD = "drop_merchant_guard";
    public static final String BLOCKED_ACTION_SAVE_BOOKMARK = "save_bookmark";
    public static final String BLOCKED_ACTION_USE_BOOKMARK = "use_bookmark";
    public static final String BLOCKED_ACTION_MINIMAP = "open_minimap";
    private ZoneType _type;
    private boolean _active;
    private final MultiValueSet<String> _params;
    private final ZoneTemplate _template;
    private Reflection _reflection;
    private final ZoneListenerList listeners = new ZoneListenerList();
    private final ReadWriteLock lock = new ReentrantReadWriteLock();
    private final Lock readLock = this.lock.readLock();
    private final Lock writeLock = this.lock.writeLock();
    private final List<Creature> _objects = new LazyArrayList(32);
    private final Map<Creature, ZoneTimer> _zoneTimers = new ConcurrentHashMap<Creature, ZoneTimer>();
    public static final int ZONE_STATS_ORDER = 64;

    public Zone(ZoneTemplate template) {
        this(template.getType(), template);
    }

    public Zone(ZoneType type, ZoneTemplate template) {
        this._type = type;
        this._template = template;
        this._params = template.getParams();
    }

    public ZoneTemplate getTemplate() {
        return this._template;
    }

    public final String getName() {
        return this.getTemplate().getName();
    }

    public ZoneType getType() {
        return this._type;
    }

    public void setType(ZoneType type) {
        this._type = type;
    }

    public Territory getTerritory() {
        return this.getTemplate().getTerritory();
    }

    public final int getEnteringMessageId() {
        return this.getTemplate().getEnteringMessageId();
    }

    public final int getLeavingMessageId() {
        return this.getTemplate().getLeavingMessageId();
    }

    public Skill getZoneSkill() {
        return this.getTemplate().getZoneSkill();
    }

    public ZoneTarget getZoneTarget() {
        return this.getTemplate().getZoneTarget();
    }

    public Race getAffectRace() {
        return this.getTemplate().getAffectRace();
    }

    public int getDamageMessageId() {
        return this.getTemplate().getDamageMessageId();
    }

    public int getDamageOnHP() {
        return this.getTemplate().getDamageOnHP();
    }

    public int getDamageOnMP() {
        return this.getTemplate().getDamageOnMP();
    }

    public double getMoveBonus() {
        return this.getTemplate().getMoveBonus();
    }

    public double getRegenBonusHP() {
        return this.getTemplate().getRegenBonusHP();
    }

    public double getRegenBonusMP() {
        return this.getTemplate().getRegenBonusMP();
    }

    public long getRestartTime() {
        return this.getTemplate().getRestartTime();
    }

    public List<Location> getRestartPoints() {
        return this.getTemplate().getRestartPoints();
    }

    public List<Location> getPKRestartPoints() {
        return this.getTemplate().getPKRestartPoints();
    }

    public Location getSpawn() {
        if (this.getRestartPoints() == null) {
            return null;
        }
        Location loc = this.getRestartPoints().get(Rnd.get((int)this.getRestartPoints().size()));
        return loc.clone();
    }

    public Location getPKSpawn() {
        if (this.getPKRestartPoints() == null) {
            return this.getSpawn();
        }
        Location loc = this.getPKRestartPoints().get(Rnd.get((int)this.getPKRestartPoints().size()));
        return loc.clone();
    }

    public boolean checkIfInZone(int x, int y) {
        return this.getTerritory().isInside(x, y);
    }

    public boolean checkIfInZone(int x, int y, int z) {
        return this.checkIfInZone(x, y, z, this.getReflection());
    }

    public boolean checkIfInZone(int x, int y, int z, Reflection reflection) {
        return this.isActive() && this._reflection == reflection && this.getTerritory().isInside(x, y, z);
    }

    public boolean checkIfInZone(Creature cha) {
        this.readLock.lock();
        try {
            boolean bl = this._objects.contains(cha);
            return bl;
        }
        finally {
            this.readLock.unlock();
        }
    }

    public final double findDistanceToZone(GameObject obj, boolean includeZAxis) {
        return this.findDistanceToZone(obj.getX(), obj.getY(), obj.getZ(), includeZAxis);
    }

    public final double findDistanceToZone(int x, int y, int z, boolean includeZAxis) {
        return PositionUtils.calculateDistance(x, y, z, (this.getTerritory().getXmax() + this.getTerritory().getXmin()) / 2, (this.getTerritory().getYmax() + this.getTerritory().getYmin()) / 2, (this.getTerritory().getZmax() + this.getTerritory().getZmin()) / 2, includeZAxis);
    }

    public void doEnter(Creature cha) {
        boolean added = false;
        this.writeLock.lock();
        try {
            if (!this._objects.contains(cha)) {
                added = this._objects.add(cha);
            }
        }
        finally {
            this.writeLock.unlock();
        }
        if (added) {
            this.onZoneEnter(cha);
        }
    }

    protected void onZoneEnter(Creature actor) {
        this.checkEffects(actor, true);
        this.addZoneStats(actor);
        actor.onZoneEnter(this);
        this.listeners.onEnter(actor);
    }

    public void doLeave(Creature cha) {
        boolean removed = false;
        this.writeLock.lock();
        try {
            removed = this._objects.remove(cha);
        }
        finally {
            this.writeLock.unlock();
        }
        if (removed) {
            this.onZoneLeave(cha);
        }
    }

    protected void onZoneLeave(Creature actor) {
        this.checkEffects(actor, false);
        this.removeZoneStats(actor);
        actor.onZoneLeave(this);
        this.listeners.onLeave(actor);
    }

    private void addZoneStats(Creature cha) {
        Func[] funcs;
        boolean update = false;
        if (this.checkTarget(cha)) {
            if (this.getMoveBonus() != 0.0 && cha.isPlayable()) {
                cha.getStat().addFuncs(new FuncAdd(Stats.RUN_SPEED, 64, this, this.getMoveBonus(), StatsSet.EMPTY));
                update = true;
            }
            if (this.getRegenBonusHP() != 0.0) {
                cha.getStat().addFuncs(new FuncAdd(Stats.REGENERATE_HP_RATE, 64, this, this.getRegenBonusHP(), StatsSet.EMPTY));
                update = true;
            }
            if (this.getRegenBonusMP() != 0.0) {
                cha.getStat().addFuncs(new FuncAdd(Stats.REGENERATE_MP_RATE, 64, this, this.getRegenBonusMP(), StatsSet.EMPTY));
                update = true;
            }
        }
        if ((funcs = this.getStatFuncs()).length > 0) {
            cha.getStat().addFuncs(this.getStatFuncs());
            update = true;
        }
        if (update) {
            cha.updateStats();
        }
    }

    private void removeZoneStats(Creature cha) {
        Func[] funcs = this.getStatFuncs();
        if (this.getRegenBonusHP() == 0.0 && this.getRegenBonusMP() == 0.0 && this.getMoveBonus() == 0.0 && funcs.length == 0) {
            return;
        }
        cha.getStat().removeFuncsByOwner(this);
        cha.updateStats();
    }

    private void checkEffects(Creature cha, boolean enter) {
        if (this.checkTarget(cha)) {
            if (enter) {
                if (this.getZoneSkill() != null) {
                    SkillTimer timer = new SkillTimer(cha);
                    this._zoneTimers.put(cha, timer);
                    timer.start();
                } else if (this.getDamageOnHP() > 0 || this.getDamageOnHP() > 0) {
                    DamageTimer timer = new DamageTimer(cha);
                    this._zoneTimers.put(cha, timer);
                    timer.start();
                }
            } else {
                ZoneTimer timer = this._zoneTimers.remove(cha);
                if (timer != null) {
                    timer.stop();
                }
                if (this.getZoneSkill() != null) {
                    cha.getAbnormalList().stop(this.getZoneSkill(), true);
                }
            }
        }
    }

    private boolean checkTarget(Creature cha) {
        switch (this.getZoneTarget()) {
            case pc: {
                if (cha.isPlayable()) break;
                return false;
            }
            case only_pc: {
                if (cha.isPlayer()) break;
                return false;
            }
            case npc: {
                if (cha.isNpc()) break;
                return false;
            }
        }
        if (this.getAffectRace() != null) {
            Player player = cha.getPlayer();
            if (player == null) {
                return false;
            }
            if (player.getRace() != this.getAffectRace()) {
                return false;
            }
        }
        return true;
    }

    public Creature[] getObjects() {
        this.readLock.lock();
        try {
            Creature[] creatureArray = this._objects.toArray(new Creature[this._objects.size()]);
            return creatureArray;
        }
        finally {
            this.readLock.unlock();
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public List<Player> getInsidePlayers() {
        LazyArrayList result = new LazyArrayList();
        this.readLock.lock();
        try {
            for (int i = 0; i < this._objects.size(); ++i) {
                Creature cha = this._objects.get(i);
                if (cha == null || !cha.isPlayer()) continue;
                result.add((Player)cha);
            }
        }
        finally {
            this.readLock.unlock();
        }
        return result;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public List<Playable> getInsidePlayables() {
        LazyArrayList result = new LazyArrayList();
        this.readLock.lock();
        try {
            for (int i = 0; i < this._objects.size(); ++i) {
                Creature cha = this._objects.get(i);
                if (cha == null || !cha.isPlayable()) continue;
                result.add((Playable)cha);
            }
        }
        finally {
            this.readLock.unlock();
        }
        return result;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public List<NpcInstance> getInsideNpcs() {
        LazyArrayList result = new LazyArrayList();
        this.readLock.lock();
        try {
            for (int i = 0; i < this._objects.size(); ++i) {
                Creature cha = this._objects.get(i);
                if (cha == null || !cha.isNpc()) continue;
                result.add((NpcInstance)cha);
            }
        }
        finally {
            this.readLock.unlock();
        }
        return result;
    }

    public void setActive(boolean value) {
        this.writeLock.lock();
        try {
            if (this._active == value) {
                return;
            }
            this._active = value;
        }
        finally {
            this.writeLock.unlock();
        }
        if (this.isActive()) {
            World.addZone(this);
        } else {
            World.removeZone(this);
        }
    }

    public boolean isActive() {
        return this._active;
    }

    public void setReflection(Reflection reflection) {
        this._reflection = reflection;
    }

    public Reflection getReflection() {
        return this._reflection;
    }

    public void setParam(String name, String value) {
        this._params.put(name, value);
    }

    public void setParam(String name, Object value) {
        this._params.put(name, value);
    }

    public MultiValueSet<String> getParams() {
        return this._params;
    }

    public <T extends Listener<Zone>> boolean addListener(T listener) {
        return this.listeners.add(listener);
    }

    public <T extends Listener<Zone>> boolean removeListener(T listener) {
        return this.listeners.remove(listener);
    }

    public final String toString() {
        return "[Zone " + (Object)((Object)this.getType()) + " name: " + this.getName() + "]";
    }

    public void broadcastPacket(L2GameServerPacket packet, boolean toAliveOnly) {
        List<Player> insideZoners = this.getInsidePlayers();
        if (insideZoners != null && !insideZoners.isEmpty()) {
            for (Player player : insideZoners) {
                if (toAliveOnly) {
                    if (player.isDead()) continue;
                    player.broadcastPacket(packet);
                    continue;
                }
                player.broadcastPacket(packet);
            }
        }
    }

    public void refreshListeners() {
        for (Creature creature : this.getObjects()) {
            this.listeners.onLeave(creature);
            this.listeners.onEnter(creature);
        }
    }

    private final Func[] getStatFuncs() {
        return this.getTemplate().getStatFuncs(this);
    }

    public class ZoneListenerList
    extends ListenerList<Zone> {
        public void onEnter(Creature actor) {
            if (!this.getListeners().isEmpty()) {
                for (Listener listener : this.getListeners()) {
                    ((OnZoneEnterLeaveListener)listener).onZoneEnter(Zone.this, actor);
                }
            }
        }

        public void onLeave(Creature actor) {
            if (!this.getListeners().isEmpty()) {
                for (Listener listener : this.getListeners()) {
                    ((OnZoneEnterLeaveListener)listener).onZoneLeave(Zone.this, actor);
                }
            }
        }
    }

    private class DamageTimer
    extends ZoneTimer {
        public DamageTimer(Creature cha) {
            super(cha);
        }

        @Override
        public void run() {
            if (!Zone.this.isActive()) {
                return;
            }
            if (!Zone.this.checkTarget(this.cha)) {
                return;
            }
            int hp = Zone.this.getDamageOnHP();
            int mp = Zone.this.getDamageOnMP();
            int message = Zone.this.getDamageMessageId();
            if (hp == 0 && mp == 0) {
                return;
            }
            if (hp > 0) {
                this.cha.reduceCurrentHp(hp, this.cha, null, false, false, true, false, false, true, true);
                if (message > 0) {
                    this.cha.sendPacket((IBroadcastPacket)new SystemMessage(message).addNumber(hp));
                }
            }
            if (mp > 0) {
                this.cha.reduceCurrentMp(mp, null);
                if (message > 0) {
                    this.cha.sendPacket((IBroadcastPacket)new SystemMessage(message).addNumber(mp));
                }
            }
            this.next();
        }
    }

    private class SkillTimer
    extends ZoneTimer {
        public SkillTimer(Creature cha) {
            super(cha);
        }

        @Override
        public void run() {
            if (!Zone.this.isActive()) {
                return;
            }
            if (!Zone.this.checkTarget(this.cha)) {
                return;
            }
            Skill skill = Zone.this.getZoneSkill();
            if (skill == null) {
                return;
            }
            if (Rnd.chance((int)Zone.this.getTemplate().getSkillProb()) && !this.cha.isDead()) {
                skill.getEffects(this.cha, this.cha);
            }
            this.next();
        }
    }

    private abstract class ZoneTimer
    implements Runnable {
        protected Creature cha;
        protected Future<?> future;
        protected boolean active;

        public ZoneTimer(Creature cha) {
            this.cha = cha;
        }

        public void start() {
            this.active = true;
            this.future = EffectTaskManager.getInstance().schedule(this, (long)Zone.this.getTemplate().getInitialDelay() * 1000L);
        }

        public void stop() {
            this.active = false;
            if (this.future != null) {
                this.future.cancel(false);
                this.future = null;
            }
        }

        public void next() {
            if (!this.active) {
                return;
            }
            if (Zone.this.getTemplate().getUnitTick() == 0 && Zone.this.getTemplate().getRandomTick() == 0) {
                return;
            }
            this.future = EffectTaskManager.getInstance().schedule(this, (long)(Zone.this.getTemplate().getUnitTick() + Rnd.get((int)0, (int)Zone.this.getTemplate().getRandomTick())) * 1000L);
        }
    }

    public static enum ZoneTarget {
        pc,
        npc,
        only_pc;

    }

    public static enum ZoneType {
        SIEGE,
        RESIDENCE,
        HEADQUARTER,
        FISHING,
        JUMPING,
        TELEPORT,
        water,
        battle_zone,
        damage,
        instant_skill,
        mother_tree,
        peace_zone,
        poison,
        CHANGED_ZONE,
        ssq_zone,
        swamp,
        no_escape,
        no_landing,
        no_restart,
        no_summon,
        dummy,
        offshore,
        epic,
        buff_store;

    }
}


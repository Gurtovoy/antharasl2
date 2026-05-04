package l2s.gameserver.model.entity.events;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.Future;
import java.util.concurrent.ScheduledFuture;
import l2s.commons.collections.MultiValueSet;
import l2s.commons.listener.Listener;
import l2s.commons.listener.ListenerList;
import l2s.commons.logging.LoggerObject;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.dao.ItemsDAO;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.listener.event.OnStartStopListener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.base.RestartType;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.events.EventAction;
import l2s.gameserver.model.entity.events.EventTimeTask;
import l2s.gameserver.model.entity.events.EventType;
import l2s.gameserver.model.entity.events.objects.InitableObject;
import l2s.gameserver.model.entity.events.objects.OpenableObject;
import l2s.gameserver.model.entity.events.objects.SpawnableObject;
import l2s.gameserver.model.entity.events.objects.TaskObject;
import l2s.gameserver.model.entity.events.objects.ZoneObject;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.stats.conditions.Condition;
import l2s.gameserver.utils.ItemFunctions;
import l2s.gameserver.utils.TimeUtils;
import org.napile.primitive.Containers;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.CHashIntObjectMap;
import org.napile.primitive.maps.impl.TreeIntObjectMap;
import org.napile.primitive.pair.IntObjectPair;

public abstract class Event
extends LoggerObject {
    public static final String EVENT = "event";
    protected final IntObjectMap<List<EventAction>> _onTimeActions = new TreeIntObjectMap();
    protected final Map<String, List<EventAction>> _onActActions = new HashMap<String, List<EventAction>>();
    protected final List<EventAction> _onStartActions = new ArrayList<EventAction>(0);
    protected final List<EventAction> _onStopActions = new ArrayList<EventAction>(0);
    protected final List<EventAction> _onInitActions = new ArrayList<EventAction>(0);
    protected final Map<Object, List<Object>> _objects = new HashMap<Object, List<Object>>(0);
    protected final MultiValueSet<String> _params;
    protected final int _id;
    protected final String _name;
    protected final ListenerListImpl _listenerList = new ListenerListImpl();
    protected IntObjectMap<ItemInstance> _banishedItems = Containers.emptyIntObjectMap();
    private List<Future<?>> _tasks = null;

    protected Event(MultiValueSet<String> set) {
        this._params = set;
        this._id = set.getInteger("id");
        this._name = set.getString("name");
    }

    protected Event(int id, String name) {
        this._params = new MultiValueSet(0);
        this._id = id;
        this._name = name;
    }

    public void initEvent() {
        this.callActions(this._onInitActions);
        this.reCalcNextTime(true);
        this.printInfo();
    }

    public void startEvent() {
        this.callActions(this._onStartActions);
        this._listenerList.onStart();
    }

    public void stopEvent(boolean force) {
        this.callActions(this._onStopActions);
        this._listenerList.onStop();
    }

    public void printInfo() {
        long startSiegeMillis = this.startTimeMillis();
        if (startSiegeMillis == 0L) {
            this.info(this.getName() + " time - undefined");
        } else {
            this.info(this.getName() + " time - " + TimeUtils.toSimpleFormat(startSiegeMillis));
        }
    }

    public String toString() {
        return this.getClass().getSimpleName() + "[" + this.getId() + ";" + this.getName() + "]";
    }

    protected void callActions(List<EventAction> actions) {
        for (EventAction action : actions) {
            action.call(this);
        }
    }

    public void addOnStartActions(List<EventAction> start) {
        this._onStartActions.addAll(start);
    }

    public void addOnStopActions(List<EventAction> start) {
        this._onStopActions.addAll(start);
    }

    public void addOnInitActions(List<EventAction> start) {
        this._onInitActions.addAll(start);
    }

    public void addOnTimeAction(int time, EventAction action) {
        List list = (List)this._onTimeActions.get(time);
        if (list != null) {
            list.add(action);
        } else {
            ArrayList<EventAction> actions = new ArrayList<EventAction>(1);
            actions.add(action);
            this._onTimeActions.put(time, actions);
        }
    }

    public void addOnTimeActions(int time, List<EventAction> actions) {
        if (actions.isEmpty()) {
            return;
        }
        for (EventAction action : actions) {
            this.addOnTimeAction(time, action);
        }
    }

    public void timeActions(int time) {
        List actions = (List)this._onTimeActions.get(time);
        if (actions == null) {
            this.info("Undefined time : " + time);
            return;
        }
        this.callActions(actions);
    }

    public int[] timeActions() {
        return this._onTimeActions.keySet().toArray();
    }

    public void addOnActAction(String act, EventAction action) {
        List<EventAction> list = this._onActActions.get(act.toLowerCase());
        if (list != null) {
            list.add(action);
        } else {
            ArrayList<EventAction> actions = new ArrayList<EventAction>(1);
            actions.add(action);
            this._onActActions.put(act.toLowerCase(), actions);
        }
    }

    public void addOnActActions(String act, List<EventAction> actions) {
        if (actions.isEmpty()) {
            return;
        }
        for (EventAction action : actions) {
            this.addOnActAction(act, action);
        }
    }

    public void actActions(String act) {
        List<EventAction> actions = this._onActActions.get(act.toLowerCase());
        if (actions == null) {
            this.info("Undefined act : " + act);
            return;
        }
        this.callActions(actions);
    }

    public synchronized void registerActions() {
        long t = this.startTimeMillis();
        if (t == 0L) {
            return;
        }
        if (this._tasks == null) {
            this._tasks = new ArrayList(this._onTimeActions.size());
        }
        long c = System.currentTimeMillis();
        for (int key : this._onTimeActions.keySet().toArray()) {
            long time = t + (long)key * 1000L;
            EventTimeTask wrapper = new EventTimeTask(this, key);
            if (time <= c) {
                ThreadPoolManager.getInstance().execute(wrapper);
                continue;
            }
            ScheduledFuture<?> task = ThreadPoolManager.getInstance().schedule(wrapper, time - c);
            if (task == null) continue;
            this._tasks.add(task);
        }
    }

    public synchronized void clearActions() {
        if (this._tasks != null) {
            for (Future future : this._tasks) {
                future.cancel(false);
            }
            this._tasks.clear();
        }
        for (List list : this._objects.values()) {
            for (Object o : list) {
                if (!(o instanceof TaskObject)) continue;
                ((TaskObject)o).cancel(this);
            }
        }
    }

    public boolean containsObjects(Object name) {
        return this._objects.get(name) != null;
    }

    @SuppressWarnings("unchecked")
    public <O> List<O> getObjects(Object name) {
        List<Object> objects = this._objects.get(name);
        return objects == null ? Collections.emptyList() : (List<O>)(List<?>)objects;
    }

    public <O> O getFirstObject(Object name) {
        List<O> objects = this.getObjects(name);
        return objects.size() > 0 ? (O)objects.get(0) : null;
    }

    public void addObject(Object name, Object object) {
        if (object == null) {
            return;
        }
        List<Object> list = this._objects.get(name);
        if (list != null) {
            list.add(object);
        } else {
            list = new CopyOnWriteArrayList<Object>();
            list.add(object);
            this._objects.put(name, list);
        }
    }

    public void removeObject(Object name, Object o) {
        if (o == null) {
            return;
        }
        List<Object> list = this._objects.get(name);
        if (list != null) {
            list.remove(o);
        }
    }

    @SuppressWarnings("unchecked")
    public <O> List<O> removeObjects(Object name) {
        List<Object> objects = this._objects.remove(name);
        return objects == null ? Collections.emptyList() : (List<O>)(List<?>)objects;
    }

    public void addObjects(Object name, Collection<?> objects) {
        if (objects.isEmpty()) {
            return;
        }
        List<Object> list = this._objects.get(name);
        if (list != null) {
            list.addAll(objects);
        } else {
            this._objects.put(name, new CopyOnWriteArrayList(objects));
        }
    }

    public Map<Object, List<Object>> getObjects() {
        return this._objects;
    }

    public void spawnAction(Object name, boolean spawn) {
        List objects = this.getObjects(name);
        if (objects.isEmpty()) {
            this.info("Undefined objects: " + name);
            return;
        }
        for (Object object : objects) {
            if (!(object instanceof SpawnableObject)) continue;
            if (spawn) {
                ((SpawnableObject)object).spawnObject(this, this.getReflection());
                continue;
            }
            ((SpawnableObject)object).despawnObject(this, this.getReflection());
        }
    }

    public void respawnAction(Object name) {
        List objects = this.getObjects(name);
        if (objects.isEmpty()) {
            this.info("Undefined objects: " + name);
            return;
        }
        for (Object object : objects) {
            if (!(object instanceof SpawnableObject)) continue;
            ((SpawnableObject)object).respawnObject(this, this.getReflection());
        }
    }

    public void openAction(Object name, boolean open) {
        List objects = this.getObjects(name);
        if (objects.isEmpty()) {
            this.info("Undefined objects: " + name);
            return;
        }
        for (Object object : objects) {
            if (!(object instanceof OpenableObject)) continue;
            if (open) {
                ((OpenableObject)object).openObject(this);
                continue;
            }
            ((OpenableObject)object).closeObject(this);
        }
    }

    public void zoneAction(Object name, boolean active) {
        List objects = this.getObjects(name);
        if (objects.isEmpty()) {
            this.info("Undefined objects: " + name);
            return;
        }
        for (Object object : objects) {
            if (!(object instanceof ZoneObject)) continue;
            ((ZoneObject)object).setActive(active, this);
        }
    }

    public void initAction(Object name) {
        List objects = this.getObjects(name);
        if (objects.isEmpty()) {
            this.info("Undefined objects: " + name);
            return;
        }
        for (Object object : objects) {
            if (!(object instanceof InitableObject)) continue;
            ((InitableObject)object).initObject(this);
        }
    }

    public void action(String name, boolean start) {
        if (name.equalsIgnoreCase(EVENT)) {
            if (start) {
                this.startEvent();
            } else {
                this.stopEvent(false);
            }
        }
    }

    public void refreshAction(Object name) {
        List objects = this.getObjects(name);
        if (objects.isEmpty()) {
            this.info("Undefined objects: " + name);
            return;
        }
        for (Object object : objects) {
            if (!(object instanceof SpawnableObject)) continue;
            ((SpawnableObject)object).refreshObject(this, this.getReflection());
        }
    }

    public void taskAction(Object name, boolean schedule) {
        List objects = this.getObjects(name);
        if (objects.isEmpty()) {
            this.info("Undefined objects: " + name);
            return;
        }
        for (Object object : objects) {
            if (!(object instanceof TaskObject)) continue;
            if (schedule) {
                ((TaskObject)object).schedule(this);
                continue;
            }
            ((TaskObject)object).cancel(this);
        }
    }

    public abstract void reCalcNextTime(boolean var1);

    public abstract EventType getType();

    protected abstract long startTimeMillis();

    public void broadcastToWorld(IBroadcastPacket packet) {
        for (Player player : GameObjectsStorage.getPlayers(false, false)) {
            player.sendPacket(packet);
        }
    }

    public MultiValueSet<String> getParams() {
        return this._params;
    }

    public int getId() {
        return this._id;
    }

    public String getName() {
        return this._name;
    }

    public GameObject getCenterObject() {
        return null;
    }

    public Reflection getReflection() {
        return ReflectionManager.MAIN;
    }

    public int getRelation(Player thisPlayer, Player target, int oldRelation) {
        return oldRelation;
    }

    public int getUserRelation(Player thisPlayer, int oldRelation) {
        return oldRelation;
    }

    public void checkRestartLocs(Player player, Map<RestartType, Boolean> r) {
    }

    public Location getRestartLoc(Player player, RestartType type) {
        return null;
    }

    public boolean canAttack(Creature target, Creature attacker, Skill skill, boolean force, boolean nextAttackCheck) {
        return false;
    }

    public SystemMsg checkForAttack(Creature target, Creature attacker, Skill skill, boolean force) {
        return null;
    }

    public SystemMsg canUseItem(Player player, ItemInstance item) {
        return null;
    }

    public boolean canUseSkill(Creature caster, Creature target, Skill skill) {
        return true;
    }

    public boolean canUseTeleport(Player player) {
        return true;
    }

    public boolean isInProgress() {
        return false;
    }

    public void findEvent(Player player) {
    }

    public void announce(int id, String value, int time) {
        throw new UnsupportedOperationException(this.getClass().getName() + " not implemented announce");
    }

    public void teleportPlayers(String teleportWho) {
        throw new UnsupportedOperationException(this.getClass().getName() + " not implemented teleportPlayers");
    }

    public boolean ifVar(String name) {
        throw new UnsupportedOperationException(this.getClass().getName() + " not implemented ifVar");
    }

    public List<Player> itemObtainPlayers() {
        throw new UnsupportedOperationException(this.getClass().getName() + " not implemented itemObtainPlayers");
    }

    public void giveItem(Player player, int itemId, long count) {
        switch (itemId) {
            case -300: {
                player.setFame(player.getFame() + (int)count, this.toString(), true);
                break;
            }
            default: {
                ItemFunctions.addItem(player, itemId, count);
            }
        }
    }

    public List<Player> broadcastPlayers(int range) {
        throw new UnsupportedOperationException(this.getClass().getName() + " not implemented broadcastPlayers");
    }

    public boolean canResurrect(Creature active, Creature target, boolean force, boolean quiet) {
        throw new UnsupportedOperationException(this.getClass().getName() + " not implemented canResurrect");
    }

    public void onAddEvent(GameObject o) {
    }

    public void onRemoveEvent(GameObject o) {
    }

    @SuppressWarnings("unchecked")
    public void addBanishItem(ItemInstance item) {
        if (this._banishedItems == (IntObjectMap)Containers.emptyIntObjectMap()) {
            this._banishedItems = new CHashIntObjectMap();
        }
        this._banishedItems.put(item.getObjectId(), item);
    }

    public void removeBanishItems() {
        Iterator iterator = this._banishedItems.entrySet().iterator();
        while (iterator.hasNext()) {
            IntObjectPair entry = (IntObjectPair)iterator.next();
            iterator.remove();
            ItemInstance item = ItemsDAO.getInstance().load(entry.getKey());
            if (item != null) {
                GameObject object;
                if (item.getOwnerId() > 0 && (object = GameObjectsStorage.findObject(item.getOwnerId())) != null && object.isPlayable()) {
                    ((Playable)object).getInventory().destroyItem(item);
                    object.getPlayer().sendPacket((IBroadcastPacket)SystemMessagePacket.removeItems(item));
                }
                item.delete();
            } else {
                item = (ItemInstance)entry.getValue();
            }
            item.deleteMe();
        }
    }

    public void addListener(Listener<Event> l) {
        this._listenerList.add(l);
    }

    public void removeListener(Listener<Event> l) {
        this._listenerList.remove(l);
    }

    public void cloneTo(Event e) {
        for (EventAction eventAction : this._onInitActions) {
            e._onInitActions.add(eventAction);
        }
        for (EventAction eventAction : this._onStartActions) {
            e._onStartActions.add(eventAction);
        }
        for (EventAction eventAction : this._onStopActions) {
            e._onStopActions.add(eventAction);
        }
        for (Map.Entry entry : this._onActActions.entrySet()) {
            e.addOnActActions((String)entry.getKey(), (List)entry.getValue());
        }
        for (IntObjectPair intObjectPair : this._onTimeActions.entrySet()) {
            e.addOnTimeActions(intObjectPair.getKey(), (List)intObjectPair.getValue());
        }
        for (Map.Entry entry : this._objects.entrySet()) {
            e.addObjects(entry.getKey(), (Collection)entry.getValue());
        }
    }

    public String getVisibleName(Player player, Player observer) {
        return null;
    }

    public String getVisibleTitle(Player player, Player observer) {
        return null;
    }

    public Integer getVisibleNameColor(Player player, Player observer) {
        return null;
    }

    public Integer getVisibleTitleColor(Player player, Player observer) {
        return null;
    }

    public boolean isPledgeVisible(Player player, Player observer) {
        return true;
    }

    public boolean checkCondition(Creature creature, Class<? extends Condition> conditionClass) {
        return true;
    }

    public Boolean isInZoneBattle(Creature creature) {
        return null;
    }

    public Boolean isInvisible(Creature creature, GameObject observer) {
        return null;
    }

    public boolean canJoinParty(Player inviter, Player target) {
        return true;
    }

    public boolean canLeaveParty(Player player) {
        return true;
    }

    public void checkTargetsForSkill(Skill skill, Set<Creature> targets, Creature activeChar, Creature aimingTarget, boolean forceUse) {
    }

    public final long getForceStartTime() {
        int minTime = 0;
        for (int time : this.timeActions()) {
            if (time >= minTime) continue;
            minTime = time;
        }
        return System.currentTimeMillis() + (long)Math.abs(minTime) * 1000L + 1000L;
    }

    public boolean isForceScheduled() {
        return false;
    }

    public boolean forceScheduleEvent() {
        return false;
    }

    public boolean forceCancelEvent() {
        return false;
    }

    private class ListenerListImpl
    extends ListenerList<Event> {
        private ListenerListImpl() {
        }

        public void onStart() {
            for (Listener listener : this.getListeners()) {
                if (!OnStartStopListener.class.isInstance(listener)) continue;
                ((OnStartStopListener)listener).onStart(Event.this);
            }
        }

        public void onStop() {
            for (Listener listener : this.getListeners()) {
                if (!OnStartStopListener.class.isInstance(listener)) continue;
                ((OnStartStopListener)listener).onStop(Event.this);
            }
        }
    }
}


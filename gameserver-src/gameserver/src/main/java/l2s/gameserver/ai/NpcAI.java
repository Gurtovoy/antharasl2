package l2s.gameserver.ai;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.ai.CharacterAI;
import l2s.gameserver.ai.CtrlEvent;
import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.WorldRegion;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.network.l2.components.NpcString;
import l2s.gameserver.network.l2.s2c.ExRotation;
import l2s.gameserver.network.l2.s2c.SocialActionPacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.taskmanager.AiTaskManager;
import l2s.gameserver.templates.npc.RandomActions;
import l2s.gameserver.templates.npc.WalkerRoute;
import l2s.gameserver.templates.npc.WalkerRoutePoint;
import l2s.gameserver.utils.Functions;
import l2s.gameserver.utils.NpcUtils;

public class NpcAI
extends CharacterAI {
    public static final String WALKER_ROUTE_PARAM = "walker_route_id";
    private static final int WALKER_ROUTE_TIMER_ID = -1000;
    private static final int RANDOM_ACTION_TIMER_ID = -2000;
    protected ScheduledFuture<?> _aiTask;
    protected long _attackAITaskDelay = Config.AI_TASK_ATTACK_DELAY;
    protected long _activeAITaskDelay;
    protected long _currentAITaskDelay = this._activeAITaskDelay = Config.AI_TASK_ACTIVE_DELAY;
    protected Lock _thinking = new ReentrantLock();
    private final RandomActions _randomActions;
    private final boolean _haveRandomActions;
    private int _currentActionId;
    private WalkerRoute _walkerRoute;
    private boolean _haveWalkerRoute;
    private boolean _toBackWay;
    private int _currentWalkerPoint;
    private boolean _delete;
    private final List<Creature> _neighbors = new ArrayList<Creature>();
    private long _lastNeighborsClean = 0L;
    protected boolean _isGlobal;
    protected long _lastActiveCheck;
    private int _walkTryCount = 0;
    private long _lookNeighborTimestamp = 0L;
    private final Lock _lockLookNeighbor = new ReentrantLock();
    private final List<NpcInstance> _exPrivates = new ArrayList<NpcInstance>();

    public NpcAI(NpcInstance actor) {
        super(actor);
        this._randomActions = actor.getTemplate().getRandomActions();
        this._haveRandomActions = this._randomActions != null && this._randomActions.getActionsCount() > 0;
        this._currentActionId = 0;
        this.setWalkerRoute(actor.getParameter(WALKER_ROUTE_PARAM, -1));
        this._isGlobal = actor.getParameter("GlobalAI", false);
    }

    public void setWalkerRoute(WalkerRoute walkerRoute) {
        this._walkerRoute = walkerRoute;
        this._haveWalkerRoute = this._walkerRoute != null && this._walkerRoute.isValid();
        this._toBackWay = false;
        this._currentWalkerPoint = -1;
        this._delete = false;
        if (this.isActive()) {
            this.setIntention(CtrlIntention.AI_INTENTION_WALKER_ROUTE);
        }
    }

    public void setWalkerRoute(int id) {
        this.setWalkerRoute(this.getActor().getTemplate().getWalkerRoute(id));
    }

    @Override
    protected void onEvtArrived() {
        NpcInstance actor = this.getActor();
        Location sloc = actor.getSpawnedLoc();
        if (sloc != null && sloc.h >= 0 && actor.isInRangeZ(sloc, 32)) {
            actor.setHeading(sloc.h);
        }
        actor.broadcastPacket(new ExRotation(actor.getObjectId(), actor.getHeading()));
        this.continueWalkerRoute();
    }

    @Override
    protected void onEvtTeleported() {
        this.continueWalkerRoute();
    }

    @Override
    protected void onEvtSeeCreatue(Creature creature) {
        this.getActor().onSeeCreatue(creature);
    }

    @Override
    protected void onEvtDisappearCreatue(Creature creature) {
        this.getActor().onDisappearCreatue(creature);
    }

    @Override
    protected void onEvtDead(Creature killer) {
        super.onEvtDead(killer);
        for (NpcInstance minion : this._exPrivates) {
            minion.deleteMe();
        }
    }

    public NpcInstance createOnePrivateEx(int npcId, String ai, int weight, int respawn, int x, int y, int z, int h, long p1, long p2, long p3) {
        NpcInstance npc;
        NpcInstance actor = this.getActor();
        if (actor.isVisible() && !actor.isDead() && (npc = NpcUtils.spawnSingle(npcId, x, y, z, h, actor.getReflection(), 0L)) != null) {
            this._exPrivates.add(npc);
            return npc;
        }
        return null;
    }

    @Override
    protected void onIntentionIdle() {
        this._lockLookNeighbor.lock();
        try {
            this._neighbors.clear();
        }
        finally {
            this._lockLookNeighbor.unlock();
        }
        this.changeIntention(CtrlIntention.AI_INTENTION_IDLE, null, null);
    }

    @Override
    protected void onIntentionWalkerRoute() {
        if (this._haveWalkerRoute) {
            this.clientStopMoving();
            this.moveToNextPoint(0);
            this.changeIntention(CtrlIntention.AI_INTENTION_WALKER_ROUTE, null, null);
        }
    }

    @Override
    protected void onEvtTimer(int timerId, Object arg1, Object arg2) {
        NpcInstance actor = this.getActor();
        if (timerId == -1000) {
            if (this._haveWalkerRoute) {
                this.moveToNextPoint(0);
            }
        } else if (timerId == -2000 && this._haveRandomActions) {
            this.makeRandomAction();
        }
        actor.onTimerFired(timerId);
    }

    @Override
    protected void onEvtThink() {
        NpcInstance actor = this.getActor();
        if (actor == null || actor.isActionsDisabled()) {
            return;
        }
        if (!this._thinking.tryLock()) {
            return;
        }
        try {
            this.lookNeighbor(actor.getAggroRange(), false);
            if (this.getIntention() == CtrlIntention.AI_INTENTION_ACTIVE || this.getIntention() == CtrlIntention.AI_INTENTION_WALKER_ROUTE) {
                this.thinkActive();
            }
        }
        finally {
            this._thinking.unlock();
        }
    }

    protected boolean thinkActive() {
        NpcInstance actor = this.getActor();
        if (actor == null) {
            return false;
        }
        if (this._haveWalkerRoute) {
            if (this.getIntention() == CtrlIntention.AI_INTENTION_WALKER_ROUTE) {
                if (!actor.getMovement().isMoving() && !this.haveTask(-1000)) {
                    ++this._walkTryCount;
                    if (this._walkTryCount >= 10) {
                        this.moveToNextPoint(0);
                        return true;
                    }
                }
            } else {
                this.changeIntention(CtrlIntention.AI_INTENTION_WALKER_ROUTE, null, null);
                this.moveToLocation(actor.getSpawnedLoc());
                return true;
            }
        }
        return false;
    }

    @Override
    public final synchronized void startAITask() {
        RandomActions.Action action;
        if (this._aiTask == null) {
            this._currentAITaskDelay = this._activeAITaskDelay;
            this._aiTask = AiTaskManager.getInstance().scheduleAtFixedRate(this, 0L, this._currentAITaskDelay);
        }
        if (this._haveWalkerRoute) {
            this.setIntention(CtrlIntention.AI_INTENTION_WALKER_ROUTE);
        }
        if (this._haveRandomActions && (action = this._randomActions.getAction(1)) != null) {
            this.addTask(-2000, (long)Rnd.get((int)0, (int)action.getDelay()) * 1000L);
        }
    }

    protected final synchronized void switchAITask(long delay) {
        if (this._aiTask != null) {
            if (this._currentAITaskDelay == delay) {
                return;
            }
            this._aiTask.cancel(false);
        }
        this._currentAITaskDelay = delay;
        this._aiTask = AiTaskManager.getInstance().scheduleAtFixedRate(this, 0L, this._currentAITaskDelay);
    }

    @Override
    public final synchronized void stopAITask() {
        if (this._aiTask != null) {
            this._aiTask.cancel(false);
            this._aiTask = null;
        }
    }

    @Override
    public boolean isGlobalAI() {
        return this._isGlobal;
    }

    @Override
    public boolean isActive() {
        return this._aiTask != null;
    }

    @Override
    public void run() {
        if (!this.isActive()) {
            return;
        }
        if (!this.isGlobalAI() && System.currentTimeMillis() - this._lastActiveCheck > 60000L) {
            WorldRegion region;
            this._lastActiveCheck = System.currentTimeMillis();
            NpcInstance actor = this.getActor();
            WorldRegion worldRegion = region = actor == null ? null : actor.getCurrentRegion();
            if (region == null || !region.isActive()) {
                this.stopAITask();
                return;
            }
        }
        this.onEvtThink();
    }

    private void continueWalkerRoute() {
        if (!this.isActive() || this.getIntention() != CtrlIntention.AI_INTENTION_WALKER_ROUTE) {
            return;
        }
        if (this._haveWalkerRoute) {
            if (this._currentWalkerPoint >= 0) {
                NpcString phrase;
                WalkerRoutePoint route = this._walkerRoute.getPoint(this._currentWalkerPoint);
                if (route == null) {
                    this.moveToNextPoint(0);
                    return;
                }
                NpcInstance actor = this.getActor();
                int socialActionId = route.getSocialActionId();
                if (socialActionId >= 0) {
                    actor.broadcastPacket(new SocialActionPacket(actor.getObjectId(), socialActionId));
                }
                if ((phrase = (NpcString)((Object)Rnd.get((Object[])route.getPhrases()))) != null) {
                    Functions.npcSay(actor, phrase, new String[0]);
                }
                this.moveToNextPoint(route.getDelay());
            } else {
                this.moveToNextPoint(0);
            }
        }
    }

    private void moveToNextPoint(int delay) {
        if (!this.isActive() || this.getIntention() != CtrlIntention.AI_INTENTION_WALKER_ROUTE) {
            return;
        }
        if (!this._haveWalkerRoute) {
            return;
        }
        if (delay > 0) {
            this.addTask(-1000, (long)delay * 1000L);
            return;
        }
        this._walkTryCount = 0;
        NpcInstance actor = this.getActor();
        if (actor == null) {
            return;
        }
        switch (this._walkerRoute.getType()) {
            case LENGTH: {
                this._currentWalkerPoint = this._toBackWay ? --this._currentWalkerPoint : ++this._currentWalkerPoint;
                if (this._currentWalkerPoint >= this._walkerRoute.size() - 1) {
                    this._toBackWay = true;
                }
                if (this._currentWalkerPoint != 0) break;
                this._toBackWay = false;
                break;
            }
            case ROUND: {
                ++this._currentWalkerPoint;
                if (this._currentWalkerPoint < this._walkerRoute.size()) break;
                this._currentWalkerPoint = 0;
                break;
            }
            case RANDOM: {
                if (this._walkerRoute.size() <= 1) break;
                int oldPoint = this._currentWalkerPoint;
                while (oldPoint == this._currentWalkerPoint) {
                    this._currentWalkerPoint = Rnd.get((int)(this._walkerRoute.size() - 1));
                }
                break;
            }
            case DELETE: {
                if (this._delete) {
                    actor.deleteMe();
                    return;
                }
                ++this._currentWalkerPoint;
                if (this._currentWalkerPoint < this._walkerRoute.size()) break;
                this._delete = true;
                break;
            }
            case FINISH: {
                ++this._currentWalkerPoint;
                if (this._currentWalkerPoint < this._walkerRoute.size()) break;
                actor.getMovement().stopMove();
                int routeId = this._walkerRoute.getId();
                this.setWalkerRoute(null);
                this.notifyEvent(CtrlEvent.EVT_FINISH_WALKER_ROUTE, routeId);
                return;
            }
        }
        WalkerRoutePoint route = this._walkerRoute.getPoint(this._currentWalkerPoint);
        if (route == null) {
            return;
        }
        if (route.isRunning()) {
            actor.setRunning();
        } else {
            actor.setWalking();
        }
        if (route.isTeleport()) {
            actor.teleToLocation(route.getLocation());
            this.continueWalkerRoute();
        } else {
            this.moveToLocation(route.getLocation());
        }
    }

    private void makeRandomAction() {
        if (!this.isActive()) {
            return;
        }
        if (!this._haveRandomActions) {
            return;
        }
        NpcInstance actor = this.getActor();
        if (actor == null) {
            return;
        }
        if (this.getIntention() == CtrlIntention.AI_INTENTION_ACTIVE || this.getIntention() == CtrlIntention.AI_INTENTION_WALKER_ROUTE) {
            NpcString phrase;
            RandomActions.Action action;
            ++this._currentActionId;
            if (this._currentActionId > this._randomActions.getActionsCount()) {
                this._currentActionId = 1;
            }
            if ((action = this._randomActions.getAction(this._currentActionId)) == null) {
                return;
            }
            int socialActionId = action.getSocialActionId();
            if (socialActionId >= 0) {
                actor.broadcastPacket(new SocialActionPacket(actor.getObjectId(), socialActionId));
            }
            if ((phrase = action.getPhrase()) != null) {
                Functions.npcSay(actor, phrase, new String[0]);
            }
            this.addTask(-2000, (long)action.getDelay() * 1000L);
        } else {
            this.addTask(-2000, 1000L);
        }
    }

    private void moveToLocation(Location loc) {
        NpcInstance actor = this.getActor();
        if (actor == null) {
            return;
        }
        if (this.getIntention() == CtrlIntention.AI_INTENTION_WALKER_ROUTE) {
            loc = Location.findPointToStay(loc, 50, actor.getGeoIndex());
            loc.h = -1;
            actor.setSpawnedLoc(loc);
            if (!actor.getMovement().moveToLocation(loc, 0, true)) {
                this.clientStopMoving();
                actor.teleToLocation(loc);
            }
        }
    }

    @Override
    public NpcInstance getActor() {
        return (NpcInstance)super.getActor();
    }

    protected boolean isHaveRandomActions() {
        return this._haveRandomActions;
    }

    protected boolean isHaveWalkerRoute() {
        return this._haveWalkerRoute;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    protected boolean lookNeighbor(int range, boolean force) {
        if (!this.isActive()) {
            return false;
        }
        if (range <= 0) {
            return false;
        }
        NpcInstance actor = this.getActor();
        if (actor == null) {
            return false;
        }
        this._lockLookNeighbor.lock();
        try {
            long now = System.currentTimeMillis();
            if (now - this._lookNeighborTimestamp > 500L) {
                this._lookNeighborTimestamp = now;
                for (Creature creature : actor.getAroundCharacters(range, 250)) {
                    if (this._neighbors.contains(creature) || creature.isInvisible(actor)) continue;
                    this.notifyEvent(CtrlEvent.EVT_SEE_CREATURE, creature);
                    this._neighbors.add(creature);
                }
                Iterator<Creature> itr = this._neighbors.iterator();
                while (itr.hasNext()) {
                    Creature creature;
                    creature = itr.next();
                    if (actor.isInRangeZ(creature, range) && !creature.isInvisible(actor)) continue;
                    itr.remove();
                    this.notifyEvent(CtrlEvent.EVT_DISAPPEAR_CREATURE, creature);
                }
                boolean bl = true;
                return bl;
            }
        }
        finally {
            this._lockLookNeighbor.unlock();
        }
        return false;
    }

    protected void removeNeighbor(Creature creature) {
        this._lockLookNeighbor.lock();
        try {
            if (this._neighbors.remove(creature)) {
                this.notifyEvent(CtrlEvent.EVT_DISAPPEAR_CREATURE, creature);
            }
        }
        finally {
            this._lockLookNeighbor.unlock();
        }
    }

    @Override
    protected void onEvtForgetObject(GameObject object) {
        super.onEvtForgetObject(object);
        if (object.isCreature()) {
            this.removeNeighbor((Creature)object);
        }
    }

    protected boolean hasRandomWalk() {
        return !this._haveWalkerRoute && this.getActor().hasRandomWalk();
    }

    public boolean returnHomeAndRestore(boolean running) {
        return false;
    }

    public void addTaskCast(Creature target, SkillEntry skillEntry) {
    }

    public void addTaskBuff(Creature target, SkillEntry skillEntry) {
    }

    public void addTaskAttack(Creature target) {
        this.addTaskAttack(target, null, 10000);
    }

    public void addTaskAttack(Creature target, SkillEntry skillEntry, int weight) {
    }

    public void addTaskMove(Location loc, boolean pathfind, boolean teleportIfCantMove) {
    }

    public void addTaskMove(int locX, int locY, int locZ, boolean pathfind, boolean teleportIfCantMove) {
        this.addTaskMove(new Location(locX, locY, locZ), pathfind, teleportIfCantMove);
    }

    public void addUseSkillDesire(Creature target, SkillEntry skillEntry, int p1, int p2, long desire) {
    }

    public void addAttackDesire(Creature target, int p1, long desire) {
    }

    public void addMoveAroundDesire(int p1, long desire) {
    }
}


/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.collections.LazyArrayList
 *  l2s.commons.lang.reference.HardReference
 *  l2s.commons.math.random.RndSelector
 *  l2s.commons.util.Rnd
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.ai;

import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.NavigableSet;
import java.util.concurrent.ConcurrentSkipListSet;
import java.util.concurrent.ScheduledFuture;
import l2s.commons.collections.LazyArrayList;
import l2s.commons.lang.reference.HardReference;
import l2s.commons.math.random.RndSelector;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.ai.CtrlEvent;
import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.ai.NpcAI;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.AggroList;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.World;
import l2s.gameserver.model.instances.DecoyInstance;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.instances.RaidBossInstance;
import l2s.gameserver.model.quest.QuestEventType;
import l2s.gameserver.model.quest.QuestState;
import l2s.gameserver.network.l2.s2c.MagicSkillUse;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.templates.spawn.SpawnRange;
import l2s.gameserver.utils.NpcUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DefaultAI
extends NpcAI {
    protected static final Logger _log = LoggerFactory.getLogger(DefaultAI.class);
    public static final int TaskDefaultWeight = 10000;
    public final int MAX_HATE_RANGE = 2000;
    private int _maxPursueRange;
    protected ScheduledFuture<?> _runningTask;
    protected ScheduledFuture<?> _madnessTask;
    protected boolean _def_think = false;
    protected long _globalAggro;
    protected long _randomAnimationEnd;
    protected int _pathfindFails;
    protected final NavigableSet<Task> _tasks = new ConcurrentSkipListSet<Task>(TaskComparator.getInstance());
    protected final Skill[] _damSkills;
    protected final Skill[] _dotSkills;
    protected final Skill[] _debuffSkills;
    protected final Skill[] _healSkills;
    protected final Skill[] _buffSkills;
    protected final Skill[] _stunSkills;
    protected long _checkAggroTimestamp = 0L;
    protected long _lastFactionNotifyTime = 0L;
    protected final long _minFactionNotifyInterval;
    protected final Comparator<Creature> _nearestTargetComparator;
    private ScheduledFuture<?> _followTask;
    protected Object _intention_arg0 = null;
    protected Object _intention_arg1 = null;
    private static final int MAX_PATHFIND_FAILS = 3;
    private static final int TELEPORT_TIMEOUT = 10000;
    private static final int MAX_ATTACK_TIMEOUT = 15000;
    private boolean _isSearchingMaster;
    private boolean _canRestoreOnReturnHome;
    private long _lastRaidPvpZoneCheck;
    private Location _lastLeaderPos = null;

    @Override
    public void addTaskCast(Creature target, SkillEntry skillEntry) {
        Task task = new Task();
        task.type = TaskType.CAST;
        task.target = target.getRef();
        task.skillEntry = skillEntry;
        this._tasks.add(task);
        this._def_think = true;
    }

    @Override
    public void addTaskBuff(Creature target, SkillEntry skillEntry) {
        Task task = new Task();
        task.type = TaskType.BUFF;
        task.target = target.getRef();
        task.skillEntry = skillEntry;
        this._tasks.add(task);
        this._def_think = true;
    }

    @Override
    public void addTaskAttack(Creature target, SkillEntry skillEntry, int weight) {
        Task task = new Task();
        task.type = skillEntry == null ? TaskType.ATTACK : (skillEntry.getTemplate().isDebuff() ? TaskType.CAST : TaskType.BUFF);
        task.target = target.getRef();
        task.skillEntry = skillEntry;
        task.weight = weight;
        if (skillEntry != null) {
            this._globalAggro = 0L;
        }
        this._tasks.add(task);
        this._def_think = true;
    }

    @Override
    public void addTaskMove(Location loc, boolean pathfind, boolean teleportIfCantMove) {
        Task task = new Task();
        task.type = TaskType.MOVE;
        task.loc = loc;
        task.pathfind = pathfind;
        task.teleportIfCantMove = teleportIfCantMove;
        this._tasks.add(task);
        this._def_think = true;
    }

    @Override
    public void addUseSkillDesire(Creature target, SkillEntry skillEntry, int p1, int p2, long desire) {
        Task task = new Task();
        task.type = skillEntry.getTemplate().isDebuff() ? TaskType.CAST : TaskType.BUFF;
        task.target = target.getRef();
        task.skillEntry = skillEntry;
        task.p1 = p1;
        task.p2 = p2;
        task.weight = desire;
        this._globalAggro = 0L;
        this._tasks.add(task);
        this._def_think = true;
    }

    @Override
    public void addAttackDesire(Creature target, int p1, long desire) {
        Task task = new Task();
        task.type = TaskType.ATTACK;
        task.target = target.getRef();
        task.p1 = p1;
        task.weight = desire;
        this._globalAggro = 0L;
        this._tasks.add(task);
        this._def_think = true;
    }

    @Override
    public void addMoveAroundDesire(int p1, long desire) {
        if (this.getIntention() != CtrlIntention.AI_INTENTION_ACTIVE || !Rnd.chance((int)p1)) {
            return;
        }
        Task task = new Task();
        task.type = TaskType.MOVE;
        task.p1 = p1;
        Location loc = this.getActor().getSpawnedLoc();
        if (loc == null) {
            loc = this.getActor().getLoc();
        }
        task.loc = Location.findPointToStay(loc, 50, 150, this.getActor().getGeoIndex());
        task.pathfind = true;
        task.weight = desire;
        this._tasks.add(task);
        this._def_think = true;
    }

    public DefaultAI(NpcInstance actor) {
        super(actor);
        this._damSkills = actor.getTemplate().getDamageSkills();
        this._dotSkills = actor.getTemplate().getDotSkills();
        this._debuffSkills = actor.getTemplate().getDebuffSkills();
        this._buffSkills = actor.getTemplate().getBuffSkills();
        this._stunSkills = actor.getTemplate().getStunSkills();
        this._healSkills = actor.getTemplate().getHealSkills();
        this._nearestTargetComparator = new NearestTargetComparator(actor);
        this._maxPursueRange = actor.getParameter("max_pursue_range", actor.isRaid() ? Config.MAX_PURSUE_RANGE_RAID : (actor.isUnderground() ? Config.MAX_PURSUE_UNDERGROUND_RANGE : Config.MAX_PURSUE_RANGE));
        this._minFactionNotifyInterval = actor.getParameter("FactionNotifyInterval", 1000);
        this._isSearchingMaster = actor.getParameter("searchingMaster", false);
        this._canRestoreOnReturnHome = actor.getParameter("restore_on_return_home", actor.isRaid() && !actor.isBoss());
    }

    @Override
    public void changeIntention(CtrlIntention intention, Object arg0, Object arg1) {
        super.changeIntention(intention, arg0, arg1);
        this._intention_arg0 = arg0;
        this._intention_arg1 = arg1;
    }

    @Override
    public void setIntention(CtrlIntention intention, Object arg0, Object arg1) {
        this._intention_arg0 = null;
        this._intention_arg1 = null;
        super.setIntention(intention, arg0, arg1);
    }

    protected boolean canSeeInSilentMove(Playable target) {
        if (this.getActor().getParameter("canSeeInSilentMove", false)) {
            return true;
        }
        return !target.isSilentMoving();
    }

    protected boolean checkAggression(Creature target) {
        NpcInstance actor = this.getActor();
        if (this.getIntention() != CtrlIntention.AI_INTENTION_ACTIVE && this.getIntention() != CtrlIntention.AI_INTENTION_WALKER_ROUTE || !this.isGlobalAggro()) {
            return false;
        }
        if (target.isAlikeDead()) {
            return false;
        }
        if (!target.isTargetable(actor)) {
            return false;
        }
        if (target.isPlayable()) {
            if (!this.canSeeInSilentMove((Playable)target)) {
                return false;
            }
            if (actor.getFaction().containsName("varka_silenos_clan") && target.getPlayer().getVarka() > 0) {
                return false;
            }
            if (actor.getFaction().containsName("ketra_orc_clan") && target.getPlayer().getKetra() > 0) {
                return false;
            }
            if (((Playable)target).isInNonAggroTime()) {
                return false;
            }
            if (target.isPlayer()) {
                Player player = target.getPlayer();
                if (player.isGMInvisible()) {
                    return false;
                }
                if (player.isInAwayingMode() && !Config.AWAY_PLAYER_TAKE_AGGRO) {
                    return false;
                }
                if (!player.isActive()) {
                    return false;
                }
                if ((actor.isMonster() || actor instanceof DecoyInstance) && (player.isInStoreMode() || player.isInOfflineMode())) {
                    return false;
                }
            }
        }
        if (!this.isInAggroRange(target)) {
            return false;
        }
        if (!this.canAttackCharacter(target)) {
            return false;
        }
        return GeoEngine.canSeeTarget(actor, target);
    }

    protected boolean isInAggroRange(Creature target) {
        NpcInstance actor = this.getActor();
        AggroList.AggroInfo ai = actor.getAggroList().get(target);
        return !(ai != null && ai.hate > 0 ? !target.isInRangeZ(actor.getSpawnedLoc(), this.getMaxHateRange()) : !this.isAggressive() || !target.isInRangeZ(actor.getSpawnedLoc(), this.getAggroRange()));
    }

    protected void setIsInRandomAnimation(long time) {
        this._randomAnimationEnd = System.currentTimeMillis() + time;
    }

    protected boolean randomAnimation() {
        if (this.isHaveRandomActions()) {
            return false;
        }
        NpcInstance actor = this.getActor();
        if (actor.getParameter("noRandomAnimation", false)) {
            return false;
        }
        if (!(!actor.hasRandomAnimation() || actor.isActionsDisabled() || actor.getMovement().isMoving() || actor.isInCombat() || !Rnd.chance((int)Config.RND_ANIMATION_RATE) || actor.isKnockDowned() || actor.isKnockBacked() || actor.isFlyUp())) {
            this.setIsInRandomAnimation(3000L);
            actor.onRandomAnimation();
            return true;
        }
        return false;
    }

    protected boolean randomWalk() {
        return !this.getActor().getMovement().isMoving() && this.maybeMoveToHome(false);
    }

    @Override
    protected boolean thinkActive() {
        NpcInstance leader;
        NpcInstance leader2;
        NpcInstance actor = this.getActor();
        if (actor.isMinion() && (leader2 = actor.getLeader()) != null && !leader2.isVisible()) {
            actor.deleteMe();
            return false;
        }
        if (super.thinkActive()) {
            return true;
        }
        if (actor.isActionsDisabled()) {
            return true;
        }
        if (this._randomAnimationEnd > System.currentTimeMillis()) {
            return true;
        }
        if (this._def_think) {
            if (this.doTask()) {
                this.clearTasks();
            }
            return true;
        }
        long now = System.currentTimeMillis();
        if (now - this._checkAggroTimestamp > (long)Config.AGGRO_CHECK_INTERVAL) {
            int radius = 0;
            this._checkAggroTimestamp = now;
            boolean aggressive = Rnd.chance((int)actor.getParameter("SelfAggressive", this.isAggressive() ? 100 : 0));
            int n = !actor.getAggroList().isEmpty() ? this.getMaxPursueRange() : (aggressive ? (this.getAggroRange() > 0 ? this.getAggroRange() : 1000) : (radius = 0));
            if (radius > 0) {
                List<Creature> targets = World.getAroundAttackableCreatures(actor, radius, 250);
                try {
                    Collections.sort(targets, this._nearestTargetComparator);
                }
                catch (Exception e) {
                    // empty catch block
                }
                for (Creature target : targets) {
                    if (!aggressive && actor.getAggroList().get(target) == null || !this.checkAggression(target)) continue;
                    this.notifyEvent(CtrlEvent.EVT_AGGRESSION, target, 2);
                    return true;
                }
            }
        }
        if (actor.isMinion() && actor.isSpawnLeaderDepends() && (leader = actor.getLeader()) != null) {
            Location leaderPos = leader.getLoc();
            if (actor.getDistance(leader) > this.getMaxPursueRange() || !GeoEngine.canSeeTarget(actor, leader)) {
                this._lastLeaderPos = leaderPos;
                actor.teleToLocation(leader.getRndMinionPosition());
                return true;
            }
            if (this._lastLeaderPos == null || !this._lastLeaderPos.equals(leader.getLoc())) {
                this._lastLeaderPos = leaderPos;
                this.addTaskMove(leader.getRndMinionPosition(), true, false);
                return true;
            }
        }
        this.notifyEvent(CtrlEvent.EVT_NO_DESIRE);
        return true;
    }

    @Override
    protected void onEvtNoDesire() {
        if (this.randomAnimation()) {
            return;
        }
        this.randomWalk();
    }

    @Override
    protected void onIntentionIdle() {
        NpcInstance actor = this.getActor();
        this.clearTasks();
        actor.getMovement().stopMove();
        actor.getAggroList().clear(true);
        this.setAttackTarget(null);
        super.onIntentionIdle();
    }

    @Override
    protected void onIntentionActive() {
        NpcInstance actor = this.getActor();
        actor.getMovement().stopMove();
        actor.setLastAttackTime(-1L);
        if (this.getIntention() != CtrlIntention.AI_INTENTION_ACTIVE) {
            this.switchAITask(this._activeAITaskDelay);
            this.changeIntention(CtrlIntention.AI_INTENTION_ACTIVE, null, null);
        }
        this.onEvtThink();
    }

    @Override
    protected void onIntentionAttack(Creature target) {
        NpcInstance actor = this.getActor();
        this.clearTasks();
        actor.getMovement().stopMove();
        this.setAttackTarget(target);
        this.setGlobalAggro(0L);
        if (this.getIntention() != CtrlIntention.AI_INTENTION_ATTACK) {
            this.changeIntention(CtrlIntention.AI_INTENTION_ATTACK, target, null);
            this.switchAITask(this._attackAITaskDelay);
        }
        this.onEvtThink();
    }

    @Override
    public boolean canAttackCharacter(Creature target) {
        return this.getActor().canAttackCharacter(target);
    }

    protected boolean isAggressive() {
        return this.getActor().isAggressive();
    }

    protected int getAggroRange() {
        return this.getActor().getAggroRange();
    }

    protected boolean checkTarget(Creature target, int range) {
        NpcInstance actor = this.getActor();
        if (target == null || actor == target || target.isAlikeDead() || !actor.isInRangeZ(target, range) || !target.isTargetable(actor)) {
            return false;
        }
        if (target.isPlayable() && ((Playable)target).isInNonAggroTime()) {
            return false;
        }
        boolean hidden = target.isInvisible(actor);
        if (!hidden && actor.isConfused()) {
            return true;
        }
        if (this.getIntention() == CtrlIntention.AI_INTENTION_ATTACK && (this.canAttackCharacter(target) || target.getAI().canAttackCharacter(actor))) {
            AggroList.AggroInfo ai = actor.getAggroList().get(target);
            if (ai != null) {
                if (hidden) {
                    ai.hate = 0;
                    return false;
                }
                return ai.hate > 0;
            }
            return false;
        }
        if (hidden) {
            return false;
        }
        return this.canAttackCharacter(target);
    }

    protected void thinkAttack() {
        NpcInstance actor = this.getActor();
        if (actor.isDead()) {
            return;
        }
        if (!actor.isInRange(actor.getSpawnedLoc(), this.getMaxPursueRange())) {
            this.returnHomeAndRestore(actor.isRunning());
            return;
        }
        if (!actor.isRunning() && this._runningTask == null) {
            actor.setRunning();
        }
        if (this.doTask() && !actor.isAttackingNow() && !actor.isCastingNow() && !this.createNewTask()) {
            if (actor.getLastAttackTime() > 0L) {
                if (System.currentTimeMillis() > actor.getLastAttackTime() + 15000L) {
                    this.returnHome(false);
                }
            } else {
                this.changeIntention(CtrlIntention.AI_INTENTION_ACTIVE, null, null);
            }
        }
    }

    @Override
    protected void onEvtSpawn() {
        this.setGlobalAggro(System.currentTimeMillis() + this.getActor().getParameter("globalAggro", 10000L));
        if (this.getActor().isMinion() && this.getActor().getLeader() != null) {
            this._isGlobal = this.getActor().getLeader().getAI().isGlobalAI();
        }
    }

    @Override
    protected void onEvtReadyToAct() {
        this.onEvtThink();
    }

    @Override
    protected void onEvtArrivedTarget() {
        this.onEvtThink();
    }

    @Override
    protected void onEvtArrived() {
        this.onEvtThink();
        super.onEvtArrived();
    }

    protected boolean tryMoveToTarget(Creature target) {
        return this.tryMoveToTarget(target, 10 + (int)this.getActor().getMinDistance(target));
    }

    protected boolean tryMoveToTarget(Creature target, int range) {
        NpcInstance actor = this.getActor();
        if (!actor.isInRange(actor.getSpawnedLoc(), this.getMaxPursueRange())) {
            this.returnHomeAndRestore(actor.isRunning());
            return false;
        }
        if (actor.getMovement().followToCharacter(target, range, true)) {
            return true;
        }
        if (!GeoEngine.canSeeTarget(actor, target)) {
            return false;
        }
        ++this._pathfindFails;
        if (this._pathfindFails >= this.getMaxPathfindFails() && System.currentTimeMillis() > actor.getLastAttackTime() + 10000L) {
            AggroList.AggroInfo hate;
            this._pathfindFails = 0;
            if (target.isPlayable() && ((hate = actor.getAggroList().get(target)) == null || hate.hate < 100 || !actor.getReflection().isMain() && actor.isRaid())) {
                this.returnHome(false);
                return false;
            }
            Location targetLoc = target.getLoc();
            Location loc = GeoEngine.moveCheckForAI(targetLoc, actor.getLoc(), actor.getGeoIndex());
            if (loc == null || !GeoEngine.canMoveToCoord(actor.getX(), actor.getY(), actor.getZ(), loc.x, loc.y, loc.z, actor.getGeoIndex())) {
                loc = targetLoc;
            }
            actor.teleToLocation(loc);
            return true;
        }
        return false;
    }

    protected boolean maybeNextTask(Task currentTask) {
        this._tasks.remove(currentTask);
        return this._tasks.size() == 0;
    }

    protected boolean doTask() {
        if (!this._def_think) {
            return true;
        }
        Task currentTask = this._tasks.pollFirst();
        if (currentTask == null) {
            this.clearTasks();
            return true;
        }
        NpcInstance actor = this.getActor();
        if (actor.isDead() || actor.isAttackingNow() || actor.isCastingNow()) {
            return false;
        }
        switch (currentTask.type) {
            case MOVE: {
                if (actor.isMovementDisabled() || !this.getIsMobile()) {
                    return true;
                }
                if (actor.isInRange(currentTask.loc, 100)) {
                    return this.maybeNextTask(currentTask);
                }
                if (actor.getMovement().isMoving()) {
                    return false;
                }
                if (actor.getMovement().moveToLocation(currentTask.loc, 0, currentTask.pathfind)) break;
                if (currentTask.teleportIfCantMove) {
                    actor.broadcastPacketToOthers(new MagicSkillUse(actor, actor, 2036, 1, 500, 0L));
                    ThreadPoolManager.getInstance().schedule(new Teleport(currentTask.loc), 500L);
                    return false;
                }
                return this.maybeNextTask(currentTask);
            }
            case ATTACK: {
                Creature target = (Creature)currentTask.target.get();
                if (target == null) {
                    return true;
                }
                if (!this.checkTarget(target, this.getMaxHateRange())) {
                    return true;
                }
                this.setAttackTarget(target);
                int range = Math.max(10, actor.getPhysicalAttackRange()) + (int)actor.getMinDistance(target);
                if (actor.isInRangeZ(target, range + 32) && GeoEngine.canSeeTarget(actor, target)) {
                    if (actor.isAttackingDisabled()) {
                        return false;
                    }
                    this.clientStopMoving();
                    this._pathfindFails = 0;
                    actor.doAttack(target);
                    return this.maybeNextTask(currentTask);
                }
                if (actor.getMovement().isMoving()) {
                    return Rnd.chance((int)25);
                }
                if (actor.isMovementDisabled() || !this.getIsMobile()) {
                    return true;
                }
                this.tryMoveToTarget(target, range);
                break;
            }
            case CAST: {
                Creature target = (Creature)currentTask.target.get();
                if (target == null) {
                    return true;
                }
                SkillEntry skillEntry = currentTask.skillEntry;
                if (skillEntry == null) {
                    return true;
                }
                Skill skill = skillEntry.getTemplate();
                if (actor.isMuted(skill) || actor.isSkillDisabled(skill) || actor.isUnActiveSkill(skill.getId())) {
                    return true;
                }
                if (skill.getTargetType() == Skill.SkillTargetType.TARGET_AURA) {
                    this.clientStopMoving();
                    this._pathfindFails = 0;
                    actor.doCast(skillEntry, actor, false);
                    return this.maybeNextTask(currentTask);
                }
                if (!this.checkTarget(target, this.getMaxHateRange())) {
                    return true;
                }
                this.setCastTarget(target);
                int range = Math.max(10, actor.getMagicalAttackRange(skill)) + (int)actor.getMinDistance(target);
                if (actor.isInRangeZ(target, range + 32) && GeoEngine.canSeeTarget(actor, target)) {
                    this.clientStopMoving();
                    this._pathfindFails = 0;
                    actor.doCast(skillEntry, target, !target.isPlayable());
                    return this.maybeNextTask(currentTask);
                }
                if (actor.getMovement().isMoving()) {
                    return Rnd.chance((int)10);
                }
                if (actor.isMovementDisabled() || !this.getIsMobile()) {
                    return true;
                }
                this.tryMoveToTarget(target, range);
                break;
            }
            case BUFF: {
                Creature target = (Creature)currentTask.target.get();
                if (target == null) {
                    return true;
                }
                SkillEntry skillEntry = currentTask.skillEntry;
                if (skillEntry == null) {
                    return true;
                }
                Skill skill = skillEntry.getTemplate();
                if (actor.isMuted(skill) || actor.isSkillDisabled(skill) || actor.isUnActiveSkill(skill.getId())) {
                    return true;
                }
                if (skill.getTargetType() == Skill.SkillTargetType.TARGET_SELF || skill.getTargetType() == Skill.SkillTargetType.TARGET_AURA) {
                    this.clientStopMoving();
                    this._pathfindFails = 0;
                    actor.doCast(skillEntry, actor, false);
                    return this.maybeNextTask(currentTask);
                }
                if (target == null || target.isAlikeDead() || !actor.isInRange(target, 2000)) {
                    return true;
                }
                int range = Math.max(10, actor.getMagicalAttackRange(skill)) + (int)actor.getMinDistance(target);
                if (actor.isInRangeZ(target, range + 32) && GeoEngine.canSeeTarget(actor, target)) {
                    this.clientStopMoving();
                    this._pathfindFails = 0;
                    actor.doCast(skillEntry, target, !target.isPlayable());
                    return this.maybeNextTask(currentTask);
                }
                if (actor.getMovement().isMoving()) {
                    return Rnd.chance((int)10);
                }
                if (actor.isMovementDisabled() || !this.getIsMobile()) {
                    return true;
                }
                this.tryMoveToTarget(target, range);
                break;
            }
        }
        return false;
    }

    protected boolean createNewTask() {
        return false;
    }

    protected boolean defaultNewTask() {
        Creature target;
        this.clearTasks();
        NpcInstance actor = this.getActor();
        if (actor == null || (target = this.prepareTarget()) == null) {
            if (this.getIntention() != CtrlIntention.AI_INTENTION_ACTIVE) {
                this.changeIntention(CtrlIntention.AI_INTENTION_ACTIVE, null, null);
                return this.maybeMoveToHome(true);
            }
            return false;
        }
        return this.chooseTaskAndTargets(null, target, actor.getDistance(target));
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    protected void onEvtThink() {
        NpcInstance actor = this.getActor();
        if (actor == null) {
            return;
        }
        if (Config.BATTLE_ZONE_AROUND_RAID_BOSSES_RANGE > 0 && actor.isRaid() && System.currentTimeMillis() > this._lastRaidPvpZoneCheck + 1000L) {
            this._lastRaidPvpZoneCheck = System.currentTimeMillis();
            for (Player player : World.getAroundPlayers(actor, Config.BATTLE_ZONE_AROUND_RAID_BOSSES_RANGE, 200)) {
                player.startPvPFlag(null);
                player.setLastPvPAttack(System.currentTimeMillis() - (long)Config.PVP_TIME + 21000L);
            }
        }
        if (actor.isActionsDisabled() || actor.isAfraid()) {
            return;
        }
        if (this._randomAnimationEnd > System.currentTimeMillis()) {
            return;
        }
        if (!this._thinking.tryLock()) {
            return;
        }
        try {
            this.lookNeighbor(actor.getAggroRange(), false);
            if (!(Config.BLOCK_ACTIVE_TASKS || this.getIntention() != CtrlIntention.AI_INTENTION_ACTIVE && this.getIntention() != CtrlIntention.AI_INTENTION_WALKER_ROUTE)) {
                this.thinkActive();
            } else if (this.getIntention() == CtrlIntention.AI_INTENTION_ATTACK) {
                this.thinkAttack();
            } else if (this.getIntention() == CtrlIntention.AI_INTENTION_FOLLOW) {
                this.thinkFollow();
            } else if (this.getIntention() == CtrlIntention.AI_INTENTION_RETURN_HOME) {
                this.thinkReturnHome();
            }
        }
        finally {
            this._thinking.unlock();
        }
    }

    @Override
    protected void onEvtDead(Creature killer) {
        NpcInstance actor = this.getActor();
        int transformer = actor.getParameter("transformOnDead", 0);
        int chance = actor.getParameter("transformChance", 100);
        if (transformer > 0 && Rnd.chance((int)chance)) {
            NpcInstance npc = NpcUtils.spawnSingle(transformer, (SpawnRange)actor.getLoc(), actor.getReflection());
            if (killer != null && killer.isPlayable()) {
                npc.getAI().notifyEvent(CtrlEvent.EVT_AGGRESSION, killer, 100);
                killer.setTarget(npc);
            }
        }
        super.onEvtDead(killer);
        this.notifyFriendsOnDie(killer);
    }

    @Override
    protected void onEvtClanAttacked(NpcInstance member, Creature attacker, int damage) {
        if (damage > 0) {
            if (Math.abs(attacker.getZ() - this.getActor().getZ()) > 400) {
                return;
            }
            this.notifyEvent(CtrlEvent.EVT_AGGRESSION, attacker, (int)Math.max(1.0, (double)damage * 0.25 + 0.5));
        }
    }

    @Override
    protected void onEvtClanDied(NpcInstance member, Creature killer) {
    }

    @Override
    protected void onEvtPartyAttacked(NpcInstance minion, Creature attacker, int damage) {
        this.onEvtClanAttacked(minion, attacker, damage);
    }

    @Override
    protected void onEvtPartyDied(NpcInstance minion, Creature killer) {
        this.onEvtClanDied(minion, killer);
    }

    @Override
    protected void onEvtAttacked(Creature attacker, Skill skill, int damage) {
        List<QuestState> quests;
        if (this.getIntention() == CtrlIntention.AI_INTENTION_RETURN_HOME) {
            return;
        }
        NpcInstance actor = this.getActor();
        if (attacker == null || actor.isDead()) {
            return;
        }
        if (attacker.isConfused()) {
            return;
        }
        Player player = attacker.getPlayer();
        if (player != null && (quests = player.getQuestsForEvent(actor, QuestEventType.ATTACKED_WITH_QUEST)) != null) {
            for (QuestState qs : quests) {
                qs.getQuest().notifyAttack(actor, qs);
            }
        }
        if (damage <= 0) {
            return;
        }
        if (attacker.isInvisible(actor)) {
            return;
        }
        if (!this.canAttackCharacter(attacker)) {
            return;
        }
        Creature myTarget = attacker;
        if (attacker.isServitor()) {
            Player summoner = attacker.getPlayer();
            if (summoner != null) {
                if (this._isSearchingMaster) {
                    myTarget = summoner;
                } else {
                    actor.getAggroList().addDamageHate(summoner, 0, 1);
                }
            }
        } else if (attacker.isSymbolInstance()) {
            myTarget = attacker.getPlayer();
        }
        if (myTarget == null) {
            myTarget = attacker;
        }
        actor.getAggroList().addDamageHate(myTarget, 0, (int)myTarget.getStat().calc(Stats.DAMAGE_HATE_BONUS, damage));
        if (this.getIntention() != CtrlIntention.AI_INTENTION_ATTACK) {
            if (!actor.isRunning()) {
                this.startRunningTask(this._attackAITaskDelay);
            }
            this.setIntention(CtrlIntention.AI_INTENTION_ATTACK, myTarget);
        }
        if (actor.isRaid()) {
            ((RaidBossInstance)actor).startRaidBerserkTask();
        }
        if (actor.isArenaRaid() && actor.hasMinions()) {
            actor.getMinionList().spawnMinions();
        }
        this.notifyFriendsOnAttack(attacker, skill, damage);
    }

    @Override
    protected void onEvtAggression(Creature attacker, int aggro) {
        if (this.getIntention() == CtrlIntention.AI_INTENTION_RETURN_HOME) {
            return;
        }
        NpcInstance actor = this.getActor();
        if (attacker == null || actor.isDead()) {
            return;
        }
        if (attacker.isConfused()) {
            return;
        }
        Creature myTarget = attacker;
        if (aggro > 0) {
            if (attacker.isServitor()) {
                Player summoner = attacker.getPlayer();
                if (summoner != null) {
                    if (this._isSearchingMaster) {
                        myTarget = summoner;
                    } else {
                        actor.getAggroList().addDamageHate(summoner, 0, 1);
                    }
                }
            } else if (attacker.isSymbolInstance()) {
                myTarget = attacker.getPlayer();
            }
        }
        if (myTarget == null) {
            myTarget = attacker;
        }
        actor.getAggroList().addDamageHate(myTarget, 0, aggro);
        if (this.getIntention() != CtrlIntention.AI_INTENTION_ATTACK) {
            this.startRunningTask(this._attackAITaskDelay);
            this.setIntention(CtrlIntention.AI_INTENTION_ATTACK, myTarget);
        }
    }

    protected boolean maybeMoveToHome(boolean force) {
        NpcInstance actor = this.getActor();
        if (actor.isDead() || actor.isMovementDisabled()) {
            return false;
        }
        Location sloc = actor.getSpawnedLoc();
        boolean isInRange = actor.isInRangeZ(sloc, Config.MAX_DRIFT_RANGE);
        if (!force) {
            boolean randomWalk = this.hasRandomWalk();
            if (!(!randomWalk || Config.RND_WALK && Rnd.chance((int)Config.RND_WALK_RATE))) {
                return false;
            }
            if (!randomWalk && isInRange) {
                return false;
            }
        }
        Location pos = Location.findPointToStay(actor, sloc, 0, Config.MAX_DRIFT_RANGE);
        actor.setWalking();
        if (!(actor.getMovement().moveToLocation(pos, 0, true) || isInRange || actor instanceof DecoyInstance)) {
            actor.broadcastPacketToOthers(new MagicSkillUse(actor, actor, 2036, 1, 500, 0L));
            ThreadPoolManager.getInstance().schedule(new Teleport(sloc), 500L);
        }
        return true;
    }

    @Override
    public boolean returnHomeAndRestore(boolean running) {
        NpcInstance actor = this.getActor();
        if (this.returnHome(running, actor.isRaid() ? Config.ALWAYS_TELEPORT_HOME_RB : Config.ALWAYS_TELEPORT_HOME, running, true)) {
            if (this.canRestoreOnReturnHome()) {
                actor.setCurrentHpMp(actor.getMaxHp(), actor.getMaxMp());
            }
            return true;
        }
        return false;
    }

    protected boolean returnHome(boolean running) {
        return this.returnHome(true, false, running, false);
    }

    protected boolean teleportHome() {
        return this.returnHome(true, true, false, false);
    }

    protected boolean returnHome(boolean clearAggro, boolean teleport, boolean running, boolean force) {
        NpcInstance leader;
        NpcInstance actor = this.getActor();
        if (actor.isDead()) {
            return false;
        }
        if (actor.isMovementDisabled()) {
            this.changeIntention(CtrlIntention.AI_INTENTION_ACTIVE, null, null);
            return false;
        }
        if (actor.isMinion() && (leader = actor.getLeader()) != null && !leader.isVisible()) {
            actor.deleteMe();
            return false;
        }
        Location sloc = actor.getSpawnedLoc();
        if (actor.isInRangeZ(sloc, 32)) {
            this.changeIntention(CtrlIntention.AI_INTENTION_ACTIVE, null, null);
            return false;
        }
        if (!teleport && this.getIntention() == CtrlIntention.AI_INTENTION_RETURN_HOME) {
            return false;
        }
        this.clearTasks();
        actor.getMovement().stopMove();
        if (clearAggro) {
            actor.getAggroList().clear(true);
        }
        this.setAttackTarget(null);
        if (teleport) {
            this.changeIntention(CtrlIntention.AI_INTENTION_ACTIVE, null, null);
            actor.broadcastPacketToOthers(new MagicSkillUse(actor, actor, 2036, 1, 500, 0L));
            ThreadPoolManager.getInstance().schedule(new Teleport(sloc), 500L);
        } else if (force) {
            this.setIntention(CtrlIntention.AI_INTENTION_RETURN_HOME, running);
        } else {
            this.changeIntention(CtrlIntention.AI_INTENTION_ACTIVE, null, null);
            if (running) {
                actor.setRunning();
            } else {
                actor.setWalking();
            }
            this.addTaskMove(sloc, true, false);
        }
        return true;
    }

    @Override
    protected void onIntentionReturnHome(boolean running) {
        NpcInstance actor = this.getActor();
        if (running) {
            actor.setRunning();
        } else {
            actor.setWalking();
        }
        this.changeIntention(CtrlIntention.AI_INTENTION_RETURN_HOME, null, null);
        this.onEvtThink();
    }

    private void thinkReturnHome() {
        this.clearTasks();
        NpcInstance actor = this.getActor();
        Location spawnLoc = actor.getSpawnedLoc();
        if (actor.isInRange(spawnLoc, Math.min(this.getMaxPursueRange(), 100))) {
            this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
        } else {
            this.addTaskMove(spawnLoc, true, true);
            this.doTask();
        }
    }

    protected boolean canRestoreOnReturnHome() {
        return this._canRestoreOnReturnHome;
    }

    protected Creature prepareTarget() {
        Creature randomHated;
        NpcInstance actor = this.getActor();
        if (actor.isConfused()) {
            return this.getAttackTarget();
        }
        Creature agressionTarget = actor.getAggressionTarget();
        if (agressionTarget != null) {
            return agressionTarget;
        }
        if (Rnd.chance((int)actor.getParameter("isMadness", 0)) && (randomHated = actor.getAggroList().getRandomHated(this.getMaxHateRange())) != null && Math.abs(actor.getZ() - randomHated.getZ()) < 1000) {
            this.setAttackTarget(randomHated);
            if (this._madnessTask == null) {
                actor.getFlags().getConfused().start();
                this._madnessTask = ThreadPoolManager.getInstance().schedule(new MadnessTask(), 10000L);
            }
            return randomHated;
        }
        List<Creature> hateList = actor.getAggroList().getHateList(-1);
        Creature hated = null;
        for (Creature cha : hateList) {
            if (!this.checkTarget(cha, this.getMaxHateRange())) {
                actor.getAggroList().remove(cha, true);
                continue;
            }
            hated = cha;
            break;
        }
        if (hated != null) {
            this.setAttackTarget(hated);
            return hated;
        }
        return null;
    }

    protected boolean canUseSkill(Skill skill, Creature target, double distance) {
        NpcInstance actor = this.getActor();
        if (skill == null || skill.isNotUsedByAI()) {
            return false;
        }
        if (skill.getTargetType() == Skill.SkillTargetType.TARGET_SELF && target != actor) {
            return false;
        }
        int castRange = skill.getAOECastRange();
        if (castRange <= 200 && distance > 200.0) {
            return false;
        }
        if (actor.isSkillDisabled(skill) || actor.isMuted(skill) || actor.isUnActiveSkill(skill.getId())) {
            return false;
        }
        double mpConsume2 = skill.getMpConsume2();
        mpConsume2 = skill.isMagic() ? actor.getStat().calc(Stats.MP_MAGIC_SKILL_CONSUME, mpConsume2, target, skill) : actor.getStat().calc(Stats.MP_PHYSICAL_SKILL_CONSUME, mpConsume2, target, skill);
        if (actor.getCurrentMp() < mpConsume2) {
            return false;
        }
        return !target.getAbnormalList().contains(skill.getId());
    }

    protected boolean canUseSkill(Skill sk, Creature target) {
        return this.canUseSkill(sk, target, 0.0);
    }

    protected Skill[] selectUsableSkills(Creature target, double distance, Skill[] skills) {
        if (skills == null || skills.length == 0 || target == null) {
            return null;
        }
        Skill[] ret = null;
        int usable = 0;
        for (Skill skill : skills) {
            if (!this.canUseSkill(skill, target, distance)) continue;
            if (ret == null) {
                ret = new Skill[skills.length];
            }
            ret[usable++] = skill;
        }
        if (ret == null || usable == skills.length) {
            return ret;
        }
        if (usable == 0) {
            return null;
        }
        ret = (Skill[])Arrays.copyOf(ret, usable);
        return ret;
    }

    protected static SkillEntry selectTopSkillByDamage(Creature actor, Creature target, double distance, Skill[] skills) {
        if (skills == null || skills.length == 0) {
            return null;
        }
        if (skills.length == 1) {
            return SkillEntry.makeSkillEntry(SkillEntryType.NONE, skills[0]);
        }
        Skill oneTargetSkill = null;
        for (Skill skill : skills) {
            if (!skill.oneTarget() || oneTargetSkill != null && (!((double)skill.getCastRange() >= distance) || !(distance / (double)oneTargetSkill.getCastRange() < distance / (double)skill.getCastRange()))) continue;
            oneTargetSkill = skill;
        }
        if (oneTargetSkill != null && oneTargetSkill.getCastRange() > 300 && distance < 200.0) {
            oneTargetSkill = null;
        }
        RndSelector rnd = new RndSelector(skills.length);
        for (Skill skill : skills) {
            if (skill.oneTarget()) continue;
            double weight = skill.getSimpleDamage(actor, target) / 10.0 + distance / (double)skill.getCastRange() * 100.0;
            if (weight < 1.0) {
                weight = 1.0;
            }
            rnd.add(skill, (int)weight);
        }
        Skill skill = (Skill)rnd.select();
        if (skill == null) {
            return SkillEntry.makeSkillEntry(SkillEntryType.NONE, oneTargetSkill);
        }
        if (oneTargetSkill == null) {
            return SkillEntry.makeSkillEntry(SkillEntryType.NONE, skill);
        }
        if (Rnd.chance((int)90)) {
            return SkillEntry.makeSkillEntry(SkillEntryType.NONE, oneTargetSkill);
        }
        return SkillEntry.makeSkillEntry(SkillEntryType.NONE, skill);
    }

    protected static SkillEntry selectTopSkillByDebuff(Creature actor, Creature target, double distance, Skill[] skills) {
        if (skills == null || skills.length == 0) {
            return null;
        }
        if (skills.length == 1) {
            return SkillEntry.makeSkillEntry(SkillEntryType.NONE, skills[0]);
        }
        RndSelector rnd = new RndSelector(skills.length);
        for (Skill skill : skills) {
            if (skill.getSameByAbnormalType(target) != null) continue;
            double weight = 100.0 * (double)skill.getAOECastRange() / distance;
            if (weight <= 0.0) {
                weight = 1.0;
            }
            rnd.add(skill, (int)weight);
        }
        return SkillEntry.makeSkillEntry(SkillEntryType.NONE, (Skill)rnd.select());
    }

    protected static SkillEntry selectTopSkillByBuff(Creature target, Skill[] skills) {
        if (skills == null || skills.length == 0) {
            return null;
        }
        if (skills.length == 1) {
            return SkillEntry.makeSkillEntry(SkillEntryType.NONE, skills[0]);
        }
        RndSelector rnd = new RndSelector(skills.length);
        for (Skill skill : skills) {
            if (skill.getSameByAbnormalType(target) != null) continue;
            double weight = skill.getPower();
            if (weight <= 0.0) {
                weight = 1.0;
            }
            rnd.add(skill, (int)weight);
        }
        return SkillEntry.makeSkillEntry(SkillEntryType.NONE, (Skill)rnd.select());
    }

    protected static SkillEntry selectTopSkillByHeal(Creature target, Skill[] skills) {
        if (skills == null || skills.length == 0) {
            return null;
        }
        double hpReduced = (double)target.getMaxHp() - target.getCurrentHp();
        if (hpReduced < 1.0) {
            return null;
        }
        if (skills.length == 1) {
            return SkillEntry.makeSkillEntry(SkillEntryType.NONE, skills[0]);
        }
        RndSelector rnd = new RndSelector(skills.length);
        for (Skill skill : skills) {
            double weight = Math.abs(skill.getPower() - hpReduced);
            if (weight <= 0.0) {
                weight = 1.0;
            }
            rnd.add(skill, (int)weight);
        }
        return SkillEntry.makeSkillEntry(SkillEntryType.NONE, (Skill)rnd.select());
    }

    protected void addDesiredSkill(Map<SkillEntry, Integer> skillMap, Creature target, double distance, SkillEntry[] skills) {
        if (skills == null || skills.length == 0 || target == null) {
            return;
        }
        for (SkillEntry sk : skills) {
            this.addDesiredSkill(skillMap, target, distance, sk);
        }
    }

    protected void addDesiredSkill(Map<SkillEntry, Integer> skillMap, Creature target, double distance, SkillEntry skillEntry) {
        if (skillEntry == null || target == null) {
            return;
        }
        Skill skill = skillEntry.getTemplate();
        if (!this.canUseSkill(skill, target)) {
            return;
        }
        int weight = (int)(-Math.abs((double)skill.getAOECastRange() - distance));
        if ((double)skill.getAOECastRange() >= distance) {
            weight += 1000000;
        } else if (skill.isNotTargetAoE() && skill.getTargets(skillEntry, this.getActor(), target, false).size() == 0) {
            return;
        }
        skillMap.put(skillEntry, weight);
    }

    protected void addDesiredHeal(Map<SkillEntry, Integer> skillMap, SkillEntry[] skills) {
        if (skills == null || skills.length == 0) {
            return;
        }
        NpcInstance actor = this.getActor();
        double hpReduced = (double)actor.getMaxHp() - actor.getCurrentHp();
        double hpPercent = actor.getCurrentHpPercents();
        if (hpReduced < 1.0) {
            return;
        }
        for (SkillEntry sk : skills) {
            Skill skill = sk.getTemplate();
            if (!this.canUseSkill(skill, actor) || !(skill.getPower() <= hpReduced)) continue;
            int weight = (int)skill.getPower();
            if (hpPercent < 50.0) {
                weight += 1000000;
            }
            skillMap.put(sk, weight);
        }
    }

    protected void addDesiredBuff(Map<SkillEntry, Integer> skillMap, SkillEntry[] skills) {
        if (skills == null || skills.length == 0) {
            return;
        }
        NpcInstance actor = this.getActor();
        for (SkillEntry sk : skills) {
            if (!this.canUseSkill(sk.getTemplate(), actor)) continue;
            skillMap.put(sk, 1000000);
        }
    }

    protected SkillEntry selectTopSkill(Map<SkillEntry, Integer> skillMap) {
        int nWeight;
        if (skillMap == null || skillMap.isEmpty()) {
            return null;
        }
        int topWeight = Integer.MIN_VALUE;
        for (SkillEntry next : skillMap.keySet()) {
            nWeight = skillMap.get(next);
            if (nWeight <= topWeight) continue;
            topWeight = nWeight;
        }
        if (topWeight == Integer.MIN_VALUE) {
            return null;
        }
        SkillEntry[] skills = new SkillEntry[skillMap.size()];
        nWeight = 0;
        for (Map.Entry<SkillEntry, Integer> e : skillMap.entrySet()) {
            if (e.getValue() < topWeight) continue;
            skills[nWeight++] = e.getKey();
        }
        return skills[Rnd.get((int)nWeight)];
    }

    protected boolean chooseTaskAndTargets(SkillEntry skillEntry, Creature target, double distance) {
        NpcInstance actor = this.getActor();
        if (skillEntry != null) {
            Skill skill = skillEntry.getTemplate();
            if (actor.isMovementDisabled() && distance > (double)(skill.getAOECastRange() + 60)) {
                target = null;
                if (skill.isDebuff()) {
                    LazyArrayList targets = LazyArrayList.newInstance();
                    for (Creature cha : actor.getAggroList().getHateList(this.getMaxHateRange())) {
                        if (!this.checkTarget(cha, skill.getAOECastRange() + 60) || !this.canUseSkill(skill, cha)) continue;
                        targets.add(cha);
                    }
                    if (!targets.isEmpty()) {
                        target = (Creature)targets.get(Rnd.get((int)targets.size()));
                    }
                    LazyArrayList.recycle((LazyArrayList)targets);
                }
            }
            if (target == null) {
                return false;
            }
            if (skill.isDebuff()) {
                this.addTaskCast(target, skillEntry);
            } else {
                this.addTaskBuff(target, skillEntry);
            }
            return true;
        }
        if (actor.isMovementDisabled() && distance > (double)(actor.getPhysicalAttackRange() + 32)) {
            target = null;
            LazyArrayList targets = LazyArrayList.newInstance();
            for (Creature cha : actor.getAggroList().getHateList(this.getMaxHateRange())) {
                if (!this.checkTarget(cha, actor.getPhysicalAttackRange() + 32)) continue;
                targets.add(cha);
            }
            if (!targets.isEmpty()) {
                target = (Creature)targets.get(Rnd.get((int)targets.size()));
            }
            LazyArrayList.recycle((LazyArrayList)targets);
        }
        if (target == null) {
            return false;
        }
        this.addTaskAttack(target);
        return true;
    }

    protected void clearTasks() {
        this._def_think = false;
        this._tasks.clear();
    }

    protected void startRunningTask(long interval) {
        NpcInstance actor = this.getActor();
        if (this._runningTask == null && !actor.isRunning()) {
            this._runningTask = ThreadPoolManager.getInstance().schedule(new RunningTask(), interval);
        }
    }

    protected boolean isGlobalAggro() {
        if (this._globalAggro == 0L) {
            return true;
        }
        if (this._globalAggro <= System.currentTimeMillis()) {
            this._globalAggro = 0L;
            return true;
        }
        return false;
    }

    public void setGlobalAggro(long value) {
        this._globalAggro = value;
    }

    protected boolean defaultThinkBuff(int rateSelf) {
        return this.defaultThinkBuff(rateSelf, 0);
    }

    protected void notifyFriendsOnAttack(Creature attacker, Skill skill, int damage) {
        NpcInstance master;
        if (damage <= 0) {
            return;
        }
        NpcInstance actor = this.getActor();
        if (System.currentTimeMillis() - this._lastFactionNotifyTime > this._minFactionNotifyInterval) {
            this._lastFactionNotifyTime = System.currentTimeMillis();
            for (NpcInstance npcInstance : this.activeFactionTargets()) {
                npcInstance.getAI().notifyEvent(CtrlEvent.EVT_CLAN_ATTACKED, actor, attacker, damage);
            }
        }
        if (actor.isMinion() && (master = actor.getLeader()) != null) {
            if (!master.isDead() && master.isVisible()) {
                master.getAI().notifyEvent(CtrlEvent.EVT_PARTY_ATTACKED, actor, attacker, damage);
            }
            if (master.hasMinions()) {
                for (NpcInstance minion : master.getMinionList().getAliveMinions()) {
                    if (minion == actor) continue;
                    minion.getAI().notifyEvent(CtrlEvent.EVT_PARTY_ATTACKED, actor, attacker, damage);
                }
            }
        }
        if (actor.hasMinions()) {
            for (NpcInstance npcInstance : actor.getMinionList().getAliveMinions()) {
                npcInstance.getAI().notifyEvent(CtrlEvent.EVT_PARTY_ATTACKED, actor, attacker, damage);
            }
        }
    }

    protected void notifyFriendsOnDie(Creature killer) {
        NpcInstance master;
        NpcInstance actor = this.getActor();
        for (NpcInstance npcInstance : this.activeFactionTargets()) {
            npcInstance.getAI().notifyEvent(CtrlEvent.EVT_CLAN_DIED, actor, killer);
        }
        if (actor.isMinion() && (master = actor.getLeader()) != null) {
            if (!master.isDead() && master.isVisible()) {
                master.getAI().notifyEvent(CtrlEvent.EVT_PARTY_DIED, actor, killer);
            }
            if (master.hasMinions()) {
                for (NpcInstance minion : master.getMinionList().getAliveMinions()) {
                    if (minion == actor) continue;
                    minion.getAI().notifyEvent(CtrlEvent.EVT_PARTY_DIED, actor, killer);
                }
            }
        }
        if (actor.hasMinions()) {
            for (NpcInstance npcInstance : actor.getMinionList().getAliveMinions()) {
                npcInstance.getAI().notifyEvent(CtrlEvent.EVT_PARTY_DIED, actor, killer);
            }
        }
    }

    protected List<NpcInstance> activeFactionTargets() {
        NpcInstance actor = this.getActor();
        if (actor.getFaction().isNone()) {
            return Collections.emptyList();
        }
        int range = actor.getFaction().getRange();
        LazyArrayList npcFriends = new LazyArrayList();
        for (NpcInstance npc : World.getAroundNpc(actor)) {
            if (npc.isDead() || !npc.isInRangeZ(actor, range) || !npc.isInFaction(actor)) continue;
            npcFriends.add(npc);
        }
        return npcFriends;
    }

    protected boolean defaultThinkBuff(int rateSelf, int rateFriends) {
        NpcInstance actor = this.getActor();
        if (actor.isDead()) {
            return true;
        }
        if (Rnd.chance((int)rateSelf)) {
            Skill[] skills;
            double actorHp = actor.getCurrentHpPercents();
            Skill[] skillArray = skills = actorHp < 50.0 ? this.selectUsableSkills(actor, 0.0, this._healSkills) : this.selectUsableSkills(actor, 0.0, this._buffSkills);
            if (skills == null || skills.length == 0) {
                return false;
            }
            Skill skill = skills[Rnd.get((int)skills.length)];
            this.addTaskBuff(actor, SkillEntry.makeSkillEntry(SkillEntryType.NONE, skill));
            return true;
        }
        if (Rnd.chance((int)rateFriends)) {
            for (NpcInstance npc : this.activeFactionTargets()) {
                double targetHp = npc.getCurrentHpPercents();
                Skill[] skills = targetHp < 50.0 ? this.selectUsableSkills(actor, 0.0, this._healSkills) : this.selectUsableSkills(actor, 0.0, this._buffSkills);
                if (skills == null || skills.length == 0) continue;
                Skill skill = skills[Rnd.get((int)skills.length)];
                this.addTaskBuff(actor, SkillEntry.makeSkillEntry(SkillEntryType.NONE, skill));
                return true;
            }
        }
        return false;
    }

    protected boolean defaultFightTask() {
        Skill[] stun;
        Skill[] dot;
        this.clearTasks();
        NpcInstance actor = this.getActor();
        if (actor.isDead() || actor.isAMuted()) {
            return false;
        }
        Creature target = this.prepareTarget();
        if (target == null) {
            if (this.getIntention() != CtrlIntention.AI_INTENTION_ACTIVE) {
                this.changeIntention(CtrlIntention.AI_INTENTION_ACTIVE, null, null);
                return this.maybeMoveToHome(true);
            }
            return false;
        }
        double distance = actor.getDistance(target);
        double targetHp = target.getCurrentHpPercents();
        double actorHp = actor.getCurrentHpPercents();
        Skill[] dam = Rnd.chance((int)this.getRateDAM()) ? this.selectUsableSkills(target, distance, this._damSkills) : null;
        Skill[] skillArray = dot = Rnd.chance((int)this.getRateDOT()) ? this.selectUsableSkills(target, distance, this._dotSkills) : null;
        Skill[] debuff = targetHp > 10.0 ? (Rnd.chance((int)this.getRateDEBUFF()) ? this.selectUsableSkills(target, distance, this._debuffSkills) : null) : null;
        Skill[] skillArray2 = stun = Rnd.chance((int)this.getRateSTUN()) ? this.selectUsableSkills(target, distance, this._stunSkills) : null;
        Skill[] heal = actorHp < 50.0 ? (Rnd.chance((int)this.getRateHEAL()) ? this.selectUsableSkills(actor, 0.0, this._healSkills) : null) : null;
        Skill[] buff = Rnd.chance((int)this.getRateBUFF()) ? this.selectUsableSkills(actor, 0.0, this._buffSkills) : null;
        RndSelector rnd = new RndSelector();
        if (!actor.isAMuted()) {
            rnd.add(null, this.getRatePHYS());
        }
        rnd.add(dam, this.getRateDAM());
        rnd.add(dot, this.getRateDOT());
        rnd.add(debuff, this.getRateDEBUFF());
        rnd.add(heal, this.getRateHEAL());
        rnd.add(buff, this.getRateBUFF());
        rnd.add(stun, this.getRateSTUN());
        Skill[] selected = (Skill[])rnd.select();
        if (selected != null) {
            if (selected == dam || selected == dot) {
                return this.chooseTaskAndTargets(DefaultAI.selectTopSkillByDamage(actor, target, distance, selected), target, distance);
            }
            if (selected == debuff || selected == stun) {
                return this.chooseTaskAndTargets(DefaultAI.selectTopSkillByDebuff(actor, target, distance, selected), target, distance);
            }
            if (selected == buff) {
                return this.chooseTaskAndTargets(DefaultAI.selectTopSkillByBuff(actor, selected), actor, distance);
            }
            if (selected == heal) {
                return this.chooseTaskAndTargets(DefaultAI.selectTopSkillByHeal(actor, selected), actor, distance);
            }
        }
        return this.chooseTaskAndTargets(null, target, distance);
    }

    public int getRatePHYS() {
        return 100;
    }

    public int getRateDOT() {
        return 0;
    }

    public int getRateDEBUFF() {
        return 0;
    }

    public int getRateDAM() {
        return 0;
    }

    public int getRateSTUN() {
        return 0;
    }

    public int getRateBUFF() {
        return 0;
    }

    public int getRateHEAL() {
        return 0;
    }

    public boolean getIsMobile() {
        return !this.getActor().getParameter("isImmobilized", false);
    }

    public int getMaxPathfindFails() {
        return 3;
    }

    protected void thinkFollow() {
        NpcInstance actor = this.getActor();
        Creature target = (Creature)this._intention_arg0;
        Integer offset = (Integer)this._intention_arg1;
        if (target == null || target.isAlikeDead() || actor.getDistance(target) > 4000 || offset == null || actor.getReflection() != target.getReflection()) {
            this.clientActionFailed();
            return;
        }
        if (actor.getMovement().isFollow() && actor.getMovement().getFollowTarget() == target) {
            this.clientActionFailed();
            return;
        }
        if (actor.isInRange(target, offset + 16) || actor.isMovementDisabled()) {
            this.clientActionFailed();
        }
        if (this._followTask != null) {
            this._followTask.cancel(false);
            this._followTask = null;
        }
        this._followTask = ThreadPoolManager.getInstance().schedule(new ThinkFollow(), 250L);
    }

    public int getMaxPursueRange() {
        return Math.max(this.getAggroRange(), this._maxPursueRange);
    }

    public void setMaxPursueRange(int value) {
        this._maxPursueRange = value;
    }

    @Override
    public int getMaxHateRange() {
        return Math.max(this.getAggroRange(), 2000);
    }

    @Override
    protected void onEvtMostHatedChanged() {
        this.clearTasks();
        if (this.getActor().isAttackingNow()) {
            this.getActor().abortAttack(true, false);
        }
        if (this.getActor().isCastingNow()) {
            this.getActor().abortCast(true, false);
        }
        this.onEvtThink();
    }

    protected class ThinkFollow
    implements Runnable {
        protected ThinkFollow() {
        }

        @Override
        public void run() {
            if (DefaultAI.this.getIntention() != CtrlIntention.AI_INTENTION_FOLLOW) {
                return;
            }
            Creature target = (Creature)DefaultAI.this._intention_arg0;
            int offset = DefaultAI.this._intention_arg1 != null && DefaultAI.this._intention_arg1 instanceof Integer ? (Integer)DefaultAI.this._intention_arg1 : 0;
            NpcInstance actor = DefaultAI.this.getActor();
            if (target == null || target.isAlikeDead() || actor.getDistance(target) > 4000 || actor.getReflection() != target.getReflection()) {
                DefaultAI.this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
                return;
            }
            if (!(actor.isInRange(target, offset + 16) || actor.getMovement().isFollow() && actor.getMovement().getFollowTarget() == target)) {
                Location loc = new Location(target.getX() + 30, target.getY() + 30, target.getZ());
                actor.getMovement().followToCharacter(loc, target, offset, false);
            }
            DefaultAI.this._followTask = ThreadPoolManager.getInstance().schedule(this, 250L);
        }
    }

    protected class MadnessTask
    implements Runnable {
        protected MadnessTask() {
        }

        @Override
        public void run() {
            DefaultAI.this.getActor().getFlags().getConfused().stop();
            DefaultAI.this._madnessTask = null;
        }
    }

    protected class RunningTask
    implements Runnable {
        protected RunningTask() {
        }

        @Override
        public void run() {
            DefaultAI.this.getActor().setRunning();
            DefaultAI.this._runningTask = null;
        }
    }

    protected class Teleport
    implements Runnable {
        Location _destination;

        public Teleport(Location destination) {
            this._destination = destination;
        }

        @Override
        public void run() {
            DefaultAI.this.clientStopMoving();
            DefaultAI.this._pathfindFails = 0;
            DefaultAI.this.getActor().teleToLocation(this._destination.x, this._destination.y, GeoEngine.getLowerHeight(this._destination, DefaultAI.this.getActor().getGeoIndex()));
        }
    }

    public static class NearestTargetComparator
    implements Comparator<Creature> {
        private final HardReference<? extends Creature> _creatureRef;

        public NearestTargetComparator(Creature creature) {
            this._creatureRef = creature.getRef();
        }

        @Override
        public int compare(Creature o1, Creature o2) {
            if (o1 == null || o2 == null) {
                return 0;
            }
            if (o1 == o2) {
                return 0;
            }
            if (o1.getObjectId() == o2.getObjectId()) {
                return 0;
            }
            Creature creature = (Creature)this._creatureRef.get();
            if (creature == null) {
                return 0;
            }
            return Integer.compare(creature.getDistance3D(o1), creature.getDistance3D(o2));
        }
    }

    private static class TaskComparator
    implements Comparator<Task> {
        private static final Comparator<Task> instance = new TaskComparator();

        private TaskComparator() {
        }

        public static final Comparator<Task> getInstance() {
            return instance;
        }

        @Override
        public int compare(Task o1, Task o2) {
            if (o1 == null || o2 == null) {
                return 0;
            }
            if (o1.weight == o2.weight) {
                return Long.compare(o2.addTime, o1.addTime);
            }
            return Long.compare(o2.weight, o1.weight);
        }
    }

    public static class Task {
        public TaskType type;
        public SkillEntry skillEntry;
        public HardReference<? extends Creature> target;
        public Location loc;
        public boolean pathfind;
        public boolean teleportIfCantMove;
        public long weight = 10000L;
        public int p1;
        public int p2;
        public final long addTime = System.currentTimeMillis();
    }

    public static enum TaskType {
        MOVE,
        ATTACK,
        CAST,
        BUFF;

    }
}


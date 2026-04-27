/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.util.Rnd
 *  org.napile.primitive.lists.IntList
 *  org.napile.primitive.sets.IntSet
 */
package l2s.gameserver.ai;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.atomic.AtomicBoolean;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.ai.PlayerAI;
import l2s.gameserver.dao.CharacterDAO;
import l2s.gameserver.data.xml.holder.FakePlayersHolder;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.geometry.ILocation;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.listener.actor.OnDeathListener;
import l2s.gameserver.listener.actor.player.OnLevelChangeListener;
import l2s.gameserver.listener.actor.player.OnPlayerChatMessageReceive;
import l2s.gameserver.listener.actor.player.OnTeleportListener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.World;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.model.actor.instances.creature.AbnormalList;
import l2s.gameserver.model.base.Race;
import l2s.gameserver.model.base.RestartType;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.components.ChatType;
import l2s.gameserver.skills.EffectUseType;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.templates.fakeplayer.FakePlayerAITemplate;
import l2s.gameserver.templates.fakeplayer.FarmZoneTemplate;
import l2s.gameserver.templates.fakeplayer.TownZoneTemplate;
import l2s.gameserver.templates.fakeplayer.actions.AbstractAction;
import l2s.gameserver.templates.fakeplayer.actions.GoToTownActions;
import l2s.gameserver.templates.fakeplayer.actions.OrdinaryActions;
import l2s.gameserver.templates.fakeplayer.actions.ReviveAction;
import l2s.gameserver.templates.fakeplayer.actions.StopFarmAction;
import l2s.gameserver.templates.fakeplayer.actions.TeleportToClosestTownAction;
import l2s.gameserver.templates.fakeplayer.actions.UseCommunityAction;
import l2s.gameserver.templates.fakeplayer.actions.WaitAction;
import l2s.gameserver.utils.FakePlayerUtils;
import l2s.gameserver.utils.ItemFunctions;
import l2s.gameserver.utils.PositionUtils;
import l2s.gameserver.utils.TeleportUtils;
import org.napile.primitive.lists.IntList;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.napile.primitive.sets.IntSet;

public class FakeAI
extends PlayerAI
implements OnDeathListener,
OnLevelChangeListener,
OnTeleportListener,
OnPlayerChatMessageReceive {
    private static final Logger _log = LoggerFactory.getLogger(FakeAI.class);
    private static final int MAX_ACTION_TRY_COUNT = 500;
    private static final int BUFF_DELAY = 600000;
    private static final int CHECK_INVENTORY_DELAY = 10000;
    private static final int SEARCH_PVP_PK_DELAY = 60000;
    private static final int ATTACK_WAIT_DELAY = 180000;
    private static final int SHOUT_CHAT_MIN_DELAY = 60000;
    private static final int SHOUT_CHAT_MAX_DELAY = 600000;
    private final FakePlayerAITemplate _aiTemplate;
    private final DistanceComparator _distanceComparator = new DistanceComparator();
    private ScheduledFuture<?> _actionTask;
    private final List<AbstractAction> _plannedActions = new ArrayList<AbstractAction>();
    private int _lastActionTryCount = 0;
    private FarmZoneTemplate _currentFarmZone = null;
    private long _waitEndTime = 0L;
    private long _goToTownTime = -1L;
    private long _lastBuffTime = 0L;
    private long _lastCheckInventoryTime = 0L;
    private long _lastSearchPvPPKTime = 0L;
    private long _lastAttackTime = 0L;
    private long _nextShoutChatTime = 0L;
    private IntList todoEquip = null;
    private final AtomicBoolean deleted = new AtomicBoolean();

    public FakeAI(Player player, FakePlayerAITemplate aiTemplate) {
        super(player);
        this._aiTemplate = aiTemplate;
    }

    @Override
    protected void onEvtSpawn() {
        super.onEvtSpawn();
        Player actor = this.getActor();
        actor.addListener(this);
        if (actor.entering && actor.getOnlineTime() == 0) {
            this.planActions(this._aiTemplate.getOnCreateAction());
        }
        actor.setActive();
        this.startActionTask();
        FakePlayerUtils.checkAutoShots(this);
    }

    @Override
    public void onEvtDeSpawn() {
        this.getActor().removeListener(this);
        this.stopActionTask();
        super.onEvtDeSpawn();
    }

    @Override
    public boolean isFake() {
        return true;
    }

    public void startWait(int minDelay, int maxDelay) {
        this._waitEndTime = System.currentTimeMillis() + (long)Rnd.get((int)minDelay, (int)maxDelay);
    }

    public void stopWait() {
        this._waitEndTime = 0L;
    }

    private boolean isWait() {
        return this._waitEndTime > System.currentTimeMillis() || this.getIntention() == CtrlIntention.AI_INTENTION_PICK_UP;
    }

    private boolean planActions(OrdinaryActions action) {
        this.clearPlannedActions();
        if (action == null) {
            return false;
        }
        List<AbstractAction> actions = this.makeActionsList(action.makeActionsList());
        if (actions.isEmpty()) {
            return false;
        }
        this._plannedActions.addAll(actions);
        return true;
    }

    private List<AbstractAction> makeActionsList(List<AbstractAction> actions) {
        if (actions.isEmpty()) {
            return Collections.emptyList();
        }
        ArrayList<AbstractAction> actionsList = new ArrayList<AbstractAction>();
        for (AbstractAction action : actions) {
            double chance = action.getChance();
            if (!(chance <= 0.0) && !(chance >= 100.0) && !Rnd.chance((double)chance)) continue;
            List<AbstractAction> tempList = action.makeActionsList();
            if (tempList == null) {
                actionsList.add(action);
                continue;
            }
            actionsList.addAll(this.makeActionsList(tempList));
        }
        return actionsList;
    }

    public void clearPlannedActions() {
        this._plannedActions.clear();
        this._lastActionTryCount = 0;
    }

    public boolean clearCurrentFarmZone() {
        boolean result = this._currentFarmZone != null;
        this.getActor().setTarget(null);
        this._currentFarmZone = null;
        this._goToTownTime = -1L;
        return result;
    }

    /*
     * Enabled aggressive block sorting
     */
    private synchronized boolean performNextAction(boolean force) {
        if (this.deleted.get()) {
            return false;
        }
        if (this._nextShoutChatTime < System.currentTimeMillis()) {
            FakePlayerUtils.writeToRandomChat(this);
            this._nextShoutChatTime = System.currentTimeMillis() + (long)Rnd.get((int)60000, (int)600000);
        }
        if (this.isWait()) {
            return false;
        }
        Player player = this.getActor();
        if (!player.isAlikeDead()) {
            Player targetPlayer;
            GameObject target;
            int itemId;
            IntList todoEquip = this.todoEquip;
            if (todoEquip != null && !todoEquip.isEmpty() && FakePlayerUtils.addEquip(this, itemId = todoEquip.removeByIndex(0))) {
                this.startWait(100, 1000);
                return true;
            }
            if (this._lastCheckInventoryTime + 10000L < System.currentTimeMillis()) {
                FakePlayerUtils.checkInventory(this);
                this._lastCheckInventoryTime = System.currentTimeMillis();
            }
            int dropCount = 0;
            Object dropItem = null;
            if (Rnd.chance((int)(player.isInPeaceZone() ? 3 : 97))) {
                for (GameObject object : World.getAroundObjects(player, 2000, 1000)) {
                    ItemInstance item;
                    if (!(object instanceof ItemInstance) || (item = (ItemInstance)object).getItemId() == 8190 || item.getItemId() == 8689 || player.getDistance(item) > 10000 || !GeoEngine.canMoveToCoord(player.getX(), player.getY(), player.getZ(), item.getX(), item.getY(), item.getZ(), player.getGeoIndex()) || !ItemFunctions.checkIfCanPickup(player, item)) continue;
                    if (dropItem == null || player.getDistance(item) < player.getDistance((ILocation)dropItem)) {
                        dropItem = item;
                    }
                    ++dropCount;
                }
            }
            if ((target = player.getTarget()) instanceof Creature && Rnd.chance((int)95)) {
                Creature creatureTarget = (Creature)target;
                if (!player.isInPeaceZone() || ((GameObject)creatureTarget).isMonster()) {
                    boolean attackable = creatureTarget.isAutoAttackable(player);
                    targetPlayer = ((GameObject)creatureTarget).getPlayer();
                    if (targetPlayer != null) {
                        attackable = targetPlayer.isCtrlAttackable(player, targetPlayer.isPK() || targetPlayer.getPvpFlag() > 0, false);
                    }
                    if (!attackable || creatureTarget.isAlikeDead() || !((GameObject)creatureTarget).isVisible() || creatureTarget.isInvisible(player) || player.getDistance((ILocation)creatureTarget) > 10000 || !GeoEngine.canMoveToCoord(player.getX(), player.getY(), player.getZ(), ((GameObject)creatureTarget).getX(), ((GameObject)creatureTarget).getY(), ((GameObject)creatureTarget).getZ(), player.getGeoIndex())) {
                        player.setTarget(null);
                        player.abortAttack(true, false);
                        player.abortCast(true, false);
                        this.startWait(100, dropCount == 0 ? 2000 : 700);
                        return true;
                    }
                    if (player.getAI().getAttackTarget() != creatureTarget && player.getAI().getCastTarget() != creatureTarget || this.getIntention() != CtrlIntention.AI_INTENTION_ATTACK || Rnd.chance((int)5)) {
                        this.attack(creatureTarget);
                        return true;
                    }
                }
            }
            if (this._plannedActions.isEmpty() && this.getIntention() == CtrlIntention.AI_INTENTION_ACTIVE || Rnd.chance((int)5)) {
                if (dropItem != null && !player.getMovement().isMoving() && !player.isMovementDisabled()) {
                    ((ItemInstance)dropItem).onAction(player, false);
                    this.startWait(500, dropCount == 1 ? 3000 : 1000);
                    return true;
                }
                if (!player.isInPeaceZone() && this._lastSearchPvPPKTime + 60000L < System.currentTimeMillis()) {
                    for (Creature pk : player.getAroundCharacters(1000, 250)) {
                        if (!pk.isPlayer() || (targetPlayer = pk.getPlayer()).isAlikeDead() || !targetPlayer.isVisible() || targetPlayer.isInvisible(player) || player.getDistance(targetPlayer) > 10000 || !GeoEngine.canMoveToCoord(player.getX(), player.getY(), player.getZ(), pk.getX(), pk.getY(), pk.getZ(), player.getGeoIndex())) continue;
                        double attackChance = 0.0;
                        boolean targeted = targetPlayer.getAI().getAttackTarget() == player && targetPlayer.getAI().getCastTarget() == player;
                        boolean attackable = targetPlayer.isCtrlAttackable(player, false, false);
                        if (attackable) {
                            attackChance = 20.0;
                            if (!targeted) {
                                attackChance /= 5.0;
                            }
                        } else {
                            attackable = targetPlayer.isCtrlAttackable(player, true, false);
                            if (attackable) {
                                attackChance = 5.0;
                                if (!targeted) {
                                    attackChance /= 5.0;
                                }
                            }
                        }
                        if (!Rnd.chance((double)attackChance)) continue;
                        player.setTarget(targetPlayer);
                        this.startWait(1000, 3000);
                        return true;
                    }
                    this._lastSearchPvPPKTime = System.currentTimeMillis();
                }
            }
            if (this._lastBuffTime + 600000L < System.currentTimeMillis()) {
                if (player.getClassId().isOfRace(Race.ORC) || !player.isMageClass()) {
                    this._plannedActions.add(new UseCommunityAction("_cbbsbuffer get 0 1_0 1", 100.0));
                } else {
                    this._plannedActions.add(new UseCommunityAction("_cbbsbuffer get 0 1_0 2", 100.0));
                }
                this._lastBuffTime = System.currentTimeMillis();
            }
        }
        if (!this._plannedActions.isEmpty()) {
            AbstractAction action = this._plannedActions.get(0);
            ++this._lastActionTryCount;
            if (this._lastActionTryCount <= 500) {
                if (!action.checkCondition(this, force)) {
                    return false;
                }
                if (!action.performAction(this)) {
                    return false;
                }
            } else {
                this._lastActionTryCount = 0;
            }
            this._plannedActions.remove(action);
            return true;
        }
        if (player.isDead()) {
            this.doRevive();
            return true;
        }
        if (this._currentFarmZone != null) {
            this.farm();
            return true;
        }
        Location closestTownLoc = TeleportUtils.getRestartPoint(player, RestartType.TO_VILLAGE).getLoc();
        TownZoneTemplate townZone = null;
        block2: for (TownZoneTemplate t : FakePlayersHolder.getInstance().getTownZones()) {
            for (Zone zone : t.getZones()) {
                if (!zone.checkIfInZone(closestTownLoc.x, closestTownLoc.y, closestTownLoc.z)) continue;
                townZone = t;
                break block2;
            }
        }
        if (townZone != null) {
            for (Zone zone : townZone.getZones()) {
                if (!zone.checkIfInZone(player)) continue;
                this.planActions(townZone.getActions());
                return true;
            }
        }
        FarmZoneTemplate farmZone = null;
        for (FarmZoneTemplate f : this._aiTemplate.getFarmZones()) {
            for (Zone zone : f.getZones()) {
                if (!zone.checkIfInZone(player) || farmZone != null && player.getLevel() - farmZone.getMaxLevel() <= player.getLevel() - f.getMaxLevel() || !(farmZone = f).checkCondition(player)) continue;
            }
        }
        if (farmZone != null) {
            if (farmZone.checkCondition(player)) {
                this._currentFarmZone = farmZone;
                return this.performFarm();
            }
            if (player.getLevel() >= farmZone.getMaxLevel()) {
                this.planActions(farmZone.getOnObtainMaxLevelAction());
                return true;
            }
            this._plannedActions.add(new TeleportToClosestTownAction(100.0));
            return true;
        }
        if (townZone == null) {
            return this.performFarm();
        }
        this._plannedActions.add(new TeleportToClosestTownAction(100.0));
        return true;
    }

    public boolean performFarm() {
        Player player = this.getActor();
        if (this._currentFarmZone == null) {
            FarmZoneTemplate farmZone;
            ArrayList<FarmZoneTemplate> availableFarmZones = new ArrayList<FarmZoneTemplate>();
            block0: for (FarmZoneTemplate f : this._aiTemplate.getFarmZones()) {
                if (!f.checkCondition(player)) continue;
                for (Zone zone : f.getZones()) {
                    if (!zone.checkIfInZone(player)) continue;
                    availableFarmZones.add(f);
                    break block0;
                }
            }
            if (availableFarmZones.isEmpty()) {
                for (FarmZoneTemplate f : this._aiTemplate.getFarmZones()) {
                    if (!f.checkCondition(player)) continue;
                    availableFarmZones.add(f);
                }
            }
            FarmZoneTemplate farmZoneTemplate = farmZone = availableFarmZones.isEmpty() ? null : (FarmZoneTemplate)Rnd.get(availableFarmZones);
            if (farmZone == null) {
                this.deleteFake(player);
                return false;
            }
            this._currentFarmZone = farmZone;
            this._lastAttackTime = System.currentTimeMillis();
        }
        this.clearPlannedActions();
        return true;
    }

    private void farm() {
        Location loc;
        NpcInstance npcInstance;
        if (this.isWait()) {
            return;
        }
        Player player = this.getActor();
        if (player.getMovement().isMoving() || player.isMovementDisabled()) {
            return;
        }
        if (!this._currentFarmZone.checkCondition(player)) {
            FarmZoneTemplate currentFarmZone = this._currentFarmZone;
            this.clearCurrentFarmZone();
            if (player.getLevel() >= currentFarmZone.getMaxLevel()) {
                this.planActions(currentFarmZone.getOnObtainMaxLevelAction());
            } else {
                this.clearPlannedActions();
            }
            return;
        }
        GoToTownActions goToTownActions = this._currentFarmZone.getGoToTownActions();
        if (goToTownActions != null) {
            if (this._goToTownTime == -1L) {
                this._goToTownTime = System.currentTimeMillis() + (long)Rnd.get((int)goToTownActions.getMinFarmTime(), (int)goToTownActions.getMaxFarmTime()) * 1000L;
            } else if (this._goToTownTime < System.currentTimeMillis()) {
                this._goToTownTime = Long.MAX_VALUE;
                this.planActions(goToTownActions);
                this._plannedActions.add(new StopFarmAction(100.0));
                return;
            }
        }
        ArrayList<NpcInstance> npcs = new ArrayList<NpcInstance>();
        for (Zone zone : this._currentFarmZone.getZones()) {
            npcs.addAll(this.getNpcsForAttack(zone.getInsideNpcs()));
        }
        Collections.sort(npcs, this._distanceComparator);
        for (NpcInstance npcInstance2 : npcs) {
            if (!this.prepareAttack(npcInstance2)) continue;
            return;
        }
        List<NpcInstance> arroundNpcs = this.getNpcsForAttack(player.getAroundNpc(2000, 1000));
        Collections.sort(arroundNpcs, this._distanceComparator);
        for (NpcInstance npc3 : arroundNpcs) {
            if (!this.prepareAttack(npc3)) continue;
            return;
        }
        NpcInstance npcInstance3 = npcInstance = npcs.isEmpty() ? null : (NpcInstance)npcs.get(0);
        if (this._lastAttackTime + 180000L < System.currentTimeMillis()) {
            this._lastAttackTime = System.currentTimeMillis();
            loc = npcInstance != null ? npcInstance.getLoc() : FakeAI.getRandomLoc(this._currentFarmZone.getZones(), player.getGeoIndex(), player.isFlying());
            player.teleToLocation(loc, 0, 0);
            return;
        }
        if (npcInstance != null || !FakeAI.isInside(this._currentFarmZone.getZones(), player.getX(), player.getY(), player.getZ())) {
            Location location = loc = npcInstance != null ? npcInstance.getLoc() : FakeAI.getRandomLoc(this._currentFarmZone.getZones(), player.getGeoIndex(), player.isFlying());
            if (player.getDistance(loc) > 10000 || !player.getMovement().moveToLocation(Location.findAroundPosition(loc, 0, player.getGeoIndex()), 0, true, 50)) {
                Location restartLoc = (Location)Rnd.get(this._currentFarmZone.getSpawnPoints());
                if (!FakeAI.isInside(this._currentFarmZone.getZones(), restartLoc.x, restartLoc.y, restartLoc.z) && PositionUtils.calculateDistance(restartLoc.x, restartLoc.y, loc.x, loc.y) > 10000) {
                    restartLoc = null;
                }
                if (restartLoc == null) {
                    restartLoc = loc;
                }
                if (player.isInRange(restartLoc, 50)) {
                    restartLoc = loc;
                }
                if (!player.isInRange(restartLoc, 50)) {
                    if (player.getDistance(restartLoc) > 10000 || !player.getMovement().moveToLocation(Location.findAroundPosition(restartLoc, 50, 150, player.getGeoIndex()), 0, true, 50)) {
                        player.teleToLocation(restartLoc, 0, 0);
                    }
                    return;
                }
            } else {
                return;
            }
        }
        loc = Location.coordsRandomize(player.getLoc(), 100, 300);
        if (FakeAI.isInside(this._currentFarmZone.getZones(), loc.x, loc.y, loc.z) && player.getMovement().moveToLocation(Location.findAroundPosition(loc, 0, player.getGeoIndex()), 0, true, 50)) {
            this.startWait(1000, 10000);
        }
    }

    private List<NpcInstance> getNpcsForAttack(List<NpcInstance> avaialbleNpcs) {
        Player player = this.getActor();
        ArrayList<NpcInstance> npcs = new ArrayList<NpcInstance>();
        for (NpcInstance n : avaialbleNpcs) {
            IntSet farmMonsters;
            if (n.isAlikeDead() || n.isInvulnerable() || !n.isVisible() || n.isInvisible(player) || this._currentFarmZone.isIgnoredMonster(n.getNpcId()) || (!(farmMonsters = this._currentFarmZone.getFarmMonsters()).isEmpty() ? !farmMonsters.contains(n.getNpcId()) : Math.abs(player.getLevel() - n.getLevel()) > 10)) continue;
            if (!n.isMonster() || n.isRaid() || (n.getAI().getAttackTarget() != null && n.getAI().getAttackTarget() != player || n.getAI().getCastTarget() != null && n.getAI().getCastTarget() != player) && Rnd.chance((int)95)) continue;
            npcs.add(n);
        }
        return npcs;
    }

    private boolean prepareAttack(Creature target) {
        Player player = this.getActor();
        if (player.getDistance(target) <= 10000 && GeoEngine.canMoveToCoord(player.getX(), player.getY(), player.getZ(), target.getX(), target.getY(), target.getZ(), player.getGeoIndex())) {
            if (Rnd.chance((int)80)) {
                int distanceToTarget = player.getDistance(target);
                for (Creature neighbor : target.getAroundCharacters(distanceToTarget + 5000, 250)) {
                    if (!neighbor.isFakePlayer() || neighbor.getTarget() != target && neighbor.getAI().getAttackTarget() != target && neighbor.getAI().getCastTarget() != target) continue;
                    return false;
                }
            }
            if (Rnd.chance((int)20)) {
                player.setCurrentHp(player.getMaxHp(), true, true);
                player.setCurrentMp(player.getMaxMp());
            }
            if (Rnd.chance((int)10)) {
                if (player.getClassId().isOfRace(Race.ORC) || !player.isMageClass()) {
                    player.getMovement().moveToLocation(Location.findAroundPosition(target, 80, 180), 0, true);
                } else {
                    player.getMovement().moveToLocation(Location.findAroundPosition(target, 160, 360), 0, true);
                }
                player.setTarget(target);
                this.startWait(500, 3000);
                return true;
            }
            this._lastAttackTime = System.currentTimeMillis();
            player.setTarget(target);
            this.startWait(1000, 3000);
            return true;
        }
        return false;
    }

    private void attack(Creature target) {
        Skill skill;
        Player player = this.getActor();
        if (Rnd.chance((int)80) && this.tryRunOff(target)) {
            return;
        }
        if (Rnd.chance((int)5) && (skill = this.getRandomSkillSelf()) != null) {
            this.Cast(SkillEntry.makeSkillEntry(SkillEntryType.NONE, skill), player);
            return;
        }
        if (!GeoEngine.canSeeTarget(player, target) && !player.getMovement().isMoving()) {
            if (!player.getMovement().moveToLocation(Location.findAroundPosition(target, 50, 150), 0, true, 50)) {
                player.setTarget(null);
            }
            return;
        }
        skill = this.getRandomSkill(player, target);
        if (skill == null && player.isMageClass() && !player.getClassId().isOfRace(Race.ORC) && Rnd.chance((int)90)) {
            return;
        }
        if (skill != null && Rnd.chance((int)30)) {
            this.Cast(SkillEntry.makeSkillEntry(SkillEntryType.NONE, skill), target, false, false);
            return;
        }
        if (player.getClassId().isOfRace(Race.ORC) || !player.isMageClass()) {
            this.Attack(target, true, false);
        }
    }

    private boolean tryRunOff(Creature target) {
        if (target.isAlikeDead()) {
            return false;
        }
        Player player = this.getActor();
        if ((player.getPhysicalAttackRange() > 100 || !player.getClassId().isOfRace(Race.ORC) && player.isMageClass()) && player.getDistance(target) <= 200 && !player.getMovement().isMoving()) {
            int posX = player.getX();
            int posY = player.getY();
            int posZ = player.getZ();
            int old_posX = posX;
            int old_posY = posY;
            int old_posZ = posZ;
            int signx = posX < target.getX() ? -1 : 1;
            int signy = posY < target.getY() ? -1 : 1;
            int range = Math.max((int)((double)player.getPhysicalAttackRange() * 0.9), 200);
            posZ = GeoEngine.getLowerHeight(posX += signx * range, posY += signy * range, posZ, player.getGeoIndex());
            if (GeoEngine.canMoveToCoord(old_posX, old_posY, old_posZ, posX, posY, posZ, player.getGeoIndex())) {
                player.abortAttack(true, false);
                if (player.getMovement().moveToLocation(Location.findAroundPosition(posX, posY, posZ, 0, 0, player.getGeoIndex()), 0, true)) {
                    return true;
                }
            }
        }
        return false;
    }

    private Skill getRandomSkillSelf() {
        ArrayList<Skill> skills = new ArrayList<Skill>();
        block3: for (SkillEntry skillEntry : this.getActor().getAllSkills()) {
            Skill skill = skillEntry.getTemplate();
            if (!skill.isActive() && !skill.isToggle() || skill.hasEffect(EffectUseType.NORMAL, "Transformation") || this.getActor().isSkillDisabled(skill) || skill.getSkillType() != Skill.SkillType.BUFF) continue;
            for (Abnormal e : this.getActor().getAbnormalList()) {
                if (!this.checkAbnormal(e, skill)) continue;
                continue block3;
            }
            switch (skill.getTargetType()) {
                case TARGET_ONE: 
                case TARGET_SELF: {
                    skills.add(skill);
                }
            }
        }
        return skills.isEmpty() ? null : (Skill)skills.get(Rnd.get((int)skills.size()));
    }

    private boolean checkAbnormal(Abnormal abnormal, Skill skill) {
        if (skill.getAbnormalTime() <= 0) {
            return true;
        }
        if (abnormal == null) {
            return false;
        }
        if (!skill.hasEffects(EffectUseType.NORMAL)) {
            return false;
        }
        if (abnormal.checkBlockedAbnormalType(skill.getAbnormalType())) {
            return true;
        }
        if (!AbnormalList.checkAbnormalType(abnormal.getSkill(), skill)) {
            return false;
        }
        if (abnormal.getAbnormalLvl() < skill.getAbnormalLvl()) {
            return false;
        }
        return abnormal.getTimeLeft() > 10;
    }

    private Skill getRandomSkill(Player player, Creature target) {
        ArrayList<Skill> weakSkills = new ArrayList<Skill>();
        ArrayList<Skill> skills = new ArrayList<Skill>();
        block12: for (SkillEntry skillEntry : player.getAllSkills()) {
            Skill skill = skillEntry.getTemplate();
            if (!skill.isActive()) continue;
            switch (skill.getId()) {
                case 11030: 
                case 30546: 
                case 30547: {
                    continue block12;
                }
            }
            if (player.isSkillDisabled(skill) || !skillEntry.checkCondition(player, target, false, false, true)) continue;
            double chance = 0.0;
            switch (skill.getSkillType()) {
                case DEBUFF: 
                case PARALYZE: 
                case ROOT: 
                case STEAL_BUFF: 
                case DOT: 
                case AIEFFECTS: 
                case CPDAM: 
                case DELETE_HATE: 
                case MDOT: 
                case DECOY: 
                case CHARGE: 
                case POISON: 
                case SLEEP: 
                case DESTROY_SUMMON: 
                case SHIFT_AGGRESSION: 
                case DISCORD: 
                case MANADAM: 
                case MUTE: {
                    chance = 5.0;
                    break;
                }
                case DRAIN: {
                    chance = (5.0 + (100.0 - this.getActor().getCurrentCpPercents()) / 5.0) / (player.isMageClass() ? 1.0 : 3.0);
                    break;
                }
                case MDAM: {
                    chance = !player.getClassId().isOfRace(Race.ORC) && player.isMageClass() ? 100.0 : 5.0;
                    break;
                }
                case PDAM: 
                case STUN: 
                case LETHAL_SHOT: {
                    chance = 15.0;
                }
            }
            switch (skill.getTargetType()) {
                case TARGET_AURA: 
                case TARGET_AREA: 
                case TARGET_FAN: 
                case TARGET_FAN_PB: 
                case TARGET_SQUARE: 
                case TARGET_SQUARE_PB: 
                case TARGET_RING_RANGE: {
                    chance /= 10.0;
                }
            }
            if (!Rnd.chance((double)chance)) continue;
            if (skill.getMagicLevel() < player.getLevel() - 10) {
                weakSkills.add(skill);
                continue;
            }
            skills.add(skill);
        }
        if (skills.isEmpty()) {
            skills = weakSkills;
        }
        return (Skill)Rnd.get(skills);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    protected void onEvtAttacked(Creature attacker, Skill skill, int damage) {
        FakeAI fakeAI = this;
        synchronized (fakeAI) {
            if (Rnd.chance((int)60) && this.tryRunOff(attacker)) {
                return;
            }
            if (damage > 0) {
                Player player = this.getActor();
                if (attacker.isNpc() && Rnd.chance((int)25)) {
                    player.setCurrentHp(player.getCurrentHp() + (double)(player.getMaxHp() / 5), true, true);
                    player.setCurrentMp(player.getCurrentMp() + (double)(player.getMaxMp() / 5));
                }
                double chance = 25.0;
                GameObject target = player.getTarget();
                if (target != null) {
                    if (target == attacker) {
                        return;
                    }
                    if (target instanceof Creature) {
                        Creature creatureTarget = (Creature)target;
                        chance = creatureTarget.getAI().getAttackTarget() != player && creatureTarget.getAI().getCastTarget() != player ? 80.0 : 5.0;
                    } else {
                        return;
                    }
                }
                if (attacker.isPlayable()) {
                    chance = 30.0;
                }
                if (attacker.getLevel() - player.getLevel() >= 10) {
                    chance /= 5.0;
                }
                if (Rnd.chance((double)chance)) {
                    player.setTarget(attacker);
                    this.stopWait();
                }
            }
        }
    }

    @Override
    public void onDeath(Creature actor, Creature killer) {
        this.doRevive();
    }

    private void doRevive() {
        this.clearCurrentFarmZone();
        this.clearPlannedActions();
        this._plannedActions.add(new WaitAction(3000, 10000, 100.0));
        this._plannedActions.add(new ReviveAction());
        this._plannedActions.add(new WaitAction(2000, 6000, 100.0));
    }

    @Override
    public void onLevelChange(Player player, int oldLvl, int newLvl) {
        if (player.isFakePlayer()) {
            FakePlayerUtils.setProf(player);
            this.todoEquip = FakePlayerUtils.checkEquip(this);
        }
        if (player.getLevel() == Config.ALT_MAX_LEVEL) {
            this.deleteFake(player);
        }
    }

    private void deleteFake(Player player) {
        if (!player.isFakePlayer()) {
            return;
        }
        if (!this.deleted.compareAndSet(false, true)) {
            return;
        }
        int objectId = player.getObjectId();
        player.kick();
        CharacterDAO.getInstance().deleteCharByObjId(objectId);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    public void onTeleport(Player player, int x, int y, int z, Reflection reflection) {
        FakeAI fakeAI = this;
        synchronized (fakeAI) {
            this.startWait(2000, 5000);
            TownZoneTemplate townZone = null;
            block3: for (TownZoneTemplate t : FakePlayersHolder.getInstance().getTownZones()) {
                for (Zone zone : t.getZones()) {
                    if (!zone.checkIfInZone(x, y, z)) continue;
                    townZone = t;
                    break block3;
                }
            }
            if (townZone != null && this.clearCurrentFarmZone()) {
                this.clearPlannedActions();
            }
        }
    }

    @Override
    public void onChatMessageReceive(Player player, ChatType type, String charName, String text) {
        if (type == ChatType.TELL) {
            FakePlayerUtils.writeInPrivateChat(this, charName);
        }
    }

    @Override
    public void run() {
        Player actor = this.getActor();
        if (actor == null || this.deleted.get()) {
            this.stopActionTask();
            return;
        }
        try {
            this.performNextAction(false);
        } catch (Exception e) {
            _log.error("FakeAI action task failed for " + (actor != null ? actor.getName() : "null"), e);
            this.stopActionTask();
        }
    }

    private synchronized void startActionTask() {
        if (this._actionTask == null) {
            this._actionTask = ThreadPoolManager.getInstance().scheduleAtFixedDelay(this, 500L, 500L);
        }
    }

    private synchronized void stopActionTask() {
        if (this._actionTask != null) {
            this._actionTask.cancel(true);
            this._actionTask = null;
        }
    }

    private static Location getRandomLoc(List<Zone> zones, int geoIndex, boolean fly) {
        Zone zone = (Zone)Rnd.get(zones);
        if (zone != null) {
            return zone.getTerritory().getRandomLoc(geoIndex, fly);
        }
        return new Location();
    }

    private static boolean isInside(List<Zone> zones, int x, int y, int z) {
        for (Zone zone : zones) {
            if (!zone.checkIfInZone(x, y, z)) continue;
            return true;
        }
        return false;
    }

    private class DistanceComparator
    implements Comparator<GameObject> {
        private DistanceComparator() {
        }

        @Override
        public int compare(GameObject o1, GameObject o2) {
            Player player = FakeAI.this.getActor();
            if (player != null) {
                return Integer.compare(o1.getDistance(player), o2.getDistance(player));
            }
            return 0;
        }
    }
}


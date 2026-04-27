/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  gnu.trove.iterator.TIntObjectIterator
 *  l2s.commons.util.Rnd
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.model;

import gnu.trove.iterator.TIntObjectIterator;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Set;
import java.util.concurrent.Future;
import java.util.concurrent.ScheduledFuture;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.ai.ServitorAI;
import l2s.gameserver.dao.EffectsDAO;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.handler.onshiftaction.OnShiftActionHolder;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Party;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.World;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.model.actor.recorder.ServitorStatsChangeRecorder;
import l2s.gameserver.model.actor.stat.ServitorStat;
import l2s.gameserver.model.base.Experience;
import l2s.gameserver.model.base.TeamType;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.impl.SingleMatchEvent;
import l2s.gameserver.model.instances.PetInstance;
import l2s.gameserver.model.instances.SummonInstance;
import l2s.gameserver.model.instances.residences.SiegeToggleNpcInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.PetInventory;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.StatusUpdate;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ActionFailPacket;
import l2s.gameserver.network.l2.s2c.AutoAttackStartPacket;
import l2s.gameserver.network.l2.s2c.ExChangeNPCState;
import l2s.gameserver.network.l2.s2c.ExMagicAttackInfo;
import l2s.gameserver.network.l2.s2c.ExPartyPetWindowAdd;
import l2s.gameserver.network.l2.s2c.ExPartyPetWindowDelete;
import l2s.gameserver.network.l2.s2c.ExPartyPetWindowUpdate;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.MyPetSummonInfoPacket;
import l2s.gameserver.network.l2.s2c.NpcInfoPacket;
import l2s.gameserver.network.l2.s2c.NpcInfoState;
import l2s.gameserver.network.l2.s2c.PartySpelledPacket;
import l2s.gameserver.network.l2.s2c.PetDeletePacket;
import l2s.gameserver.network.l2.s2c.PetItemListPacket;
import l2s.gameserver.network.l2.s2c.PetStatusShowPacket;
import l2s.gameserver.network.l2.s2c.PetStatusUpdatePacket;
import l2s.gameserver.network.l2.s2c.RelationChangedPacket;
import l2s.gameserver.network.l2.s2c.SetSummonRemainTimePacket;
import l2s.gameserver.network.l2.s2c.StatusUpdatePacket;
import l2s.gameserver.network.l2.s2c.SystemMessage;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.network.l2.s2c.updatetype.IUpdateTypeComponent;
import l2s.gameserver.network.l2.s2c.updatetype.NpcInfoType;
import l2s.gameserver.skills.AbnormalEffect;
import l2s.gameserver.skills.SkillCastingType;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.skills.TimeStamp;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.taskmanager.DecayTaskManager;
import l2s.gameserver.templates.item.WeaponTemplate;
import l2s.gameserver.templates.npc.NpcTemplate;
import l2s.gameserver.utils.ItemFunctions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class Servitor
extends Playable {
    public static final String TITLE_BY_OWNER_NAME = "%OWNER_NAME%";
    private static final Logger _log = LoggerFactory.getLogger(Servitor.class);
    private static final int SUMMON_DISAPPEAR_RANGE = 2500;
    private final String _ownerName;
    private final Player _owner;
    private int _spawnAnimation = 2;
    protected long _exp = 0L;
    protected int _sp = 0;
    private int _maxLoad;
    private boolean _follow = true;
    private boolean _depressed = false;
    private UsedSkill _usedSkill;
    private double _chargedSoulshotPower = 0.0;
    private double _chargedSpiritshotPower = 0.0;
    private double _chargedSpiritshotHealBonus = 0.0;
    private Future<?> _decayTask;
    private int _summonTime = 0;
    private int _index = 0;
    private final int _corpseTime;
    private final boolean _targetable;
    private boolean _showName;
    private ScheduledFuture<?> _broadcastCharInfoTask;
    private Future<?> _petInfoTask;

    public Servitor(int objectId, NpcTemplate template, Player owner) {
        super(objectId, template);
        this._ownerName = owner.getName();
        this._owner = owner;
        if (template.getSkills().size() > 0) {
            TIntObjectIterator iterator = template.getSkills().iterator();
            while (iterator.hasNext()) {
                iterator.advance();
                this.addSkill(SkillEntry.makeSkillEntry(SkillEntryType.SERVITOR, (Skill)iterator.value()));
            }
        }
        this.setXYZ(owner.getX() + Rnd.get((int)-100, (int)100), owner.getY() + Rnd.get((int)-100, (int)100), owner.getZ());
        this._corpseTime = template.getAIParams().getInteger("corpse_time", 7);
        this._targetable = template.getAIParams().getBool("targetable", true);
        this.setTargetable(this._targetable);
        this.setShowName(template.getAIParams().getBool("show_name", true));
    }

    @Override
    protected void onSpawn() {
        super.onSpawn();
        this._spawnAnimation = 0;
        Player owner = this.getPlayer();
        Party party = owner.getParty();
        if (party != null) {
            party.broadcastToPartyMembers(owner, new ExPartyPetWindowAdd(this));
        }
        this.getAI().setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
        EffectsDAO.getInstance().restoreEffects(this);
        if (owner.isInOlympiadMode()) {
            this.getAbnormalList().stopAll();
        }
        this.transferOwnerBuffs();
        this._summonTime = (int)(System.currentTimeMillis() / 1000L);
        this._index = owner.getServitorsCount();
        if (owner.isGMInvisible()) {
            this.startAbnormalEffect(AbnormalEffect.STEALTH);
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    public ServitorAI getAI() {
        if (this._ai == null) {
            Servitor servitor = this;
            synchronized (servitor) {
                if (this._ai == null) {
                    this._ai = new ServitorAI(this);
                }
            }
        }
        return (ServitorAI)this._ai;
    }

    @Override
    public NpcTemplate getTemplate() {
        return (NpcTemplate)super.getTemplate();
    }

    @Override
    public boolean isUndead() {
        return this.getTemplate().isUndead();
    }

    public abstract int getServitorType();

    public abstract int getEffectIdentifier();

    public boolean isMountable() {
        return false;
    }

    @Override
    public void onAction(Player player, boolean shift) {
        Player owner = this.getPlayer();
        if (!this.isTargetable(player)) {
            player.sendActionFailed();
            return;
        }
        if (this.isFrozen()) {
            player.sendActionFailed();
            return;
        }
        if (shift && OnShiftActionHolder.getInstance().callShiftAction(player, (Class)this.getClass(), this, true)) {
            return;
        }
        if (player.getTarget() != this) {
            player.setTarget(this);
        } else if (player == owner) {
            player.sendPacket((IBroadcastPacket)new MyPetSummonInfoPacket(this).update());
            if (!player.isActionsDisabled()) {
                player.sendPacket((IBroadcastPacket)new PetStatusShowPacket(this));
            }
            player.sendPacket((IBroadcastPacket)ActionFailPacket.STATIC);
        } else if (this.isAutoAttackable(player)) {
            player.getAI().Attack(this, false, shift);
        } else if (player.getAI().getIntention() != CtrlIntention.AI_INTENTION_FOLLOW) {
            if (!shift) {
                player.getAI().setIntention(CtrlIntention.AI_INTENTION_FOLLOW, this, Config.FOLLOW_RANGE);
            } else {
                player.sendActionFailed();
            }
        } else {
            player.sendActionFailed();
        }
    }

    public long getExpForThisLevel() {
        return Experience.getExpForLevel(this.getLevel());
    }

    public long getExpForNextLevel() {
        return Experience.getExpForLevel(this.getLevel() + 1);
    }

    @Override
    public int getNpcId() {
        return this.getTemplate().getId();
    }

    public int getDisplayId() {
        return this.getTemplate().displayId;
    }

    public final long getExp() {
        return this._exp;
    }

    public final void setExp(long exp) {
        this._exp = exp;
    }

    public final int getSp() {
        return this._sp;
    }

    public void setSp(int sp) {
        this._sp = sp;
    }

    @Override
    public int getMaxLoad() {
        return this._maxLoad;
    }

    public void setMaxLoad(int maxLoad) {
        this._maxLoad = maxLoad;
    }

    @Override
    public int getBuffLimit() {
        Player owner = this.getPlayer();
        return (int)this.getStat().calc(Stats.BUFF_LIMIT, owner.getBuffLimit(), null, null);
    }

    public abstract int getCurrentFed();

    public abstract int getMaxFed();

    @Override
    protected void onDeath(Creature killer) {
        super.onDeath(killer);
        this.broadcastPacket(new NpcInfoState(this));
        this.startDecay((long)this.getCorpseTime() * 1000L);
        Player owner = this.getPlayer();
        if (killer == null || killer == owner || killer == this || this.isInZoneBattle() || killer.isInZoneBattle()) {
            return;
        }
        if (killer.isServitor()) {
            killer = killer.getPlayer();
        }
        if (killer == null) {
            return;
        }
        if (killer.isPlayer()) {
            if (killer.isMyServitor(this.getObjectId())) {
                return;
            }
            if (this.isInSiegeZone()) {
                return;
            }
            Player pk = (Player)killer;
            if (this.getPvpFlag() == 0 && !this.getPlayer().atMutualWarWith(pk) && !this.isPK()) {
                boolean eventPvPFlag = true;
                for (SingleMatchEvent matchEvent : this.getEvents(SingleMatchEvent.class)) {
                    if (matchEvent.canIncreasePvPPKCounter(pk, owner)) continue;
                    eventPvPFlag = false;
                    break;
                }
                if (eventPvPFlag) {
                    int pkCountMulti = Math.max(pk.getPkKills() / 2, 1);
                    pk.decreaseKarma(Config.KARMA_MIN_KARMA * pkCountMulti);
                    pk.sendChanges();
                }
            }
        }
    }

    protected void startDecay(long delay) {
        this.stopDecay();
        this._decayTask = DecayTaskManager.getInstance().addDecayTask(this, delay);
    }

    protected void stopDecay() {
        if (this._decayTask != null) {
            this._decayTask.cancel(false);
            this._decayTask = null;
        }
    }

    @Override
    protected void onDecay() {
        this.deleteMe();
    }

    public void endDecayTask() {
        this.stopDecay();
        this.doDecay();
    }

    @Override
    public void broadcastStatusUpdate() {
        if (!this.needStatusUpdate()) {
            return;
        }
        Player owner = this.getPlayer();
        this.sendStatusUpdate();
        this.broadcastPacket(new StatusUpdate((Creature)this, StatusUpdatePacket.UpdateType.DEFAULT, 9, 10, 11, 12));
        Party party = owner.getParty();
        if (party != null) {
            party.broadcastToPartyMembers(owner, new ExPartyPetWindowUpdate(this));
        }
    }

    public void sendStatusUpdate() {
        Player owner = this.getPlayer();
        owner.sendPacket((IBroadcastPacket)new PetStatusUpdatePacket(this));
    }

    @Override
    protected void onDelete() {
        Player owner = this.getPlayer();
        Party party = owner.getParty();
        if (party != null) {
            party.broadcastToPartyMembers(owner, new ExPartyPetWindowDelete(this));
        }
        owner.sendPacket((IBroadcastPacket)new PetDeletePacket(this.getObjectId(), this.getServitorType()));
        owner.deleteServitor(this.getObjectId());
        for (Servitor servitor : owner.getServitors()) {
            if (this._index >= servitor.getIndex()) continue;
            servitor.setIndex(servitor.getIndex() - 1);
        }
        this.stopDecay();
        super.onDelete();
    }

    public void unSummon(boolean logout) {
        this.storeEffects(!logout);
        this.deleteMe();
    }

    public void storeEffects(boolean clean) {
        Player owner = this.getPlayer();
        if (owner == null) {
            return;
        }
        if (clean || owner.isInOlympiadMode()) {
            this.getAbnormalList().stopAll();
        }
        EffectsDAO.getInstance().insert(this);
    }

    public void setFollowMode(boolean state) {
        Player owner = this.getPlayer();
        this._follow = state;
        if (this._follow) {
            if (this.getAI().getIntention() == CtrlIntention.AI_INTENTION_ACTIVE) {
                this.getAI().setIntention(CtrlIntention.AI_INTENTION_FOLLOW, owner, Config.FOLLOW_RANGE);
            }
        } else if (this.getAI().getIntention() == CtrlIntention.AI_INTENTION_FOLLOW) {
            this.getAI().setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
        }
    }

    public boolean isFollowMode() {
        return this._follow;
    }

    @Override
    public void updateAbnormalIconsImpl() {
        Player owner = this.getPlayer();
        PartySpelledPacket ps = new PartySpelledPacket(this, true);
        Party party = owner.getParty();
        if (party != null) {
            party.broadCast(ps);
        } else {
            owner.sendPacket((IBroadcastPacket)ps);
        }
        super.updateAbnormalIconsImpl();
    }

    public int getControlItemObjId() {
        return 0;
    }

    @Override
    public PetInventory getInventory() {
        return null;
    }

    @Override
    public void doPickupItem(GameObject object) {
    }

    @Override
    public void doRevive() {
        super.doRevive();
        this.setRunning();
        this.getAI().setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
        this.setFollowMode(true);
    }

    @Override
    public ItemInstance getActiveWeaponInstance() {
        return null;
    }

    @Override
    public WeaponTemplate getActiveWeaponTemplate() {
        return null;
    }

    @Override
    public ItemInstance getSecondaryWeaponInstance() {
        return null;
    }

    @Override
    public WeaponTemplate getSecondaryWeaponTemplate() {
        return null;
    }

    @Override
    public void displayGiveDamageMessage(Creature target, Skill skill, int damage, Servitor servitorTransferedDamage, int transferedDamage, boolean crit, boolean miss, boolean shld, boolean blocked) {
        super.displayGiveDamageMessage(target, skill, damage, servitorTransferedDamage, transferedDamage, crit, miss, shld, blocked);
        if (miss) {
            if (skill == null) {
                this.getPlayer().sendPacket((IBroadcastPacket)new SystemMessage(2265).addName(this));
            } else {
                this.getPlayer().sendPacket((IBroadcastPacket)new ExMagicAttackInfo(this.getPlayer().getObjectId(), target.getObjectId(), 4));
            }
            return;
        }
        if (crit) {
            this.getPlayer().sendPacket((IBroadcastPacket)new SystemMessage(2266).addName(this));
        }
        if (blocked) {
            this.getPlayer().sendPacket((IBroadcastPacket)SystemMsg.THE_ATTACK_HAS_BEEN_BLOCKED);
            this.getPlayer().sendPacket((IBroadcastPacket)new ExMagicAttackInfo(this.getPlayer().getObjectId(), target.getObjectId(), target.isInvulnerable() ? 7 : 5));
        } else if (!target.isDoor() && !(target instanceof SiegeToggleNpcInstance)) {
            this.getPlayer().sendPacket((IBroadcastPacket)((SystemMessagePacket)((SystemMessagePacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.C1_HAS_DONE_S3_POINTS_OF_DAMAGE_TO_C2).addName(this)).addName(target)).addInteger(damage)).addHpChange(target.getObjectId(), this.getObjectId(), -damage));
        }
    }

    @Override
    public void displayReceiveDamageMessage(Creature attacker, int damage) {
        if (attacker != this) {
            this.getPlayer().sendPacket((IBroadcastPacket)((SystemMessagePacket)((SystemMessagePacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.C1_HAS_RECEIVED_S3_DAMAGE_FROM_C2).addName(this)).addName(attacker)).addInteger(damage)).addHpChange(this.getObjectId(), attacker.getObjectId(), -damage));
        }
    }

    @Override
    public boolean unChargeShots(boolean spirit) {
        Player owner = this.getPlayer();
        if (spirit) {
            if (this._chargedSpiritshotPower > 0.0 || this._chargedSpiritshotHealBonus > 0.0) {
                this._chargedSpiritshotPower = 0.0;
                this._chargedSpiritshotHealBonus = 0.0;
                owner.autoShot();
                return true;
            }
        } else if (this._chargedSoulshotPower > 0.0) {
            this._chargedSoulshotPower = 0.0;
            owner.autoShot();
            return true;
        }
        return false;
    }

    @Override
    public double getChargedSoulshotPower() {
        if (this._chargedSoulshotPower > 0.0) {
            return this.getStat().calc(Stats.SOULSHOT_POWER, this._chargedSoulshotPower);
        }
        return 0.0;
    }

    @Override
    public void setChargedSoulshotPower(double val) {
        this._chargedSoulshotPower = val;
    }

    @Override
    public double getChargedSpiritshotPower() {
        if (this._chargedSpiritshotPower > 0.0) {
            return this.getStat().calc(Stats.SPIRITSHOT_POWER, this._chargedSpiritshotPower);
        }
        return 0.0;
    }

    @Override
    public double getChargedSpiritshotHealBonus() {
        if (this._chargedSpiritshotHealBonus > 0.0) {
            return this._chargedSpiritshotHealBonus;
        }
        return 0.0;
    }

    @Override
    public void setChargedSpiritshotPower(double power, int unk, double healBonus) {
        this._chargedSpiritshotPower = power;
        this._chargedSpiritshotHealBonus = healBonus;
    }

    public int getSoulshotConsumeCount() {
        return 1;
    }

    public int getSpiritshotConsumeCount() {
        return 1;
    }

    public boolean isDepressed() {
        return this._depressed;
    }

    public void setDepressed(boolean depressed) {
        this._depressed = depressed;
    }

    public boolean isInRange() {
        Player owner = this.getPlayer();
        return this.getDistance(owner) < 2500;
    }

    public void teleportToOwner() {
        Player owner = this.getPlayer();
        this.setNonAggroTime(System.currentTimeMillis() + Config.NONAGGRO_TIME_ONTELEPORT);
        this.setNonPvpTime(System.currentTimeMillis() + Config.NONPVP_TIME_ONTELEPORT);
        if (owner.isInOlympiadMode()) {
            this.teleToLocation(owner.getLoc(), owner.getReflection());
        } else {
            this.teleToLocation(Location.findPointToStay(owner, 50, 150), owner.getReflection());
        }
        if (!this.isDead() && this._follow) {
            this.getAI().setIntention(CtrlIntention.AI_INTENTION_FOLLOW, owner, Config.FOLLOW_RANGE);
        }
    }

    @Override
    public void broadcastCharInfo() {
        if (this._broadcastCharInfoTask != null) {
            return;
        }
        this._broadcastCharInfoTask = ThreadPoolManager.getInstance().schedule(new BroadcastCharInfoTask(), Config.BROADCAST_CHAR_INFO_INTERVAL);
    }

    @Override
    public void broadcastCharInfoImpl(IUpdateTypeComponent ... components) {
        this.broadcastCharInfoImpl(World.getAroundObservers(this), components);
    }

    public void broadcastCharInfoImpl(Iterable<Player> players, IUpdateTypeComponent ... components) {
        if (components.length == 0) {
            _log.warn(this.getClass().getSimpleName() + ": Trying broadcast char info without components!", (Throwable)new Exception());
            return;
        }
        Player owner = this.getPlayer();
        for (Player player : players) {
            if (player == owner) {
                player.sendPacket((IBroadcastPacket)new MyPetSummonInfoPacket(this).update());
            } else if (!owner.isInvisible(player)) {
                if (this.isPet()) {
                    player.sendPacket((IBroadcastPacket)new NpcInfoPacket.PetInfoPacket((PetInstance)this, (Creature)player).update(components));
                } else if (this.isSummon()) {
                    player.sendPacket((IBroadcastPacket)new NpcInfoPacket.SummonInfoPacket((SummonInstance)this, (Creature)player).update(components));
                } else {
                    player.sendPacket((IBroadcastPacket)new NpcInfoPacket(this, (Creature)player).update(components));
                }
            }
            player.sendPacket((IBroadcastPacket)new RelationChangedPacket(this, player));
        }
    }

    private void sendPetInfoImpl() {
        Player owner = this.getPlayer();
        owner.sendPacket((IBroadcastPacket)new MyPetSummonInfoPacket(this).update());
    }

    public void sendPetInfo() {
        this.sendPetInfo(false);
    }

    public void sendPetInfo(boolean force) {
        if (Config.USER_INFO_INTERVAL == 0L || force) {
            if (this._petInfoTask != null) {
                this._petInfoTask.cancel(false);
                this._petInfoTask = null;
            }
            this.sendPetInfoImpl();
            return;
        }
        if (this._petInfoTask != null) {
            return;
        }
        this._petInfoTask = ThreadPoolManager.getInstance().schedule(new PetInfoTask(), Config.USER_INFO_INTERVAL);
    }

    public int getSpawnAnimation() {
        return this._spawnAnimation;
    }

    @Override
    public void startPvPFlag(Creature target) {
        Player owner = this.getPlayer();
        owner.startPvPFlag(target);
    }

    @Override
    public int getPvpFlag() {
        Player owner = this.getPlayer();
        return owner.getPvpFlag();
    }

    @Override
    public int getKarma() {
        Player owner = this.getPlayer();
        return owner.getKarma();
    }

    @Override
    public TeamType getTeam() {
        Player owner = this.getPlayer();
        return owner.getTeam();
    }

    @Override
    public Player getPlayer() {
        return this._owner;
    }

    public abstract double getExpPenalty();

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public ServitorStatsChangeRecorder getStatsRecorder() {
        if (this._statsRecorder == null) {
            Servitor servitor = this;
            synchronized (servitor) {
                if (this._statsRecorder == null) {
                    this._statsRecorder = new ServitorStatsChangeRecorder(this);
                }
            }
        }
        return (ServitorStatsChangeRecorder)this._statsRecorder;
    }

    @Override
    public List<L2GameServerPacket> addPacketList(Player forPlayer, Creature dropper) {
        ArrayList<L2GameServerPacket> list = new ArrayList<L2GameServerPacket>();
        Player owner = this.getPlayer();
        if (owner == forPlayer) {
            list.add(new MyPetSummonInfoPacket(this));
            list.add(new SetSummonRemainTimePacket(this));
            list.add(new PartySpelledPacket(this, true));
            if (this.getNpcState() != 101) {
                list.add(new ExChangeNPCState(this.getObjectId(), this.getNpcState()));
            }
            if (this.isPet()) {
                list.add(new PetItemListPacket((PetInstance)this));
            }
        } else if (!this.getPlayer().isInvisible(forPlayer)) {
            Party party = forPlayer.getParty();
            if (this.getReflection() == ReflectionManager.GIRAN_HARBOR && (owner == null || party == null || party != owner.getParty())) {
                return list;
            }
            if (this.isPet()) {
                list.add(new NpcInfoPacket.PetInfoPacket((PetInstance)this, (Creature)forPlayer).init());
            } else if (this.isSummon()) {
                list.add(new NpcInfoPacket.SummonInfoPacket((SummonInstance)this, (Creature)forPlayer).init());
            } else {
                list.add(new NpcInfoPacket(this, (Creature)forPlayer).init());
            }
            if (owner != null && party != null && party == owner.getParty()) {
                list.add(new PartySpelledPacket(this, true));
            }
        } else {
            return Collections.emptyList();
        }
        if (this.isInCombat()) {
            list.add(new AutoAttackStartPacket(this.getObjectId()));
        }
        list.add(new RelationChangedPacket(this, forPlayer));
        if (this.isInBoat()) {
            list.add(this.getBoat().getOnPacket(this, this.getInBoatPosition()));
        } else if (this.getMovement().isMoving() || this.getMovement().isFollow()) {
            list.add(this.movePacket());
        }
        return list;
    }

    @Override
    public void startAttackStanceTask() {
        this.startAttackStanceTask0();
        Player player = this.getPlayer();
        if (player != null) {
            player.startAttackStanceTask0();
        }
    }

    @Override
    public <E extends Event> E getEvent(Class<E> eventClass) {
        Player player = this.getPlayer();
        if (player != null) {
            return player.getEvent(eventClass);
        }
        return super.getEvent(eventClass);
    }

    @Override
    public <E extends Event> List<E> getEvents(Class<E> eventClass) {
        Player player = this.getPlayer();
        if (player != null) {
            return player.getEvents(eventClass);
        }
        return super.getEvents(eventClass);
    }

    @Override
    public boolean containsEvent(Event event) {
        Player player = this.getPlayer();
        if (player != null) {
            return player.containsEvent(event);
        }
        return super.containsEvent(event);
    }

    @Override
    public boolean containsEvent(Class<? extends Event> eventClass) {
        Player player = this.getPlayer();
        if (player != null) {
            return player.containsEvent(eventClass);
        }
        return super.containsEvent(eventClass);
    }

    @Override
    public Set<Event> getEvents() {
        Player player = this.getPlayer();
        if (player != null) {
            return player.getEvents();
        }
        return super.getEvents();
    }

    @Override
    public void sendReuseMessage(Skill skill) {
        Player player = this.getPlayer();
        if (player != null) {
            if (this.getSkillCast(SkillCastingType.NORMAL).isCastingNow() && (!this.isDualCastEnable() || this.getSkillCast(SkillCastingType.NORMAL_SECOND).isCastingNow())) {
                return;
            }
            TimeStamp sts = this.getSkillReuse(skill);
            if (sts == null || !sts.hasNotPassed()) {
                return;
            }
            long timeleft = sts.getReuseCurrent();
            if (!Config.ALT_SHOW_REUSE_MSG && timeleft < 10000L || timeleft < 500L) {
                return;
            }
            player.sendPacket((IBroadcastPacket)SystemMsg.THAT_PET_SERVITOR_SKILL_CANNOT_BE_USED_BECAUSE_IT_IS_RECHARGING);
        }
    }

    @Override
    public boolean isServitor() {
        return true;
    }

    public boolean isHungry() {
        return false;
    }

    public boolean isNotControlled() {
        return false;
    }

    public int getNpcState() {
        return 101;
    }

    public void onAttacked(Creature attacker) {
    }

    public void onOwnerGotAttacked(Creature attacker) {
        this.onAttacked(attacker);
    }

    public void onOwnerOfAttacks(Creature target) {
    }

    public void setAttackMode(AttackMode mode) {
    }

    public AttackMode getAttackMode() {
        return AttackMode.PASSIVE;
    }

    public void transferOwnerBuffs() {
        Collection<Abnormal> abnormals = this.getPlayer().getAbnormalList().values();
        for (Abnormal a : abnormals) {
            Skill skill = a.getSkill();
            if (a.isOffensive() || skill.isToggle() || skill.isCubicSkill() || this.isSummon() && !skill.applyEffectsOnSummon() || this.isPet() && !skill.applyEffectsOnPet()) continue;
            Abnormal abnormal = new Abnormal(a.getEffector(), this, a);
            abnormal.setDuration(a.getDuration());
            abnormal.setTimeLeft(a.getTimeLeft());
            this.getAbnormalList().add(abnormal);
        }
    }

    @Override
    public boolean checkPvP(Creature target, SkillEntry skillEntry) {
        if (target != this && target.isServitor() && this.getPlayer().isMyServitor(target.getObjectId()) && (skillEntry == null || skillEntry.getTemplate().isDebuff())) {
            return true;
        }
        return super.checkPvP(target, skillEntry);
    }

    public UsedSkill getUsedSkill() {
        return this._usedSkill;
    }

    public void setUsedSkill(Skill skill, int actionId) {
        this._usedSkill = new UsedSkill(skill, actionId);
    }

    public void setUsedSkill(UsedSkill usedSkill) {
        this._usedSkill = usedSkill;
    }

    public void notifyMasterDeath() {
        this.getAI().setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
        this.setFollowMode(true);
    }

    public int getSummonTime() {
        return this._summonTime;
    }

    @Override
    public boolean isSpecialAbnormal(Skill skill) {
        if (this.getPlayer() != null) {
            return this.getPlayer().isSpecialAbnormal(skill);
        }
        return false;
    }

    protected int getCorpseTime() {
        return this._corpseTime;
    }

    public void setIndex(int index) {
        this._index = index;
    }

    public int getIndex() {
        return this._index;
    }

    @Override
    public int getAdditionalVisualSSEffect() {
        return this.getPlayer().getAdditionalVisualSSEffect();
    }

    @Override
    public SkillEntry getAdditionalSSEffect(boolean spiritshot, boolean blessed) {
        if (!spiritshot) {
            if (ItemFunctions.checkIsEquipped(this.getPlayer(), -1, 70455, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17891, 1);
            }
            if (ItemFunctions.checkIsEquipped(this.getPlayer(), -1, 70454, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17890, 1);
            }
            if (ItemFunctions.checkIsEquipped(this.getPlayer(), -1, 70453, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17889, 1);
            }
            if (ItemFunctions.checkIsEquipped(this.getPlayer(), -1, 70452, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17888, 2);
            }
            if (ItemFunctions.checkIsEquipped(this.getPlayer(), -1, 70451, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17888, 1);
            }
            if (ItemFunctions.checkIsEquipped(this.getPlayer(), -1, 90332, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17891, 1);
            }
            if (ItemFunctions.checkIsEquipped(this.getPlayer(), -1, 90331, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17890, 1);
            }
            if (ItemFunctions.checkIsEquipped(this.getPlayer(), -1, 90330, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17889, 1);
            }
            if (ItemFunctions.checkIsEquipped(this.getPlayer(), -1, 90329, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17888, 2);
            }
            if (ItemFunctions.checkIsEquipped(this.getPlayer(), -1, 90328, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17888, 1);
            }
        } else {
            if (ItemFunctions.checkIsEquipped(this.getPlayer(), -1, 70460, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 39242, 1);
            }
            if (ItemFunctions.checkIsEquipped(this.getPlayer(), -1, 70459, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 39241, 1);
            }
            if (ItemFunctions.checkIsEquipped(this.getPlayer(), -1, 70458, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 39240, 1);
            }
            if (ItemFunctions.checkIsEquipped(this.getPlayer(), -1, 70457, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 39239, 2);
            }
            if (ItemFunctions.checkIsEquipped(this.getPlayer(), -1, 70456, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 39239, 1);
            }
            if (ItemFunctions.checkIsEquipped(this.getPlayer(), -1, 90337, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 39242, 1);
            }
            if (ItemFunctions.checkIsEquipped(this.getPlayer(), -1, 90336, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 39241, 1);
            }
            if (ItemFunctions.checkIsEquipped(this.getPlayer(), -1, 90335, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 39240, 1);
            }
            if (ItemFunctions.checkIsEquipped(this.getPlayer(), -1, 90334, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 39239, 2);
            }
            if (ItemFunctions.checkIsEquipped(this.getPlayer(), -1, 90333, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 39239, 1);
            }
        }
        return null;
    }

    public boolean isShowName() {
        return this._showName;
    }

    public void setShowName(boolean value) {
        this._showName = value;
    }

    @Override
    protected L2GameServerPacket changeMovePacket() {
        return new NpcInfoState(this);
    }

    @Override
    public boolean isInvisible(GameObject observer) {
        Player owner = this.getPlayer();
        if (owner != null) {
            Player observPlayer;
            if (owner == observer) {
                return false;
            }
            if (observer != null && observer.isPlayer() && owner.isInSameParty(observPlayer = (Player)observer)) {
                return false;
            }
            if (owner.isGMInvisible()) {
                return true;
            }
        }
        return super.isInvisible(observer);
    }

    @Override
    public boolean isTargetable(Creature creature) {
        if (!this._targetable) {
            return false;
        }
        if (this.getPlayer() == creature) {
            return true;
        }
        return super.isTargetable(creature);
    }

    @Override
    public int getPAtk(Creature target) {
        return (int)((double)super.getPAtk(target) * Config.SERVITOR_P_ATK_MODIFIER);
    }

    @Override
    public int getPDef(Creature target) {
        return (int)((double)super.getPDef(target) * Config.SERVITOR_P_DEF_MODIFIER);
    }

    @Override
    public int getMAtk(Creature target, Skill skill) {
        return (int)((double)super.getMAtk(target, skill) * Config.SERVITOR_M_ATK_MODIFIER);
    }

    @Override
    public int getMDef(Creature target, Skill skill) {
        return (int)((double)super.getMDef(target, skill) * Config.SERVITOR_M_DEF_MODIFIER);
    }

    public List<Skill> getActiveSkills() {
        return Collections.emptyList();
    }

    public int getActiveSkillLevel(int skillId) {
        return this.getSkillLevel(skillId, 0);
    }

    @Override
    public final String getVisibleName(Player receiver) {
        String name = this.getName();
        if (name.equals(this.getTemplate().name)) {
            name = "";
        }
        return name;
    }

    @Override
    public final String getVisibleTitle(Player receiver) {
        String title = this.getTitle();
        if (title.equals(TITLE_BY_OWNER_NAME)) {
            Player player = this.getPlayer();
            title = player == null || player == receiver ? this._ownerName : player.getVisibleName(receiver);
        }
        return title;
    }

    @Override
    public ServitorStat getStat() {
        if (this._stat == null) {
            this._stat = new ServitorStat(this);
        }
        return (ServitorStat)this._stat;
    }

    private class PetInfoTask
    implements Runnable {
        private PetInfoTask() {
        }

        @Override
        public void run() {
            Servitor.this.sendPetInfoImpl();
            Servitor.this._petInfoTask = null;
        }
    }

    public class BroadcastCharInfoTask
    implements Runnable {
        @Override
        public void run() {
            Servitor.this.broadcastCharInfoImpl(NpcInfoType.VALUES);
            Servitor.this._broadcastCharInfoTask = null;
        }
    }

    public static enum AttackMode {
        PASSIVE,
        DEFENCE;

    }

    public static class UsedSkill {
        private final Skill _skill;
        private final int _actionId;

        public UsedSkill(Skill skill, int actionId) {
            this._skill = skill;
            this._actionId = actionId;
        }

        public Skill getSkill() {
            return this._skill;
        }

        public int getActionId() {
            return this._actionId;
        }
    }

    public static class ServitorComparator
    implements Comparator<Servitor> {
        private static final ServitorComparator _instance = new ServitorComparator();

        public static final ServitorComparator getInstance() {
            return _instance;
        }

        @Override
        public int compare(Servitor o1, Servitor o2) {
            if (o1 == null) {
                return -1;
            }
            if (o2 == null) {
                return 1;
            }
            return o1.getSummonTime() - o2.getSummonTime();
        }
    }
}


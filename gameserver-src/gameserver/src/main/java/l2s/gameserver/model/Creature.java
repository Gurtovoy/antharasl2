package l2s.gameserver.model;

import gnu.trove.set.TIntSet;
import gnu.trove.set.hash.TIntHashSet;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArraySet;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import l2s.commons.collections.LazyArrayList;
import l2s.commons.geometry.Circle;
import l2s.commons.geometry.Shape;
import l2s.commons.lang.reference.HardReference;
import l2s.commons.lang.reference.HardReferences;
import l2s.commons.listener.Listener;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.ai.CharacterAI;
import l2s.gameserver.ai.CtrlEvent;
import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.ai.PlayableAI;
import l2s.gameserver.data.xml.holder.LevelBonusHolder;
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.data.xml.holder.TransformTemplateHolder;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.geometry.ILocation;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.listener.hooks.ListenerHook;
import l2s.gameserver.listener.hooks.ListenerHookType;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.GameObjectTasks;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.World;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.actor.CreatureMovement;
import l2s.gameserver.model.actor.CreatureSkillCast;
import l2s.gameserver.model.actor.basestats.CreatureBaseStats;
import l2s.gameserver.model.actor.flags.CreatureFlags;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.model.actor.instances.creature.AbnormalList;
import l2s.gameserver.model.actor.listener.CharListenerList;
import l2s.gameserver.model.actor.recorder.CharStatsChangeRecorder;
import l2s.gameserver.model.actor.stat.CreatureStat;
import l2s.gameserver.model.base.Element;
import l2s.gameserver.model.base.Sex;
import l2s.gameserver.model.base.TeamType;
import l2s.gameserver.model.base.TransformType;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.quest.QuestEventType;
import l2s.gameserver.model.quest.QuestState;
import l2s.gameserver.model.reference.L2Reference;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.StatusUpdate;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ActionFailPacket;
import l2s.gameserver.network.l2.s2c.AttackPacket;
import l2s.gameserver.network.l2.s2c.AutoAttackStartPacket;
import l2s.gameserver.network.l2.s2c.AutoAttackStopPacket;
import l2s.gameserver.network.l2.s2c.ChangeMoveTypePacket;
import l2s.gameserver.network.l2.s2c.ExAbnormalStatusUpdateFromTargetPacket;
import l2s.gameserver.network.l2.s2c.ExRotation;
import l2s.gameserver.network.l2.s2c.ExShowChannelingEffectPacket;
import l2s.gameserver.network.l2.s2c.ExTeleportToLocationActivate;
import l2s.gameserver.network.l2.s2c.FlyToLocationPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.MTLPacket;
import l2s.gameserver.network.l2.s2c.MagicSkillCanceled;
import l2s.gameserver.network.l2.s2c.MagicSkillLaunchedPacket;
import l2s.gameserver.network.l2.s2c.MagicSkillUse;
import l2s.gameserver.network.l2.s2c.MoveToPawnPacket;
import l2s.gameserver.network.l2.s2c.SetupGaugePacket;
import l2s.gameserver.network.l2.s2c.StatusUpdatePacket;
import l2s.gameserver.network.l2.s2c.StopMovePacket;
import l2s.gameserver.network.l2.s2c.SystemMessage;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.network.l2.s2c.TeleportToLocationPacket;
import l2s.gameserver.network.l2.s2c.updatetype.IUpdateTypeComponent;
import l2s.gameserver.skills.AbnormalEffect;
import l2s.gameserver.skills.AbnormalType;
import l2s.gameserver.skills.BasicProperty;
import l2s.gameserver.skills.BasicPropertyResist;
import l2s.gameserver.skills.EffectUseType;
import l2s.gameserver.skills.SkillCastingType;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillInfo;
import l2s.gameserver.skills.TimeStamp;
import l2s.gameserver.stats.Formulas;
import l2s.gameserver.stats.StatFunctions;
import l2s.gameserver.stats.StatTemplate;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.stats.triggers.RunnableTrigger;
import l2s.gameserver.stats.triggers.TriggerInfo;
import l2s.gameserver.stats.triggers.TriggerType;
import l2s.gameserver.taskmanager.LazyPrecisionTaskManager;
import l2s.gameserver.taskmanager.RegenTaskManager;
import l2s.gameserver.templates.CreatureTemplate;
import l2s.gameserver.templates.item.WeaponTemplate;
import l2s.gameserver.templates.npc.NpcTemplate;
import l2s.gameserver.templates.player.transform.TransformTemplate;
import l2s.gameserver.templates.skill.EffectTemplate;
import l2s.gameserver.utils.AbnormalsComparator;
import l2s.gameserver.utils.PositionUtils;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.CHashIntObjectMap;
import org.napile.primitive.maps.impl.CTreeIntObjectMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class Creature
extends GameObject {
    private static final Logger _log = LoggerFactory.getLogger(Creature.class);
    public static final double HEADINGS_IN_PI = 10430.378350470453;
    public static final int INTERACTION_DISTANCE = 200;
    private Future<?> _stanceTask;
    private Runnable _stanceTaskRunnable;
    private long _stanceEndTime;
    private Future<?> _deleteTask;
    public static final int CLIENT_BAR_SIZE = 352;
    private int _lastCpBarUpdate = -1;
    private int _lastHpBarUpdate = -1;
    private int _lastMpBarUpdate = -1;
    protected double _currentCp = 0.0;
    private double _currentHp = 1.0;
    protected double _currentMp = 1.0;
    protected boolean _isAttackAborted;
    protected long _attackEndTime;
    protected long _attackReuseEndTime;
    private long _lastAttackTime = -1L;
    private int _poleAttackCount = 0;
    private static final double[] POLE_VAMPIRIC_MOD = new double[]{1.0, 0.9, 0.0, 7.0, 0.2, 0.01};
    protected final IntObjectMap<SkillEntry> _skills = new CTreeIntObjectMap();
    protected Map<TriggerType, Set<TriggerInfo>> _triggers;
    protected IntObjectMap<TimeStamp> _skillReuses = new CHashIntObjectMap();
    protected volatile AbnormalList _effectList;
    protected volatile CharStatsChangeRecorder<? extends Creature> _statsRecorder;
    private Set<AbnormalEffect> _abnormalEffects = new CopyOnWriteArraySet<AbnormalEffect>();
    private AtomicBoolean isDead = new AtomicBoolean();
    protected AtomicBoolean isTeleporting = new AtomicBoolean();
    private boolean _fakeDeath;
    private boolean _isPreserveAbnormal;
    private boolean _isSalvation;
    private boolean _meditated;
    private boolean _lockedTarget;
    private boolean _blocked;
    private final Map<EffectHandler, TIntSet> _ignoreSkillsEffects = new HashMap<EffectHandler, TIntSet>();
    private volatile HardReference<? extends Creature> _effectImmunityException = HardReferences.emptyRef();
    private volatile HardReference<? extends Creature> _damageBlockedException = HardReferences.emptyRef();
    private boolean _flying;
    private boolean _running;
    private volatile HardReference<? extends GameObject> _target = HardReferences.emptyRef();
    private volatile HardReference<? extends Creature> _aggressionTarget = HardReferences.emptyRef();
    private int _rndCharges = 0;
    private int _heading;
    private CreatureTemplate _template;
    protected volatile CharacterAI _ai;
    protected String _name;
    protected String _title;
    protected TeamType _team = TeamType.NONE;
    private boolean _isRegenerating;
    private final Lock regenLock = new ReentrantLock();
    private Future<?> _regenTask;
    private Runnable _regenTaskRunnable;
    private List<Zone> _zones = new LazyArrayList();
    private final ReadWriteLock zonesLock = new ReentrantReadWriteLock();
    private final Lock zonesRead = this.zonesLock.readLock();
    private final Lock zonesWrite = this.zonesLock.writeLock();
    protected volatile CharListenerList listeners;
    private final Lock statusListenersLock = new ReentrantLock();
    protected HardReference<? extends Creature> reference;
    private boolean _isInTransformUpdate = false;
    private TransformTemplate _visualTransform = null;
    private boolean _isDualCastEnable = false;
    private boolean _isTargetable = true;
    protected CreatureBaseStats _baseStats = null;
    protected CreatureStat _stat = null;
    protected CreatureFlags _statuses = null;
    private volatile Map<BasicProperty, BasicPropertyResist> _basicPropertyResists;
    private int _gmSpeed = 0;
    private final CreatureMovement _movement = new CreatureMovement(this);
    private final CreatureSkillCast[] _skillCasts = new CreatureSkillCast[SkillCastingType.VALUES.length];
    private Future<?> _updateAbnormalIconsTask;
    private TIntSet _unActiveSkills = new TIntHashSet();

    public Creature(int objectId, CreatureTemplate template) {
        super(objectId);
        this._template = template;
        StatFunctions.addPredefinedFuncs(this);
        this.reference = new L2Reference<Creature>(this);
        if (!this.isPlayer()) {
            GameObjectsStorage.put(this);
        }
    }

    public HardReference<? extends Creature> getRef() {
        return this.reference;
    }

    public boolean isAttackAborted() {
        return this._isAttackAborted;
    }

    public final void abortAttack(boolean force, boolean message) {
        if (this.isAttackingNow()) {
            this._attackEndTime = 0L;
            if (force) {
                this._isAttackAborted = true;
            }
            this.getAI().setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
            if (this.isPlayer() && message) {
                this.sendActionFailed();
                this.sendPacket((IBroadcastPacket)new SystemMessage(2268).addName(this));
            }
        }
    }

    public final void abortCast(boolean force, boolean message, boolean normalCast, boolean dualCast) {
        boolean cancelled = false;
        if (normalCast && this.getSkillCast(SkillCastingType.NORMAL).abortCast(force)) {
            cancelled = true;
        }
        if (dualCast && this.getSkillCast(SkillCastingType.NORMAL_SECOND).abortCast(force)) {
            cancelled = true;
        }
        if (cancelled) {
            this.broadcastPacket(new MagicSkillCanceled(this.getObjectId()));
            this.getAI().setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
            if (this.isPlayer() && message) {
                this.sendPacket((IBroadcastPacket)SystemMsg.YOUR_CASTING_HAS_BEEN_INTERRUPTED);
            }
        }
    }

    public final void abortCast(boolean force, boolean message) {
        this.abortCast(force, message, true, true);
    }

    private double reflectDamage(Creature attacker, Skill skill, double damage) {
        if (this.isDead() || damage <= 0.0 || !attacker.checkRange(attacker, this) || this.getCurrentHp() + this.getCurrentCp() <= damage) {
            return 0.0;
        }
        boolean bow = attacker.getBaseStats().getAttackType() == WeaponTemplate.WeaponType.BOW || attacker.getBaseStats().getAttackType() == WeaponTemplate.WeaponType.CROSSBOW || attacker.getBaseStats().getAttackType() == WeaponTemplate.WeaponType.TWOHANDCROSSBOW;
        double resistReflect = 1.0 - attacker.getStat().calc(Stats.RESIST_REFLECT_DAM, 0.0, null, null) * 0.01;
        double value = 0.0;
        double chanceValue = 0.0;
        if (skill != null) {
            if (skill.isMagic()) {
                chanceValue = this.getStat().calc(Stats.REFLECT_AND_BLOCK_MSKILL_DAMAGE_CHANCE, 0.0, attacker, skill);
                value = this.getStat().calc(Stats.REFLECT_MSKILL_DAMAGE_PERCENT, 0.0, attacker, skill);
            } else if (skill.isPhysic()) {
                chanceValue = this.getStat().calc(Stats.REFLECT_AND_BLOCK_PSKILL_DAMAGE_CHANCE, 0.0, attacker, skill);
                value = this.getStat().calc(Stats.REFLECT_PSKILL_DAMAGE_PERCENT, 0.0, attacker, skill);
            }
        } else {
            chanceValue = this.getStat().calc(Stats.REFLECT_AND_BLOCK_DAMAGE_CHANCE, 0.0, attacker, null);
            value = bow ? this.getStat().calc(Stats.REFLECT_BOW_DAMAGE_PERCENT, 0.0, attacker, null) : this.getStat().calc(Stats.REFLECT_DAMAGE_PERCENT, 0.0, attacker, null);
        }
        chanceValue = chanceValue > 0.0 && Rnd.chance((double)chanceValue) ? damage : 0.0;
        if (value > 0.0 || chanceValue > 0.0) {
            int xPDef;
            value = (value / 100.0 * damage + chanceValue) * resistReflect;
            if (Config.REFLECT_DAMAGE_CAPPED_BY_PDEF && (xPDef = attacker.getPDef(this)) > 0) {
                value = Math.min(value, (double)xPDef);
            }
            return value;
        }
        return 0.0;
    }

    private void absorbDamage(Creature target, Skill skill, double damage) {
        double absorbDamage;
        double limit;
        boolean bow;
        if (target.isDead()) {
            return;
        }
        if (damage <= 0.0) {
            return;
        }
        if (!Config.SKILL_ABSORB && skill != null) {
            return;
        }
        boolean bl = bow = this.getBaseStats().getAttackType() == WeaponTemplate.WeaponType.BOW || this.getBaseStats().getAttackType() == WeaponTemplate.WeaponType.CROSSBOW || this.getBaseStats().getAttackType() == WeaponTemplate.WeaponType.TWOHANDCROSSBOW;
        if (!Config.BOW_ABSORB && bow) {
            return;
        }
        if (target.isDamageBlocked(this)) {
            return;
        }
        double poleMod = POLE_VAMPIRIC_MOD[Math.max(0, Math.min(this._poleAttackCount, POLE_VAMPIRIC_MOD.length - 1))];
        double absorb = poleMod * this.getStat().calc(Stats.VAMPIRIC_ATTACK, 0.0, this, null);
        if (absorb > 0.0 && !target.isServitor() && !target.isInvulnerable()) {
            limit = this.getStat().calc(Stats.HP_LIMIT, null, null) * (double)this.getMaxHp() / 100.0;
            if (this.getCurrentHp() < limit) {
                absorbDamage = damage * absorb / 100.0;
                absorbDamage = Math.min(absorbDamage, (double)((int)target.getCurrentHp()));
                this.setCurrentHp(Math.min(this.getCurrentHp() + absorbDamage, limit), false);
            }
        }
        if ((absorb = poleMod * this.getStat().calc(Stats.MP_VAMPIRIC_ATTACK, 0.0, target, null)) > 0.0 && !target.isServitor() && !target.isInvulnerable()) {
            limit = this.getStat().calc(Stats.MP_LIMIT, null, null) * (double)this.getMaxMp() / 100.0;
            if (this.getCurrentMp() < limit) {
                absorbDamage = damage * absorb / 100.0;
                absorbDamage = Math.min(absorbDamage, (double)((int)target.getCurrentMp()));
                this.setCurrentMp(Math.min(this.getCurrentMp() + absorbDamage, limit));
            }
        }
    }

    public double absorbToEffector(Creature attacker, double damage) {
        if (damage == 0.0) {
            return 0.0;
        }
        double transferToEffectorDam = this.getStat().calc(Stats.TRANSFER_TO_EFFECTOR_DAMAGE_PERCENT, 0.0);
        if (transferToEffectorDam > 0.0) {
            Collection<Abnormal> abnormals = this.getAbnormalList().values();
            if (abnormals.isEmpty()) {
                return damage;
            }
            for (Abnormal abnormal : abnormals) {
                for (EffectHandler effect : abnormal.getEffects()) {
                    if (!effect.getName().equalsIgnoreCase("AbsorbDamageToEffector")) continue;
                    Creature effector = abnormal.getEffector();
                    if (effector == this || effector.isDead() || !this.isInRange(effector, 1200)) {
                        return damage;
                    }
                    Player thisPlayer = this.getPlayer();
                    Player effectorPlayer = effector.getPlayer();
                    if (thisPlayer != null && effectorPlayer != null) {
                        if (!(thisPlayer == effectorPlayer || thisPlayer.isOnline() && thisPlayer.isInParty() && thisPlayer.getParty() == effectorPlayer.getParty())) {
                            return damage;
                        }
                    } else {
                        return damage;
                    }
                    double transferDamage = damage * transferToEffectorDam * 0.01;
                    damage -= transferDamage;
                    effector.reduceCurrentHp(transferDamage, effector, null, false, false, !attacker.isPlayable(), false, true, false, true);
                }
            }
        }
        return damage;
    }

    private double reduceDamageByMp(Creature attacker, double damage) {
        if (damage == 0.0) {
            return 0.0;
        }
        double power = this.getStat().calc(Stats.TRANSFER_TO_MP_DAMAGE_PERCENT, 0.0);
        if (power <= 0.0) {
            return damage;
        }
        double mpDam = damage - damage * power / 100.0;
        if (mpDam > 0.0) {
            if (mpDam >= this.getCurrentMp()) {
                damage = mpDam - this.getCurrentMp();
                this.sendPacket((IBroadcastPacket)SystemMsg.MP_BECAME_0_AND_THE_ARCANE_SHIELD_IS_DISAPPEARING);
                this.setCurrentMp(0.0);
                this.getAbnormalList().stop(AbnormalType.MP_SHIELD);
            } else {
                this.reduceCurrentMp(mpDam, null);
                this.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.ARCANE_SHIELD_DECREASED_YOUR_MP_BY_S1_INSTEAD_OF_HP).addInteger((int)mpDam));
                return 0.0;
            }
        }
        return damage;
    }

    public Servitor getServitorForTransfereDamage(double damage) {
        return null;
    }

    public double getDamageForTransferToServitor(double damage) {
        return 0.0;
    }

    public SkillEntry addSkill(SkillEntry newSkillEntry) {
        if (newSkillEntry == null) {
            return null;
        }
        SkillEntry oldSkillEntry = (SkillEntry)this._skills.get(newSkillEntry.getId());
        if (newSkillEntry.equals(oldSkillEntry)) {
            return oldSkillEntry;
        }
        this._skills.put(newSkillEntry.getId(), newSkillEntry);
        Skill newSkill = newSkillEntry.getTemplate();
        if (oldSkillEntry != null) {
            Skill oldSkill = oldSkillEntry.getTemplate();
            if (oldSkill.isToggle() && oldSkill.getLevel() > newSkill.getLevel()) {
                this.getAbnormalList().stop(oldSkill, false);
            }
            this.removeTriggers(oldSkill);
            if (oldSkill.isPassive()) {
                this.getStat().removeFuncsByOwner(oldSkill);
                for (EffectTemplate et : oldSkill.getEffectTemplates(EffectUseType.NORMAL)) {
                    this.getStat().removeFuncsByOwner(et.getHandler());
                }
            }
            this.onRemoveSkill(oldSkillEntry);
        }
        this.addTriggers(newSkill);
        if (newSkill.isPassive()) {
            this.getStat().addFuncs(newSkill.getStatFuncs());
            for (EffectTemplate et : newSkill.getEffectTemplates(EffectUseType.NORMAL)) {
                this.getStat().addFuncs(et.getHandler().getStatFuncs());
            }
        }
        this.onAddSkill(newSkillEntry);
        return oldSkillEntry;
    }

    protected void onAddSkill(SkillEntry skill) {
    }

    protected void onRemoveSkill(SkillEntry skillEntry) {
    }

    public void altOnMagicUse(Creature aimingTarget, SkillEntry skillEntry) {
        double mpConsume2;
        if (this.isAlikeDead() || skillEntry == null) {
            return;
        }
        Skill skill = skillEntry.getTemplate();
        int magicId = skill.getDisplayId();
        int level = skill.getDisplayLevel();
        Set<Creature> targets = skill.getTargets(skillEntry, this, aimingTarget, true);
        if (!skill.isNotBroadcastable()) {
            this.broadcastPacket(new MagicSkillLaunchedPacket(this.getObjectId(), magicId, level, targets, SkillCastingType.NORMAL));
        }
        if ((mpConsume2 = skill.getMpConsume2()) > 0.0) {
            double mpConsume2WithStats = skill.isMagic() ? this.getStat().calc(Stats.MP_MAGIC_SKILL_CONSUME, mpConsume2, aimingTarget, skill) : this.getStat().calc(Stats.MP_PHYSICAL_SKILL_CONSUME, mpConsume2, aimingTarget, skill);
            if (this._currentMp < mpConsume2WithStats) {
                this.sendPacket((IBroadcastPacket)SystemMsg.NOT_ENOUGH_MP);
                return;
            }
            this.reduceCurrentMp(mpConsume2WithStats, null);
        }
        this.callSkill(aimingTarget, skillEntry, targets, false, false);
    }

    public final void forceUseSkill(SkillEntry skillEntry, Creature target) {
        if (skillEntry == null) {
            return;
        }
        Skill skill = skillEntry.getTemplate();
        if (target == null && (target = skill.getAimingTarget(this, this.getTarget())) == null) {
            return;
        }
        Set<Creature> targets = skill.getTargets(skillEntry, this, target, true);
        if (!skill.isNotBroadcastable()) {
            this.broadcastPacket(new MagicSkillUse(this, target, skill.getDisplayId(), skill.getDisplayLevel(), 0, 0L));
            this.broadcastPacket(new MagicSkillLaunchedPacket(this.getObjectId(), skill.getDisplayId(), skill.getDisplayLevel(), targets, SkillCastingType.NORMAL));
        }
        this.callSkill(target, skillEntry, targets, false, false);
    }

    public void altUseSkill(SkillEntry skillEntry, Creature target) {
        Player master;
        if (skillEntry == null) {
            return;
        }
        if (this.isUnActiveSkill(skillEntry.getId())) {
            return;
        }
        Skill skill = skillEntry.getTemplate();
        if (this.isSkillDisabled(skill)) {
            return;
        }
        if (target == null && (target = skill.getAimingTarget(this, this.getTarget())) == null) {
            return;
        }
        this.getListeners().onMagicUse(skill, target, true);
        if (!skill.isHandler() && this.isPlayable() && skill.getItemConsumeId() > 0 && skill.getItemConsume() > 0L && (skill.isItemConsumeFromMaster() ? (master = this.getPlayer()) == null || !master.consumeItem(skill.getItemConsumeId(), skill.getItemConsume(), false) : !this.consumeItem(skill.getItemConsumeId(), skill.getItemConsume(), false))) {
            return;
        }
        if (skill.getReferenceItemId() > 0 && !this.consumeItemMp(skill.getReferenceItemId(), skill.getReferenceItemMpConsume())) {
            return;
        }
        if (skill.getEnergyConsume() > this.getAgathionEnergy()) {
            return;
        }
        if (skill.getEnergyConsume() > 0) {
            this.setAgathionEnergy(this.getAgathionEnergy() - skill.getEnergyConsume());
        }
        long reuseDelay = Formulas.calcSkillReuseDelay(this, skill);
        if (!skill.isToggle() && !skill.isNotBroadcastable()) {
            MagicSkillUse msu = new MagicSkillUse(this, target, skill.getDisplayId(), skill.getDisplayLevel(), skill.getHitTime(), reuseDelay);
            msu.setReuseSkillId(skill.getReuseSkillId());
            this.broadcastPacket(msu);
        }
        this.disableSkill(skill, reuseDelay);
        this.altOnMagicUse(target, skillEntry);
    }

    public void sendReuseMessage(Skill skill) {
    }

    public void broadcastPacket(IBroadcastPacket ... packets) {
        this.sendPacket(packets);
        this.broadcastPacketToOthers(packets);
    }

    public void broadcastPacket(List<IBroadcastPacket> packets) {
        this.sendPacket(packets);
        this.broadcastPacketToOthers(packets);
    }

    public void broadcastPacketToOthers(IBroadcastPacket ... packets) {
        if (!this.isVisible() || packets.length == 0) {
            return;
        }
        for (Player target : World.getAroundObservers(this)) {
            target.sendPacket(packets);
        }
    }

    public void broadcastPacketToOthers(List<IBroadcastPacket> packets) {
        this.broadcastPacketToOthers(packets.toArray(new IBroadcastPacket[packets.size()]));
    }

    public void broadcastStatusUpdate() {
        if (!this.needStatusUpdate()) {
            return;
        }
        this.broadcastPacket(new StatusUpdate(this, StatusUpdatePacket.UpdateType.DEFAULT, 9, 10, 11, 12));
    }

    public int calcHeading(int x_dest, int y_dest) {
        return (int)(Math.atan2(this.getY() - y_dest, this.getX() - x_dest) * 10430.378350470453) + 32768;
    }

    public int calculateAttackDelay() {
        return Formulas.calcPAtkSpd(this.getPAtkSpd());
    }

    public void callSkill(Creature aimingTarget, SkillEntry skillEntry, Set<Creature> targets, boolean useActionSkills, boolean trigger) {
        try {
            Skill skill = skillEntry.getTemplate();
            if (useActionSkills) {
                if (skill.isDebuff()) {
                    this.useTriggers(aimingTarget, TriggerType.OFFENSIVE_SKILL_USE, null, skill, 0.0);
                    if (skill.isMagic()) {
                        this.useTriggers(aimingTarget, TriggerType.OFFENSIVE_MAGICAL_SKILL_USE, null, skill, 0.0);
                    } else if (skill.isPhysic()) {
                        this.useTriggers(aimingTarget, TriggerType.OFFENSIVE_PHYSICAL_SKILL_USE, null, skill, 0.0);
                    }
                } else {
                    this.useTriggers(aimingTarget, TriggerType.SUPPORT_SKILL_USE, null, skill, 0.0);
                    if (skill.isMagic()) {
                        this.useTriggers(aimingTarget, TriggerType.SUPPORT_MAGICAL_SKILL_USE, null, skill, 0.0);
                    } else if (skill.isPhysic()) {
                        this.useTriggers(aimingTarget, TriggerType.SUPPORT_PHYSICAL_SKILL_USE, null, skill, 0.0);
                    }
                }
                this.useTriggers(this, TriggerType.ON_CAST_SKILL, null, skill, 0.0);
            }
            Player player = this.getPlayer();
            for (Creature target : targets) {
                NpcInstance npc;
                List<QuestState> ql;
                if (target == null) continue;
                target.getListeners().onMagicHit(skill, this);
                if (player == null || !target.isNpc() || (ql = player.getQuestsForEvent(npc = (NpcInstance)target, QuestEventType.MOB_TARGETED_BY_SKILL)) == null) continue;
                for (QuestState qs : ql) {
                    qs.getQuest().notifySkillUse(npc, skill, qs);
                }
            }
            this.useTriggers(aimingTarget, TriggerType.ON_END_CAST, null, skill, 0.0);
            skill.onEndCast(this, targets);
        }
        catch (Exception e) {
            _log.error("", (Throwable)e);
        }
    }

    public void useTriggers(GameObject target, TriggerType type, Skill ex, Skill owner, double damage) {
        this.useTriggers(target, null, type, ex, owner, owner, damage);
    }

    public void useTriggers(GameObject target, Set<Creature> targets, TriggerType type, Skill ex, Skill owner, double damage) {
        this.useTriggers(target, targets, type, ex, owner, owner, damage);
    }

    public void useTriggers(GameObject target, TriggerType type, Skill ex, Skill owner, StatTemplate triggersOwner, double damage) {
        this.useTriggers(target, null, type, ex, owner, triggersOwner, damage);
    }

    public void useTriggers(GameObject target, Set<Creature> targets, TriggerType type, Skill ex, Skill owner, StatTemplate triggersOwner, double damage) {
        Set<TriggerInfo> triggers = null;
        switch (type) {
            case ON_START_CAST: 
            case ON_TICK_CAST: 
            case ON_END_CAST: 
            case ON_FINISH_CAST: 
            case ON_START_EFFECT: 
            case ON_EXIT_EFFECT: 
            case ON_FINISH_EFFECT: 
            case ON_REVIVE: {
                if (triggersOwner == null) break;
                triggers = new CopyOnWriteArraySet();
                for (TriggerInfo triggerInfo : triggersOwner.getTriggerList()) {
                    if (triggerInfo.getType() != type) continue;
                    triggers.add(triggerInfo);
                }
                break;
            }
            case ON_CAST_SKILL: {
                if (this._triggers == null || this._triggers.get(type) == null) break;
                triggers = new CopyOnWriteArraySet();
                for (TriggerInfo triggerInfo : this._triggers.get(type)) {
                    int skillID;
                    int n = skillID = triggerInfo.getArgs() == null || triggerInfo.getArgs().isEmpty() ? -1 : Integer.parseInt(triggerInfo.getArgs());
                    if (skillID != -1 && skillID != owner.getId()) continue;
                    triggers.add(triggerInfo);
                }
                break;
            }
            default: {
                if (this._triggers == null) break;
                triggers = this._triggers.get(type);
            }
        }
        if (triggers != null && !triggers.isEmpty()) {
            for (TriggerInfo triggerInfo : triggers) {
                SkillEntry skillEntry = triggerInfo.getSkill();
                if (skillEntry == null || skillEntry.getTemplate().equals(ex)) continue;
                this.useTriggerSkill(target == null ? this.getTarget() : target, targets, triggerInfo, owner, damage);
            }
        }
    }

    public void useTriggerSkill(GameObject target, Set<Creature> targets, TriggerInfo trigger, Skill owner, double damage) {
        Creature realTarget;
        SkillEntry skillEntry = trigger.getSkill();
        if (skillEntry == null) {
            return;
        }
        if (!Rnd.chance((double)trigger.getChance())) {
            return;
        }
        Skill skill = skillEntry.getTemplate();
        Creature aimTarget = skill.getAimingTarget(this, target);
        if (aimTarget != null && trigger.isIncreasing()) {
            int increasedTriggerLvl = 0;
            for (Abnormal effect : aimTarget.getAbnormalList()) {
                if (effect.getSkill().getId() != skillEntry.getId()) continue;
                increasedTriggerLvl = effect.getSkill().getLevel();
                break;
            }
            if (increasedTriggerLvl == 0) {
                block1: for (Servitor servitor : aimTarget.getServitors()) {
                    for (Abnormal effect : servitor.getAbnormalList()) {
                        if (effect.getSkill().getId() != skillEntry.getId()) continue;
                        increasedTriggerLvl = effect.getSkill().getLevel();
                        break block1;
                    }
                }
            }
            if (increasedTriggerLvl > 0) {
                Skill newSkill = SkillHolder.getInstance().getSkill(skillEntry.getId(), increasedTriggerLvl + 1);
                skillEntry = newSkill != null ? SkillEntry.makeSkillEntry(skillEntry.getEntryType(), newSkill) : SkillEntry.makeSkillEntry(skillEntry.getEntryType(), skillEntry.getId(), increasedTriggerLvl);
                skill = skillEntry.getTemplate();
            }
        }
        if (skill.getReuseDelay() > 0 && this.isSkillDisabled(skill)) {
            return;
        }
        Creature creature = realTarget = target != null && target.isCreature() ? (Creature)target : null;
        if (trigger.checkCondition(this, realTarget, aimTarget, owner, damage) && skillEntry.checkCondition(this, aimTarget, true, true, true, false, true)) {
            if (targets == null) {
                targets = skill.getTargets(skillEntry, this, aimTarget, false);
            }
            if (!skill.isNotBroadcastable() && trigger.getType() != TriggerType.IDLE) {
                for (Creature cha : targets) {
                    this.broadcastPacket(new MagicSkillUse(this, cha, skillEntry.getDisplayId(), skillEntry.getDisplayLevel(), 0, 0L));
                }
            }
            this.callSkill(aimTarget, skillEntry, targets, false, true);
            this.disableSkill(skill, skill.getReuseDelay());
        }
    }

    private void triggerCancelEffects(TriggerInfo trigger) {
        SkillEntry skillEntry = trigger.getSkill();
        if (skillEntry == null) {
            return;
        }
        this.getAbnormalList().stop(skillEntry.getTemplate(), false);
    }

    public boolean checkReflectSkill(Creature attacker, Skill skill) {
        if (this == attacker) {
            return false;
        }
        if (this.isDead() || attacker.isDead()) {
            return false;
        }
        if (!skill.isReflectable()) {
            return false;
        }
        if (this.isInvulnerable() || attacker.isInvulnerable() || !skill.isDebuff()) {
            return false;
        }
        if (skill.isMagic() && skill.getSkillType() != Skill.SkillType.MDAM) {
            return false;
        }
        if (Rnd.chance((double)this.getStat().calc(skill.isMagic() ? Stats.REFLECT_MAGIC_SKILL : Stats.REFLECT_PHYSIC_SKILL, 0.0, attacker, skill))) {
            this.sendPacket((IBroadcastPacket)new SystemMessage(1998).addName(attacker));
            attacker.sendPacket((IBroadcastPacket)new SystemMessage(1999).addName(this));
            return true;
        }
        return false;
    }

    public boolean checkReflectDebuff(Creature effector, Skill skill) {
        if (this == effector) {
            return false;
        }
        if (this.isDead() || effector.isDead()) {
            return false;
        }
        if (effector.isTrap()) {
            return false;
        }
        if (effector.isRaid()) {
            return false;
        }
        if (!skill.isReflectable()) {
            return false;
        }
        if (this.isInvulnerable() || effector.isInvulnerable() || !skill.isDebuff()) {
            return false;
        }
        if (this.isDebuffImmune()) {
            return false;
        }
        return Rnd.chance((double)this.getStat().calc(skill.isMagic() ? Stats.REFLECT_MAGIC_DEBUFF : Stats.REFLECT_PHYSIC_DEBUFF, 0.0, effector, skill));
    }

    public void doCounterAttack(Skill skill, Creature attacker, boolean blow) {
        if (this.isDead()) {
            return;
        }
        if (this.isDamageBlocked(attacker) || attacker.isDamageBlocked(this)) {
            return;
        }
        if (skill == null || skill.hasEffects(EffectUseType.NORMAL) || skill.isMagic() || !skill.isDebuff() || skill.getCastRange() > 200) {
            return;
        }
        if (Rnd.chance((double)this.getStat().calc(Stats.COUNTER_ATTACK, 0.0, attacker, skill))) {
            double damage = 1189 * this.getPAtk(attacker) / Math.max(attacker.getPDef(this), 1);
            attacker.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_IS_PERFORMING_A_COUNTERATTACK).addName(this));
            if (blow) {
                this.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_IS_PERFORMING_A_COUNTERATTACK).addName(this));
                this.sendPacket((IBroadcastPacket)((SystemMessagePacket)((SystemMessagePacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.C1_HAS_DONE_S3_POINTS_OF_DAMAGE_TO_C2).addName(this)).addName(attacker)).addInteger((int)damage)).addHpChange(this.getObjectId(), attacker.getObjectId(), (int)(-damage)));
                attacker.reduceCurrentHp(damage, this, skill, true, true, false, false, false, false, true);
            } else {
                this.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_IS_PERFORMING_A_COUNTERATTACK).addName(this));
            }
            this.sendPacket((IBroadcastPacket)((SystemMessagePacket)((SystemMessagePacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.C1_HAS_DONE_S3_POINTS_OF_DAMAGE_TO_C2).addName(this)).addName(attacker)).addInteger((int)damage)).addHpChange(this.getObjectId(), attacker.getObjectId(), (int)(-damage)));
            attacker.reduceCurrentHp(damage, this, skill, true, true, false, false, false, false, true);
        }
    }

    public void disableSkill(Skill skill, long delay) {
        this._skillReuses.put(skill.getReuseHash(), new TimeStamp(skill, delay));
    }

    public abstract boolean isAutoAttackable(Creature var1);

    public void doAttack(Creature target) {
        int reuse;
        if (target == null || this.isAMuted() || this.isAttackingNow() || this.isAlikeDead() || target.isDead() || !this.isInRange(target, 2000)) {
            return;
        }
        if (this.isTransformed() && !this.getTransform().isNormalAttackable()) {
            return;
        }
        this.getListeners().onAttack(target);
        int sAtk = this.calculateAttackDelay();
        int ssGrade = 0;
        int attackReuseDelay = 0;
        boolean ssEnabled = false;
        if (this.isNpc()) {
            attackReuseDelay = ((NpcTemplate)this.getTemplate()).getBaseReuseDelay();
            NpcTemplate.ShotsType shotType = ((NpcTemplate)this.getTemplate()).getShots();
            if (shotType != NpcTemplate.ShotsType.NONE && shotType != NpcTemplate.ShotsType.BSPIRIT && shotType != NpcTemplate.ShotsType.SPIRIT) {
                ssEnabled = true;
            }
        } else {
            WeaponTemplate weaponItem = this.getActiveWeaponTemplate();
            if (weaponItem != null) {
                attackReuseDelay = weaponItem.getAttackReuseDelay();
                ssGrade = weaponItem.getGrade().extOrdinal();
            }
            boolean bl = ssEnabled = this.getChargedSoulshotPower() > 0.0;
        }
        if (attackReuseDelay > 0 && (reuse = (500000 + 333 * attackReuseDelay) / this.getPAtkSpd()) > 0) {
            this.sendPacket((IBroadcastPacket)new SetupGaugePacket(this, SetupGaugePacket.Colors.RED, reuse));
            this._attackReuseEndTime = (long)reuse + System.currentTimeMillis() - 75L;
            if (reuse > sAtk) {
                ThreadPoolManager.getInstance().schedule(new GameObjectTasks.NotifyAITask(this, CtrlEvent.EVT_READY_TO_ACT), reuse);
            }
        }
        this._attackEndTime = (long)sAtk + System.currentTimeMillis() - 10L;
        this._isAttackAborted = false;
        this._lastAttackTime = System.currentTimeMillis();
        AttackPacket attack = new AttackPacket(this, target, ssEnabled, ssGrade);
        this.setHeading(PositionUtils.calculateHeadingFrom(this, target), false);
        switch (this.getBaseStats().getAttackType()) {
            case BOW: 
            case CROSSBOW: 
            case TWOHANDCROSSBOW: {
                this.doAttackHitByBow(attack, target, sAtk);
                break;
            }
            case POLE: {
                this.doAttackHitByPole(attack, target, sAtk);
                break;
            }
            case DUAL: 
            case DUALFIST: 
            case DUALDAGGER: 
            case DUALBLUNT: {
                this.doAttackHitByDual(attack, target, sAtk);
                break;
            }
            default: {
                this.doAttackHitSimple(attack, target, sAtk);
            }
        }
        if (attack.hasHits()) {
            this.broadcastPacket(attack);
        }
    }

    private void doAttackHitSimple(AttackPacket attack, Creature target, int sAtk) {
        int attackcountmax = (int)Math.round(this.getStat().calc(Stats.ATTACK_TARGETS_COUNT, 0.0, target, null));
        if (attackcountmax > 0 && !this.isInPeaceZone()) {
            int angle = this.getPhysicalAttackAngle();
            int range = this.getPhysicalAttackRadius();
            int attackedCount = 1;
            for (Creature t : this.getAroundCharacters(range, 200)) {
                if (attackedCount > attackcountmax) break;
                if (t == target || t.isDead() || !PositionUtils.isFacing(this, t, angle) || !t.isAutoAttackable(this) || (this.getPvpFlag() != 0 || t.getPvpFlag() != 0) && this.getPvpFlag() == 0) continue;
                this.doAttackHitSimple0(attack, t, 1.0, false, sAtk, false);
                ++attackedCount;
            }
        }
        this.doAttackHitSimple0(attack, target, 1.0, true, sAtk, true);
    }

    private void doAttackHitSimple0(AttackPacket attack, Creature target, double multiplier, boolean unchargeSS, int sAtk, boolean notify) {
        Formulas.AttackInfo info;
        int damage1 = 0;
        boolean shld1 = false;
        boolean crit1 = false;
        boolean miss1 = Formulas.calcHitMiss(this, target);
        if (!miss1 && (info = Formulas.calcAutoAttackDamage(this, target, 1.0, false, attack._soulshot, true)) != null) {
            damage1 = (int)(info.damage * multiplier);
            shld1 = info.shld;
            crit1 = info.crit;
        }
        int timeToHit = Formulas.calculateTimeToHit(sAtk, this.getBaseStats().getAttackType(), false);
        ThreadPoolManager.getInstance().schedule(new GameObjectTasks.HitTask(this, target, damage1, crit1, miss1, attack._soulshot, shld1, unchargeSS, notify, sAtk), timeToHit);
        attack.addHit(target, damage1, miss1, crit1, shld1);
    }

    private void doAttackHitByBow(AttackPacket attack, Creature target, int sAtk) {
        Formulas.AttackInfo info;
        int damage1 = 0;
        boolean shld1 = false;
        boolean crit1 = false;
        boolean miss1 = Formulas.calcHitMiss(this, target);
        this.reduceArrowCount();
        if (!miss1 && (info = Formulas.calcAutoAttackDamage(this, target, 1.0, true, attack._soulshot, true)) != null) {
            damage1 = (int)info.damage;
            shld1 = info.shld;
            crit1 = info.crit;
        }
        int timeToHit = Formulas.calculateTimeToHit(sAtk, this.getBaseStats().getAttackType(), false);
        ThreadPoolManager.getInstance().schedule(new GameObjectTasks.HitTask(this, target, damage1, crit1, miss1, attack._soulshot, shld1, true, true, sAtk), timeToHit);
        attack.addHit(target, damage1, miss1, crit1, shld1);
    }

    private void doAttackHitByDual(AttackPacket attack, Creature target, int sAtk) {
        Formulas.AttackInfo info;
        int damage1 = 0;
        int damage2 = 0;
        boolean shld1 = false;
        boolean shld2 = false;
        boolean crit1 = false;
        boolean crit2 = false;
        boolean miss1 = Formulas.calcHitMiss(this, target);
        boolean miss2 = Formulas.calcHitMiss(this, target);
        if (!miss1 && (info = Formulas.calcAutoAttackDamage(this, target, 0.5, false, attack._soulshot, true)) != null) {
            damage1 = (int)info.damage;
            shld1 = info.shld;
            crit1 = info.crit;
        }
        if (!miss2 && (info = Formulas.calcAutoAttackDamage(this, target, 0.5, false, attack._soulshot, true)) != null) {
            damage2 = (int)info.damage;
            shld2 = info.shld;
            crit2 = info.crit;
        }
        int timeToHit = Formulas.calculateTimeToHit(sAtk, this.getBaseStats().getAttackType(), false);
        ThreadPoolManager.getInstance().schedule(new GameObjectTasks.HitTask(this, target, damage1, crit1, miss1, attack._soulshot, shld1, true, false, sAtk / 2), timeToHit);
        timeToHit = Formulas.calculateTimeToHit(sAtk, this.getBaseStats().getAttackType(), true);
        ThreadPoolManager.getInstance().schedule(new GameObjectTasks.HitTask(this, target, damage2, crit2, miss2, attack._soulshot, shld2, false, true, sAtk), timeToHit);
        attack.addHit(target, damage1, miss1, crit1, shld1);
        attack.addHit(target, damage2, miss2, crit2, shld2);
    }

    private void doAttackHitByPole(AttackPacket attack, Creature target, int sAtk) {
        int attackcountmax = (int)Math.round(this.getStat().calc(Stats.POLE_TARGET_COUNT, 0.0, target, null));
        attackcountmax += (int)Math.round(this.getStat().calc(Stats.ATTACK_TARGETS_COUNT, 0.0, target, null));
        if (this.isBoss()) {
            attackcountmax += 27;
        } else if (this.isRaid()) {
            attackcountmax += 12;
        } else if (this.isMonster()) {
            attackcountmax = (int)((double)attackcountmax + (double)this.getLevel() / 7.5);
        }
        if (attackcountmax > 0 && !this.isInPeaceZone()) {
            int angle = (int)this.getStat().calc(Stats.POLE_ATTACK_ANGLE, this.getPhysicalAttackAngle(), target, null);
            int range = this.getPhysicalAttackRange() + this.getPhysicalAttackRadius();
            double mult = 1.0;
            this._poleAttackCount = 1;
            for (Creature t : this.getAroundCharacters(range, 200)) {
                if (this._poleAttackCount > attackcountmax) break;
                if (t == target || t.isDead() || !PositionUtils.isFacing(this, t, angle) || !t.isAutoAttackable(this) || (this.getPvpFlag() != 0 || t.getPvpFlag() != 0) && this.getPvpFlag() == 0) continue;
                this.doAttackHitSimple0(attack, t, mult, false, sAtk, false);
                mult *= Config.ALT_POLE_DAMAGE_MODIFIER;
                ++this._poleAttackCount;
            }
            this._poleAttackCount = 0;
        }
        this.doAttackHitSimple0(attack, target, 1.0, true, sAtk, true);
    }

    public boolean doCast(SkillEntry skillEntry, Creature target, boolean forceUse) {
        if (this.getSkillCast(SkillCastingType.NORMAL).doCast(skillEntry, target, forceUse)) {
            return true;
        }
        return this.getSkillCast(SkillCastingType.NORMAL_SECOND).doCast(skillEntry, target, forceUse);
    }

    public Location getFlyLocation(GameObject target, Skill skill) {
        if (target != null && target != this) {
            double radian;
            int heading = target.getHeading();
            if (!skill.isFlyDependsOnHeading()) {
                heading = PositionUtils.calculateHeadingFrom(target, this);
            }
            if ((radian = PositionUtils.convertHeadingToDegree(heading) + (double)skill.getFlyPositionDegree()) > 360.0) {
                radian -= 360.0;
            }
            radian = Math.PI * radian / 180.0;
            Location loc = new Location(target.getX() + (int)(Math.cos(radian) * 40.0), target.getY() + (int)(Math.sin(radian) * 40.0), target.getZ());
            if (this.isFlying()) {
                if (this.isInFlyingTransform() && (loc.z <= 0 || loc.z >= 6000)) {
                    return null;
                }
                if (GeoEngine.moveCheckInAir(this, loc.x, loc.y, loc.z) == null) {
                    return null;
                }
            } else {
                loc.correctGeoZ(this.getGeoIndex());
                if (!GeoEngine.canMoveToCoord(this.getX(), this.getY(), this.getZ(), loc.x, loc.y, loc.z, this.getGeoIndex())) {
                    loc = target.getLoc();
                    if (!GeoEngine.canMoveToCoord(this.getX(), this.getY(), this.getZ(), loc.x, loc.y, loc.z, this.getGeoIndex())) {
                        return null;
                    }
                }
            }
            return loc;
        }
        int x1 = 0;
        int y1 = 0;
        int z1 = 0;
        if (skill.getFlyType() == FlyToLocationPacket.FlyType.THROW_UP) {
            x1 = 0;
            y1 = 0;
            z1 = this.getZ() + skill.getFlyRadius();
        } else {
            double radian = PositionUtils.convertHeadingToRadian(this.getHeading());
            x1 = -((int)(Math.sin(radian) * (double)skill.getFlyRadius()));
            y1 = (int)(Math.cos(radian) * (double)skill.getFlyRadius());
        }
        if (this.isFlying()) {
            return GeoEngine.moveCheckInAir(this, this.getX() + x1, this.getY() + y1, this.getZ() + z1);
        }
        return GeoEngine.moveCheck(this.getX(), this.getY(), this.getZ(), this.getX() + x1, this.getY() + y1, this.getGeoIndex());
    }

    public final void doDie(Creature killer) {
        if (!this.isDead.compareAndSet(false, true)) {
            return;
        }
        this.onDeath(killer);
    }

    protected void onDeath(Creature killer) {
        if (killer != null) {
            Player killerPlayer = killer.getPlayer();
            if (killerPlayer != null) {
                killerPlayer.getListeners().onKillIgnorePetOrSummon(this);
            }
            killer.getListeners().onKill(this);
            if (this.isPlayer() && killer.isPlayable()) {
                this._currentCp = 0.0;
            }
        }
        this.setTarget(null);
        this.abortCast(true, false);
        this.abortAttack(true, false);
        this.getMovement().stopMove();
        this.stopAttackStanceTask();
        this.stopRegeneration();
        this._currentHp = 0.0;
        if (this.isPlayable()) {
            TIntHashSet effectsToRemove = new TIntHashSet();
            if (this.isPreserveAbnormal() || this.isSalvation()) {
                if (this.isSalvation() && this.isPlayer() && !this.getPlayer().isInOlympiadMode()) {
                    this.getPlayer().reviveRequest(this.getPlayer(), 100.0, false);
                }
                for (Abnormal abnormal : this.getAbnormalList()) {
                    int skillId = abnormal.getId();
                    if (skillId == 2168) {
                        effectsToRemove.add(skillId);
                        continue;
                    }
                    for (EffectHandler effect : abnormal.getEffects()) {
                        if (effect.getName().equalsIgnoreCase("p_preserve_abnormal")) {
                            effectsToRemove.add(skillId);
                            continue;
                        }
                        if (!effect.getName().equalsIgnoreCase("AgathionResurrect")) continue;
                        if (this.isPlayer()) {
                            this.getPlayer().setAgathionRes(true);
                        }
                        effectsToRemove.add(skillId);
                    }
                }
            } else {
                for (Abnormal abnormal : this.getAbnormalList()) {
                    if (abnormal.getSkill().isPreservedOnDeath()) continue;
                    effectsToRemove.add(abnormal.getSkill().getId());
                }
                this.deleteCubics();
            }
            this.getAbnormalList().stop((TIntSet)effectsToRemove);
        }
        if (this.isPlayer()) {
            this.getPlayer().sendUserInfo(true);
        }
        this.broadcastStatusUpdate();
        ThreadPoolManager.getInstance().execute(new GameObjectTasks.NotifyAITask(this, CtrlEvent.EVT_DEAD, killer, null, null));
        if (killer != null) {
            killer.useTriggers(this, TriggerType.ON_KILL, null, null, 0.0);
        }
        this.getListeners().onDeath(killer);
    }

    protected void onRevive() {
        this.useTriggers(this, TriggerType.ON_REVIVE, null, null, 0.0);
    }

    public void enableSkill(Skill skill) {
        this._skillReuses.remove(skill.getReuseHash());
    }

    public Set<AbnormalEffect> getAbnormalEffects() {
        return this._abnormalEffects;
    }

    public AbnormalEffect[] getAbnormalEffectsArray() {
        return this._abnormalEffects.toArray(new AbnormalEffect[this._abnormalEffects.size()]);
    }

    public int getPAccuracy() {
        return (int)Math.round(this.getStat().calc(Stats.P_ACCURACY_COMBAT, 0.0, null, null));
    }

    public int getMAccuracy() {
        return (int)this.getStat().calc(Stats.M_ACCURACY_COMBAT, 0.0, null, null);
    }

    public Collection<SkillEntry> getAllSkills() {
        return this._skills.valueCollection();
    }

    public final SkillEntry[] getAllSkillsArray() {
        return (SkillEntry[])this._skills.values(new SkillEntry[this._skills.size()]);
    }

    public final double getAttackSpeedMultiplier() {
        return 1.1 * (double)this.getPAtkSpd() / this.getBaseStats().getPAtkSpd();
    }

    public int getBuffLimit() {
        return (int)this.getStat().calc(Stats.BUFF_LIMIT, Config.ALT_BUFF_LIMIT, null, null);
    }

    public int getPCriticalHit(Creature target) {
        return (int)Math.round(this.getStat().calc(Stats.BASE_P_CRITICAL_RATE, this.getBaseStats().getPCritRate(), target, null));
    }

    public int getMCriticalHit(Creature target, Skill skill) {
        return (int)Math.round(this.getStat().calc(Stats.BASE_M_CRITICAL_RATE, this.getBaseStats().getMCritRate(), target, skill));
    }

    public double getCurrentCp() {
        return this._currentCp;
    }

    public final double getCurrentCpRatio() {
        return this.getCurrentCp() / (double)this.getMaxCp();
    }

    public final double getCurrentCpPercents() {
        return this.getCurrentCpRatio() * 100.0;
    }

    public final boolean isCurrentCpFull() {
        return this.getCurrentCp() >= (double)this.getMaxCp();
    }

    public final boolean isCurrentCpZero() {
        return this.getCurrentCp() < 1.0;
    }

    public double getCurrentHp() {
        return this._currentHp;
    }

    public final double getCurrentHpRatio() {
        return this.getCurrentHp() / (double)this.getMaxHp();
    }

    public final double getCurrentHpPercents() {
        return this.getCurrentHpRatio() * 100.0;
    }

    public final boolean isCurrentHpFull() {
        return this.getCurrentHp() >= (double)this.getMaxHp();
    }

    public final boolean isCurrentHpZero() {
        return this.getCurrentHp() < 1.0;
    }

    public double getCurrentMp() {
        return this._currentMp;
    }

    public final double getCurrentMpRatio() {
        return this.getCurrentMp() / (double)this.getMaxMp();
    }

    public final double getCurrentMpPercents() {
        return this.getCurrentMpRatio() * 100.0;
    }

    public final boolean isCurrentMpFull() {
        return this.getCurrentMp() >= (double)this.getMaxMp();
    }

    public final boolean isCurrentMpZero() {
        return this.getCurrentMp() < 1.0;
    }

    public int getINT() {
        return (int)this.getStat().calc(Stats.STAT_INT, this.getBaseStats().getINT(), null, null);
    }

    public int getSTR() {
        return (int)this.getStat().calc(Stats.STAT_STR, this.getBaseStats().getSTR(), null, null);
    }

    public int getCON() {
        return (int)this.getStat().calc(Stats.STAT_CON, this.getBaseStats().getCON(), null, null);
    }

    public int getMEN() {
        return (int)this.getStat().calc(Stats.STAT_MEN, this.getBaseStats().getMEN(), null, null);
    }

    public int getDEX() {
        return (int)this.getStat().calc(Stats.STAT_DEX, this.getBaseStats().getDEX(), null, null);
    }

    public int getWIT() {
        return (int)this.getStat().calc(Stats.STAT_WIT, this.getBaseStats().getWIT(), null, null);
    }

    public int getPEvasionRate(Creature target) {
        return (int)Math.round(this.getStat().calc(Stats.P_EVASION_RATE, 0.0, target, null));
    }

    public int getMEvasionRate(Creature target) {
        return (int)this.getStat().calc(Stats.M_EVASION_RATE, 0.0, target, null);
    }

    public List<Creature> getAroundCharacters(int radius, int height) {
        if (!this.isVisible()) {
            return Collections.emptyList();
        }
        return World.getAroundCharacters(this, radius, height);
    }

    public List<NpcInstance> getAroundNpc(int range, int height) {
        if (!this.isVisible()) {
            return Collections.emptyList();
        }
        return World.getAroundNpc(this, range, height);
    }

    public boolean knowsObject(GameObject obj) {
        return World.getAroundObjectById(this, obj.getObjectId()) != null;
    }

    public final SkillEntry getKnownSkill(int skillId) {
        return (SkillEntry)this._skills.get(skillId);
    }

    public final int getMagicalAttackRange(Skill skill) {
        if (skill != null) {
            return (int)this.getStat().calc(Stats.MAGIC_ATTACK_RANGE, skill.getCastRange(), null, skill);
        }
        return this.getBaseStats().getAtkRange();
    }

    public int getMAtk(Creature target, Skill skill) {
        if (skill != null && skill.getMatak() > 0) {
            return skill.getMatak();
        }
        return (int)Math.round(this.getStat().calc(Stats.MAGIC_ATTACK, this.getBaseStats().getMAtk(), target, skill));
    }

    public int getMAtkSpd() {
        return (int)this.getStat().calc(Stats.MAGIC_ATTACK_SPEED, this.getBaseStats().getMAtkSpd(), null, null);
    }

    public int getMaxCp() {
        return Math.max(1, (int)this.getStat().calc(Stats.MAX_CP, this.getBaseStats().getCpMax(), null, null));
    }

    public int getMaxHp() {
        return Math.max(1, (int)this.getStat().calc(Stats.MAX_HP, this.getBaseStats().getHpMax(), null, null));
    }

    public int getMaxMp() {
        return Math.max(1, (int)this.getStat().calc(Stats.MAX_MP, this.getBaseStats().getMpMax(), null, null));
    }

    public int getMDef(Creature target, Skill skill) {
        double mDef = this.getStat().calc(Stats.MAGIC_DEFENCE, this.getBaseStats().getMDef(), target, skill);
        return (int)Math.max(mDef, this.getBaseStats().getMDef() / 2.0);
    }

    public double getMinDistance(GameObject obj) {
        double distance = this.getCurrentCollisionRadius();
        if (obj != null && obj.isCreature()) {
            distance += ((Creature)obj).getCurrentCollisionRadius();
        }
        return distance;
    }

    @Override
    public String getName() {
        return StringUtils.defaultString((String)this._name);
    }

    public String getVisibleName(Player receiver) {
        return this.getName();
    }

    public int getPAtk(Creature target) {
        return (int)this.getStat().calc(Stats.POWER_ATTACK, this.getBaseStats().getPAtk(), target, null);
    }

    public int getPAtkSpd() {
        return (int)this.getStat().calc(Stats.POWER_ATTACK_SPEED, this.getBaseStats().getPAtkSpd(), null, null);
    }

    public int getPDef(Creature target) {
        double pDef = this.getStat().calc(Stats.POWER_DEFENCE, this.getBaseStats().getPDef(), target, null);
        return (int)Math.max(pDef, this.getBaseStats().getPDef() / 2.0);
    }

    public int getPhysicalAttackRange() {
        return (int)this.getStat().calc(Stats.POWER_ATTACK_RANGE, this.getBaseStats().getAtkRange());
    }

    public int getPhysicalAttackRadius() {
        return (int)this.getStat().calc(Stats.P_ATTACK_RADIUS, this.getBaseStats().getAttackRadius());
    }

    public int getPhysicalAttackAngle() {
        return this.getBaseStats().getAttackAngle();
    }

    public int getRandomDamage() {
        WeaponTemplate weaponItem = this.getActiveWeaponTemplate();
        if (weaponItem == null) {
            return this.getBaseStats().getRandDam();
        }
        return weaponItem.getRandomDamage();
    }

    public double getReuseModifier(Creature target) {
        return this.getStat().calc(Stats.ATK_REUSE, 1.0, target, null);
    }

    public final int getShldDef() {
        return (int)this.getStat().calc(Stats.SHIELD_DEFENCE, this.getBaseStats().getShldDef(), null, null);
    }

    public double getPhysicalAbnormalResist() {
        return this.getStat().calc(Stats.PHYSICAL_ABNORMAL_RESIST, this.getBaseStats().getPhysicalAbnormalResist());
    }

    public double getMagicAbnormalResist() {
        return this.getStat().calc(Stats.MAGIC_ABNORMAL_RESIST, this.getBaseStats().getMagicAbnormalResist());
    }

    public int getSkillLevel(int skillId) {
        return this.getSkillLevel(skillId, -1);
    }

    public final int getSkillLevel(int skillId, int def) {
        SkillEntry skill = (SkillEntry)this._skills.get(skillId);
        if (skill == null) {
            return def;
        }
        return skill.getLevel();
    }

    public GameObject getTarget() {
        return (GameObject)this._target.get();
    }

    public final int getTargetId() {
        GameObject target = this.getTarget();
        return target == null ? -1 : target.getObjectId();
    }

    public CreatureTemplate getTemplate() {
        return this._template;
    }

    protected void setTemplate(CreatureTemplate template) {
        this._template = template;
    }

    public String getTitle() {
        return StringUtils.defaultString((String)this._title);
    }

    public String getVisibleTitle(Player receiver) {
        return this.getTitle();
    }

    public double headingToRadians(int heading) {
        return (double)(heading - 32768) / 10430.378350470453;
    }

    public final boolean isAlikeDead() {
        return this._fakeDeath || this.isDead();
    }

    public final boolean isAttackingNow() {
        return this._attackEndTime > System.currentTimeMillis();
    }

    public final long getLastAttackTime() {
        return this._lastAttackTime;
    }

    public final void setLastAttackTime(long value) {
        this._lastAttackTime = value;
    }

    public final boolean isPreserveAbnormal() {
        return this._isPreserveAbnormal;
    }

    public final boolean isSalvation() {
        return this._isSalvation;
    }

    public boolean isEffectImmune(Creature effector) {
        Creature exception = (Creature)this._effectImmunityException.get();
        if (exception != null && exception == effector) {
            return false;
        }
        return this.getFlags().getEffectImmunity().get();
    }

    public boolean isBuffImmune() {
        return this.getFlags().getBuffImmunity().get();
    }

    public boolean isDebuffImmune() {
        return this.getFlags().getDebuffImmunity().get() || this.isPeaceNpc();
    }

    public boolean isDead() {
        return this._currentHp < 0.5 || this.isDead.get();
    }

    @Override
    public boolean isFlying() {
        return this._flying;
    }

    public final boolean isInCombat() {
        return System.currentTimeMillis() < this._stanceEndTime;
    }

    public boolean isMageClass() {
        return this.getBaseStats().getMAtk() > 3.0;
    }

    public final boolean isRunning() {
        return this._running;
    }

    public boolean isSkillDisabled(Skill skill) {
        TimeStamp sts = (TimeStamp)this._skillReuses.get(skill.getReuseHash());
        if (sts == null) {
            return false;
        }
        if (sts.hasNotPassed()) {
            return true;
        }
        this._skillReuses.remove(skill.getReuseHash());
        return false;
    }

    public final boolean isTeleporting() {
        return this.isTeleporting.get();
    }

    public void broadcastMove() {
        this.broadcastPacket(this.movePacket());
    }

    public void broadcastStopMove() {
        this.broadcastPacket(this.stopMovePacket());
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public int[] getWaterZ() {
        int[] waterZ = new int[]{Integer.MIN_VALUE, Integer.MAX_VALUE};
        if (!this.isInWater()) {
            return waterZ;
        }
        this.zonesRead.lock();
        try {
            for (int i = 0; i < this._zones.size(); ++i) {
                Zone zone = this._zones.get(i);
                if (zone.getType() != Zone.ZoneType.water) continue;
                if (waterZ[0] == Integer.MIN_VALUE || waterZ[0] > zone.getTerritory().getZmin()) {
                    waterZ[0] = zone.getTerritory().getZmin();
                }
                if (waterZ[1] != Integer.MAX_VALUE && waterZ[1] >= zone.getTerritory().getZmax()) continue;
                waterZ[1] = zone.getTerritory().getZmax();
            }
        }
        finally {
            this.zonesRead.unlock();
        }
        return waterZ;
    }

    protected L2GameServerPacket stopMovePacket() {
        return new StopMovePacket(this);
    }

    public L2GameServerPacket movePacket() {
        Creature target;
        if (this.getMovement().isFollow() && !this.getMovement().isPathfindMoving() && (target = this.getMovement().getFollowTarget()) != null) {
            return new MoveToPawnPacket(this, target, this.getMovement().getMoveOffset());
        }
        return new MTLPacket(this);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void updateZones() {
        if (this.isTeleporting()) {
            return;
        }
        Zone[] zones = this.isVisible() ? this.getCurrentRegion().getZones() : Zone.EMPTY_L2ZONE_ARRAY;
        LazyArrayList entering = null;
        LazyArrayList leaving = null;
        this.zonesWrite.lock();
        try {
            Zone zone;
            int i;
            if (!this._zones.isEmpty()) {
                leaving = LazyArrayList.newInstance();
                for (i = 0; i < this._zones.size(); ++i) {
                    zone = this._zones.get(i);
                    if (ArrayUtils.contains((Object[])zones, (Object)zone) && zone.checkIfInZone(this.getX(), this.getY(), this.getZ(), this.getReflection())) continue;
                    leaving.add(zone);
                }
                if (!leaving.isEmpty()) {
                    for (i = 0; i < leaving.size(); ++i) {
                        zone = (Zone)leaving.get(i);
                        this._zones.remove(zone);
                    }
                }
            }
            if (zones.length > 0) {
                entering = LazyArrayList.newInstance();
                for (i = 0; i < zones.length; ++i) {
                    zone = zones[i];
                    if (this._zones.contains(zone) || !zone.checkIfInZone(this.getX(), this.getY(), this.getZ(), this.getReflection())) continue;
                    entering.add(zone);
                }
                if (!entering.isEmpty()) {
                    for (i = 0; i < entering.size(); ++i) {
                        zone = (Zone)entering.get(i);
                        this._zones.add(zone);
                    }
                }
            }
        }
        finally {
            this.zonesWrite.unlock();
        }
        this.onUpdateZones((List<Zone>)leaving, (List<Zone>)entering);
        if (leaving != null) {
            LazyArrayList.recycle((LazyArrayList)leaving);
        }
        if (entering != null) {
            LazyArrayList.recycle((LazyArrayList)entering);
        }
    }

    protected void onUpdateZones(List<Zone> leaving, List<Zone> entering) {
        Zone zone;
        int i;
        if (leaving != null && !leaving.isEmpty()) {
            for (i = 0; i < leaving.size(); ++i) {
                zone = leaving.get(i);
                zone.doLeave(this);
            }
        }
        if (entering != null && !entering.isEmpty()) {
            for (i = 0; i < entering.size(); ++i) {
                zone = entering.get(i);
                zone.doEnter(this);
            }
        }
    }

    public boolean isInPeaceZone() {
        return this.isInZone(Zone.ZoneType.peace_zone) && !this.isInZoneBattle();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean isHaveZoneParam(String param) {
        this.zonesRead.lock();
        try {
            for (Zone zone : this._zones) {
                if (!zone.getTemplate().getParams().getBool(param, false)) continue;
                boolean bl = true;
                return bl;
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            this.zonesRead.unlock();
        }
        return false;
    }

    public boolean isInZoneBattle() {
        for (Event event : this.getEvents()) {
            Boolean result = event.isInZoneBattle(this);
            if (result == null) continue;
            return result;
        }
        return this.isInZone(Zone.ZoneType.battle_zone);
    }

    @Override
    public boolean isInWater() {
        return this.isInZone(Zone.ZoneType.water) && !this.isInBoat() && !this.isBoat() && !this.isFlying();
    }

    public boolean isInSiegeZone() {
        return this.isInZone(Zone.ZoneType.SIEGE);
    }

    public boolean isInSSQZone() {
        return this.isInZone(Zone.ZoneType.ssq_zone);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean isInDangerArea() {
        this.zonesRead.lock();
        try {
            for (int i = 0; i < this._zones.size(); ++i) {
                Zone zone = this._zones.get(i);
                if (!zone.getTemplate().isShowDangerzone()) continue;
                boolean bl = true;
                return bl;
            }
        }
        finally {
            this.zonesRead.unlock();
        }
        return false;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean isInZone(Zone.ZoneType type) {
        this.zonesRead.lock();
        try {
            for (int i = 0; i < this._zones.size(); ++i) {
                Zone zone = this._zones.get(i);
                if (zone.getType() != type) continue;
                boolean bl = true;
                return bl;
            }
        }
        finally {
            this.zonesRead.unlock();
        }
        return false;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public List<Event> getZoneEvents() {
        List<Event> e = Collections.emptyList();
        this.zonesRead.lock();
        try {
            for (int i = 0; i < this._zones.size(); ++i) {
                Zone zone = this._zones.get(i);
                if (zone.getEvents().isEmpty()) continue;
                if (e.isEmpty()) {
                    e = new ArrayList<Event>(2);
                }
                e.addAll(zone.getEvents());
            }
        }
        finally {
            this.zonesRead.unlock();
        }
        return e;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean isInZone(String name) {
        this.zonesRead.lock();
        try {
            for (int i = 0; i < this._zones.size(); ++i) {
                Zone zone = this._zones.get(i);
                if (!zone.getName().equals(name)) continue;
                boolean bl = true;
                return bl;
            }
        }
        finally {
            this.zonesRead.unlock();
        }
        return false;
    }

    public boolean isInZone(Zone zone) {
        this.zonesRead.lock();
        try {
            boolean bl = this._zones.contains(zone);
            return bl;
        }
        finally {
            this.zonesRead.unlock();
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public Zone getZone(Zone.ZoneType type) {
        this.zonesRead.lock();
        try {
            for (int i = 0; i < this._zones.size(); ++i) {
                Zone zone = this._zones.get(i);
                if (zone.getType() != type) continue;
                Zone zone2 = zone;
                return zone2;
            }
        }
        finally {
            this.zonesRead.unlock();
        }
        return null;
    }

    public List<Zone> getZones() {
        return this._zones;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public Location getRestartPoint() {
        this.zonesRead.lock();
        try {
            for (int i = 0; i < this._zones.size(); ++i) {
                Zone.ZoneType type;
                Zone zone = this._zones.get(i);
                if (zone.getRestartPoints() == null || (type = zone.getType()) != Zone.ZoneType.battle_zone && type != Zone.ZoneType.peace_zone && type != Zone.ZoneType.offshore && type != Zone.ZoneType.dummy) continue;
                Location location = zone.getSpawn();
                return location;
            }
        }
        finally {
            this.zonesRead.unlock();
        }
        return null;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public Location getPKRestartPoint() {
        this.zonesRead.lock();
        try {
            for (int i = 0; i < this._zones.size(); ++i) {
                Zone.ZoneType type;
                Zone zone = this._zones.get(i);
                if (zone.getRestartPoints() == null || (type = zone.getType()) != Zone.ZoneType.battle_zone && type != Zone.ZoneType.peace_zone && type != Zone.ZoneType.offshore && type != Zone.ZoneType.dummy) continue;
                Location location = zone.getPKSpawn();
                return location;
            }
        }
        finally {
            this.zonesRead.unlock();
        }
        return null;
    }

    @Override
    public int getGeoZ(int x, int y, int z) {
        if (this.isFlying() || this.isInWater() || this.isInBoat() || this.isBoat() || this.isDoor()) {
            return z;
        }
        return super.getGeoZ(x, y, z);
    }

    protected boolean needStatusUpdate() {
        if (!this.isVisible()) {
            return false;
        }
        boolean result = false;
        int bar = (int)(this.getCurrentHp() * 352.0 / (double)this.getMaxHp());
        if (bar == 0 || bar != this._lastHpBarUpdate) {
            this._lastHpBarUpdate = bar;
            result = true;
        }
        if ((bar = (int)(this.getCurrentMp() * 352.0 / (double)this.getMaxMp())) == 0 || bar != this._lastMpBarUpdate) {
            this._lastMpBarUpdate = bar;
            result = true;
        }
        if (this.isPlayer() && ((bar = (int)(this.getCurrentCp() * 352.0 / (double)this.getMaxCp())) == 0 || bar != this._lastCpBarUpdate)) {
            this._lastCpBarUpdate = bar;
            result = true;
        }
        return result;
    }

    public void onHitTimer(Creature target, int damage, boolean crit, boolean miss, boolean soulshot, boolean shld, boolean unchargeSS) {
        if (this.isAlikeDead()) {
            this.sendActionFailed();
            return;
        }
        if (target.isDead() || !this.isInRange(target, 2000)) {
            this.sendActionFailed();
            return;
        }
        if (this.isPlayable() && target.isPlayable() && this.isInZoneBattle() != target.isInZoneBattle()) {
            Player player = this.getPlayer();
            if (player != null) {
                player.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
                player.sendActionFailed();
            }
            return;
        }
        target.getListeners().onAttackHit(this);
        ThreadPoolManager.getInstance().execute(new GameObjectTasks.NotifyAITask(this, CtrlEvent.EVT_ATTACK, target, null, damage));
        ThreadPoolManager.getInstance().execute(new GameObjectTasks.NotifyAITask(target, CtrlEvent.EVT_ATTACKED, this, null, damage));
        boolean checkPvP = this.checkPvP(target, null);
        target.reduceCurrentHp(damage, this, null, true, true, false, true, false, false, true, true, crit, miss, shld);
        if (!miss && damage > 0) {
            if (!target.isDead()) {
                if (crit) {
                    this.useTriggers(target, TriggerType.CRIT, null, null, damage);
                }
                this.useTriggers(target, TriggerType.ATTACK, null, null, damage);
                if (Formulas.calcStunBreak(crit, false, false)) {
                    target.getAbnormalList().stop(AbnormalType.STUN);
                }
                for (Abnormal abnormal : target.getAbnormalList()) {
                    double d = crit ? abnormal.getSkill().getOnCritCancelChance() : abnormal.getSkill().getOnAttackCancelChance();
                    double chance = d;
                    if (!(chance > 0.0) || !Rnd.chance((double)chance)) continue;
                    abnormal.exit();
                }
                if (Formulas.calcCastBreak(target, crit)) {
                    target.abortCast(false, true);
                }
            }
            if (soulshot && unchargeSS) {
                this.unChargeShots(false);
            }
        }
        if (miss) {
            target.useTriggers(this, TriggerType.UNDER_MISSED_ATTACK, null, null, damage);
        }
        this.startAttackStanceTask();
        if (checkPvP) {
            this.startPvPFlag(target);
        }
    }

    public void onCastEndTime(SkillEntry skillEntry, Creature aimingTarget, Set<Creature> targets, boolean success) {
        if (skillEntry == null) {
            return;
        }
        Skill skill = skillEntry.getTemplate();
        this.getAI().notifyEvent(CtrlEvent.EVT_FINISH_CASTING, skill, aimingTarget, success);
        if (success) {
            skill.onFinishCast(aimingTarget, this, targets);
            this.useTriggers(aimingTarget, TriggerType.ON_FINISH_CAST, null, skill, 0.0);
            if (this.isPlayer()) {
                for (ListenerHook hook : this.getPlayer().getListenerHooks(ListenerHookType.PLAYER_FINISH_CAST_SKILL)) {
                    hook.onPlayerFinishCastSkill(this.getPlayer(), skill.getId());
                }
                for (ListenerHook hook : ListenerHook.getGlobalListenerHooks(ListenerHookType.PLAYER_FINISH_CAST_SKILL)) {
                    hook.onPlayerFinishCastSkill(this.getPlayer(), skill.getId());
                }
            }
        }
    }

    public final void reduceCurrentHp(double damage, Creature attacker, Skill skill, boolean awake, boolean standUp, boolean directHp, boolean canReflectAndAbsorb, boolean transferDamage, boolean isDot, boolean sendReceiveMessage) {
        this.reduceCurrentHp(damage, attacker, skill, awake, standUp, directHp, canReflectAndAbsorb, transferDamage, isDot, sendReceiveMessage, false, false, false, false);
    }

    public void reduceCurrentHp(double damage, Creature attacker, Skill skill, boolean awake, boolean standUp, boolean directHp, boolean canReflectAndAbsorb, boolean transferDamage, boolean isDot, boolean sendReceiveMessage, boolean sendGiveMessage, boolean crit, boolean miss, boolean shld) {
        if (this.isImmortal()) {
            return;
        }
        if (canReflectAndAbsorb) {
            damage = Math.max(0.0, damage - this.getStat().calc(Stats.DAMAGE_BLOCK_COUNT));
        }
        boolean damaged = true;
        if (miss || damage <= 0.0) {
            damaged = false;
        }
        boolean damageBlocked = this.isDamageBlocked(attacker);
        if (attacker == null || this.isDead() || attacker.isDead() && !isDot || damageBlocked) {
            damaged = false;
        }
        if (!damaged) {
            if (attacker != this && sendGiveMessage) {
                attacker.displayGiveDamageMessage(this, skill, 0, null, 0, crit, miss, shld, damageBlocked);
            }
            return;
        }
        double reflectedDamage = 0.0;
        double transferedDamage = 0.0;
        Servitor servitorForTransfereDamage = null;
        if (canReflectAndAbsorb) {
            boolean canAbsorb = this.canAbsorb(this, attacker);
            if (canAbsorb) {
                damage = this.absorbToEffector(attacker, damage);
            }
            if ((servitorForTransfereDamage = this.getServitorForTransfereDamage(transferedDamage = this.getDamageForTransferToServitor(damage = this.reduceDamageByMp(attacker, damage)))) != null) {
                damage -= transferedDamage;
            } else {
                transferedDamage = 0.0;
            }
            reflectedDamage = this.reflectDamage(attacker, skill, damage);
            if (canAbsorb) {
                attacker.absorbDamage(this, skill, damage);
            }
        }
        double damageLimit = -1.0;
        damageLimit = skill == null ? this.getStat().calc(Stats.RECIEVE_DAMAGE_LIMIT, damage) : (skill.isMagic() ? this.getStat().calc(Stats.RECIEVE_DAMAGE_LIMIT_M_SKILL, damage) : this.getStat().calc(Stats.RECIEVE_DAMAGE_LIMIT_P_SKILL, damage));
        if (damageLimit >= 0.0 && damage > damageLimit) {
            damage = damageLimit;
        }
        this.getListeners().onCurrentHpDamage(damage, attacker, skill);
        if (attacker != this) {
            if (sendGiveMessage) {
                attacker.displayGiveDamageMessage(this, skill, (int)damage, servitorForTransfereDamage, (int)transferedDamage, crit, miss, shld, damageBlocked);
            }
            if (sendReceiveMessage) {
                this.displayReceiveDamageMessage(attacker, (int)damage);
            }
            if (!isDot) {
                this.useTriggers(attacker, TriggerType.RECEIVE_DAMAGE, null, null, damage);
            }
        }
        if (servitorForTransfereDamage != null && transferedDamage > 0.0) {
            servitorForTransfereDamage.reduceCurrentHp(transferedDamage, attacker, null, false, false, false, false, true, false, true);
        }
        this.onReduceCurrentHp(damage, attacker, skill, awake, standUp, directHp, isDot);
        if (reflectedDamage > 0.0) {
            this.displayGiveDamageMessage(attacker, skill, (int)reflectedDamage, null, 0, false, false, false, false);
            attacker.reduceCurrentHp(reflectedDamage, this, null, true, true, false, false, false, false, true);
        }
    }

    protected void onReduceCurrentHp(double damage, Creature attacker, Skill skill, boolean awake, boolean standUp, boolean directHp, boolean isDot) {
        if (awake && this.isSleeping()) {
            this.getAbnormalList().stop(AbnormalType.SLEEP);
        }
        if (attacker != this || skill != null && skill.isDebuff()) {
            TIntHashSet effectsToRemove = new TIntHashSet();
            for (Abnormal effect : this.getAbnormalList()) {
                if (!effect.getSkill().isDispelOnDamage()) continue;
                effectsToRemove.add(effect.getSkill().getId());
            }
            this.getAbnormalList().stop((TIntSet)effectsToRemove);
            if (this.isMeditated()) {
                this.getAbnormalList().stop("Meditation");
            }
            this.startAttackStanceTask();
            this.checkAndRemoveInvisible();
        }
        if (damage <= 0.0) {
            return;
        }
        if (this.getCurrentHp() - damage < 10.0 && this.getStat().calc(Stats.ShillienProtection) == 1.0) {
            this.setCurrentHp(this.getMaxHp(), false, !isDot);
            this.setCurrentCp(this.getMaxCp(), !isDot);
            if (isDot) {
                StatusUpdate su = new StatusUpdate(this, attacker, StatusUpdatePacket.UpdateType.REGEN, 9, 33);
                attacker.sendPacket((IBroadcastPacket)su);
                this.sendPacket((IBroadcastPacket)su);
                this.broadcastStatusUpdate();
                this.sendChanges();
            }
            return;
        }
        boolean isUndying = this.isUndying();
        this.setCurrentHp(Math.max(this.getCurrentHp() - damage, isDot ? 1.5 : (isUndying ? 0.5 : 0.0)), false, !isDot);
        if (isDot) {
            StatusUpdate su = new StatusUpdate(this, attacker, StatusUpdatePacket.UpdateType.REGEN, 9);
            attacker.sendPacket((IBroadcastPacket)su);
            this.sendPacket((IBroadcastPacket)su);
            this.broadcastStatusUpdate();
            this.sendChanges();
        }
        if (isUndying) {
            if (!(this.getCurrentHp() != 0.5 || this.isPlayer() && this.getPlayer().isGMUndying() || !this.getFlags().getUndying().getFlag().compareAndSet(false, true))) {
                this.getListeners().onDeathFromUndying(attacker);
            }
        } else if (this.getCurrentHp() < 0.5) {
            if (attacker != this || skill != null && skill.isDebuff()) {
                this.useTriggers(attacker, TriggerType.DIE, null, null, damage);
            }
            this.doDie(attacker);
        }
    }

    public void reduceCurrentMp(double i, Creature attacker) {
        if (attacker != null && attacker != this) {
            if (this.isSleeping()) {
                this.getAbnormalList().stop(AbnormalType.SLEEP);
            }
            if (this.isMeditated()) {
                this.getAbnormalList().stop("Meditation");
            }
        }
        if (this.isDamageBlocked(attacker) && attacker != null && attacker != this) {
            attacker.sendPacket((IBroadcastPacket)SystemMsg.THE_ATTACK_HAS_BEEN_BLOCKED);
            return;
        }
        if (attacker != null && attacker.isPlayer() && Math.abs(attacker.getLevel() - this.getLevel()) > 10) {
            if (attacker.isPK() && this.getAbnormalList().contains(5182) && !this.isInSiegeZone()) {
                return;
            }
            if (this.isPK() && attacker.getAbnormalList().contains(5182) && !attacker.isInSiegeZone()) {
                return;
            }
        }
        if ((i = this._currentMp - i) < 0.0) {
            i = 0.0;
        }
        this.setCurrentMp(i);
        if (attacker != null && attacker != this) {
            this.startAttackStanceTask();
        }
    }

    public void removeAllSkills() {
        for (SkillEntry s : this.getAllSkillsArray()) {
            this.removeSkill(s);
        }
    }

    public SkillEntry removeSkill(SkillInfo skillInfo) {
        if (skillInfo == null) {
            return null;
        }
        return this.removeSkillById(skillInfo.getId());
    }

    public SkillEntry removeSkillById(int id) {
        SkillEntry oldSkillEntry = (SkillEntry)this._skills.remove(id);
        if (oldSkillEntry != null) {
            Object args1;
            PlayableAI.AINextAction nextAction;
            Skill oldSkill = oldSkillEntry.getTemplate();
            if (oldSkill.isToggle()) {
                this.getAbnormalList().stop(oldSkill, false);
            }
            this.removeTriggers(oldSkill);
            if (oldSkill.isPassive()) {
                this.getStat().removeFuncsByOwner(oldSkill);
                for (EffectTemplate et : oldSkill.getEffectTemplates(EffectUseType.NORMAL)) {
                    this.getStat().removeFuncsByOwner(et.getHandler());
                }
            }
            if (Config.ALT_DELETE_SA_BUFFS && (oldSkill.isItemSkill() || oldSkill.isHandler())) {
                this.getAbnormalList().stop(oldSkill, false);
                for (Servitor servitor : this.getServitors()) {
                    servitor.getAbnormalList().stop(oldSkill, false);
                }
            }
            if ((nextAction = this.getAI().getNextAction()) != null && nextAction == PlayableAI.AINextAction.CAST && oldSkillEntry.equals(args1 = this.getAI().getNextActionArgs()[0])) {
                this.getAI().clearNextAction();
            }
            this.onRemoveSkill(oldSkillEntry);
        }
        return oldSkillEntry;
    }

    public void addTriggers(StatTemplate f) {
        if (f.getTriggerList().isEmpty()) {
            return;
        }
        for (TriggerInfo t : f.getTriggerList()) {
            this.addTrigger(t);
        }
    }

    public void addTrigger(TriggerInfo t) {
        Set<TriggerInfo> hs;
        if (this._triggers == null) {
            this._triggers = new ConcurrentHashMap<TriggerType, Set<TriggerInfo>>();
        }
        if ((hs = this._triggers.get(t.getType())) == null) {
            hs = new CopyOnWriteArraySet<TriggerInfo>();
            this._triggers.put(t.getType(), hs);
        }
        hs.add(t);
        if (t.getType() == TriggerType.ADD) {
            this.useTriggerSkill(this, null, t, null, 0.0);
        } else if (t.getType() == TriggerType.IDLE) {
            new RunnableTrigger(this, t).schedule();
        }
    }

    public Map<TriggerType, Set<TriggerInfo>> getTriggers() {
        return this._triggers;
    }

    public void removeTriggers(StatTemplate f) {
        if (this._triggers == null || f.getTriggerList().isEmpty()) {
            return;
        }
        for (TriggerInfo t : f.getTriggerList()) {
            this.removeTrigger(t);
        }
    }

    public void removeTrigger(TriggerInfo t) {
        if (this._triggers == null) {
            return;
        }
        Set<TriggerInfo> hs = this._triggers.get(t.getType());
        if (hs == null) {
            return;
        }
        hs.remove(t);
        if (t.cancelEffectsOnRemove()) {
            this.triggerCancelEffects(t);
        }
    }

    public void sendActionFailed() {
        this.sendPacket((IBroadcastPacket)ActionFailPacket.STATIC);
    }

    public boolean hasAI() {
        return this._ai != null;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public CharacterAI getAI() {
        if (this._ai == null) {
            Creature creature = this;
            synchronized (creature) {
                if (this._ai == null) {
                    this._ai = new CharacterAI(this);
                }
            }
        }
        return this._ai;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void setAI(CharacterAI newAI) {
        if (newAI == null) {
            return;
        }
        CharacterAI oldAI = this._ai;
        Creature creature = this;
        synchronized (creature) {
            this._ai = newAI;
        }
        if (oldAI != null && oldAI.isActive()) {
            oldAI.stopAITask();
            newAI.startAITask();
            newAI.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
        }
    }

    public final void setCurrentHp(double newHp, boolean canResurrect, boolean sendInfo) {
        int maxHp = this.getMaxHp();
        newHp = Math.min((double)maxHp, Math.max(0.0, newHp));
        if (this.isDeathImmune()) {
            newHp = Math.max(1.1, newHp);
        }
        if (this._currentHp == newHp) {
            return;
        }
        if (newHp >= 0.5 && this.isDead() && !canResurrect) {
            return;
        }
        double hpStart = this._currentHp;
        this._currentHp = newHp;
        if (this.isDead.compareAndSet(true, false)) {
            this.onRevive();
        }
        this.checkHpMessages(hpStart, this._currentHp);
        if (sendInfo) {
            this.broadcastStatusUpdate();
            this.sendChanges();
        }
        if (this._currentHp < (double)maxHp) {
            this.startRegeneration();
        }
        this.onChangeCurrentHp(hpStart, newHp);
        this.getListeners().onChangeCurrentHp(hpStart, newHp);
    }

    public final void setCurrentHp(double newHp, boolean canResurrect) {
        this.setCurrentHp(newHp, canResurrect, true);
    }

    public void onChangeCurrentHp(double oldHp, double newHp) {
    }

    public final void setCurrentMp(double newMp, boolean sendInfo) {
        int maxMp = this.getMaxMp();
        newMp = Math.min((double)maxMp, Math.max(0.0, newMp));
        if (this._currentMp == newMp) {
            return;
        }
        if (newMp >= 0.5 && this.isDead()) {
            return;
        }
        double mpStart = this._currentMp;
        this._currentMp = newMp;
        if (sendInfo) {
            this.broadcastStatusUpdate();
            this.sendChanges();
        }
        if (this._currentMp < (double)maxMp) {
            this.startRegeneration();
        }
        this.getListeners().onChangeCurrentMp(mpStart, newMp);
    }

    public final void setCurrentMp(double newMp) {
        this.setCurrentMp(newMp, true);
    }

    public final void setCurrentCp(double newCp, boolean sendInfo) {
        if (!this.isPlayer()) {
            return;
        }
        int maxCp = this.getMaxCp();
        newCp = Math.min((double)maxCp, Math.max(0.0, newCp));
        if (this._currentCp == newCp) {
            return;
        }
        if (newCp >= 0.5 && this.isDead()) {
            return;
        }
        double cpStart = this._currentCp;
        this._currentCp = newCp;
        if (sendInfo) {
            this.broadcastStatusUpdate();
            this.sendChanges();
        }
        if (this._currentCp < (double)maxCp) {
            this.startRegeneration();
        }
        this.getListeners().onChangeCurrentCp(cpStart, newCp);
    }

    public final void setCurrentCp(double newCp) {
        this.setCurrentCp(newCp, true);
    }

    public void setCurrentHpMp(double newHp, double newMp, boolean canResurrect) {
        int maxHp = this.getMaxHp();
        int maxMp = this.getMaxMp();
        newHp = Math.min((double)maxHp, Math.max(0.0, newHp));
        newMp = Math.min((double)maxMp, Math.max(0.0, newMp));
        if (this.isDeathImmune()) {
            newHp = Math.max(1.1, newHp);
        }
        if (this._currentHp == newHp && this._currentMp == newMp) {
            return;
        }
        if (newHp >= 0.5 && this.isDead() && !canResurrect) {
            return;
        }
        double hpStart = this._currentHp;
        double mpStart = this._currentMp;
        this._currentHp = newHp;
        this._currentMp = newMp;
        if (this.isDead.compareAndSet(true, false)) {
            this.onRevive();
        }
        this.checkHpMessages(hpStart, this._currentHp);
        this.broadcastStatusUpdate();
        this.sendChanges();
        if (this._currentHp < (double)maxHp || this._currentMp < (double)maxMp) {
            this.startRegeneration();
        }
        this.getListeners().onChangeCurrentHp(hpStart, newHp);
        this.getListeners().onChangeCurrentMp(mpStart, newMp);
    }

    public void setCurrentHpMp(double newHp, double newMp) {
        this.setCurrentHpMp(newHp, newMp, false);
    }

    public final void setFlying(boolean mode) {
        this._flying = mode;
    }

    @Override
    public final int getHeading() {
        return this._heading;
    }

    public final void setHeading(int heading) {
        this.setHeading(heading, false);
    }

    public final void setHeading(int heading, boolean broadcast) {
        this._heading = heading;
        if (broadcast) {
            this.broadcastPacket(new ExRotation(this.getObjectId(), heading));
        }
    }

    public final void setIsTeleporting(boolean value) {
        this.isTeleporting.compareAndSet(!value, value);
    }

    public final void setName(String name) {
        this._name = name;
    }

    public final void setRunning() {
        if (!this._running) {
            this._running = true;
            this.broadcastPacket(this.changeMovePacket());
        }
    }

    public void setAggressionTarget(Creature target) {
        this._aggressionTarget = target == null ? HardReferences.emptyRef() : target.getRef();
    }

    public Creature getAggressionTarget() {
        return (Creature)this._aggressionTarget.get();
    }

    public void setTarget(GameObject object) {
        if (object != null && !object.isVisible()) {
            object = null;
        }
        this._target = object == null ? HardReferences.emptyRef() : object.getRef();
    }

    public void setTitle(String title) {
        this._title = title;
    }

    public void setWalking() {
        if (this._running) {
            this._running = false;
            this.broadcastPacket(this.changeMovePacket());
        }
    }

    protected L2GameServerPacket changeMovePacket() {
        return new ChangeMoveTypePacket(this);
    }

    public final void startAbnormalEffect(AbnormalEffect ae) {
        if (ae == AbnormalEffect.NONE) {
            return;
        }
        this._abnormalEffects.add(ae);
        this.sendChanges();
    }

    public void startAttackStanceTask() {
        this.startAttackStanceTask0();
    }

    protected void startAttackStanceTask0() {
        if (this.isInCombat()) {
            this._stanceEndTime = System.currentTimeMillis() + 15000L;
            return;
        }
        this._stanceEndTime = System.currentTimeMillis() + 15000L;
        this.broadcastPacket(new AutoAttackStartPacket(this.getObjectId()));
        Future<?> task = this._stanceTask;
        if (task != null) {
            task.cancel(false);
        }
        this._stanceTask = LazyPrecisionTaskManager.getInstance().scheduleAtFixedRate(this._stanceTaskRunnable == null ? (this._stanceTaskRunnable = new AttackStanceTask()) : this._stanceTaskRunnable, 1000L, 1000L);
    }

    public void stopAttackStanceTask() {
        this._stanceEndTime = 0L;
        Future<?> task = this._stanceTask;
        if (task != null) {
            task.cancel(false);
            this._stanceTask = null;
            this.broadcastPacket(new AutoAttackStopPacket(this.getObjectId()));
        }
    }

    protected void stopRegeneration() {
        this.regenLock.lock();
        try {
            if (this._isRegenerating) {
                this._isRegenerating = false;
                if (this._regenTask != null) {
                    this._regenTask.cancel(false);
                    this._regenTask = null;
                }
            }
        }
        finally {
            this.regenLock.unlock();
        }
    }

    protected void startRegeneration() {
        if (!this.isVisible() || this.isDead() || this.getRegenTick() == 0L) {
            return;
        }
        if (this._isRegenerating) {
            return;
        }
        this.regenLock.lock();
        try {
            if (!this._isRegenerating) {
                this._isRegenerating = true;
                this._regenTask = RegenTaskManager.getInstance().scheduleAtFixedRate(this._regenTaskRunnable == null ? (this._regenTaskRunnable = new RegenTask()) : this._regenTaskRunnable, this.getRegenTick(), this.getRegenTick());
            }
        }
        finally {
            this.regenLock.unlock();
        }
    }

    public long getRegenTick() {
        return 3000L;
    }

    public final void stopAbnormalEffect(AbnormalEffect ae) {
        this._abnormalEffects.remove(ae);
        this.sendChanges();
    }

    public final void stopAllAbnormalEffects() {
        this._abnormalEffects.clear();
        this.sendChanges();
    }

    public void block() {
        this._blocked = true;
    }

    public void unblock() {
        this._blocked = false;
    }

    public void setDamageBlockedException(Creature exception) {
        this._damageBlockedException = exception == null ? HardReferences.emptyRef() : exception.getRef();
    }

    public void setEffectImmunityException(Creature exception) {
        this._effectImmunityException = exception == null ? HardReferences.emptyRef() : exception.getRef();
    }

    @Override
    public boolean isInvisible(GameObject observer) {
        if (observer != null && this.getObjectId() == observer.getObjectId()) {
            return false;
        }
        for (Event event : this.getEvents()) {
            Boolean result = event.isInvisible(this, observer);
            if (result == null) continue;
            return result;
        }
        return this.getFlags().getInvisible().get();
    }

    public boolean startInvisible(Object owner, boolean withServitors) {
        boolean result = owner == null ? this.getFlags().getInvisible().start() : this.getFlags().getInvisible().start(owner);
        if (result) {
            for (Player p : World.getAroundObservers(this)) {
                if (!this.isInvisible(p)) continue;
                p.sendPacket(p.removeVisibleObject(this, null));
            }
            if (withServitors) {
                for (Servitor servitor : this.getServitors()) {
                    servitor.startInvisible(owner, false);
                }
            }
        }
        return result;
    }

    public final boolean startInvisible(boolean withServitors) {
        return this.startInvisible(null, withServitors);
    }

    public boolean stopInvisible(Object owner, boolean withServitors) {
        boolean result = owner == null ? this.getFlags().getInvisible().stop() : this.getFlags().getInvisible().stop(owner);
        if (result) {
            List<Player> players = World.getAroundObservers(this);
            for (Player p : players) {
                if (!this.isVisible() || this.isInvisible(p)) continue;
                p.sendPacket(p.addVisibleObject(this, null));
            }
            if (withServitors) {
                for (Servitor servitor : this.getServitors()) {
                    servitor.stopInvisible(owner, false);
                }
            }
        }
        return result;
    }

    public final boolean stopInvisible(boolean withServitors) {
        return this.stopInvisible(null, withServitors);
    }

    public void addIgnoreSkillsEffect(EffectHandler effect, TIntSet skills) {
        this._ignoreSkillsEffects.put(effect, skills);
    }

    public boolean removeIgnoreSkillsEffect(EffectHandler effect) {
        return this._ignoreSkillsEffects.remove(effect) != null;
    }

    public boolean isIgnoredSkill(Skill skill) {
        for (TIntSet set : this._ignoreSkillsEffects.values()) {
            if (!set.contains(skill.getId())) continue;
            return true;
        }
        return false;
    }

    public boolean isUndying() {
        return this.getFlags().getUndying().get();
    }

    public boolean isInvulnerable() {
        return this.getFlags().getInvulnerable().get();
    }

    public void setFakeDeath(boolean value) {
        this._fakeDeath = value;
    }

    public void breakFakeDeath() {
        this.getAbnormalList().stop("FakeDeath");
    }

    public void setMeditated(boolean value) {
        this._meditated = value;
    }

    public final void setPreserveAbnormal(boolean value) {
        this._isPreserveAbnormal = value;
    }

    public final void setIsSalvation(boolean value) {
        this._isSalvation = value;
    }

    public void setLockedTarget(boolean value) {
        this._lockedTarget = value;
    }

    public boolean isConfused() {
        return this.getFlags().getConfused().get();
    }

    public boolean isFakeDeath() {
        return this._fakeDeath;
    }

    public boolean isAfraid() {
        return this.getFlags().getAfraid().get();
    }

    public boolean isBlocked() {
        return this._blocked;
    }

    public boolean isMuted(Skill skill) {
        if (skill == null || skill.isNotAffectedByMute()) {
            return false;
        }
        return this.isMMuted() && skill.isMagic() || this.isPMuted() && !skill.isMagic();
    }

    public boolean isPMuted() {
        return this.getFlags().getPMuted().get();
    }

    public boolean isMMuted() {
        return this.getFlags().getMuted().get();
    }

    public boolean isAMuted() {
        return this.getFlags().getAMuted().get() || this.isTransformed() && !this.getTransform().getType().isCanAttack();
    }

    public boolean isSleeping() {
        return this.getFlags().getSleeping().get();
    }

    public boolean isStunned() {
        return this.getFlags().getStunned().get();
    }

    public boolean isMeditated() {
        return this._meditated;
    }

    public boolean isWeaponEquipBlocked() {
        return this.getFlags().getWeaponEquipBlocked().get();
    }

    public boolean isParalyzed() {
        return this.getFlags().getParalyzed().get();
    }

    public boolean isFrozen() {
        return this.getFlags().getFrozen().get();
    }

    public boolean isImmobilized() {
        return this.getFlags().getImmobilized().get() || this.getRunSpeed() < 1;
    }

    public boolean isHealBlocked() {
        return this.isAlikeDead() || this.getFlags().getHealBlocked().get();
    }

    public boolean isDamageBlocked(Creature attacker) {
        if (attacker == this) {
            return false;
        }
        if (this.isInvulnerable()) {
            return true;
        }
        Creature exception = (Creature)this._damageBlockedException.get();
        if (exception != null && exception == attacker) {
            return false;
        }
        if (this.getFlags().getDamageBlocked().get()) {
            double blockRadius = this.getStat().calc(Stats.DAMAGE_BLOCK_RADIUS);
            if (blockRadius == -1.0) {
                return true;
            }
            if (attacker == null) {
                return false;
            }
            if ((double)attacker.getDistance(this) <= blockRadius) {
                return true;
            }
        }
        return false;
    }

    public boolean isDistortedSpace() {
        return this.getFlags().getDistortedSpace().get();
    }

    public boolean isCastingNow() {
        return this.getSkillCast(SkillCastingType.NORMAL).isCastingNow() || this.getSkillCast(SkillCastingType.NORMAL_SECOND).isCastingNow();
    }

    public boolean isLockedTarget() {
        return this._lockedTarget;
    }

    public boolean isMovementDisabled() {
        return this.isBlocked() || this.isImmobilized() || this.isAlikeDead() || this.isStunned() || this.isSleeping() || this.isDecontrolled() || this.isAttackingNow() || this.isCastingNow() || this.isFrozen();
    }

    public final boolean isActionsDisabled() {
        return this.isActionsDisabled(true);
    }

    public boolean isActionsDisabled(boolean withCast) {
        return this.isBlocked() || this.isAlikeDead() || this.isStunned() || this.isSleeping() || this.isDecontrolled() || this.isAttackingNow() || withCast && this.isCastingNow() || this.isFrozen();
    }

    public boolean isUseItemDisabled() {
        return this.isAlikeDead() || this.isStunned() || this.isSleeping() || this.isParalyzed() || this.isFrozen();
    }

    public final boolean isDecontrolled() {
        return this.isParalyzed() || this.isKnockDowned() || this.isKnockBacked() || this.isFlyUp();
    }

    public final boolean isAttackingDisabled() {
        return this._attackReuseEndTime > System.currentTimeMillis();
    }

    public boolean isOutOfControl() {
        return this.isBlocked() || this.isConfused() || this.isAfraid();
    }

    public void checkAndRemoveInvisible() {
        this.getAbnormalList().stop(AbnormalType.HIDE);
    }

    public void teleToLocation(ILocation loc) {
        this.teleToLocation(loc.getX(), loc.getY(), loc.getZ(), this.getReflection());
    }

    public void teleToLocation(ILocation loc, Reflection r) {
        this.teleToLocation(loc.getX(), loc.getY(), loc.getZ(), r);
    }

    public void teleToLocation(int x, int y, int z) {
        this.teleToLocation(x, y, z, this.getReflection());
    }

    public void teleToLocation(Location location, int min, int max) {
        this.teleToLocation(Location.findAroundPosition(location, min, max, 0), this.getReflection());
    }

    public void teleToLocation(int x, int y, int z, Reflection r) {
        if (!this.isTeleporting.compareAndSet(false, true)) {
            return;
        }
        if (this.isFakeDeath()) {
            this.breakFakeDeath();
        }
        this.abortCast(true, false);
        if (!this.isLockedTarget()) {
            this.setTarget(null);
        }
        this.getMovement().stopMove();
        if (!(this.isBoat() || this.isFlying() || World.isWater(new Location(x, y, z), r))) {
            z = GeoEngine.getLowerHeight(x, y, z, r.getGeoIndex());
        }
        Location loc = Location.findPointToStay(x, y, z, 0, 50, r.getGeoIndex());
        if (this.isPlayer()) {
            Player player = (Player)this;
            if (!player.isInObserverMode()) {
                this.sendPacket((IBroadcastPacket)new TeleportToLocationPacket(this, loc.x, loc.y, loc.z));
            }
            player.getListeners().onTeleport(loc.x, loc.y, loc.z, r);
            this.decayMe();
            this.setLoc(loc);
            this.setReflection(r);
            if (!player.isInObserverMode()) {
                this.sendPacket((IBroadcastPacket)new ExTeleportToLocationActivate(this, loc.x, loc.y, loc.z));
            }
            if (player.isInObserverMode() || this.isFakePlayer()) {
                this.onTeleported();
            }
        } else {
            this.broadcastPacket(new TeleportToLocationPacket(this, loc.x, loc.y, loc.z));
            World.forgetObject(this);
            this.setLoc(loc);
            this.setReflection(r);
            this.sendPacket((IBroadcastPacket)new ExTeleportToLocationActivate(this, loc.x, loc.y, loc.z));
            this.onTeleported();
        }
    }

    public boolean onTeleported() {
        if (this.isTeleporting.compareAndSet(true, false)) {
            this.updateZones();
            return true;
        }
        return false;
    }

    public void sendMessage(CustomMessage message) {
    }

    public String toString() {
        return this.getClass().getSimpleName() + "[" + this.getObjectId() + "]";
    }

    @Override
    public double getCollisionRadius() {
        return this.getBaseStats().getCollisionRadius();
    }

    @Override
    public double getCollisionHeight() {
        return this.getBaseStats().getCollisionHeight();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public AbnormalList getAbnormalList() {
        if (this._effectList == null) {
            Creature creature = this;
            synchronized (creature) {
                if (this._effectList == null) {
                    this._effectList = new AbnormalList(this);
                }
            }
        }
        return this._effectList;
    }

    public boolean paralizeOnAttack(Creature attacker) {
        int max_attacker_level = 65535;
        if (this.isNpc()) {
            NpcInstance npc = (NpcInstance)this;
            NpcInstance leader = npc.getLeader();
            if (leader != null) {
                return leader.paralizeOnAttack(attacker);
            }
            if (this.isRaid() && !this.isArenaRaid()) {
                max_attacker_level = this.getLevel() + npc.getParameter("ParalizeOnAttack", Config.RAID_MAX_LEVEL_DIFF);
            } else {
                int max_level_diff = npc.getParameter("ParalizeOnAttack", -1000);
                if (max_level_diff != -1000) {
                    max_attacker_level = this.getLevel() + max_level_diff;
                }
            }
        }
        return attacker.getLevel() > max_attacker_level;
    }

    @Override
    protected void onDelete() {
        CharacterAI ai = this.getAI();
        if (ai != null) {
            ai.stopAllTaskAndTimers();
            ai.notifyEvent(CtrlEvent.EVT_DELETE);
        }
        this.stopDeleteTask();
        GameObjectsStorage.remove(this);
        this.getAbnormalList().stopAll();
        super.onDelete();
    }

    public void addExpAndSp(long exp, long sp) {
    }

    public void broadcastCharInfo() {
    }

    public void broadcastCharInfoImpl(IUpdateTypeComponent ... components) {
    }

    public void checkHpMessages(double currentHp, double newHp) {
    }

    public boolean checkPvP(Creature target, SkillEntry skillEntry) {
        return false;
    }

    public boolean consumeItem(int itemConsumeId, long itemCount, boolean sendMessage) {
        return true;
    }

    public boolean consumeItemMp(int itemId, int mp) {
        return true;
    }

    public boolean isFearImmune() {
        return this.isPeaceNpc();
    }

    public boolean isThrowAndKnockImmune() {
        return this.isPeaceNpc();
    }

    public boolean isTransformImmune() {
        return this.isPeaceNpc();
    }

    public boolean isLethalImmune() {
        return this.isBoss() || this.isRaid();
    }

    public double getChargedSoulshotPower() {
        return 0.0;
    }

    public void setChargedSoulshotPower(double val) {
    }

    public double getChargedSpiritshotPower() {
        return 0.0;
    }

    public double getChargedSpiritshotHealBonus() {
        return 0.0;
    }

    public void setChargedSpiritshotPower(double power, int unk, double healBonus) {
    }

    public int getIncreasedForce() {
        return 0;
    }

    public int getAgathionEnergy() {
        return 0;
    }

    public void setAgathionEnergy(int val) {
    }

    public int getKarma() {
        return 0;
    }

    public boolean isPK() {
        return this.getKarma() < 0;
    }

    public double getLevelBonus() {
        return LevelBonusHolder.getInstance().getLevelBonus(this.getLevel());
    }

    public int getNpcId() {
        return 0;
    }

    public boolean isMyServitor(int objId) {
        return false;
    }

    public List<Servitor> getServitors() {
        return Collections.emptyList();
    }

    public int getPvpFlag() {
        return 0;
    }

    public void setTeam(TeamType t) {
        this._team = t;
        this.sendChanges();
    }

    public TeamType getTeam() {
        return this._team;
    }

    public boolean isUndead() {
        return false;
    }

    public boolean isParalyzeImmune() {
        return false;
    }

    public void reduceArrowCount() {
    }

    public void sendChanges() {
        this.getStatsRecorder().sendChanges();
    }

    public void sendMessage(String message) {
    }

    public void sendPacket(IBroadcastPacket mov) {
    }

    public void sendPacket(IBroadcastPacket ... mov) {
    }

    public void sendPacket(List<? extends IBroadcastPacket> mov) {
    }

    public int getMaxIncreasedForce() {
        return (int)this.getStat().calc(Stats.MAX_INCREASED_FORCE, 10.0, null, null);
    }

    public void setIncreasedForce(int i) {
    }

    public void startPvPFlag(Creature target) {
    }

    public boolean unChargeShots(boolean spirit) {
        return false;
    }

    public void updateAbnormalIcons() {
        if (Config.USER_INFO_INTERVAL == 0L) {
            if (this._updateAbnormalIconsTask != null) {
                this._updateAbnormalIconsTask.cancel(false);
                this._updateAbnormalIconsTask = null;
            }
            this.updateAbnormalIconsImpl();
            return;
        }
        if (this._updateAbnormalIconsTask != null) {
            return;
        }
        this._updateAbnormalIconsTask = ThreadPoolManager.getInstance().schedule(new UpdateAbnormalIcons(), Config.USER_INFO_INTERVAL);
    }

    public void updateAbnormalIconsImpl() {
        this.broadcastAbnormalStatus(this.getAbnormalStatusUpdate());
    }

    public ExAbnormalStatusUpdateFromTargetPacket getAbnormalStatusUpdate() {
        Abnormal[] effects = this.getAbnormalList().toArray();
        Arrays.sort(effects, AbnormalsComparator.getInstance());
        ExAbnormalStatusUpdateFromTargetPacket abnormalStatus = new ExAbnormalStatusUpdateFromTargetPacket(this.getObjectId());
        for (Abnormal effect : effects) {
            if (effect == null || effect.checkAbnormalType(AbnormalType.HP_RECOVER) || !(this.isPlayable() ? effect.getSkill().isShowPlayerAbnormal() : effect.getSkill().isShowNpcAbnormal())) continue;
            effect.addIcon(abnormalStatus);
        }
        return abnormalStatus;
    }

    public void broadcastAbnormalStatus(ExAbnormalStatusUpdateFromTargetPacket packet) {
        if (this.getTarget() == this) {
            this.sendPacket((IBroadcastPacket)packet);
        }
        if (!this.isVisible()) {
            return;
        }
        List<Player> players = World.getAroundObservers(this);
        for (int i = 0; i < players.size(); ++i) {
            Player target = players.get(i);
            if (target.getTarget() != this) continue;
            target.sendPacket((IBroadcastPacket)packet);
        }
    }

    protected void refreshHpMpCp() {
        int maxCp;
        int maxHp = this.getMaxHp();
        int maxMp = this.getMaxMp();
        int n = maxCp = this.isPlayer() ? this.getMaxCp() : 0;
        if (this._currentHp > (double)maxHp) {
            this.setCurrentHp(maxHp, false);
        }
        if (this._currentMp > (double)maxMp) {
            this.setCurrentMp(maxMp, false);
        }
        if (this._currentCp > (double)maxCp) {
            this.setCurrentCp(maxCp, false);
        }
        if (this._currentHp < (double)maxHp || this._currentMp < (double)maxMp || this._currentCp < (double)maxCp) {
            this.startRegeneration();
        }
    }

    public void updateStats() {
        this.refreshHpMpCp();
        this.sendChanges();
    }

    public void setOverhitAttacker(Creature attacker) {
    }

    public void setOverhitDamage(double damage) {
    }

    public boolean isHero() {
        return false;
    }

    public int getAccessLevel() {
        return 0;
    }

    public Clan getClan() {
        return null;
    }

    public int getFormId() {
        return 0;
    }

    public boolean isNameAbove() {
        return true;
    }

    @Override
    public boolean setLoc(ILocation loc) {
        return this.setXYZ(loc.getX(), loc.getY(), loc.getZ());
    }

    public boolean setLoc(ILocation loc, boolean stopMove) {
        return this.setXYZ(loc.getX(), loc.getY(), loc.getZ(), stopMove);
    }

    @Override
    public boolean setXYZ(int x, int y, int z) {
        return this.setXYZ(x, y, z, false);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean setXYZ(int x, int y, int z, boolean stopMove) {
        if (!stopMove) {
            this.getMovement().stopMove();
        }
        this.getMovement().getMoveLock().lock();
        try {
            if (!super.setXYZ(x, y, z)) {
                boolean bl = false;
                return bl;
            }
        }
        finally {
            this.getMovement().getMoveLock().unlock();
        }
        this.updateZones();
        return true;
    }

    @Override
    protected void onSpawn() {
        super.onSpawn();
        this.updateStats();
        this.updateZones();
    }

    @Override
    public void spawnMe(Location loc) {
        if (loc.h >= 0) {
            this.setHeading(loc.h);
        }
        super.spawnMe(loc);
    }

    @Override
    protected void onDespawn() {
        if (!this.isLockedTarget()) {
            this.setTarget(null);
        }
        this.getMovement().stopMove();
        this.stopAttackStanceTask();
        this.stopRegeneration();
        this.updateZones();
        super.onDespawn();
    }

    public final void doDecay() {
        if (!this.isDead()) {
            return;
        }
        this.onDecay();
    }

    protected void onDecay() {
        this.decayMe();
    }

    public void addUnActiveSkill(Skill skill) {
        if (skill == null || this.isUnActiveSkill(skill.getId())) {
            return;
        }
        if (skill.isToggle()) {
            this.getAbnormalList().stop(skill, false);
        }
        this.getStat().removeFuncsByOwner(skill);
        this.removeTriggers(skill);
        this._unActiveSkills.add(skill.getId());
    }

    public void removeUnActiveSkill(Skill skill) {
        if (skill == null || !this.isUnActiveSkill(skill.getId())) {
            return;
        }
        this.getStat().addFuncs(skill.getStatFuncs());
        this.addTriggers(skill);
        this._unActiveSkills.remove(skill.getId());
    }

    public boolean isUnActiveSkill(int id) {
        return this._unActiveSkills.contains(id);
    }

    public abstract int getLevel();

    public abstract ItemInstance getActiveWeaponInstance();

    public abstract WeaponTemplate getActiveWeaponTemplate();

    public abstract ItemInstance getSecondaryWeaponInstance();

    public abstract WeaponTemplate getSecondaryWeaponTemplate();

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public CharListenerList getListeners() {
        if (this.listeners == null) {
            Creature creature = this;
            synchronized (creature) {
                if (this.listeners == null) {
                    this.listeners = new CharListenerList(this);
                }
            }
        }
        return this.listeners;
    }

    public <T extends Listener<Creature>> boolean addListener(T listener) {
        return this.getListeners().add(listener);
    }

    public <T extends Listener<Creature>> boolean removeListener(T listener) {
        return this.getListeners().remove(listener);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public CharStatsChangeRecorder<? extends Creature> getStatsRecorder() {
        if (this._statsRecorder == null) {
            Creature creature = this;
            synchronized (creature) {
                if (this._statsRecorder == null) {
                    this._statsRecorder = new CharStatsChangeRecorder<Creature>(this);
                }
            }
        }
        return this._statsRecorder;
    }

    @Override
    public boolean isCreature() {
        return true;
    }

    public void displayGiveDamageMessage(Creature target, Skill skill, int damage, Servitor servitorTransferedDamage, int transferedDamage, boolean crit, boolean miss, boolean shld, boolean blocked) {
        if (miss) {
            if (target.isPlayer()) {
                target.sendPacket((IBroadcastPacket)new SystemMessage(2264).addName(target).addName(this));
            }
            return;
        }
        if (!blocked && shld && target.isPlayer()) {
            if (damage == Config.EXCELLENT_SHIELD_BLOCK_RECEIVED_DAMAGE) {
                target.sendPacket((IBroadcastPacket)SystemMsg.YOUR_EXCELLENT_SHIELD_DEFENSE_WAS_A_SUCCESS);
            } else if (damage > 0) {
                target.sendPacket((IBroadcastPacket)SystemMsg.YOUR_SHIELD_DEFENSE_HAS_SUCCEEDED);
            }
        }
    }

    public void displayReceiveDamageMessage(Creature attacker, int damage) {
    }

    public Collection<TimeStamp> getSkillReuses() {
        return this._skillReuses.valueCollection();
    }

    public TimeStamp getSkillReuse(Skill skill) {
        return (TimeStamp)this._skillReuses.get(skill.getReuseHash());
    }

    public Sex getSex() {
        return Sex.MALE;
    }

    public final boolean isInFlyingTransform() {
        if (this.isTransformed()) {
            return this.getTransform().getType() == TransformType.FLYING;
        }
        return false;
    }

    public final boolean isVisualTransformed() {
        return this.getVisualTransform() != null;
    }

    public final int getVisualTransformId() {
        if (this.getVisualTransform() != null) {
            return this.getVisualTransform().getId();
        }
        return 0;
    }

    public final TransformTemplate getVisualTransform() {
        if (this._isInTransformUpdate) {
            return null;
        }
        if (this._visualTransform != null) {
            return this._visualTransform;
        }
        return this.getTransform();
    }

    public final void setVisualTransform(int id) {
        TransformTemplate template = id > 0 ? TransformTemplateHolder.getInstance().getTemplate(this.getSex(), id) : null;
        this.setVisualTransform(template);
    }

    public void setVisualTransform(TransformTemplate template) {
        if (this._visualTransform == template) {
            return;
        }
        if (template != null && this.isVisualTransformed() || template == null && this.isTransformed()) {
            this._isInTransformUpdate = true;
            this._visualTransform = null;
            this.sendChanges();
            this._isInTransformUpdate = false;
        }
        this._visualTransform = template;
        Location destLoc = this.getLoc().correctGeoZ(this.getGeoIndex()).changeZ((this._visualTransform == null ? 0 : this._visualTransform.getSpawnHeight()) + (int)this.getCurrentCollisionHeight());
        this.sendPacket((IBroadcastPacket)new FlyToLocationPacket(this, destLoc, FlyToLocationPacket.FlyType.DUMMY, 0, 0, 0));
        this.setLoc(destLoc);
        this.sendChanges();
    }

    public boolean isTransformed() {
        return false;
    }

    public final int getTransformId() {
        if (this.isTransformed()) {
            return this.getTransform().getId();
        }
        return 0;
    }

    public TransformTemplate getTransform() {
        return null;
    }

    public void setTransform(int id) {
    }

    public void setTransform(TransformTemplate template) {
    }

    public boolean isDeathImmune() {
        return this.getFlags().getDeathImmunity().get() || this.isPeaceNpc();
    }

    public final double getMovementSpeedMultiplier() {
        return (double)this.getRunSpeed() * 1.0 / this.getBaseStats().getRunSpd();
    }

    @Override
    public int getMoveSpeed() {
        if (this.isRunning()) {
            return this.getRunSpeed();
        }
        return this.getWalkSpeed();
    }

    public int getRunSpeed() {
        if (this.isMounted()) {
            return this.getRideRunSpeed();
        }
        if (this.isFlying()) {
            return this.getFlyRunSpeed();
        }
        if (this.isInWater()) {
            return this.getSwimRunSpeed();
        }
        return this.getSpeed(this.getBaseStats().getRunSpd());
    }

    public int getWalkSpeed() {
        if (this.isMounted()) {
            return this.getRideWalkSpeed();
        }
        if (this.isFlying()) {
            return this.getFlyWalkSpeed();
        }
        if (this.isInWater()) {
            return this.getSwimWalkSpeed();
        }
        return this.getSpeed(this.getBaseStats().getWalkSpd());
    }

    public final int getSwimRunSpeed() {
        return this.getSpeed(this.getBaseStats().getWaterRunSpd());
    }

    public final int getSwimWalkSpeed() {
        return this.getSpeed(this.getBaseStats().getWaterWalkSpd());
    }

    public final int getFlyRunSpeed() {
        return this.getSpeed(this.getBaseStats().getFlyRunSpd());
    }

    public final int getFlyWalkSpeed() {
        return this.getSpeed(this.getBaseStats().getFlyWalkSpd());
    }

    public final int getRideRunSpeed() {
        return this.getSpeed(this.getBaseStats().getRideRunSpd());
    }

    public final int getRideWalkSpeed() {
        return this.getSpeed(this.getBaseStats().getRideWalkSpd());
    }

    public final double relativeSpeed(GameObject target) {
        return (double)this.getMoveSpeed() - (double)target.getMoveSpeed() * Math.cos(this.headingToRadians(this.getHeading()) - this.headingToRadians(target.getHeading()));
    }

    public final int getSpeed(double baseSpeed) {
        return (int)Math.max(1.0, this.getStat().calc(Stats.RUN_SPEED, baseSpeed, null, null));
    }

    public double getHpRegen() {
        return this.getStat().calc(Stats.REGENERATE_HP_RATE, this.getBaseStats().getHpReg());
    }

    public double getMpRegen() {
        return this.getStat().calc(Stats.REGENERATE_MP_RATE, this.getBaseStats().getMpReg());
    }

    public double getCpRegen() {
        return this.getStat().calc(Stats.REGENERATE_CP_RATE, this.getBaseStats().getCpReg());
    }

    public int getEnchantEffect() {
        return 0;
    }

    public final boolean isKnockDowned() {
        return this.getFlags().getKnockDowned().get();
    }

    public final boolean isKnockBacked() {
        return this.getFlags().getKnockBacked().get();
    }

    public final boolean isFlyUp() {
        return this.getFlags().getFlyUp().get();
    }

    public void setRndCharges(int value) {
        this._rndCharges = value;
    }

    public int getRndCharges() {
        return this._rndCharges;
    }

    public void onEvtTimer(int timerId, Object arg1, Object arg2) {
    }

    public void onEvtScriptEvent(String event, Object arg1, Object arg2) {
    }

    public boolean isPeaceNpc() {
        return false;
    }

    public int getInteractionDistance(GameObject target) {
        int range = (int)Math.max(10.0, this.getMinDistance(target));
        if (target.isNpc()) {
            Location moveLoc;
            List<Location> _moveList;
            if (!target.isInRangeZ(this, range += 100) && !GeoEngine.canMoveToCoord(this.getX(), this.getY(), this.getZ(), target.getX(), target.getY(), target.getZ(), this.getGeoIndex()) && (_moveList = GeoEngine.MoveList(this.getX(), this.getY(), this.getZ(), target.getX(), target.getY(), this.getGeoIndex(), false)) != null && !target.isInRangeZ(moveLoc = _moveList.get(_moveList.size() - 1).geo2world(), range) && target.isInRangeZ(moveLoc, range + 100)) {
                range = target.getDistance3D(moveLoc) + 16;
            }
        } else {
            range += 200;
        }
        return range;
    }

    public boolean checkInteractionDistance(GameObject target) {
        return this.isInRangeZ(target, this.getInteractionDistance(target) + 32);
    }

    public void setDualCastEnable(boolean val) {
        this._isDualCastEnable = val;
    }

    public boolean isDualCastEnable() {
        return this._isDualCastEnable;
    }

    @Override
    public boolean isTargetable(Creature creature) {
        if (creature != null) {
            if (creature == this) {
                return true;
            }
            if (creature.isPlayer() && creature.getPlayer().isGM()) {
                return true;
            }
        }
        return this._isTargetable;
    }

    public boolean isTargetable() {
        return this.isTargetable(null);
    }

    public void setTargetable(boolean value) {
        this._isTargetable = value;
    }

    private boolean checkRange(Creature caster, Creature target) {
        return caster.isInRange(target, Config.REFLECT_MIN_RANGE);
    }

    private boolean canAbsorb(Creature attacked, Creature attacker) {
        if (attacked.isPlayable() || !Config.DISABLE_VAMPIRIC_VS_MOB_ON_PVP) {
            return true;
        }
        return attacker.getPvpFlag() == 0;
    }

    public CreatureBaseStats getBaseStats() {
        if (this._baseStats == null) {
            this._baseStats = new CreatureBaseStats(this);
        }
        return this._baseStats;
    }

    public CreatureStat getStat() {
        if (this._stat == null) {
            this._stat = new CreatureStat(this);
        }
        return this._stat;
    }

    public CreatureFlags getFlags() {
        if (this._statuses == null) {
            this._statuses = new CreatureFlags(this);
        }
        return this._statuses;
    }

    public boolean isSpecialAbnormal(Skill skill) {
        return false;
    }

    public boolean isImmortal() {
        return false;
    }

    public boolean isChargeBlocked() {
        return true;
    }

    public int getAdditionalVisualSSEffect() {
        return 0;
    }

    public boolean isSymbolInstance() {
        return false;
    }

    public boolean isTargetUnderDebuff() {
        for (Abnormal effect : this.getAbnormalList()) {
            if (!effect.isOffensive()) continue;
            return true;
        }
        return false;
    }

    public boolean isSitting() {
        return false;
    }

    public void sendChannelingEffect(Creature target, int state) {
        this.broadcastPacket(new ExShowChannelingEffectPacket(this, target, state));
    }

    public void startDeleteTask(long delay) {
        this.stopDeleteTask();
        this._deleteTask = ThreadPoolManager.getInstance().schedule(new GameObjectTasks.DeleteTask(this), delay);
    }

    public void stopDeleteTask() {
        if (this._deleteTask != null) {
            this._deleteTask.cancel(false);
            this._deleteTask = null;
        }
    }

    public boolean isDeleteTaskScheduled() {
        return this._deleteTask != null;
    }

    public void deleteCubics() {
    }

    public void onZoneEnter(Zone zone) {
    }

    public void onZoneLeave(Zone zone) {
    }

    public Element getAttackElement() {
        return Formulas.getAttackElement(this, null);
    }

    public int getAttack(Element element) {
        Stats stat = element.getAttack();
        if (stat != null) {
            return (int)this.getStat().calc(stat);
        }
        return 0;
    }

    public int getDefence(Element element) {
        Stats stat = element.getDefence();
        if (stat != null) {
            return (int)this.getStat().calc(stat);
        }
        return 0;
    }

    public boolean hasBasicPropertyResist() {
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public BasicPropertyResist getBasicPropertyResist(BasicProperty basicProperty) {
        if (this._basicPropertyResists == null) {
            Creature creature = this;
            synchronized (creature) {
                if (this._basicPropertyResists == null) {
                    this._basicPropertyResists = new ConcurrentHashMap<BasicProperty, BasicPropertyResist>();
                }
            }
        }
        return this._basicPropertyResists.computeIfAbsent(basicProperty, k -> new BasicPropertyResist());
    }

    public boolean isMounted() {
        return false;
    }

    @Override
    protected Shape makeGeoShape() {
        int x = this.getX();
        int y = this.getY();
        int z = this.getZ();
        Circle circle = new Circle(x, y, (int)this.getCollisionRadius());
        circle.setZmin(z - Config.MAX_Z_DIFF);
        circle.setZmax(z + (int)this.getCollisionHeight());
        return circle;
    }

    public int getGmSpeed() {
        return this._gmSpeed;
    }

    public void setGmSpeed(int value) {
        this._gmSpeed = value;
    }

    public CreatureMovement getMovement() {
        return this._movement;
    }

    public CreatureSkillCast getSkillCast(SkillCastingType castingType) {
        CreatureSkillCast skillCast = this._skillCasts[castingType.ordinal()];
        if (skillCast == null) {
            this._skillCasts[castingType.ordinal()] = skillCast = new CreatureSkillCast(this, castingType);
        }
        return skillCast;
    }

    private class UpdateAbnormalIcons
    implements Runnable {
        private UpdateAbnormalIcons() {
        }

        @Override
        public void run() {
            Creature.this.updateAbnormalIconsImpl();
            Creature.this._updateAbnormalIconsTask = null;
        }
    }

    private class RegenTask
    implements Runnable {
        private RegenTask() {
        }

        /*
         * WARNING - Removed try catching itself - possible behaviour change.
         */
        @Override
        public void run() {
            if (Creature.this.isAlikeDead() || Creature.this.getRegenTick() == 0L) {
                return;
            }
            double hpStart = Creature.this._currentHp;
            double mpStart = Creature.this._currentMp;
            double cpStart = Creature.this._currentCp;
            int maxHp = Creature.this.getMaxHp();
            int maxMp = Creature.this.getMaxMp();
            int maxCp = Creature.this.isPlayer() ? Creature.this.getMaxCp() : 0;
            double addHp = 0.0;
            double addMp = 0.0;
            double addCp = 0.0;
            Creature.this.regenLock.lock();
            try {
                if (Creature.this._currentHp < (double)maxHp) {
                    addHp += Creature.this.getHpRegen();
                }
                if (Creature.this._currentMp < (double)maxMp) {
                    addMp += Creature.this.getMpRegen();
                }
                if (Creature.this._currentCp < (double)maxCp) {
                    addCp += Creature.this.getCpRegen();
                }
                if (Creature.this.isSitting()) {
                    if (Creature.this.isPlayer() && Config.REGEN_SIT_WAIT) {
                        Player pl = Creature.this.getPlayer();
                        pl.updateWaitSitTime();
                        if (pl.getWaitSitTime() > 5) {
                            addHp += (double)pl.getWaitSitTime();
                            addMp += (double)pl.getWaitSitTime();
                            addCp += (double)pl.getWaitSitTime();
                        }
                    } else {
                        addHp += Creature.this.getHpRegen() * 0.5;
                        addMp += Creature.this.getMpRegen() * 0.5;
                        addCp += Creature.this.getCpRegen() * 0.5;
                    }
                } else if (!Creature.this.getMovement().isMoving()) {
                    addHp += Creature.this.getHpRegen() * 0.1;
                    addMp += Creature.this.getMpRegen() * 0.1;
                    addCp += Creature.this.getCpRegen() * 0.1;
                } else if (Creature.this.isRunning()) {
                    addHp -= Creature.this.getHpRegen() * 0.3;
                    addMp -= Creature.this.getMpRegen() * 0.3;
                    addCp -= Creature.this.getCpRegen() * 0.3;
                }
                if (Creature.this.isRaid()) {
                    addHp *= Config.RATE_RAID_REGEN;
                    addMp *= Config.RATE_RAID_REGEN;
                }
                Creature.this._currentHp = Creature.this._currentHp + Math.max(0.0, Math.min(addHp, Creature.this.getStat().calc(Stats.HP_LIMIT, null, null) * (double)maxHp / 100.0 - Creature.this._currentHp));
                Creature.this._currentHp = Math.min((double)maxHp, Creature.this._currentHp);
                Creature.this._currentMp += Math.max(0.0, Math.min(addMp, Creature.this.getStat().calc(Stats.MP_LIMIT, null, null) * (double)maxMp / 100.0 - Creature.this._currentMp));
                Creature.this._currentMp = Math.min((double)maxMp, Creature.this._currentMp);
                if (Creature.this.isPlayer()) {
                    Creature.this._currentCp += Math.max(0.0, Math.min(addCp, Creature.this.getStat().calc(Stats.CP_LIMIT, null, null) * (double)maxCp / 100.0 - Creature.this._currentCp));
                    Creature.this._currentCp = Math.min((double)maxCp, Creature.this._currentCp);
                }
                if (Creature.this._currentHp == (double)maxHp && Creature.this._currentMp == (double)maxMp && Creature.this._currentCp == (double)maxCp) {
                    Creature.this.stopRegeneration();
                }
            }
            finally {
                Creature.this.regenLock.unlock();
            }
            Creature.this.getListeners().onChangeCurrentHp(hpStart, Creature.this._currentHp);
            Creature.this.getListeners().onChangeCurrentMp(mpStart, Creature.this._currentMp);
            if (Creature.this.isPlayer()) {
                Creature.this.getListeners().onChangeCurrentCp(cpStart, Creature.this._currentCp);
            }
            TIntHashSet updateAttributes = new TIntHashSet(3);
            if (addHp > 0.0 && Creature.this._currentHp != hpStart) {
                updateAttributes.add(9);
            }
            if (addMp > 0.0 && Creature.this._currentMp != mpStart) {
                updateAttributes.add(11);
            }
            if (addCp > 0.0 && Creature.this._currentCp != cpStart) {
                updateAttributes.add(33);
            }
            if (!updateAttributes.isEmpty()) {
                Creature.this.sendPacket((IBroadcastPacket)new StatusUpdate(Creature.this, StatusUpdatePacket.UpdateType.REGEN, updateAttributes.toArray()));
                Creature.this.broadcastStatusUpdate();
                Creature.this.sendChanges();
            }
            Creature.this.checkHpMessages(hpStart, Creature.this._currentHp);
        }
    }

    private class AttackStanceTask
    implements Runnable {
        private AttackStanceTask() {
        }

        @Override
        public void run() {
            if (!Creature.this.isInCombat()) {
                Creature.this.stopAttackStanceTask();
            }
        }
    }

    public class AbortCastDelayed
    implements Runnable {
        private Creature _cha;

        public AbortCastDelayed(Creature cha) {
            this._cha = cha;
        }

        @Override
        public void run() {
            if (this._cha == null) {
                return;
            }
            this._cha.abortCast(true, true);
        }
    }
}


package l2s.gameserver.model;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.lang.reflect.Constructor;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.StringTokenizer;
import l2s.commons.geometry.Polygon;
import l2s.commons.lang.ArrayUtils;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.ai.CtrlEvent;
import l2s.gameserver.data.string.SkillNameHolder;
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.World;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.model.actor.instances.creature.AbnormalList;
import l2s.gameserver.model.base.Element;
import l2s.gameserver.model.base.MountType;
import l2s.gameserver.model.base.PledgeRank;
import l2s.gameserver.model.base.TeamType;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.instances.ChestInstance;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.instances.SummonInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExMagicAttackInfo;
import l2s.gameserver.network.l2.s2c.ExShowTracePacket;
import l2s.gameserver.network.l2.s2c.FlyToLocationPacket;
import l2s.gameserver.network.l2.s2c.SystemMessage;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.AbnormalEffect;
import l2s.gameserver.skills.AbnormalType;
import l2s.gameserver.skills.BasicProperty;
import l2s.gameserver.skills.EffectTargetType;
import l2s.gameserver.skills.EffectUseType;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.skills.SkillInfo;
import l2s.gameserver.skills.SkillOperateType;
import l2s.gameserver.skills.SkillTrait;
import l2s.gameserver.skills.skillclasses.Balance;
import l2s.gameserver.skills.skillclasses.BuffCharger;
import l2s.gameserver.skills.skillclasses.CPDam;
import l2s.gameserver.skills.skillclasses.Call;
import l2s.gameserver.skills.skillclasses.ChainHeal;
import l2s.gameserver.skills.skillclasses.Charge;
import l2s.gameserver.skills.skillclasses.ClanGate;
import l2s.gameserver.skills.skillclasses.Continuous;
import l2s.gameserver.skills.skillclasses.Craft;
import l2s.gameserver.skills.skillclasses.DebuffRenewal;
import l2s.gameserver.skills.skillclasses.Decoy;
import l2s.gameserver.skills.skillclasses.Default;
import l2s.gameserver.skills.skillclasses.DefuseTrap;
import l2s.gameserver.skills.skillclasses.DestroySummon;
import l2s.gameserver.skills.skillclasses.DetectTrap;
import l2s.gameserver.skills.skillclasses.Disablers;
import l2s.gameserver.skills.skillclasses.Drain;
import l2s.gameserver.skills.skillclasses.DrainSoul;
import l2s.gameserver.skills.skillclasses.EffectsFromSkills;
import l2s.gameserver.skills.skillclasses.EnergyReplenish;
import l2s.gameserver.skills.skillclasses.ExtractStone;
import l2s.gameserver.skills.skillclasses.HideHairAccessories;
import l2s.gameserver.skills.skillclasses.LethalShot;
import l2s.gameserver.skills.skillclasses.MDam;
import l2s.gameserver.skills.skillclasses.ManaDam;
import l2s.gameserver.skills.skillclasses.PDam;
import l2s.gameserver.skills.skillclasses.PcBangPointsAdd;
import l2s.gameserver.skills.skillclasses.PetFeed;
import l2s.gameserver.skills.skillclasses.PetSummon;
import l2s.gameserver.skills.skillclasses.Recall;
import l2s.gameserver.skills.skillclasses.Replace;
import l2s.gameserver.skills.skillclasses.Restoration;
import l2s.gameserver.skills.skillclasses.Resurrect;
import l2s.gameserver.skills.skillclasses.Ride;
import l2s.gameserver.skills.skillclasses.Sacrifice;
import l2s.gameserver.skills.skillclasses.ShiftAggression;
import l2s.gameserver.skills.skillclasses.StealBuff;
import l2s.gameserver.skills.skillclasses.Summon;
import l2s.gameserver.skills.skillclasses.SummonSiegeFlag;
import l2s.gameserver.skills.skillclasses.Sweep;
import l2s.gameserver.skills.skillclasses.TakeCastle;
import l2s.gameserver.skills.skillclasses.TrapActivation;
import l2s.gameserver.skills.skillclasses.Unlock;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.Formulas;
import l2s.gameserver.stats.StatTemplate;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.stats.conditions.Condition;
import l2s.gameserver.stats.conditions.ConditionPlayerOlympiad;
import l2s.gameserver.stats.funcs.Func;
import l2s.gameserver.stats.funcs.FuncTemplate;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.skill.EffectTemplate;
import l2s.gameserver.utils.ItemFunctions;
import l2s.gameserver.utils.PositionUtils;
import org.apache.commons.lang3.builder.EqualsBuilder;
import org.apache.commons.lang3.math.NumberUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Skill
extends StatTemplate
implements SkillInfo,
Cloneable {
    protected static final Logger _log = LoggerFactory.getLogger(Skill.class);
    public static final Skill[] EMPTY_ARRAY = new Skill[0];
    public static final int SKILL_CRAFTING = 172;
    public static final int SKILL_COMMON_CRAFTING = 1320;
    public static final int SKILL_POLEARM_MASTERY = 216;
    public static final int SKILL_CRYSTALLIZE = 248;
    public static final int SKILL_WEAPON_MAGIC_MASTERY1 = 249;
    public static final int SKILL_WEAPON_MAGIC_MASTERY2 = 250;
    public static final int SKILL_BLINDING_BLOW = 321;
    public static final int SKILL_STRIDER_ASSAULT = 325;
    public static final int SKILL_WYVERN_AEGIS = 327;
    public static final int SKILL_BLUFF = 358;
    public static final int SKILL_HEROIC_MIRACLE = 395;
    public static final int SKILL_HEROIC_BERSERKER = 396;
    public static final int SKILL_TRANSFORM_DISPEL = 619;
    public static final int SKILL_FINAL_FLYING_FORM = 840;
    public static final int SKILL_AURA_BIRD_FALCON = 841;
    public static final int SKILL_AURA_BIRD_OWL = 842;
    public static final int SKILL_DETECTION = 933;
    public static final int SKILL_DETECTION2 = 10785;
    public static final int SKILL_RECHARGE = 1013;
    public static final int SKILL_TRANSFER_PAIN = 1262;
    public static final int SKILL_SUMMON_CP_POTION = 1324;
    public static final int SKILL_HEROIC_VALOR = 1374;
    public static final int SKILL_HEROIC_GRANDEUR = 1375;
    public static final int SKILL_HEROIC_DREAD = 1376;
    public static final int SKILL_MYSTIC_IMMUNITY = 1411;
    public static final int SKILL_RAID_BLESSING = 2168;
    public static final int SKILL_HINDER_STRIDER = 4258;
    public static final int SKILL_WYVERN_BREATH = 4289;
    public static final int SKILL_RAID_CURSE = 4515;
    public static final int SKILL_RAID_CURSE_2 = 4215;
    public static final int SKILL_EVENT_TIMER = 5239;
    public static final int SKILL_BATTLEFIELD_DEATH_SYNDROME = 5660;
    public static final int SKILL_SERVITOR_SHARE = 1557;
    public static final int SKILL_CONFUSION = 1570;
    private final TIntObjectMap<List<EffectTemplate>> _effectTemplates = new TIntObjectHashMap(EffectUseType.VALUES.length);
    private final AddedSkill[] _addedSkills;
    private final long _itemConsume;
    private final int _itemConsumeId;
    private final boolean _itemConsumeFromMaster;
    private final int[] _relationSkillsId;
    private final int _referenceItemId;
    private final int _referenceItemMpConsume;
    private final boolean _isBehind;
    private final boolean _isCancelable;
    private final boolean _isCorpse;
    private final boolean _isItemHandler;
    private final boolean _isDebuff;
    private final boolean _isPvpSkill;
    private final boolean _isNotUsedByAI;
    private final boolean _isPvm;
    private final boolean _isForceUse;
    private final boolean _isNewbie;
    private final boolean _isPreservedOnDeath;
    private final boolean _isSaveable;
    private final boolean _isSkillTimePermanent;
    private final boolean _isReuseDelayPermanent;
    private final boolean _isReflectable;
    private final boolean _isSuicideAttack;
    private final boolean _isShieldignore;
    private final double _shieldIgnorePercent;
    private final boolean _isUndeadOnly;
    private final Ternary _isUseSS;
    private final boolean _isOverhit;
    private final boolean _isChargeBoost;
    private final boolean _isIgnoreResists;
    private final boolean _isIgnoreInvul;
    private final boolean _isTrigger;
    private final boolean _isNotAffectedByMute;
    private final boolean _basedOnTargetDebuff;
    private final boolean _deathlink;
    private final boolean _hideStartMessage;
    private final boolean _hideUseMessage;
    private final boolean _skillInterrupt;
    private final boolean _flyingTransformUsage;
    private final boolean _canUseTeleport;
    private final boolean _isProvoke;
    private boolean _isCubicSkill;
    private final boolean _isSelfDispellable;
    private final boolean _abortable;
    private final boolean _isRelation;
    private final double _decreaseOnNoPole;
    private final double _increaseOnPole;
    private final boolean _canUseWhileAbnormal;
    private final int _lethal2SkillDepencensyAddon;
    private final double _lethal2Addon;
    private final int _lethal1SkillDepencensyAddon;
    private final double _lethal1Addon;
    private final SkillType _skillType;
    private final SkillOperateType _operateType;
    private final SkillTargetType _targetType;
    private final SkillMagicType _magicType;
    private final SkillTrait _traitType;
    private final boolean _dispelOnDamage;
    private final NextAction _nextAction;
    private final Element _element;
    private final FlyToLocationPacket.FlyType _flyType;
    private final boolean _flyDependsOnHeading;
    private final int _flyRadius;
    private final int _flyPositionDegree;
    private final int _flySpeed;
    private final int _flyDelay;
    private final int _flyAnimationSpeed;
    private Condition[] _preCondition = Condition.EMPTY_ARRAY;
    private final int _id;
    private final int _level;
    private final int _maxLevel;
    private final int _displayId;
    private int _displayLevel;
    private final int _activateRate;
    private final double _minChance;
    private final double _maxChance;
    private final int _castRange;
    private final int _condCharges;
    private final int _coolTime;
    private final int _effectPoint;
    private final int _energyConsume;
    private final int _cprConsume;
    private final int _fameConsume;
    private final int _elementPower;
    private final int _hitTime;
    private final int _hpConsume;
    private final int _levelBonusRate;
    private final int _magicLevel;
    private final int _matak;
    private final PledgeRank _minPledgeRank;
    private final boolean _clanLeaderOnly;
    private final int _npcId;
    private final int _numCharges;
    private final int _hitCancelTime;
    private final AddedSkill _attachedSkill;
    private final int _channelingStart;
    private final int _affectRange;
    private final int[] _fanRange;
    private final int[] _affectLimit;
    private final int _effectiveRange;
    private final int _behindRadius;
    private final int _tickInterval;
    private final int _criticalRate;
    private final double _criticalRateMod;
    private final int _reuseDelay;
    private final double _power;
    private final double _chargeEffectPower;
    private final double _chargeDefectPower;
    private final double _powerPvP;
    private final double _chargeEffectPowerPvP;
    private final double _chargeDefectPowerPvP;
    private final double _powerPvE;
    private final double _chargeEffectPowerPvE;
    private final double _chargeDefectPowerPvE;
    private final double _mpConsume1;
    private final double _mpConsume2;
    private final double _mpConsumeTick;
    private final double _lethal1;
    private final double _lethal2;
    private final double _absorbPart;
    private final double _defenceIgnorePercent;
    private final String _name;
    private final String _baseValues;
    private final String _icon;
    public boolean _isStandart = false;
    private final int _hashCode;
    private final int _reuseSkillId;
    private final int _reuseHash;
    private final int _toggleGroupId;
    private final boolean _isNecessaryToggle;
    private final boolean _isNotDispelOnSelfBuff;
    private final int _abnormalTime;
    private final int _abnormalLvl;
    private final AbnormalType _abnormalType;
    private final AbnormalEffect[] _abnormalEffects;
    private final boolean _abnormalHideTime;
    private final boolean _abnormalCancelOnAction;
    private final boolean _irreplaceableBuff;
    private final boolean _abnormalInstant;
    private boolean _detectPcHide;
    private final int _rideState;
    private final boolean _isSelfDebuff;
    private final boolean _applyEffectsOnSummon;
    private final boolean _applyEffectsOnPet;
    private final boolean _applyMinRange;
    private final int _masteryLevel;
    private final boolean _altUse;
    private final boolean _isItemSkill;
    private final boolean _addSelfTarget;
    private final double _percentDamageIfTargetDebuff;
    private final boolean _noFlagNoForce;
    private final boolean _renewal;
    private final int _buffSlotType;
    private final BasicProperty _basicProperty;
    private final boolean _isDouble;
    private final double _onAttackCancelChance;
    private final double _onCritCancelChance;
    private final boolean _noEffectsIfFailSkill;
    private boolean showPlayerAbnormal = false;
    private boolean showNpcAbnormal = false;

    public Skill(StatsSet set) {
        String affectScope;
        this._id = set.getInteger("skill_id");
        this._level = set.getInteger("level");
        this._displayId = set.getInteger("display_id", this._id);
        this._displayLevel = set.getInteger("display_level", this._level);
        this._maxLevel = set.getInteger("max_level");
        this._name = set.getString("name");
        this._operateType = (SkillOperateType)set.getEnum("operate_type", SkillOperateType.class);
        this._isNewbie = set.getBool("isNewbie", false);
        this._isSelfDispellable = set.getBool("isSelfDispellable", true);
        this._isPreservedOnDeath = set.getBool("isPreservedOnDeath", false);
        this._energyConsume = set.getInteger("energyConsume", 0);
        this._cprConsume = set.getInteger("clanRepConsume", 0);
        this._fameConsume = set.getInteger("fameConsume", 0);
        this._hpConsume = set.getInteger("hpConsume", 0);
        this._isChargeBoost = set.getBool("chargeBoost", false);
        this._isProvoke = set.getBool("provoke", false);
        this._matak = set.getInteger("mAtk", 0);
        this._isUseSS = Ternary.valueOf(set.getString("useSS", Ternary.DEFAULT.toString()).toUpperCase());
        this._magicLevel = set.getInteger("magicLevel", 0);
        this._tickInterval = Math.max(-1, (int)(set.getDouble("tick_interval", -1.0) * 1000.0));
        this._castRange = set.getInteger("castRange", -1);
        this._baseValues = set.getString("baseValues", null);
        this._abnormalTime = set.getInteger("abnormal_time", -1);
        this._abnormalLvl = set.getInteger("abnormal_level", 0);
        this._abnormalType = AbnormalType.valueOf(set.getString("abnormal_type", AbnormalType.NONE.toString()).toUpperCase());
        String[] abnormalEffects = set.getString("abnormal_effect", AbnormalEffect.NONE.toString()).split(";");
        this._abnormalEffects = new AbnormalEffect[abnormalEffects.length];
        for (int i = 0; i < abnormalEffects.length; ++i) {
            this._abnormalEffects[i] = AbnormalEffect.valueOf(abnormalEffects[i].toUpperCase());
        }
        this._abnormalHideTime = set.getBool("abnormal_hide_time", false);
        this._abnormalCancelOnAction = set.getBool("abnormal_cancel_on_action", false);
        this._irreplaceableBuff = set.getBool("irreplaceable_buff", false);
        this._abnormalInstant = set.getBool("abnormal_instant", false);
        String[] ride_state = set.getString("ride_state", MountType.NONE.toString()).split(";");
        int rideState = 0;
        for (int i = 0; i < ride_state.length; ++i) {
            rideState |= 1 << MountType.valueOf(ride_state[i].toUpperCase()).ordinal();
        }
        this._rideState = rideState;
        this._toggleGroupId = set.getInteger("toggle_group_id", 0);
        this._isNecessaryToggle = set.getBool("is_necessarytg", false);
        this._isNotDispelOnSelfBuff = set.getBool("doNotDispelOnSelfBuff", false);
        this._itemConsume = set.getLong("itemConsumeCount", 0L);
        this._itemConsumeId = set.getInteger("itemConsumeId", 0);
        this._itemConsumeFromMaster = set.getBool("consume_item_from_master", false);
        String s3 = set.getString("relationSkillsId", "");
        if (s3.length() == 0) {
            this._isRelation = false;
            this._relationSkillsId = new int[]{0};
        } else {
            this._isRelation = true;
            String[] s = s3.split(";");
            this._relationSkillsId = new int[s.length];
            for (int i = 0; i < s.length; ++i) {
                this._relationSkillsId[i] = Integer.parseInt(s[i]);
            }
        }
        this._referenceItemId = set.getInteger("referenceItemId", 0);
        this._referenceItemMpConsume = set.getInteger("referenceItemMpConsume", 0);
        this._isItemHandler = set.getBool("isHandler", false);
        this._isSaveable = set.getBool("isSaveable", this._operateType.isActive());
        this._coolTime = set.getInteger("coolTime", 0);
        this._hitCancelTime = set.getInteger("hitCancelTime", 0);
        int[] attachedSkill = set.getIntegerArray("attached_skill", new int[2], "-");
        this._attachedSkill = attachedSkill.length > 0 && attachedSkill[0] > 0 ? new AddedSkill(SkillEntryType.NONE, attachedSkill[0], attachedSkill.length > 1 ? attachedSkill[1] : 1) : null;
        this._channelingStart = (int)(set.getDouble("channeling_start", 0.0) * 1000.0);
        this._reuseDelay = set.getInteger("reuseDelay", 0);
        this._hitTime = set.getInteger("hitTime", 0);
        this._affectRange = set.getInteger("affect_range", 80);
        this._fanRange = set.getIntegerArray("fan_range", new int[4]);
        this._affectLimit = set.getIntegerArray("affect_limit", new int[3]);
        this._effectiveRange = set.getInteger("effective_range", -1);
        this._behindRadius = Math.min(360, Math.max(0, set.getInteger("behind_radius", 0)));
        SkillTargetType targetType = (SkillTargetType)set.getEnum("target", SkillTargetType.class, null);
        if (targetType == null && (affectScope = set.getString("affect_scope", null)) != null) {
            try {
                targetType = SkillTargetType.valueOf("TARGET_" + affectScope.toUpperCase());
            }
            catch (Exception e) {
                // empty catch block
            }
        }
        if (targetType == null) {
            targetType = SkillTargetType.TARGET_SELF;
        }
        this._targetType = targetType;
        this._magicType = (SkillMagicType)set.getEnum("magicType", SkillMagicType.class, SkillMagicType.PHYSIC);
        int mpConsume = set.getInteger("mp_consume", 0);
        this._mpConsume1 = set.getInteger("mp_consume1", this._magicType == SkillMagicType.MAGIC ? mpConsume / 4 : 0);
        this._mpConsume2 = set.getInteger("mp_consume2", this._magicType == SkillMagicType.MAGIC ? mpConsume / 4 * 3 : mpConsume);
        this._mpConsumeTick = set.getInteger("mp_consume_tick", 0);
        String traitName = set.getString("trait", "NONE").toUpperCase();
        if (traitName.startsWith("TRAIT_")) {
            traitName = traitName.substring(6).trim();
        }
        this._traitType = SkillTrait.valueOf(traitName);
        this._dispelOnDamage = set.getBool("dispelOnDamage", false);
        this._hideStartMessage = set.getBool("isHideStartMessage", false);
        this._hideUseMessage = set.getBool("isHideUseMessage", false);
        this._isUndeadOnly = set.getBool("undeadOnly", false);
        this._isCorpse = set.getBool("corpse", false);
        this._power = set.getDouble("power", 0.0);
        this._chargeEffectPower = set.getDouble("chargeEffectPower", this._power);
        this._chargeDefectPower = set.getDouble("chargeDefectPower", this._power);
        this._powerPvP = set.getDouble("powerPvP", 0.0);
        this._chargeEffectPowerPvP = set.getDouble("chargeEffectPowerPvP", this._powerPvP);
        this._chargeDefectPowerPvP = set.getDouble("chargeDefectPowerPvP", this._powerPvP);
        this._powerPvE = set.getDouble("powerPvE", 0.0);
        this._chargeEffectPowerPvE = set.getDouble("chargeEffectPowerPvE", this._powerPvE);
        this._chargeDefectPowerPvE = set.getDouble("chargeDefectPowerPvE", this._powerPvE);
        this._effectPoint = set.getInteger("effectPoint", 1);
        this._skillType = (SkillType)set.getEnum("skillType", SkillType.class, SkillType.EFFECT);
        this._isSuicideAttack = set.getBool("isSuicideAttack", false);
        this._isSkillTimePermanent = set.getBool("isSkillTimePermanent", false);
        this._isReuseDelayPermanent = set.getBool("isReuseDelayPermanent", false);
        this._deathlink = set.getBool("deathlink", false);
        this._basedOnTargetDebuff = set.getBool("basedOnTargetDebuff", false);
        this._isNotUsedByAI = set.getBool("isNotUsedByAI", false);
        this._isIgnoreResists = set.getBool("isIgnoreResists", false);
        this._isIgnoreInvul = set.getBool("isIgnoreInvul", false);
        this._isTrigger = set.getBool("isTrigger", false);
        this._isNotAffectedByMute = set.getBool("isNotAffectedByMute", false);
        this._flyingTransformUsage = set.getBool("flyingTransformUsage", false);
        this._canUseTeleport = set.getBool("canUseTeleport", true);
        this._altUse = set.getBool("alt_use", false);
        String element = set.getString("element", "NONE");
        this._element = NumberUtils.isCreatable((String)element) ? Element.getElementById(Integer.parseInt(element)) : Element.getElementByName(element.toUpperCase());
        this._elementPower = set.getInteger("elementPower", 0);
        this._activateRate = set.getInteger("activateRate", -1);
        this._minChance = set.getDouble("min_chance", Config.MIN_ABNORMAL_SUCCESS_RATE);
        this._maxChance = set.getDouble("max_chance", Config.MAX_ABNORMAL_SUCCESS_RATE);
        this._levelBonusRate = set.getInteger("lv_bonus_rate", 0);
        this._isCancelable = set.getBool("cancelable", true);
        this._isReflectable = set.getBool("reflectable", true);
        this._isShieldignore = set.getBool("shieldignore", false);
        this._shieldIgnorePercent = set.getDouble("shield_ignore_percent", 0.0);
        this._criticalRate = set.getInteger("criticalRate", 0);
        this._criticalRateMod = set.getDouble("critical_rate_modifier", 1.0);
        this._isOverhit = set.getBool("overHit", false);
        this._minPledgeRank = (PledgeRank)set.getEnum("min_pledge_rank", PledgeRank.class, PledgeRank.VAGABOND);
        this._clanLeaderOnly = set.getBool("clan_leader_only", false);
        this._isDebuff = set.getBool("debuff", this._skillType.isDebuff());
        this._isPvpSkill = set.getBool("isPvpSkill", this._skillType.isPvpSkill());
        this._isPvm = set.getBool("isPvm", this._skillType.isPvM());
        this._isForceUse = set.getBool("isForceUse", false);
        this._isBehind = set.getBool("behind", false);
        this._npcId = set.getInteger("npcId", 0);
        this._flyType = FlyToLocationPacket.FlyType.valueOf(set.getString("fly_type", "NONE").toUpperCase());
        this._flyDependsOnHeading = set.getBool("fly_depends_on_heading", false);
        this._flySpeed = set.getInteger("fly_speed", 0);
        this._flyDelay = set.getInteger("fly_delay", 0);
        this._flyAnimationSpeed = set.getInteger("fly_animation_speed", 0);
        this._flyRadius = set.getInteger("fly_radius", 200);
        this._flyPositionDegree = set.getInteger("fly_position_degree", 0);
        this._numCharges = set.getInteger("num_charges", 0);
        this._condCharges = set.getInteger("cond_charges", 0);
        this._skillInterrupt = set.getBool("skillInterrupt", false);
        this._lethal1 = set.getDouble("lethal1", 0.0);
        this._decreaseOnNoPole = set.getDouble("decreaseOnNoPole", 0.0);
        this._increaseOnPole = set.getDouble("increaseOnPole", 0.0);
        this._lethal2 = set.getDouble("lethal2", 0.0);
        this._lethal2Addon = set.getDouble("lethal2DepensencyAddon", 0.0);
        this._lethal2SkillDepencensyAddon = set.getInteger("lethal2SkillDepencensyAddon", 0);
        this._lethal1Addon = set.getDouble("lethal1DepensencyAddon", 0.0);
        this._lethal1SkillDepencensyAddon = set.getInteger("lethal1SkillDepencensyAddon", 0);
        this._absorbPart = set.getDouble("absorbPart", 0.0);
        this._icon = set.getString("icon", "");
        this._canUseWhileAbnormal = set.getBool("canUseWhileAbnormal", false);
        this._abortable = set.getBool("is_abortable", true);
        this._defenceIgnorePercent = set.getDouble("defence_ignore_percent", 0.0);
        AddedSkill[] addedSkills = AddedSkill.EMPTY_ARRAY;
        StringTokenizer st = new StringTokenizer(set.getString("addSkills", ""), ";");
        while (st.hasMoreTokens()) {
            int id = Integer.parseInt(st.nextToken());
            int level = Integer.parseInt(st.nextToken());
            if (level == -1) {
                level = this._level;
            }
            addedSkills = (AddedSkill[])ArrayUtils.add(addedSkills, new AddedSkill(SkillEntryType.NONE, id, level));
        }
        this._addedSkills = addedSkills;
        NextAction nextAction = NextAction.valueOf(set.getString("nextAction", "DEFAULT").toUpperCase());
        if (nextAction == NextAction.DEFAULT) {
            switch (this._skillType) {
                case DRAIN_SOUL: 
                case LETHAL_SHOT: 
                case PDAM: 
                case CPDAM: 
                case STUN: {
                    this._nextAction = NextAction.ATTACK;
                    break;
                }
                default: {
                    this._nextAction = NextAction.NONE;
                    break;
                }
            }
        } else {
            this._nextAction = nextAction;
        }
        this._reuseSkillId = set.getInteger("reuse_skill_id", -1);
        this._reuseHash = SkillHolder.getInstance().getHashCode(this._reuseSkillId > 0 ? this._reuseSkillId : this._id, this._level);
        this._detectPcHide = set.getBool("detectPcHide", false);
        this._hashCode = SkillHolder.getInstance().getHashCode(this._id, this._level);
        this._isSelfDebuff = set.getBool("self_debuff", this._isDebuff);
        this._applyEffectsOnSummon = set.getBool("apply_effects_on_summon", true);
        this._applyEffectsOnPet = set.getBool("apply_effects_on_pet", true);
        this._applyMinRange = set.getBool("applyMinRange", true);
        this._masteryLevel = set.getInteger("masteryLevel", -1);
        this._isItemSkill = set.getBool("is_item_skill", false);
        for (EffectUseType type : EffectUseType.VALUES) {
            this._effectTemplates.put(type.ordinal(), new ArrayList(0));
        }
        this._addSelfTarget = set.getBool("add_self_target", false);
        this._percentDamageIfTargetDebuff = set.getDouble("percent_damage_if_target_debuff", 1.0);
        this._noFlagNoForce = set.getBool("noFlag_noForce", false);
        this._renewal = set.getBool("renewal", true);
        this._buffSlotType = set.getInteger("buff_slot_type", -2);
        this._basicProperty = BasicProperty.valueOf(set.getString("basic_property", "none").toUpperCase());
        this._isDouble = set.getBool("is_double", false);
        this._onAttackCancelChance = set.getDouble("on_attack_cancel_chance", 0.0);
        this._onCritCancelChance = set.getDouble("on_crit_cancel_chance", 0.0);
        this._noEffectsIfFailSkill = set.getBool("no_effects_if_fail_skill", false);
        if (this.isDebuff()) {
            this.showPlayerAbnormal = Config.SHOW_TARGET_PLAYER_DEBUFF_EFFECTS;
            this.showNpcAbnormal = Config.SHOW_TARGET_NPC_DEBUFF_EFFECTS;
        } else {
            this.showPlayerAbnormal = Config.SHOW_TARGET_PLAYER_BUFF_EFFECTS;
            this.showNpcAbnormal = Config.SHOW_TARGET_NPC_BUFF_EFFECTS;
        }
        if (!set.getBool("olympiad_use", true)) {
            ConditionPlayerOlympiad cond = new ConditionPlayerOlympiad(false);
            cond.setSystemMsg(1509);
            this.attachCondition(cond);
        }
    }

    public void init() {
        FuncTemplate[] funcs;
        if (!this.isPassive() && ((funcs = this.removeAttachedFuncs()).length > 0 || this.getAbnormalTime() > 0 && !this.hasEffects(EffectUseType.NORMAL))) {
            EffectTemplate template = new EffectTemplate(this, StatsSet.EMPTY, EffectUseType.NORMAL, EffectTargetType.NORMAL);
            template.attachFuncs(funcs);
            this.attachEffect(template);
        }
        if (!this.showPlayerAbnormal || !this.showNpcAbnormal) {
            for (Condition cond : this.getConditions()) {
                cond.init();
            }
        }
    }

    public final boolean checkCondition(SkillEntry skillEntry, Creature activeChar, Creature target, boolean forceUse, boolean dontMove, boolean first) {
        return this.checkCondition(skillEntry, activeChar, target, forceUse, dontMove, first, true, false);
    }

    public boolean checkCondition(SkillEntry skillEntry, Creature activeChar, Creature target, boolean forceUse, boolean dontMove, boolean first, boolean sendMsg, boolean trigger) {
        SystemMsg msg;
        Player player = activeChar.getPlayer();
        if (activeChar.isDead()) {
            return false;
        }
        if (!this.isHandler() && activeChar.isMuted(this)) {
            return false;
        }
        if (activeChar.isUnActiveSkill(this._id)) {
            return false;
        }
        if (target != null && activeChar.getReflection() != target.getReflection()) {
            if (sendMsg) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.CANNOT_SEE_TARGET);
            }
            return false;
        }
        if (!trigger && (player != null && player.isInZone(Zone.ZoneType.JUMPING) || target != null && target.isInZone(Zone.ZoneType.JUMPING))) {
            if (sendMsg) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_USE_SKILLS_IN_THE_CORRESPONDING_REGION);
            }
            return false;
        }
        if (first && activeChar.isSkillDisabled(this)) {
            if (sendMsg) {
                activeChar.sendReuseMessage(this);
            }
            return false;
        }
        if (first) {
            double d = activeChar.getCurrentMp();
            double d2 = this.isMagic() ? this._mpConsume1 + activeChar.getStat().calc(Stats.MP_MAGIC_SKILL_CONSUME, this._mpConsume2, target, this) : this._mpConsume1 + activeChar.getStat().calc(Stats.MP_PHYSICAL_SKILL_CONSUME, this._mpConsume2, target, this);
            if (d < d2) {
                if (sendMsg) {
                    activeChar.sendPacket((IBroadcastPacket)SystemMsg.NOT_ENOUGH_MP);
                }
                return false;
            }
        }
        if (activeChar.getCurrentHp() < (double)(this._hpConsume + 1)) {
            if (sendMsg) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.NOT_ENOUGH_HP);
            }
            return false;
        }
        if (this.getFameConsume() > 0 && (player == null || player.getFame() < this._fameConsume)) {
            if (sendMsg) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_DONT_HAVE_ENOUGH_REPUTATION_TO_DO_THAT);
            }
            return false;
        }
        if (this.getClanRepConsume() > 0 && (player == null || player.getClan() == null || player.getClan().getReputationScore() < this._cprConsume)) {
            if (sendMsg) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.THE_CLAN_REPUTATION_SCORE_IS_TOO_LOW);
            }
            return false;
        }
        if (this._targetType == SkillTargetType.TARGET_GROUND) {
            if (!activeChar.isPlayer()) {
                return false;
            }
            if (player.getGroundSkillLoc() == null) {
                return false;
            }
        }
        if (this.isNotTargetAoE() && this.isDebuff() && activeChar.isInPeaceZone()) {
            if (sendMsg) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.A_MALICIOUS_SKILL_CANNOT_BE_USED_IN_A_PEACE_ZONE);
            }
            return false;
        }
        if (activeChar.getIncreasedForce() < this.getCondCharges()) {
            if (sendMsg) {
                activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addSkillName(this));
            }
            return false;
        }
        if (player != null) {
            if (player.isInFlyingTransform() && this.isHandler() && !this.flyingTransformUsage()) {
                if (sendMsg) {
                    player.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addSkillName(this));
                }
                return false;
            }
            if (!this.checkRideState(player.getMountType())) {
                if (sendMsg) {
                    player.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addSkillName(this));
                }
                return false;
            }
            if (player.isInObserverMode()) {
                if (sendMsg) {
                    activeChar.sendPacket((IBroadcastPacket)SystemMsg.OBSERVERS_CANNOT_PARTICIPATE);
                }
                return false;
            }
            if (!this.isHandler() && activeChar.isPlayable() && first && this.getItemConsumeId() > 0 && this.getItemConsume() > 0L && ItemFunctions.getItemCount(this.isItemConsumeFromMaster() ? player : (Playable)activeChar, this.getItemConsumeId()) < this.getItemConsume()) {
                if ((this.isItemConsumeFromMaster() || activeChar == player) && sendMsg) {
                    player.sendPacket((IBroadcastPacket)SystemMsg.THERE_ARE_NOT_ENOUGH_NECESSARY_ITEMS_TO_USE_THE_SKILL);
                }
                return false;
            }
            if (player.isFishing() && !skillEntry.isAltUse() && !activeChar.isServitor()) {
                if (activeChar == player && sendMsg) {
                    player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_DO_THAT_WHILE_FISHING);
                }
                return false;
            }
            if (player.isInTrainingCamp()) {
                if (sendMsg) {
                    player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_TAKE_OTHER_ACTION_WHILE_ENTERING_THE_TRAINING_CAMP);
                }
                return false;
            }
        }
        switch (this.getFlyType()) {
            case WARP_BACK: 
            case WARP_FORWARD: 
            case CHARGE: 
            case DUMMY: {
                if (activeChar.getStat().calc(Stats.BlockFly) != 1.0) break;
                activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addSkillName(this));
                return false;
            }
        }
        if (this.getFlyType() != FlyToLocationPacket.FlyType.NONE && this.getId() != 628 && this.getId() != 821 && activeChar.isImmobilized()) {
            if (sendMsg) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOUR_TARGET_IS_OUT_OF_RANGE);
            }
            return false;
        }
        if (first && target != null && this.getFlyType() == FlyToLocationPacket.FlyType.CHARGE) {
            if (this.isApplyMinRange() && activeChar.isInRange(target.getLoc(), Math.min(150, this.getFlyRadius())) && this.getTargetType() != SkillTargetType.TARGET_SELF && !activeChar.isServitor()) {
                if (sendMsg) {
                    activeChar.sendPacket((IBroadcastPacket)SystemMsg.THERE_IS_NOT_ENOUGH_SPACE_TO_MOVE_THE_SKILL_CANNOT_BE_USED);
                }
                return false;
            }
            Location flyLoc = activeChar.getFlyLocation(target, this);
            if (flyLoc == null) {
                if (sendMsg) {
                    activeChar.sendPacket((IBroadcastPacket)SystemMsg.THE_TARGET_IS_LOCATED_WHERE_YOU_CANNOT_CHARGE);
                }
                return false;
            }
        }
        if ((msg = this.checkTarget(skillEntry, activeChar, target, target, forceUse, first, trigger)) != null && player != null) {
            if (sendMsg) {
                player.sendPacket((IBroadcastPacket)msg);
            }
            return false;
        }
        if (this._preCondition.length == 0) {
            return true;
        }
        Env env = new Env();
        env.character = activeChar;
        env.skill = this;
        env.target = target;
        if (first) {
            for (Condition \u0441 : this._preCondition) {
                SystemMsg cond_msg;
                if (\u0441.test(env)) continue;
                if (sendMsg && (cond_msg = \u0441.getSystemMsg()) != null) {
                    if (cond_msg.size() > 0) {
                        activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(cond_msg).addSkillName(this));
                    } else {
                        activeChar.sendPacket((IBroadcastPacket)cond_msg);
                    }
                }
                return false;
            }
        }
        return true;
    }

    public final SystemMsg checkTarget(SkillEntry skillEntry, Creature activeChar, Creature target, Creature aimingTarget, boolean forceUse, boolean first) {
        return this.checkTarget(skillEntry, activeChar, target, aimingTarget, forceUse, first, false);
    }

    public SystemMsg checkTarget(SkillEntry skillEntry, Creature activeChar, Creature target, Creature aimingTarget, boolean forceUse, boolean first, boolean trigger) {
        Player pcTarget;
        boolean isCorpseSkill;
        if (target == activeChar && this.isNotTargetAoE()) {
            return null;
        }
        if (target == null) {
            return SystemMsg.THAT_IS_AN_INCORRECT_TARGET;
        }
        if (target == activeChar) {
            if (this._targetType != SkillTargetType.TARGET_SELF && this.isDebuff()) {
                return SystemMsg.THAT_IS_AN_INCORRECT_TARGET;
            }
            return null;
        }
        if (this.isPvpSkill() && target.isPeaceNpc()) {
            return SystemMsg.THAT_IS_AN_INCORRECT_TARGET;
        }
        if (activeChar.getReflection() != target.getReflection()) {
            return SystemMsg.CANNOT_SEE_TARGET;
        }
        if (!(trigger || first || target != aimingTarget || this.getCastRange() <= 0 || activeChar.isInRange(target.getLoc(), this.getCastRange() + (this.getCastRange() < 200 ? 400 : 500)))) {
            return SystemMsg.YOUR_TARGET_IS_OUT_OF_RANGE;
        }
        if (activeChar.isMyServitor(target.getObjectId()) && this._targetType == SkillTargetType.TARGET_SERVITOR_AURA) {
            return null;
        }
        if (this._skillType == SkillType.TAKECASTLE) {
            return null;
        }
        boolean bl = isCorpseSkill = this.isCorpse() || target == aimingTarget && this._targetType == SkillTargetType.TARGET_AREA_AIM_CORPSE;
        if (target.isDead() != isCorpseSkill || this._isUndeadOnly && !target.isUndead()) {
            return SystemMsg.INVALID_TARGET;
        }
        if (this._targetType == SkillTargetType.TARGET_CORPSE || target == aimingTarget && this._targetType == SkillTargetType.TARGET_AREA_AIM_CORPSE) {
            if (!target.isNpc() && !target.isSummon()) {
                return SystemMsg.INVALID_TARGET;
            }
            return null;
        }
        if (skillEntry.isAltUse() || this._targetType == SkillTargetType.TARGET_UNLOCKABLE || this._targetType == SkillTargetType.TARGET_CHEST) {
            return null;
        }
        if (this.isDebuff() && target.isFakePlayer() && target.isInPeaceZone()) {
            return SystemMsg.YOU_MAY_NOT_ATTACK_THIS_TARGET_IN_A_PEACEFUL_ZONE;
        }
        Player player = activeChar.getPlayer();
        if (player != null && (pcTarget = target.getPlayer()) != null) {
            if (this.isPvM()) {
                return SystemMsg.THAT_IS_AN_INCORRECT_TARGET;
            }
            if (pcTarget != player) {
                if (player.isInZone(Zone.ZoneType.epic) != pcTarget.isInZone(Zone.ZoneType.epic)) {
                    return SystemMsg.THAT_IS_AN_INCORRECT_TARGET;
                }
                if (pcTarget.isInOlympiadMode() && (!player.isInOlympiadMode() || player.getOlympiadGame() != pcTarget.getOlympiadGame())) {
                    return SystemMsg.THAT_IS_AN_INCORRECT_TARGET;
                }
            }
            if (this.isDebuff()) {
                if (pcTarget != player) {
                    if (player.isInOlympiadMode() && !player.isOlympiadCompStart()) {
                        return SystemMsg.INVALID_TARGET;
                    }
                    if (player.isInOlympiadMode() && player.isOlympiadCompStart() && player.getOlympiadSide() == pcTarget.getOlympiadSide() && !forceUse) {
                        return SystemMsg.THAT_IS_AN_INCORRECT_TARGET;
                    }
                    if (pcTarget.isInNonPvpTime()) {
                        return SystemMsg.THAT_IS_AN_INCORRECT_TARGET;
                    }
                }
                if (this.isAoE() && !GeoEngine.canSeeTarget(activeChar, target)) {
                    return SystemMsg.CANNOT_SEE_TARGET;
                }
                if (pcTarget != player && activeChar.isInZoneBattle() != target.isInZoneBattle() && !player.getPlayerAccess().PeaceAttack) {
                    return SystemMsg.YOU_MAY_NOT_ATTACK_THIS_TARGET_IN_A_PEACEFUL_ZONE;
                }
                if ((activeChar.isInPeaceZone() || target.isInPeaceZone()) && !player.getPlayerAccess().PeaceAttack) {
                    return SystemMsg.YOU_MAY_NOT_ATTACK_THIS_TARGET_IN_A_PEACEFUL_ZONE;
                }
                if (pcTarget != player) {
                    SystemMsg msg = null;
                    for (Event e : activeChar.getEvents()) {
                        msg = e.checkForAttack(target, activeChar, this, forceUse);
                        if (msg == null) continue;
                        return msg;
                    }
                    for (Event e : activeChar.getEvents()) {
                        if (!e.canAttack(target, activeChar, this, forceUse, false)) continue;
                        return null;
                    }
                    if (activeChar.isInZoneBattle()) {
                        if (!forceUse && !this.isForceUse() && player.getParty() != null && player.getParty() == pcTarget.getParty()) {
                            return SystemMsg.INVALID_TARGET;
                        }
                        return null;
                    }
                    if (this.isProvoke()) {
                        if (!forceUse && player.getParty() != null && player.getParty() == pcTarget.getParty()) {
                            return SystemMsg.INVALID_TARGET;
                        }
                        return null;
                    }
                }
                if (this.isPvpSkill() || !forceUse || this.isAoE()) {
                    if (player == pcTarget) {
                        return SystemMsg.INVALID_TARGET;
                    }
                    if (player.getParty() != null && player.getParty() == pcTarget.getParty()) {
                        return SystemMsg.INVALID_TARGET;
                    }
                    if (player.isInParty() && player.getParty().getCommandChannel() != null && pcTarget.isInParty() && pcTarget.getParty().getCommandChannel() != null && player.getParty().getCommandChannel() == pcTarget.getParty().getCommandChannel()) {
                        return SystemMsg.INVALID_TARGET;
                    }
                    if (player.getClanId() != 0 && player.getClanId() == pcTarget.getClanId()) {
                        return SystemMsg.INVALID_TARGET;
                    }
                    if (player.getClan() != null && player.getClan().getAlliance() != null && pcTarget.getClan() != null && pcTarget.getClan().getAlliance() != null && player.getClan().getAlliance() == pcTarget.getClan().getAlliance()) {
                        return SystemMsg.INVALID_TARGET;
                    }
                }
                if (pcTarget != player) {
                    if (activeChar.isInSiegeZone() && target.isInSiegeZone()) {
                        return null;
                    }
                    if (player.atMutualWarWith(pcTarget)) {
                        return null;
                    }
                }
                if (this.isForceUse()) {
                    return null;
                }
                if (pcTarget != player) {
                    if (pcTarget.getPvpFlag() != 0) {
                        return null;
                    }
                    if (pcTarget.isPK()) {
                        return null;
                    }
                }
                if (!(!forceUse || this.isPvpSkill() || this.isAoE() && aimingTarget != target)) {
                    return null;
                }
                return SystemMsg.INVALID_TARGET;
            }
            if (pcTarget == player) {
                return null;
            }
            if (player.isInOlympiadMode() && !forceUse && player.getOlympiadSide() != pcTarget.getOlympiadSide()) {
                return SystemMsg.THAT_IS_AN_INCORRECT_TARGET;
            }
            if (player.getTeam() != TeamType.NONE && pcTarget.getTeam() != TeamType.NONE && player.getTeam() != pcTarget.getTeam()) {
                return SystemMsg.THAT_IS_AN_INCORRECT_TARGET;
            }
            if (!activeChar.isInZoneBattle() && target.isInZoneBattle()) {
                return SystemMsg.INVALID_TARGET;
            }
            if (forceUse || this.isForceUse()) {
                return null;
            }
            if (player.getParty() != null && player.getParty() == pcTarget.getParty()) {
                return null;
            }
            if (player.getClanId() != 0 && player.getClanId() == pcTarget.getClanId()) {
                return null;
            }
            if (player.atMutualWarWith(pcTarget)) {
                return SystemMsg.INVALID_TARGET;
            }
            if (pcTarget.getPvpFlag() != 0) {
                return SystemMsg.INVALID_TARGET;
            }
            if (pcTarget.isPK()) {
                return SystemMsg.INVALID_TARGET;
            }
            return null;
        }
        if ((!trigger || target != aimingTarget) && this.isAoE() && this.isDebuff() && !GeoEngine.canSeeTarget(activeChar, target)) {
            return SystemMsg.CANNOT_SEE_TARGET;
        }
        if (!(forceUse || this.isForceUse() || this.isNoFlagNoForce())) {
            if (!this.isDebuff() && target.isAutoAttackable(activeChar)) {
                return SystemMsg.INVALID_TARGET;
            }
            if (this.isDebuff() && !target.isAutoAttackable(activeChar)) {
                return SystemMsg.INVALID_TARGET;
            }
        }
        if (!target.isAttackable(activeChar)) {
            return SystemMsg.INVALID_TARGET;
        }
        return null;
    }

    public final Creature getAimingTarget(Creature activeChar, GameObject obj) {
        Creature target = obj == null || !obj.isCreature() ? null : (Creature)obj;
        switch (this._targetType) {
            case TARGET_ALLY: 
            case TARGET_CLAN: 
            case TARGET_PARTY: 
            case TARGET_PARTY_WITHOUT_ME: 
            case TARGET_CLAN_ONLY: 
            case TARGET_SELF: {
                return activeChar;
            }
            case TARGET_AURA: 
            case TARGET_COMMCHANNEL: 
            case TARGET_GROUND: 
            case TARGET_FAN_PB: 
            case TARGET_SQUARE_PB: {
                return activeChar;
            }
            case TARGET_HOLY: {
                return target != null && activeChar.isPlayer() && target.isArtefact() ? target : null;
            }
            case TARGET_FLAGPOLE: {
                return activeChar;
            }
            case TARGET_UNLOCKABLE: {
                return target != null && target.isDoor() || target instanceof ChestInstance ? target : null;
            }
            case TARGET_CHEST: {
                return target instanceof ChestInstance ? target : null;
            }
            case TARGET_SERVITORS: 
            case TARGET_SELF_AND_SUMMON: {
                return activeChar;
            }
            case TARGET_ONE_SERVITOR: 
            case TARGET_SERVITOR_AURA: {
                return target != null && target.isServitor() && activeChar.isMyServitor(target.getObjectId()) && target.isDead() == this.isCorpse() ? target : null;
            }
            case TARGET_ONE_SERVITOR_NO_TARGET: {
                target = activeChar.getPlayer().getAnyServitor();
                return target != null && target.isDead() == this.isCorpse() ? target : null;
            }
            case TARGET_SUMMON: {
                target = activeChar.isPlayer() ? activeChar.getPlayer().getSummon() : null;
                return target != null && target.isDead() == this.isCorpse() ? target : null;
            }
            case TARGET_PET: {
                target = activeChar.isPlayer() ? activeChar.getPlayer().getPet() : null;
                return target != null && target.isDead() == this.isCorpse() ? target : null;
            }
            case TARGET_OWNER: {
                if (!activeChar.isServitor()) {
                    return null;
                }
                target = activeChar.getPlayer();
                return target != null && target.isDead() == this.isCorpse() ? target : null;
            }
            case TARGET_ENEMY_PET: {
                if (target == null || activeChar.isMyServitor(target.getObjectId()) || !target.isPet()) {
                    return null;
                }
                return target;
            }
            case TARGET_ENEMY_SUMMON: {
                if (target == null || activeChar.isMyServitor(target.getObjectId()) || !target.isSummon()) {
                    return null;
                }
                return target;
            }
            case TARGET_ENEMY_SERVITOR: {
                if (target == null || activeChar.isMyServitor(target.getObjectId()) || !target.isServitor()) {
                    return null;
                }
                return target;
            }
            case TARGET_ONE: {
                return !(target == null || target.isDead() != this.isCorpse() || target == activeChar && this.isDebuff() || this._isUndeadOnly && !target.isUndead()) ? target : null;
            }
            case TARGET_CLAN_ONE: {
                if (target == null) {
                    return null;
                }
                Player cplayer = activeChar.getPlayer();
                Player cptarget = target.getPlayer();
                if (cptarget != null && cptarget == activeChar) {
                    return target;
                }
                if (!(cplayer == null || !cplayer.isInOlympiadMode() || cptarget == null || cplayer.getOlympiadSide() != cptarget.getOlympiadSide() || cplayer.getOlympiadGame() != cptarget.getOlympiadGame() || target.isDead() != this._isCorpse || target == activeChar && this.isDebuff() || this._isUndeadOnly && !target.isUndead())) {
                    return target;
                }
                if (!(cptarget == null || cplayer == null || cplayer.getClan() == null || !cplayer.isInSameClan(cptarget) || target.isDead() != this.isCorpse() || target == activeChar && this.isDebuff() || this._isUndeadOnly && !target.isUndead())) {
                    return target;
                }
                return null;
            }
            case TARGET_PARTY_ONE: {
                if (target == null) {
                    return null;
                }
                Player player = activeChar.getPlayer();
                Player ptarget = target.getPlayer();
                if (ptarget != null && ptarget == activeChar) {
                    return target;
                }
                if (!(player == null || !player.isInOlympiadMode() || ptarget == null || player.getOlympiadSide() != ptarget.getOlympiadSide() || player.getOlympiadGame() != ptarget.getOlympiadGame() || target.isDead() != this._isCorpse || target == activeChar && this.isDebuff() || this._isUndeadOnly && !target.isUndead())) {
                    return target;
                }
                if (!(ptarget == null || player == null || player.getParty() == null || !player.getParty().containsMember(ptarget) || target.isDead() != this.isCorpse() || target == activeChar && this.isDebuff() || this._isUndeadOnly && !target.isUndead())) {
                    return target;
                }
                return null;
            }
            case TARGET_PARTY_ONE_WITHOUT_ME: {
                if (target == null) {
                    return null;
                }
                Player player = activeChar.getPlayer();
                Player ptarget = target.getPlayer();
                if (ptarget != null && ptarget == activeChar) {
                    return null;
                }
                if (!(player == null || !player.isInOlympiadMode() || ptarget == null || player.getOlympiadSide() != ptarget.getOlympiadSide() || player.getOlympiadGame() != ptarget.getOlympiadGame() || target.isDead() != this._isCorpse || target == activeChar && this.isDebuff() || this._isUndeadOnly && !target.isUndead())) {
                    return target;
                }
                if (!(ptarget == null || player == null || player.getParty() == null || !player.getParty().containsMember(ptarget) || target.isDead() != this.isCorpse() || target == activeChar && this.isDebuff() || this._isUndeadOnly && !target.isUndead())) {
                    return target;
                }
                return null;
            }
            case TARGET_AREA: 
            case TARGET_FAN: 
            case TARGET_SQUARE: 
            case TARGET_RANGE: 
            case TARGET_RING_RANGE: {
                return !(target == null || target.isDead() != this.isCorpse() || target == activeChar && this.isDebuff() || this._isUndeadOnly && !target.isUndead()) ? target : null;
            }
            case TARGET_AREA_AIM_CORPSE: {
                return target != null && target.isDead() ? target : null;
            }
            case TARGET_CORPSE: {
                if (target == null || !target.isDead()) {
                    return null;
                }
                if (target.isSummon() && !activeChar.isMyServitor(target.getObjectId())) {
                    return target;
                }
                return target.isNpc() ? target : null;
            }
            case TARGET_CORPSE_PLAYER: {
                return target != null && target.isPlayable() && target.isDead() ? target : null;
            }
            case TARGET_SIEGE: {
                return target != null && !target.isDead() && target.isDoor() ? target : null;
            }
        }
        activeChar.sendMessage("Target type of skill is not currently handled");
        return null;
    }

    public Set<Creature> getTargets(SkillEntry skillEntry, Creature activeChar, Creature aimingTarget, boolean forceUse) {
        if (this.oneTarget() || this.isAoE() && this.isDebuff() && activeChar.isInPeaceZone()) {
            HashSet<Creature> targets = new HashSet<Creature>(1);
            if (!aimingTarget.isInvisible(activeChar)) {
                targets.add(aimingTarget);
            }
            if (this._addSelfTarget) {
                targets.add(activeChar);
            }
            for (Event e : activeChar.getEvents()) {
                e.checkTargetsForSkill(this, targets, activeChar, aimingTarget, forceUse);
            }
            return targets;
        }
        HashSet<Creature> targets = new HashSet<Creature>();
        if (this._addSelfTarget) {
            targets.add(activeChar);
        }
        switch (this._targetType) {
            case TARGET_SELF_AND_SUMMON: {
                int fanAffectRange;
                SummonInstance summon;
                targets.add(activeChar);
                if (!activeChar.isPlayer() || (summon = activeChar.getPlayer().getSummon()) == null || (fanAffectRange = this.getFanRange()[2]) > 0 && summon.isInRange(activeChar, fanAffectRange) || !activeChar.isInRange(summon, this.getAffectRange()) || summon.isInvisible(activeChar)) break;
                targets.add(summon);
                break;
            }
            case TARGET_AREA: 
            case TARGET_FAN: 
            case TARGET_SQUARE: 
            case TARGET_RANGE: 
            case TARGET_AREA_AIM_CORPSE: {
                if (!(aimingTarget.isDead() != this.isCorpse() || this._isUndeadOnly && !aimingTarget.isUndead() || aimingTarget.isInvisible(activeChar))) {
                    targets.add(aimingTarget);
                }
                this.addTargetsToList(skillEntry, targets, aimingTarget, activeChar, forceUse);
                break;
            }
            case TARGET_AURA: 
            case TARGET_GROUND: 
            case TARGET_FAN_PB: 
            case TARGET_SQUARE_PB: 
            case TARGET_RING_RANGE: {
                this.addTargetsToList(skillEntry, targets, activeChar, activeChar, forceUse);
                break;
            }
            case TARGET_COMMCHANNEL: {
                if (activeChar.getPlayer() == null) break;
                if (activeChar.getPlayer().isInParty()) {
                    if (activeChar.getPlayer().getParty().isInCommandChannel()) {
                        for (Player p : activeChar.getPlayer().getParty().getCommandChannel()) {
                            int fanAffectRange = this.getFanRange()[2];
                            if (fanAffectRange > 0 && p.isInRange(activeChar, fanAffectRange) || p.isDead() || this.getAffectRange() != -1 && !p.isInRange(activeChar, this.getAffectRange() == 0 ? 600 : this.getAffectRange()) || p.isInvisible(activeChar)) continue;
                            targets.add(p);
                        }
                        this.addTargetAndPetToList(targets, activeChar.getPlayer(), activeChar.getPlayer());
                        break;
                    }
                    for (Player p : activeChar.getPlayer().getParty().getPartyMembers()) {
                        int fanAffectRange = this.getFanRange()[2];
                        if (fanAffectRange > 0 && p.isInRange(activeChar, fanAffectRange) || p.isDead() || !p.isInRange(activeChar, this.getAffectRange() == -1 || this.getAffectRange() == 0 ? 600 : this.getAffectRange()) || p.isInvisible(activeChar)) continue;
                        targets.add(p);
                    }
                    this.addTargetAndPetToList(targets, activeChar.getPlayer(), activeChar.getPlayer());
                    break;
                }
                targets.add(activeChar);
                this.addTargetAndPetToList(targets, activeChar.getPlayer(), activeChar.getPlayer());
                break;
            }
            case TARGET_SERVITORS: {
                for (Servitor servitor : activeChar.getServitors()) {
                    int fanAffectRange = this.getFanRange()[2];
                    if (fanAffectRange > 0 && servitor.isInRange(activeChar, fanAffectRange) || !activeChar.isInRange(servitor, this.getAffectRange()) || servitor.isInvisible(activeChar)) continue;
                    targets.add(servitor);
                }
                break;
            }
            case TARGET_SERVITOR_AURA: {
                this.addTargetsToList(skillEntry, targets, aimingTarget, activeChar, forceUse);
                break;
            }
            case TARGET_ALLY: 
            case TARGET_CLAN: 
            case TARGET_PARTY: 
            case TARGET_PARTY_WITHOUT_ME: 
            case TARGET_CLAN_ONLY: {
                if (activeChar.isMonster() || activeChar.isSiegeGuard()) {
                    if (this._targetType != SkillTargetType.TARGET_PARTY_WITHOUT_ME) {
                        targets.add(activeChar);
                    }
                    for (Creature c : World.getAroundCharacters(activeChar, this.getAffectRange(), 600)) {
                        int fanAffectRange = this.getFanRange()[2];
                        if (fanAffectRange > 0 && c.isInRange(activeChar, fanAffectRange) || c.isDead() || !c.isMonster() && !c.isSiegeGuard() || c.isInvisible(activeChar)) continue;
                        targets.add(c);
                    }
                    break;
                }
                Player player = activeChar.getPlayer();
                if (player == null) break;
                for (Player target : World.getAroundPlayers(activeChar, this.getAffectRange(), 600)) {
                    int fanAffectRange;
                    boolean check = false;
                    switch (this._targetType) {
                        case TARGET_PARTY: 
                        case TARGET_PARTY_WITHOUT_ME: {
                            check = player.getParty() != null && player.getParty() == target.getParty();
                            break;
                        }
                        case TARGET_CLAN: {
                            check = player.getClanId() != 0 && target.getClanId() == player.getClanId() || player.getParty() != null && target.getParty() == player.getParty();
                            break;
                        }
                        case TARGET_CLAN_ONLY: {
                            check = player.getClanId() != 0 && target.getClanId() == player.getClanId();
                            break;
                        }
                        case TARGET_ALLY: {
                            boolean bl = check = player.getClanId() != 0 && target.getClanId() == player.getClanId() || player.getAllyId() != 0 && target.getAllyId() == player.getAllyId();
                        }
                    }
                    if (!check || player.isInOlympiadMode() && target.isInOlympiadMode() && player.getOlympiadSide() != target.getOlympiadSide() || (fanAffectRange = this.getFanRange()[2]) > 0 && target.isInRange(activeChar, fanAffectRange) || this.checkTarget(skillEntry, player, target, aimingTarget, forceUse, false) != null) continue;
                    this.addTargetAndPetToList(targets, activeChar, target);
                }
                this.addTargetAndPetToList(targets, activeChar, player);
                break;
            }
        }
        for (Event e : activeChar.getEvents()) {
            e.checkTargetsForSkill(this, targets, activeChar, aimingTarget, forceUse);
        }
        if (this.getId() == 933 || this.getId() == 10785) {
            for (Creature target : targets) {
                target.checkAndRemoveInvisible();
            }
        }
        return targets;
    }

    private void addTargetAndPetToList(Set<Creature> targets, Creature actor, Creature target) {
        int fanAffectRange = this.getFanRange()[2];
        if (!(actor != target && this.getAffectRange() != -1 && !actor.isInRange(target, this.getAffectRange()) || fanAffectRange > 0 && actor.isInRange(target, fanAffectRange) || target.isDead() != this.isCorpse())) {
            targets.add(target);
        }
        for (Servitor servitor : target.getServitors()) {
            if (fanAffectRange > 0 && actor.isInRange(servitor, fanAffectRange) || this.getAffectRange() != -1 && !actor.isInRange(servitor, this.getAffectRange()) || servitor.isDead() != this.isCorpse() || servitor.isInvisible(actor)) continue;
            targets.add(servitor);
        }
    }

    private void addTargetsToList(SkillEntry skillEntry, Set<Creature> targets, Creature aimingTarget, Creature activeChar, boolean forceUse) {
        if (this._targetType == SkillTargetType.TARGET_FAN || this._targetType == SkillTargetType.TARGET_FAN_PB) {
            double headingAngle = PositionUtils.convertHeadingToDegree(activeChar.getHeading());
            int fanStartAngle = this.getFanRange()[1];
            int fanRadius = this.getFanRange()[2];
            int fanAngle = this.getFanRange()[3];
            double fanHalfAngle = fanAngle / 2;
            int affectLimit = this.getAffectLimit();
            int affectedCount = targets.size();
            for (Creature c : activeChar.getAroundCharacters(fanRadius, 300)) {
                if (affectedCount < affectLimit) {
                    if (c == null || activeChar == c || activeChar.getPlayer() != null && activeChar.getPlayer() == c.getPlayer() || Math.abs(PositionUtils.calculateAngleFrom(activeChar, c) - (headingAngle + (double)fanStartAngle)) > fanHalfAngle || this.checkTarget(skillEntry, activeChar, c, aimingTarget, forceUse, false) != null) continue;
                    targets.add(c);
                    if (activeChar.getPlayer() != null && activeChar.getPlayer().isDebug()) {
                        activeChar.sendPacket((IBroadcastPacket)new ExShowTracePacket(30000).addTrace(c));
                    }
                    ++affectedCount;
                    continue;
                }
                break;
            }
        } else if (this._targetType == SkillTargetType.TARGET_SQUARE || this._targetType == SkillTargetType.TARGET_SQUARE_PB) {
            int squareStartAngle = this.getFanRange()[1];
            int squareLength = this.getFanRange()[2];
            int squareWidth = this.getFanRange()[3];
            int radius = (int)Math.sqrt(squareLength * squareLength + squareWidth * squareWidth);
            int affectLimit = this.getAffectLimit();
            double rectX = activeChar.getX();
            double rectY = activeChar.getY() - squareWidth / 2;
            double heading = Math.toRadians((double)squareStartAngle + PositionUtils.convertHeadingToDegree(activeChar.getHeading()));
            double cos = Math.cos(-heading);
            double sin = Math.sin(-heading);
            int affectedCount = targets.size();
            for (Creature c : activeChar.getAroundCharacters(radius * (this._targetType == SkillTargetType.TARGET_SQUARE ? 2 : 1), 300)) {
                if (affectedCount < affectLimit) {
                    if (c == null || activeChar == c || activeChar.getPlayer() != null && activeChar.getPlayer() == c.getPlayer()) continue;
                    double xp = c.getX() - activeChar.getX();
                    double yp = c.getY() - activeChar.getY();
                    double xr = (double)activeChar.getX() + xp * cos - yp * sin;
                    double yr = (double)activeChar.getY() + xp * sin + yp * cos;
                    if (!(xr > rectX && xr < rectX + (double)squareLength && yr > rectY && yr < rectY + (double)squareWidth && this.checkTarget(skillEntry, activeChar, c, aimingTarget, forceUse, false) == null)) continue;
                    targets.add(c);
                    if (activeChar.getPlayer() != null && activeChar.getPlayer().isDebug()) {
                        activeChar.sendPacket((IBroadcastPacket)new ExShowTracePacket(30000).addTrace(c));
                    }
                    ++affectedCount;
                    continue;
                }
                break;
            }
        } else {
            List<Creature> arround;
            if (this._targetType == SkillTargetType.TARGET_RANGE) {
                int affectRange = this.getAffectRange();
                int affectLimit = this.getAffectLimit();
                int affectedCount = targets.size();
                for (Creature c : aimingTarget.getAroundCharacters(affectRange, 300)) {
                    if (affectedCount >= affectLimit) break;
                    if (c == null || activeChar == c || activeChar.getPlayer() != null && activeChar.getPlayer() == c.getPlayer() || this.checkTarget(skillEntry, activeChar, c, aimingTarget, forceUse, false) != null) continue;
                    targets.add(c);
                    if (activeChar.getPlayer() != null && activeChar.getPlayer().isDebug()) {
                        activeChar.sendPacket((IBroadcastPacket)new ExShowTracePacket(30000).addTrace(c));
                    }
                    ++affectedCount;
                }
                return;
            }
            if (this._targetType == SkillTargetType.TARGET_RING_RANGE) {
                int affectRange = this.getAffectRange();
                int affectLimit = this.getAffectLimit();
                int startRange = this.getFanRange()[2];
                int affectedCount = targets.size();
                for (Creature c : aimingTarget.getAroundCharacters(affectRange, 300)) {
                    if (affectedCount >= affectLimit) break;
                    if (c == null || activeChar == c || activeChar.getPlayer() != null && activeChar.getPlayer() == c.getPlayer() || c.isInRange(aimingTarget, startRange) || this.checkTarget(skillEntry, activeChar, c, aimingTarget, forceUse, false) != null) continue;
                    targets.add(c);
                    if (activeChar.getPlayer() != null && activeChar.getPlayer().isDebug()) {
                        activeChar.sendPacket((IBroadcastPacket)new ExShowTracePacket(30000).addTrace(c));
                    }
                    ++affectedCount;
                }
                return;
            }
            Polygon terr = null;
            if (this._targetType == SkillTargetType.TARGET_GROUND) {
                if (!activeChar.isPlayer()) {
                    return;
                }
                Location loc = activeChar.getPlayer().getGroundSkillLoc();
                if (loc == null) {
                    return;
                }
                arround = World.getAroundCharacters(loc, aimingTarget.getObjectId(), aimingTarget.getReflectionId(), this.getAffectRange(), 300);
            } else {
                arround = aimingTarget.getAroundCharacters(this.getAffectRange(), 300);
                if (this._targetType == SkillTargetType.TARGET_AREA && this.getBehindRadius() > 0) {
                    int zmin1 = activeChar.getZ() - 200;
                    int zmax1 = activeChar.getZ() + 200;
                    int zmin2 = aimingTarget.getZ() - 200;
                    int zmax2 = aimingTarget.getZ() + 200;
                    double radian = PositionUtils.convertHeadingToDegree(activeChar.getHeading()) + (double)(this.getBehindRadius() / 2);
                    if (radian > 360.0) {
                        radian -= 360.0;
                    }
                    radian = Math.PI * radian / 180.0;
                    int x1 = aimingTarget.getX() + (int)(Math.cos(radian) * (double)this.getAffectRange());
                    int y1 = aimingTarget.getY() + (int)(Math.sin(radian) * (double)this.getAffectRange());
                    radian = PositionUtils.convertHeadingToDegree(activeChar.getHeading()) - (double)(this.getBehindRadius() / 2);
                    if (radian > 360.0) {
                        radian -= 360.0;
                    }
                    radian = Math.PI * radian / 180.0;
                    int x2 = aimingTarget.getX() + (int)(Math.cos(radian) * (double)this.getAffectRange());
                    int y2 = aimingTarget.getY() + (int)(Math.sin(radian) * (double)this.getAffectRange());
                    terr = new Polygon().add(aimingTarget.getX(), aimingTarget.getY()).add(x1, y1).add(x2, y2).setZmin(Math.min(zmin1, zmin2)).setZmax(Math.max(zmax1, zmax2));
                }
            }
            int affectLimit = this.getAffectLimit();
            if (affectLimit == 0) {
                affectLimit = this.isDebuff() && !activeChar.isRaid() ? 20 : 256;
            }
            int affectedCount = targets.size();
            for (Creature target : arround) {
                if (affectedCount < affectLimit) {
                    if (terr != null && !terr.isInside(target.getX(), target.getY(), target.getZ()) || target == null || activeChar == target || activeChar.getPlayer() != null && activeChar.getPlayer() == target.getPlayer() || this.checkTarget(skillEntry, activeChar, target, aimingTarget, forceUse, false) != null) continue;
                    targets.add(target);
                    if (activeChar.getPlayer() != null && activeChar.getPlayer().isDebug()) {
                        activeChar.sendPacket((IBroadcastPacket)new ExShowTracePacket(30000).addTrace(target));
                    }
                    ++affectedCount;
                    continue;
                }
                break;
            }
        }
    }

    public void checkTargetsEffectiveRange(Creature caster, Set<Creature> targets) {
        if (targets == null) {
            return;
        }
        Iterator<Creature> iterator = targets.iterator();
        while (iterator.hasNext()) {
            Creature target = iterator.next();
            if (this.getEffectiveRange() == -1 || caster.isInRangeZ(target, this.getEffectiveRange())) continue;
            iterator.remove();
        }
    }

    public boolean calcCriticalBlow(Creature caster, Creature target) {
        return false;
    }

    public final boolean calcEffectsSuccess(Creature effector, Creature effected, boolean showMsg) {
        int chance = this.getActivateRate();
        if (chance >= 0 && !Formulas.calcEffectsSuccess(effector, effected, this, chance)) {
            if (showMsg) {
                effector.sendPacket((IBroadcastPacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.C1_HAS_RESISTED_YOUR_S2).addName(effected)).addSkillName(this));
                effector.sendPacket((IBroadcastPacket)new ExMagicAttackInfo(effector.getObjectId(), effected.getObjectId(), 6));
            }
            return false;
        }
        if (effected.getStat().calc(Stats.MarkOfTrick) == 1.0 && Rnd.chance((int)20)) {
            if (showMsg) {
                effector.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_HAS_FAILED).addSkillName(this));
            }
            return false;
        }
        return true;
    }

    public final boolean getEffects(Creature effector, Creature effected) {
        return this.getEffects(effector, effected, true);
    }

    public final boolean getEffects(Creature effector, Creature effected, boolean saveable) {
        double timeMult = 1.0;
        if (this.isMusic()) {
            timeMult = Config.SONGDANCETIME_MODIFIER;
        } else if (this.getId() >= 4342 && this.getId() <= 4360) {
            timeMult = Config.CLANHALL_BUFFTIME_MODIFIER;
        } else if (Config.BUFFTIME_MODIFIER_SKILLS.length > 0) {
            for (int i : Config.BUFFTIME_MODIFIER_SKILLS) {
                if (i != this.getId()) continue;
                timeMult = Config.BUFFTIME_MODIFIER;
            }
        }
        return this.getEffects(effector, effected, 0, timeMult, saveable);
    }

    public final boolean getEffects(Creature effector, Creature effected, int timeConst, double timeMult) {
        return this.getEffects(effector, effected, timeConst, timeMult, true);
    }

    public final boolean getEffects(Creature effector, Creature effected, int timeConst, double timeMult, boolean saveable) {
        return this.getEffects(effector, effected, EffectUseType.NORMAL, timeConst, timeMult, saveable);
    }

    private final boolean getEffects(Creature effector, Creature effected, EffectUseType useType, int timeConst, double timeMult, boolean saveable) {
        Creature owner;
        if (this.isPassive() || effector == null) {
            return false;
        }
        if (useType.isInstant()) {
            _log.warn("Cannot get effects from instant effect use type:");
            Thread.dumpStack();
            return false;
        }
        if (!this.isToggle()) {
            // empty if block
        }
        if (!this.hasEffects(useType)) {
            return true;
        }
        if (effected == null || effected.isDoor() || effected.isDead() && !this.isPreservedOnDeath()) {
            return false;
        }
        if (effector != effected && useType == EffectUseType.NORMAL && effected.isEffectImmune(effector)) {
            return false;
        }
        boolean reflected = false;
        if (useType == EffectUseType.NORMAL) {
            reflected = effected.checkReflectDebuff(effector, this);
        }
        HashSet<Creature> targets = new HashSet<Creature>(1);
        if (useType == EffectUseType.SELF) {
            targets.add(effector);
        } else if (reflected) {
            targets.add(effector);
        } else {
            targets.add(effected);
        }
        if (useType == EffectUseType.NORMAL && (this.applyEffectsOnSummon() || this.applyEffectsOnPet()) && !this.isDebuff() && !this.isToggle() && !this.isCubicSkill() && (owner = reflected ? effector : effected).isPlayer()) {
            for (Servitor servitor : owner.getPlayer().getServitors()) {
                if (this.applyEffectsOnSummon() && servitor.isSummon()) {
                    targets.add(servitor);
                    continue;
                }
                if (!this.applyEffectsOnPet() || !servitor.isPet()) continue;
                targets.add(servitor);
            }
        }
        boolean successOnEffected = false;
        for (Creature target : targets) {
            Abnormal abnormal = new Abnormal(effector, target, this, useType, saveable);
            double abnormalTimeModifier = Math.max(1.0, timeMult);
            if (!this.isToggle() && !this.isCubicSkill()) {
                abnormalTimeModifier *= target.getStat().calc(this.isDebuff() ? Stats.DEBUFF_TIME_MODIFIER : Stats.BUFF_TIME_MODIFIER, null, null);
            }
            int duration = abnormal.getDuration();
            if (timeConst > 0) {
                duration = timeConst / 1000;
            } else if (abnormalTimeModifier > 1.0) {
                duration = (int)((double)duration * abnormalTimeModifier);
            }
            abnormal.setDuration(duration);
            if (abnormal.apply(effected)) {
                if (abnormal.isActive()) {
                    for (EffectHandler effect : abnormal.getEffects()) {
                        effect.onApplied(abnormal, abnormal.getEffector(), abnormal.getEffected());
                    }
                }
                if (this.isDebuff() && this.getBasicProperty() != BasicProperty.NONE && target.hasBasicPropertyResist()) {
                    target.getBasicPropertyResist(this.getBasicProperty()).increaseResistLevel();
                }
                if (target == effected) {
                    successOnEffected = true;
                }
            }
            if (target != effected || !reflected) continue;
            target.sendPacket((IBroadcastPacket)new SystemMessage(1998).addName(effector));
            effector.sendPacket((IBroadcastPacket)new SystemMessage(1999).addName(target));
        }
        return successOnEffected;
    }

    public final void attachEffect(EffectTemplate effect) {
        if (effect == null) {
            return;
        }
        ((List)this._effectTemplates.get(effect.getUseType().ordinal())).add(effect);
    }

    public List<EffectTemplate> getEffectTemplates(EffectUseType useType) {
        return (List)this._effectTemplates.get(useType.ordinal());
    }

    public int getEffectsCount(EffectUseType useType) {
        return this.getEffectTemplates(useType).size();
    }

    public boolean hasEffects(EffectUseType useType) {
        return this.getEffectsCount(useType) > 0;
    }

    public boolean hasEffect(EffectUseType useType, String name) {
        List<EffectTemplate> templates = this.getEffectTemplates(useType);
        for (EffectTemplate et : templates) {
            if (!et.getName().equalsIgnoreCase(name)) continue;
            return true;
        }
        return false;
    }

    public final Func[] getStatFuncs() {
        return this.getStatFuncs(this);
    }

    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof Skill)) {
            return false;
        }
        Skill skill = (Skill)obj;
        EqualsBuilder builder = new EqualsBuilder();
        builder.append(this.getId(), skill.getId());
        builder.append(this.getLevel(), skill.getLevel());
        builder.append(this.getClass(), skill.getClass());
        return builder.isEquals();
    }

    public int getReuseSkillId() {
        return this._reuseSkillId;
    }

    public int getReuseHash() {
        return this._reuseHash;
    }

    public int hashCode() {
        return this._hashCode;
    }

    public final void attachCondition(Condition c) {
        this._preCondition = (Condition[])ArrayUtils.add((Object[])this._preCondition, (Object)c);
    }

    public final Condition[] getConditions() {
        return this._preCondition;
    }

    public final boolean isAltUse(SkillEntryType entryType) {
        return (this._altUse || this._isItemHandler || entryType == SkillEntryType.CUNSUMABLE_ITEM) && this._hitTime <= 0;
    }

    public final int getActivateRate() {
        return this._activateRate;
    }

    public AddedSkill[] getAddedSkills() {
        return this._addedSkills;
    }

    public final int getCastRange() {
        return this._castRange;
    }

    public final int getAOECastRange() {
        return Math.max(this.getCastRange(), this.getAffectRange());
    }

    public int getCondCharges() {
        return this._condCharges;
    }

    public final int getCoolTime() {
        return this._coolTime;
    }

    public boolean isCorpse() {
        return this._isCorpse || this._targetType == SkillTargetType.TARGET_CORPSE || this._targetType == SkillTargetType.TARGET_CORPSE_PLAYER;
    }

    @Override
    public final int getDisplayId() {
        return this._displayId;
    }

    @Override
    public int getDisplayLevel() {
        return this._displayLevel;
    }

    @Override
    public final Skill getTemplate() {
        return this;
    }

    public int getEffectPoint() {
        return this._effectPoint;
    }

    public Abnormal getSameByAbnormalType(Collection<Abnormal> list) {
        for (Abnormal abnormal : list) {
            if (abnormal == null || !AbnormalList.checkAbnormalType(abnormal.getSkill(), this)) continue;
            return abnormal;
        }
        return null;
    }

    public Abnormal getSameByAbnormalType(AbnormalList list) {
        return this.getSameByAbnormalType(list.values());
    }

    public Abnormal getSameByAbnormalType(Creature actor) {
        return this.getSameByAbnormalType(actor.getAbnormalList());
    }

    public final Element getElement() {
        return this._element;
    }

    public final int getElementPower() {
        return this._elementPower;
    }

    public SkillEntry getFirstAddedSkill() {
        if (this._addedSkills.length == 0) {
            return null;
        }
        return this._addedSkills[0].getSkill();
    }

    public int getFlyRadius() {
        return this._flyRadius;
    }

    public int getFlyPositionDegree() {
        return this._flyPositionDegree;
    }

    public FlyToLocationPacket.FlyType getFlyType() {
        return this._flyType;
    }

    public boolean isFlyDependsOnHeading() {
        return this._flyDependsOnHeading;
    }

    public int getFlySpeed() {
        return this._flySpeed;
    }

    public int getFlyDelay() {
        return this._flyDelay;
    }

    public int getFlyAnimationSpeed() {
        return this._flyAnimationSpeed;
    }

    public final int getHitTime() {
        if (this._hitTime < Config.MIN_HIT_TIME) {
            return Config.MIN_HIT_TIME;
        }
        return this._hitTime;
    }

    public final int getHpConsume() {
        return this._hpConsume;
    }

    @Override
    public final int getId() {
        return this._id;
    }

    public final long getItemConsume() {
        return this._itemConsume;
    }

    public final int getItemConsumeId() {
        return this._itemConsumeId;
    }

    public final boolean isItemConsumeFromMaster() {
        return this._itemConsumeFromMaster;
    }

    public final int getReferenceItemId() {
        return this._referenceItemId;
    }

    public final int getReferenceItemMpConsume() {
        return this._referenceItemMpConsume;
    }

    @Override
    public final int getLevel() {
        return this._level;
    }

    public final int getMaxLevel() {
        return this._maxLevel;
    }

    public final int getLevelBonusRate() {
        return this._levelBonusRate;
    }

    public final int getMagicLevel() {
        return this._magicLevel;
    }

    public int getMatak() {
        return this._matak;
    }

    public PledgeRank getMinPledgeRank() {
        return this._minPledgeRank;
    }

    public boolean clanLeaderOnly() {
        return this._clanLeaderOnly;
    }

    public final double getMpConsume() {
        return this._mpConsume1 + this._mpConsume2;
    }

    public final double getMpConsume1() {
        return this._mpConsume1;
    }

    public final double getMpConsume2() {
        return this._mpConsume2;
    }

    public final double getMpConsumeTick() {
        return this._mpConsumeTick;
    }

    public final String getName() {
        return this._name;
    }

    public final String getName(Player player) {
        String name = SkillNameHolder.getInstance().getSkillName(player, this);
        return name == null ? this._name : name;
    }

    public final NextAction getNextAction() {
        return this._nextAction;
    }

    public final int getNpcId() {
        return this._npcId;
    }

    public final int getNumCharges() {
        return this._numCharges;
    }

    public final double getPower(Creature target) {
        if (target != null) {
            if (target.isPlayable()) {
                return this.getPowerPvP();
            }
            if (target.isNpc()) {
                return this.getPowerPvE();
            }
        }
        return this.getPower();
    }

    public final double getPower() {
        return this._power;
    }

    public final double getPowerPvP() {
        return this._powerPvP != 0.0 ? this._powerPvP : this._power;
    }

    public final double getPowerPvE() {
        return this._powerPvE != 0.0 ? this._powerPvE : this._power;
    }

    public final int getReuseDelay() {
        return this._reuseDelay;
    }

    public final boolean getShieldIgnore() {
        return this._isShieldignore;
    }

    public final double getShieldIgnorePercent() {
        return this._shieldIgnorePercent;
    }

    public final boolean isReflectable() {
        return this._isReflectable;
    }

    public final int getHitCancelTime() {
        return this._hitCancelTime;
    }

    public final AddedSkill getAttachedSkill() {
        return this._attachedSkill;
    }

    public final int getChannelingStart() {
        return this._channelingStart;
    }

    public final int getAffectRange() {
        return this._affectRange;
    }

    public final int[] getFanRange() {
        return this._fanRange;
    }

    public final int getAffectLimit() {
        if (this._affectLimit[0] > 0 || this._affectLimit[1] > 0) {
            return this._affectLimit[0] + (this._affectLimit[1] > 0 ? Rnd.get((int)this._affectLimit[1]) : 0);
        }
        return 0;
    }

    public final int getEffectiveRange() {
        return this._effectiveRange;
    }

    public final SkillType getSkillType() {
        return this._skillType;
    }

    public final SkillTargetType getTargetType() {
        return this._targetType;
    }

    public final SkillTrait getTraitType() {
        return this._traitType;
    }

    public final boolean isDispelOnDamage() {
        return this._dispelOnDamage;
    }

    public double getLethal1(Creature self) {
        return this._lethal1 + this.getAddedLethal1(self);
    }

    public double getIncreaseOnPole() {
        return this._increaseOnPole;
    }

    public double getDecreaseOnNoPole() {
        return this._decreaseOnNoPole;
    }

    public boolean isDetectPC() {
        return this._detectPcHide;
    }

    public double getLethal2(Creature self) {
        return this._lethal2 + this.getAddedLethal2(self);
    }

    private double getAddedLethal2(Creature self) {
        Player player = self.getPlayer();
        if (player == null) {
            return 0.0;
        }
        if (this._lethal2Addon == 0.0 || this._lethal2SkillDepencensyAddon == 0) {
            return 0.0;
        }
        if (player.getAbnormalList().contains(this._lethal2SkillDepencensyAddon)) {
            return this._lethal2Addon;
        }
        return 0.0;
    }

    private double getAddedLethal1(Creature self) {
        Player player = self.getPlayer();
        if (player == null) {
            return 0.0;
        }
        if (this._lethal1Addon == 0.0 || this._lethal1SkillDepencensyAddon == 0) {
            return 0.0;
        }
        if (player.getAbnormalList().contains(this._lethal1SkillDepencensyAddon)) {
            return this._lethal1Addon;
        }
        return 0.0;
    }

    public String getBaseValues() {
        return this._baseValues;
    }

    public final boolean isCancelable() {
        return this._isCancelable && this._isSelfDispellable && !this.hasEffect(EffectUseType.NORMAL, "Transformation") && !this.isToggle() && !this.isAura();
    }

    public final boolean isSelfDispellable() {
        return this._isSelfDispellable && !this.hasEffect(EffectUseType.NORMAL, "Transformation") && !this.isToggle() && !this.isDebuff() && !this.isMusic();
    }

    public final int getCriticalRate() {
        return this._criticalRate;
    }

    public final double getCriticalRateMod() {
        return this._criticalRateMod;
    }

    public final boolean isHandler() {
        return this._isItemHandler;
    }

    public final boolean isMagic() {
        return this._magicType == SkillMagicType.MAGIC || this._magicType == SkillMagicType.SPECIAL || this._magicType == SkillMagicType.AWAKED_BUFF;
    }

    public final boolean isPhysic() {
        if (this._magicType == SkillMagicType.UNK_MAG_TYPE_21) {
            return true;
        }
        return this._magicType == SkillMagicType.PHYSIC || this._magicType == SkillMagicType.MUSIC || this._magicType == SkillMagicType.ITEM;
    }

    public final boolean isSpecial() {
        return this._magicType == SkillMagicType.SPECIAL;
    }

    public final boolean isMusic() {
        return this._magicType == SkillMagicType.MUSIC;
    }

    public final SkillMagicType getMagicType() {
        return this._magicType;
    }

    public final boolean isNewbie() {
        return this._isNewbie;
    }

    public final boolean isPreservedOnDeath() {
        return this._isPreservedOnDeath || this.isNecessaryToggle();
    }

    public final boolean isOverhit() {
        return this._isOverhit;
    }

    public boolean isSaveable() {
        if (!Config.ALT_SAVE_UNSAVEABLE && (this.isMusic() || this.isAbnormalInstant())) {
            return false;
        }
        return this._isSaveable || this.isToggle() && this.isNecessaryToggle();
    }

    public final boolean isSkillTimePermanent() {
        return this._isSkillTimePermanent || this.isHandler() || this._name.contains("Talisman") || this.isChanneling();
    }

    public final boolean isReuseDelayPermanent() {
        return this._isReuseDelayPermanent || this.isHandler();
    }

    public boolean isDeathlink() {
        return this._deathlink;
    }

    public boolean isBasedOnTargetDebuff() {
        return this._basedOnTargetDebuff;
    }

    public boolean isChargeBoost() {
        return this._isChargeBoost;
    }

    public boolean isBehind() {
        return this._isBehind;
    }

    public boolean isHideStartMessage() {
        return this._hideStartMessage || this.isHidingMesseges();
    }

    public boolean isHideUseMessage() {
        return this._hideUseMessage || this.isHidingMesseges();
    }

    public boolean isSSPossible() {
        if (this.isAura()) {
            return false;
        }
        if (this._isUseSS == Ternary.TRUE) {
            return true;
        }
        if (this._isUseSS == Ternary.FALSE) {
            return false;
        }
        if (this._isUseSS == Ternary.DEFAULT) {
            if (this.isHandler()) {
                return false;
            }
            if (this.isSpecial()) {
                return false;
            }
            if (this.isMusic()) {
                return false;
            }
            if (!this.isActive()) {
                return false;
            }
            if (this.getTargetType() == SkillTargetType.TARGET_SELF && !this.isMagic()) {
                return false;
            }
            if (this.isPhysic()) {
                if (this.getSkillType() == SkillType.CHARGE) {
                    return true;
                }
                if (this.getSkillType() == SkillType.DRAIN) {
                    return true;
                }
                if (this.getSkillType() == SkillType.LETHAL_SHOT) {
                    return true;
                }
                if (this.getSkillType() == SkillType.PDAM) {
                    return true;
                }
                if (this.getSkillType() == SkillType.DEBUFF) {
                    for (EffectUseType useType : EffectUseType.VALUES) {
                        if (useType.isSelf()) continue;
                        if (this.hasEffect(useType, "i_p_attack")) {
                            return true;
                        }
                        if (this.hasEffect(useType, "i_m_attack")) {
                            return true;
                        }
                        if (!this.hasEffect(useType, "i_hp_drain")) continue;
                        return true;
                    }
                }
                return false;
            }
            return true;
        }
        return false;
    }

    public final boolean isSuicideAttack() {
        return this._isSuicideAttack;
    }

    public boolean isActive() {
        return this._operateType.isActive();
    }

    public boolean isPassive() {
        return this._operateType.isPassive();
    }

    public boolean isToggle() {
        return this._operateType.isToggle();
    }

    public boolean isToggleGrouped() {
        return this._operateType.isToggleGrouped();
    }

    public boolean isAura() {
        return this._operateType.isAura();
    }

    public boolean isHidingMesseges() {
        return this._operateType.isHidingMesseges();
    }

    public boolean isNotBroadcastable() {
        return this._operateType.isNotBroadcastable();
    }

    public boolean isContinuous() {
        return this._operateType.isContinuous() || this.isSelfContinuous();
    }

    public boolean isSelfContinuous() {
        return this._operateType.isSelfContinuous();
    }

    public boolean isChanneling() {
        return this._operateType.isChanneling();
    }

    public boolean isSynergy() {
        return this._operateType.isSynergy();
    }

    public void setDisplayLevel(int lvl) {
        this._displayLevel = lvl;
    }

    public final boolean isItemSkill() {
        return this._isItemSkill;
    }

    public String toString() {
        return String.format("%s[id=%d, lvl=%d, hash_code=%d]", this._name, this._id, this._level, this.hashCode());
    }

    private final boolean checkCastTarget(Creature target) {
        return !target.isIgnoredSkill(this);
    }

    private final boolean applyEffectPoint(Creature activeChar, Creature target) {
        if (!this.isAI() && this.getEffectPoint() < 0) {
            activeChar.getAI().notifyEvent(CtrlEvent.EVT_ATTACK, target, this, Math.abs(this.getEffectPoint()));
            target.getAI().notifyEvent(CtrlEvent.EVT_ATTACKED, activeChar, this, Math.abs(this.getEffectPoint()));
            return true;
        }
        return false;
    }

    public final void onStartCast(SkillEntry skillEntry, Creature activeChar, Creature target) {
        if (target == null) {
            return;
        }
        if (this.isPassive()) {
            return;
        }
        if (!this.hasEffects(EffectUseType.START)) {
            return;
        }
        boolean startAttackStance = false;
        if (!this.checkCastTarget(target)) {
            return;
        }
        if (this.applyEffectPoint(activeChar, target)) {
            startAttackStance = true;
        }
        for (EffectTemplate et : this.getEffectTemplates(EffectUseType.START)) {
            this.useInstantEffect(et, activeChar, target, false);
        }
        if (this.isSSPossible() && (!Config.SAVING_SPS || this._skillType != SkillType.BUFF)) {
            activeChar.unChargeShots(this.isMagic());
        }
        if (startAttackStance) {
            activeChar.startAttackStanceTask();
        }
    }

    public final void onTickCast(Creature activeChar, Set<Creature> targets) {
        if (this.isPassive()) {
            return;
        }
        if (!this.isChanneling()) {
            return;
        }
        boolean startAttackStance = false;
        AddedSkill attachedSkill = this.getAttachedSkill();
        if (attachedSkill != null) {
            SkillEntry skillEntry = attachedSkill.getSkill();
            if (skillEntry == null) {
                return;
            }
            Skill skill = skillEntry.getTemplate();
            for (Creature target : targets) {
                boolean successEffect;
                if (target == null || !skill.checkCastTarget(target)) continue;
                if (skill.applyEffectPoint(activeChar, target)) {
                    startAttackStance = true;
                }
                boolean reflected = target.checkReflectSkill(activeChar, skill);
                boolean bl = successEffect = skill.hasEffects(EffectUseType.NORMAL) && skill.calcEffectsSuccess(activeChar, target, true);
                if (successEffect || !skill.hasEffects(EffectUseType.NORMAL) || !this._noEffectsIfFailSkill) {
                    skill.useSkill(activeChar, target, reflected);
                    for (EffectTemplate et : skill.getEffectTemplates(EffectUseType.NORMAL_INSTANT)) {
                        skill.useInstantEffect(et, activeChar, target, reflected);
                    }
                }
                if (!successEffect) continue;
                skill.getEffects(activeChar, target);
            }
        } else if (this.hasEffects(EffectUseType.TICK)) {
            for (Creature target : targets) {
                if (target == null || !this.checkCastTarget(target)) continue;
                if (this.applyEffectPoint(activeChar, target)) {
                    startAttackStance = true;
                }
                for (EffectTemplate et : this.getEffectTemplates(EffectUseType.TICK)) {
                    this.useInstantEffect(et, activeChar, target, false);
                }
            }
        }
        if (this.isSSPossible() && (!Config.SAVING_SPS || this._skillType != SkillType.BUFF)) {
            activeChar.unChargeShots(this.isMagic());
        }
        if (startAttackStance) {
            activeChar.startAttackStanceTask();
        }
    }

    public void onEndCast(Creature activeChar, Set<Creature> targets) {
        if (this.isPassive()) {
            return;
        }
        if (!this.isNotTargetAoE() || !this.isDebuff() || targets.size() != 0) {
            for (EffectTemplate et : this.getEffectTemplates(EffectUseType.SELF_INSTANT)) {
                this.useInstantEffect(et, activeChar, activeChar, false);
            }
            this.getEffects(activeChar, activeChar, EffectUseType.SELF, 0, 1.0, true);
        }
        boolean startAttackStance = false;
        for (Creature target : targets) {
            boolean successEffect;
            if (target == null || !this.checkCastTarget(target)) continue;
            if (this.applyEffectPoint(activeChar, target)) {
                startAttackStance = true;
            }
            boolean reflected = target.checkReflectSkill(activeChar, this);
            boolean bl = successEffect = this.hasEffects(EffectUseType.NORMAL) && this.calcEffectsSuccess(activeChar, target, true);
            if (successEffect || !this.hasEffects(EffectUseType.NORMAL) || !this._noEffectsIfFailSkill) {
                this.useSkill(activeChar, target, reflected);
                for (EffectTemplate et : this.getEffectTemplates(EffectUseType.NORMAL_INSTANT)) {
                    this.useInstantEffect(et, activeChar, target, reflected);
                }
            }
            if (!successEffect) continue;
            this.getEffects(activeChar, target);
        }
        if (this.isSSPossible() && (!Config.SAVING_SPS || this._skillType != SkillType.BUFF)) {
            activeChar.unChargeShots(this.isMagic());
        }
        if (this.isSuicideAttack()) {
            activeChar.doDie(null);
        } else if (startAttackStance) {
            activeChar.startAttackStanceTask();
        }
    }

    public void onFinishCast(Creature aimingTarget, Creature activeChar, Set<Creature> targets) {
        block3: {
            block4: {
                block5: {
                    if (!this.isDebuff()) break block3;
                    if (this.getTargetType() != SkillTargetType.TARGET_AREA_AIM_CORPSE) break block4;
                    if (!aimingTarget.isNpc()) break block5;
                    ((NpcInstance)aimingTarget).endDecayTask();
                    break block3;
                }
                if (!aimingTarget.isSummon()) break block3;
                ((SummonInstance)aimingTarget).endDecayTask();
                break block3;
            }
            if (this.getTargetType() == SkillTargetType.TARGET_CORPSE) {
                for (Creature target : targets) {
                    if (target.isNpc()) {
                        ((NpcInstance)target).endDecayTask();
                        continue;
                    }
                    if (!target.isSummon()) continue;
                    ((SummonInstance)target).endDecayTask();
                }
            }
        }
    }

    public void onAbnormalTimeEnd(Creature activeChar, Creature target) {
        if (!this.checkCastTarget(target)) {
            return;
        }
        for (EffectTemplate et : this.getEffectTemplates(EffectUseType.END)) {
            this.useInstantEffect(et, activeChar, target, false);
        }
    }

    protected void useSkill(Creature activeChar, Creature target, boolean reflected) {
    }

    private boolean useInstantEffect(EffectTemplate et, Creature activeChar, Creature target, boolean reflected) {
        if (!et.isInstant()) {
            return false;
        }
        if (!et.getTargetType().checkTarget(target)) {
            return false;
        }
        if (et.getChance() >= 0 && !Rnd.chance((int)et.getChance())) {
            return false;
        }
        EffectHandler handler = et.getHandler();
        if (!handler.checkConditionImpl(activeChar, target)) {
            return false;
        }
        handler.instantUse(activeChar, target, reflected);
        return true;
    }

    public boolean isAoE() {
        switch (this._targetType) {
            case TARGET_AURA: 
            case TARGET_GROUND: 
            case TARGET_FAN_PB: 
            case TARGET_SQUARE_PB: 
            case TARGET_SERVITOR_AURA: 
            case TARGET_AREA: 
            case TARGET_FAN: 
            case TARGET_SQUARE: 
            case TARGET_RANGE: 
            case TARGET_RING_RANGE: 
            case TARGET_AREA_AIM_CORPSE: {
                return true;
            }
        }
        return false;
    }

    public boolean isNotTargetAoE() {
        switch (this._targetType) {
            case TARGET_ALLY: 
            case TARGET_CLAN: 
            case TARGET_PARTY: 
            case TARGET_PARTY_WITHOUT_ME: 
            case TARGET_CLAN_ONLY: 
            case TARGET_AURA: 
            case TARGET_GROUND: 
            case TARGET_FAN_PB: 
            case TARGET_SQUARE_PB: {
                return true;
            }
        }
        return false;
    }

    public boolean isDebuff() {
        return this._isDebuff;
    }

    public final boolean isForceUse() {
        return this._isForceUse;
    }

    public boolean isAI() {
        return this._skillType.isAI();
    }

    public boolean isPvM() {
        return this._isPvm;
    }

    public final boolean isPvpSkill() {
        return this._isPvpSkill;
    }

    public boolean isTrigger() {
        return this._isTrigger;
    }

    public boolean oneTarget() {
        switch (this._targetType) {
            case TARGET_SELF: 
            case TARGET_HOLY: 
            case TARGET_FLAGPOLE: 
            case TARGET_UNLOCKABLE: 
            case TARGET_CHEST: 
            case TARGET_ONE_SERVITOR: 
            case TARGET_ONE_SERVITOR_NO_TARGET: 
            case TARGET_SUMMON: 
            case TARGET_PET: 
            case TARGET_OWNER: 
            case TARGET_ENEMY_PET: 
            case TARGET_ENEMY_SUMMON: 
            case TARGET_ENEMY_SERVITOR: 
            case TARGET_ONE: 
            case TARGET_CLAN_ONE: 
            case TARGET_PARTY_ONE: 
            case TARGET_PARTY_ONE_WITHOUT_ME: 
            case TARGET_CORPSE: 
            case TARGET_CORPSE_PLAYER: 
            case TARGET_SIEGE: 
            case TARGET_ITEM: 
            case TARGET_NONE: {
                return true;
            }
        }
        return false;
    }

    public boolean isSkillInterrupt() {
        return this._skillInterrupt;
    }

    public boolean isNotUsedByAI() {
        return this._isNotUsedByAI;
    }

    public boolean isIgnoreResists() {
        return this._isIgnoreResists;
    }

    public boolean isIgnoreInvul() {
        return this._isIgnoreInvul;
    }

    public boolean isNotAffectedByMute() {
        return this._isNotAffectedByMute;
    }

    public boolean flyingTransformUsage() {
        return this._flyingTransformUsage;
    }

    public final boolean canUseTeleport() {
        return this._canUseTeleport;
    }

    public int getTickInterval() {
        return this._tickInterval;
    }

    public double getSimpleDamage(Creature attacker, Creature target) {
        if (this.isMagic()) {
            double mAtk = attacker.getMAtk(target, this);
            double mdef = target.getMDef(null, this);
            double power = this.getPower();
            double shotPower = (100.0 + (this.isSSPossible() ? attacker.getChargedSpiritshotPower() : 0.0)) / 100.0;
            return 91.0 * power * Math.sqrt(shotPower * mAtk) / mdef;
        }
        double pAtk = attacker.getPAtk(target);
        double pdef = target.getPDef(attacker);
        double power = this.getPower();
        double shotPower = (100.0 + (this.isSSPossible() ? attacker.getChargedSoulshotPower() : 0.0)) / 100.0;
        return shotPower * (pAtk + power) * 70.0 / pdef;
    }

    public long getReuseForMonsters() {
        long min = 1000L;
        switch (this._skillType) {
            case DEBUFF: 
            case PARALYZE: 
            case STEAL_BUFF: {
                min = 10000L;
                break;
            }
            case MUTE: 
            case ROOT: 
            case SLEEP: 
            case STUN: {
                min = 5000L;
            }
        }
        return Math.max((long)Math.max(this._hitTime + this._coolTime, this._reuseDelay), min);
    }

    public double getAbsorbPart() {
        return this._absorbPart;
    }

    public boolean isProvoke() {
        return this._isProvoke;
    }

    public String getIcon() {
        return this._icon;
    }

    public int getEnergyConsume() {
        return this._energyConsume;
    }

    public int getClanRepConsume() {
        return this._cprConsume;
    }

    public int getFameConsume() {
        return this._fameConsume;
    }

    public void setCubicSkill(boolean value) {
        this._isCubicSkill = value;
    }

    public boolean isCubicSkill() {
        return this._isCubicSkill;
    }

    public int[] getRelationSkills() {
        return this._relationSkillsId;
    }

    public boolean isRelationSkill() {
        return this._isRelation;
    }

    public boolean isAbortable() {
        return this._abortable;
    }

    public boolean isCanUseWhileAbnormal() {
        return this._canUseWhileAbnormal;
    }

    public int getToggleGroupId() {
        return this._toggleGroupId;
    }

    public boolean isNecessaryToggle() {
        return this.isToggle() && this._isNecessaryToggle;
    }

    public boolean isDoNotDispelOnSelfBuff() {
        return this._isNotDispelOnSelfBuff;
    }

    public int getAbnormalTime() {
        return this._abnormalTime;
    }

    public int getAbnormalLvl() {
        return this._abnormalLvl;
    }

    public AbnormalType getAbnormalType() {
        return this._abnormalType;
    }

    public AbnormalEffect[] getAbnormalEffects() {
        return this._abnormalEffects;
    }

    public boolean isAbnormalHideTime() {
        return this._abnormalHideTime || this._operateType.isAura();
    }

    public boolean isAbnormalCancelOnAction() {
        return this._abnormalCancelOnAction;
    }

    public boolean isIrreplaceableBuff() {
        return this._irreplaceableBuff;
    }

    public boolean isAbnormalInstant() {
        return this._abnormalInstant;
    }

    public boolean checkRideState(MountType mountType) {
        int v = 1 << mountType.ordinal();
        return (this._rideState & v) == v;
    }

    public final boolean applyEffectsOnSummon() {
        return this._applyEffectsOnSummon;
    }

    public final boolean applyEffectsOnPet() {
        return this._applyEffectsOnPet;
    }

    public final boolean isApplyMinRange() {
        return this._applyMinRange;
    }

    public final int getMasteryLevel() {
        return this._masteryLevel;
    }

    public final boolean isSelfDebuff() {
        return this._isSelfDebuff;
    }

    public boolean canBeEvaded() {
        switch (this.getSkillType()) {
            case PDAM: 
            case CHARGE: {
                return true;
            }
        }
        return false;
    }

    public double getDefenceIgnorePercent() {
        return this._defenceIgnorePercent;
    }

    public int getBehindRadius() {
        return this._behindRadius;
    }

    public double getPercentDamageIfTargetDebuff() {
        return this._percentDamageIfTargetDebuff;
    }

    public boolean isNoFlagNoForce() {
        return this._noFlagNoForce;
    }

    public boolean isRenewal() {
        return this._renewal;
    }

    public int getBuffSlotType() {
        return this._buffSlotType;
    }

    public BasicProperty getBasicProperty() {
        return this._basicProperty;
    }

    public boolean isDouble() {
        return this._isDouble;
    }

    public double getMinChance() {
        return this._minChance;
    }

    public double getMaxChance() {
        return this._maxChance;
    }

    public double getOnAttackCancelChance() {
        return this._onAttackCancelChance;
    }

    public double getOnCritCancelChance() {
        return this._onCritCancelChance;
    }

    public void setShowPlayerAbnormal(boolean value) {
        this.showPlayerAbnormal = value;
    }

    public boolean isShowPlayerAbnormal() {
        return this.showPlayerAbnormal;
    }

    public void setShowNpcAbnormal(boolean value) {
        this.showNpcAbnormal = value;
    }

    public boolean isShowNpcAbnormal() {
        return this.showNpcAbnormal;
    }

    public static enum SkillType {
        AIEFFECTS(Continuous.class),
        BALANCE(Balance.class),
        BUFF(Continuous.class),
        BUFF_CHARGER(BuffCharger.class),
        CALL(Call.class),
        CHAIN_HEAL(ChainHeal.class),
        CHARGE(Charge.class),
        CLAN_GATE(ClanGate.class),
        CPDAM(CPDam.class),
        CPHOT(Continuous.class),
        CRAFT(Craft.class),
        DEBUFF_RENEWAL(DebuffRenewal.class),
        DECOY(Decoy.class),
        DEBUFF(Continuous.class),
        DELETE_HATE(Continuous.class),
        DESTROY_SUMMON(DestroySummon.class),
        DEFUSE_TRAP(DefuseTrap.class),
        DETECT_TRAP(DetectTrap.class),
        DISCORD(Continuous.class),
        DOT(Continuous.class),
        DRAIN(Drain.class),
        DRAIN_SOUL(DrainSoul.class),
        EFFECT(Skill.class),
        EFFECTS_FROM_SKILLS(EffectsFromSkills.class),
        ENERGY_REPLENISH(EnergyReplenish.class),
        ENCHANT_ARMOR,
        ENCHANT_WEAPON,
        EXTRACT_STONE(ExtractStone.class),
        HARDCODED(Skill.class),
        HEAL(Continuous.class),
        HEAL_PERCENT(Continuous.class),
        HOT(Continuous.class),
        HIDE_HAIR_ACCESSORIES(HideHairAccessories.class),
        LETHAL_SHOT(LethalShot.class),
        LUCK,
        MANADAM(ManaDam.class),
        MDAM(MDam.class),
        MDOT(Continuous.class),
        MPHOT(Continuous.class),
        MUTE(Disablers.class),
        ADD_PC_BANG(PcBangPointsAdd.class),
        NOTDONE,
        NOTUSED,
        PARALYZE(Disablers.class),
        PASSIVE,
        PDAM(PDam.class),
        PET_FEED(PetFeed.class),
        PET_SUMMON(PetSummon.class),
        POISON(Continuous.class),
        RECALL(Recall.class),
        RESURRECT(Resurrect.class),
        REPLACE(Replace.class),
        RIDE(Ride.class),
        ROOT(Disablers.class),
        SHIFT_AGGRESSION(ShiftAggression.class),
        SLEEP(Disablers.class),
        SACRIFICE(Sacrifice.class),
        STEAL_BUFF(StealBuff.class),
        STUN(Disablers.class),
        SUMMON(Summon.class),
        SUMMON_FLAG(SummonSiegeFlag.class),
        RESTORATION(Restoration.class),
        SWEEP(Sweep.class),
        TAKECASTLE(TakeCastle.class),
        TRAP_ACTIVATION(TrapActivation.class),
        UNLOCK(Unlock.class),
        WATCHER_GAZE(Continuous.class);

        private final Class<? extends Skill> clazz;

        private SkillType() {
            this.clazz = Default.class;
        }

        private SkillType(Class<? extends Skill> clazz) {
            this.clazz = clazz;
        }

        public Skill makeSkill(StatsSet set) {
            try {
                Constructor<? extends Skill> c = this.clazz.getConstructor(StatsSet.class);
                return c.newInstance(new Object[]{set});
            }
            catch (Exception e) {
                _log.error("Skill ID[" + set.getInteger("skill_id") + "], LEVEL[" + set.getInteger("level") + "]", (Throwable)e);
                throw new RuntimeException(e);
            }
        }

        public final boolean isPvM() {
            switch (this) {
                case DISCORD: {
                    return true;
                }
            }
            return false;
        }

        public boolean isAI() {
            switch (this) {
                case AIEFFECTS: 
                case DELETE_HATE: {
                    return true;
                }
            }
            return false;
        }

        public final boolean isPvpSkill() {
            switch (this) {
                case DELETE_HATE: 
                case DEBUFF: 
                case DOT: 
                case MDOT: 
                case MUTE: 
                case PARALYZE: 
                case POISON: 
                case ROOT: 
                case SLEEP: 
                case MANADAM: 
                case STEAL_BUFF: 
                case DEBUFF_RENEWAL: {
                    return true;
                }
            }
            return false;
        }

        public boolean isDebuff() {
            switch (this) {
                case DISCORD: 
                case AIEFFECTS: 
                case DELETE_HATE: 
                case DEBUFF: 
                case DOT: 
                case MDOT: 
                case MUTE: 
                case PARALYZE: 
                case POISON: 
                case ROOT: 
                case SLEEP: 
                case MANADAM: 
                case STEAL_BUFF: 
                case DEBUFF_RENEWAL: 
                case DRAIN: 
                case DRAIN_SOUL: 
                case LETHAL_SHOT: 
                case MDAM: 
                case PDAM: 
                case CPDAM: 
                case STUN: 
                case SWEEP: {
                    return true;
                }
            }
            return false;
        }
    }

    public static enum SkillTargetType {
        TARGET_ALLY,
        TARGET_AREA,
        TARGET_AREA_AIM_CORPSE,
        TARGET_AURA,
        TARGET_SERVITOR_AURA,
        TARGET_CHEST,
        TARGET_CLAN,
        TARGET_CLAN_ONE,
        TARGET_CLAN_ONLY,
        TARGET_CORPSE,
        TARGET_CORPSE_PLAYER,
        TARGET_ENEMY_PET,
        TARGET_ENEMY_SUMMON,
        TARGET_ENEMY_SERVITOR,
        TARGET_FLAGPOLE,
        TARGET_COMMCHANNEL,
        TARGET_HOLY,
        TARGET_ITEM,
        TARGET_NONE,
        TARGET_ONE,
        TARGET_OWNER,
        TARGET_PARTY,
        TARGET_PARTY_WITHOUT_ME,
        TARGET_PARTY_ONE,
        TARGET_PARTY_ONE_WITHOUT_ME,
        TARGET_SERVITORS,
        TARGET_SUMMON,
        TARGET_PET,
        TARGET_ONE_SERVITOR,
        TARGET_ONE_SERVITOR_NO_TARGET,
        TARGET_SELF_AND_SUMMON,
        TARGET_SELF,
        TARGET_SIEGE,
        TARGET_UNLOCKABLE,
        TARGET_GROUND,
        TARGET_FAN,
        TARGET_FAN_PB,
        TARGET_SQUARE,
        TARGET_SQUARE_PB,
        TARGET_RANGE,
        TARGET_RING_RANGE;

    }

    public static enum SkillMagicType {
        PHYSIC,
        MAGIC,
        SPECIAL,
        MUSIC,
        ITEM,
        UNK_MAG_TYPE_21,
        AWAKED_BUFF;

    }

    public static enum Ternary {
        TRUE,
        FALSE,
        DEFAULT;

    }

    public static enum NextAction {
        ATTACK,
        CAST,
        DEFAULT,
        MOVE,
        NONE;

    }

    public static enum EnchantType {
        NORMAL,
        SAFE,
        UNTRAIN,
        CHANGE,
        IMMORTAL;

        public static final EnchantType[] VALUES;

        static {
            VALUES = EnchantType.values();
        }
    }

    public static class AddedSkill {
        public static final AddedSkill[] EMPTY_ARRAY = new AddedSkill[0];
        private final SkillEntryType entryType;
        public final int id;
        public final int level;
        private SkillEntry _skillEntry;

        public AddedSkill(SkillEntryType entryType, int id, int level) {
            this.entryType = entryType;
            this.id = id;
            this.level = level;
        }

        public SkillEntryType getEntryType() {
            return this.entryType;
        }

        public SkillEntry getSkill() {
            if (this._skillEntry == null) {
                this._skillEntry = SkillEntry.makeSkillEntry(this.entryType, this.id, this.level);
            }
            if (this._skillEntry == null) {
                _log.warn("Cannot find added skill ID[" + this.id + "] LEVEL[" + this.level + "]!");
            }
            return this._skillEntry;
        }
    }
}


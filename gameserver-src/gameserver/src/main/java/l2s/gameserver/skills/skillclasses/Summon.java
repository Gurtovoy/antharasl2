package l2s.gameserver.skills.skillclasses;

import java.util.List;
import java.util.Set;
import l2s.gameserver.data.xml.holder.NpcHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.idfactory.IdFactory;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.FakePlayer;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.base.Experience;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.instances.SummonInstance;
import l2s.gameserver.model.instances.SymbolInstance;
import l2s.gameserver.model.instances.TrapInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.stats.funcs.FuncAbsorb;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.npc.NpcTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Summon
extends Skill {
    private static final Logger _log = LoggerFactory.getLogger(Summon.class);
    private static final int DEFAULT_LIFE_TIME = 2000000;
    private final SummonType _summonType;
    private final double _expPenalty;
    private final int _itemConsumeIdInTime;
    private final int _itemConsumeCountInTime;
    private final int _itemConsumeDelay;
    private final int _lifeTime;
    private final int _summonsCount;
    private final boolean _isSaveableSummon;
    private final boolean _randomOffset;

    public Summon(StatsSet set) {
        super(set);
        this._summonType = Enum.valueOf(SummonType.class, set.getString("summonType", "PET").toUpperCase());
        this._expPenalty = set.getDouble("expPenalty", 0.0);
        this._itemConsumeIdInTime = set.getInteger("itemConsumeIdInTime", 0);
        this._itemConsumeCountInTime = set.getInteger("itemConsumeCountInTime", 0);
        this._itemConsumeDelay = set.getInteger("itemConsumeDelay", 240) * 1000;
        this._lifeTime = set.getInteger("lifeTime", this._summonType == SummonType.NPC || this._summonType == SummonType.SYMBOL || this._summonType == SummonType.GROUND_ZONE ? -1 : 2000000) * 1000;
        this._summonsCount = Math.max(set.getInteger("summon_count", 1), 1);
        this._isSaveableSummon = set.getBool("is_saveable_summon", true);
        this._randomOffset = set.getBool("random_offset_on_spawn", this._summonType == SummonType.CLONE);
    }

    @Override
    public boolean checkCondition(SkillEntry skillEntry, Creature activeChar, Creature target, boolean forceUse, boolean dontMove, boolean first, boolean sendMsg, boolean trigger) {
        if (!super.checkCondition(skillEntry, activeChar, target, forceUse, dontMove, first, sendMsg, trigger)) {
            return false;
        }
        Player player = activeChar.getPlayer();
        if (player == null) {
            return false;
        }
        if (player.isProcessingRequest()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.PETS_AND_SERVITORS_ARE_NOT_AVAILABLE_AT_THIS_TIME);
            return false;
        }
        switch (this._summonType) {
            case TRAP: 
            case CLONE: 
            case GROUND_ZONE: {
                if (!player.isInPeaceZone() || !this.isDebuff()) break;
                player.sendPacket((IBroadcastPacket)SystemMsg.A_MALICIOUS_SKILL_CANNOT_BE_USED_IN_A_PEACE_ZONE);
                return false;
            }
            case PET: 
            case SIEGE_SUMMON: {
                break;
            }
            case SYMBOL: {
                if (player.getSymbol() == null) break;
                player.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addSkillName(this));
                return false;
            }
        }
        return true;
    }

    @Override
    public void onEndCast(Creature caster, Set<Creature> targets) {
        super.onEndCast(caster, targets);
        Player activeChar = caster.getPlayer();
        if (activeChar == null) {
            return;
        }
        switch (this._summonType) {
            case TRAP: {
                SkillEntry trapSkillEntry = this.getFirstAddedSkill();
                List<TrapInstance> traps = activeChar.getPlayer().getTraps();
                if (!traps.isEmpty()) {
                    traps.get(0).deleteMe();
                }
                TrapInstance trap = new TrapInstance(IdFactory.getInstance().getNextId(), NpcHolder.getInstance().getTemplate(this.getNpcId()), activeChar, trapSkillEntry);
                activeChar.addTrap(trap);
                trap.spawnMe();
                break;
            }
            case CLONE: {
                for (int i = 0; i < this._summonsCount; ++i) {
                    FakePlayer fp = new FakePlayer(IdFactory.getInstance().getNextId(), activeChar.getTemplate(), activeChar);
                    fp.setReflection(activeChar.getReflection());
                    if (this._randomOffset) {
                        fp.spawnMe(Location.findAroundPosition(activeChar, (int)(50.0 + fp.getCurrentCollisionRadius()), (int)(70.0 + fp.getCurrentCollisionRadius())));
                    } else {
                        fp.spawnMe(activeChar.getLoc());
                    }
                    fp.setFollowMode(true);
                }
                break;
            }
            case PET: 
            case SIEGE_SUMMON: {
                this.summon(activeChar, targets, null);
                break;
            }
            case NPC: {
                if (activeChar.hasSummon() || activeChar.isMounted()) {
                    return;
                }
                NpcTemplate npcTemplate = NpcHolder.getInstance().getTemplate(this.getNpcId());
                NpcInstance npc = npcTemplate.getNewInstance();
                npc.setCurrentHp(npc.getMaxHp(), false);
                npc.setCurrentMp(npc.getMaxMp());
                npc.setHeading(activeChar.getHeading());
                npc.setReflection(activeChar.getReflection());
                npc.setOwner(activeChar);
                if (this._randomOffset) {
                    npc.spawnMe(Location.findAroundPosition(activeChar, (int)(40.0 + npc.getCurrentCollisionRadius()), (int)(40.0 + npc.getCurrentCollisionRadius())));
                } else {
                    npc.spawnMe(activeChar.getLoc());
                }
                if (this._lifeTime <= 0) break;
                npc.startDeleteTask(this._lifeTime);
                break;
            }
            case SYMBOL: {
                SymbolInstance symbol = activeChar.getSymbol();
                if (symbol != null) {
                    activeChar.setSymbol(null);
                    symbol.deleteMe();
                }
                NpcTemplate npcTemplate = NpcHolder.getInstance().getTemplate(this.getNpcId());
                NpcInstance npc = npcTemplate.getNewInstance();
                npc.setCurrentHp(npc.getMaxHp(), false);
                npc.setCurrentMp(npc.getMaxMp());
                npc.setHeading(activeChar.getHeading());
                if (npc instanceof SymbolInstance) {
                    symbol = (SymbolInstance)npc;
                    activeChar.setSymbol(symbol);
                    symbol.setOwner(activeChar);
                }
                Location loc = Location.findPointToStay(activeChar.getLoc(), 50, 100, activeChar.getReflection().getGeoIndex());
                if (activeChar.getGroundSkillLoc() != null) {
                    loc = activeChar.getGroundSkillLoc();
                    activeChar.setGroundSkillLoc(null);
                }
                npc.setReflection(activeChar.getReflection());
                npc.spawnMe(loc);
                if (this._lifeTime <= 0) break;
                npc.startDeleteTask(this._lifeTime);
                break;
            }
            case GROUND_ZONE: {
                if (activeChar.isMounted()) {
                    return;
                }
                NpcTemplate npcTemplate = NpcHolder.getInstance().getTemplate(this.getNpcId());
                NpcInstance npc = npcTemplate.getNewInstance();
                npc.setCurrentHp(npc.getMaxHp(), false);
                npc.setCurrentMp(npc.getMaxMp());
                npc.setHeading(activeChar.getHeading());
                if (npc instanceof SymbolInstance) {
                    ((SymbolInstance)npc).setOwner(activeChar);
                }
                Location loc2 = activeChar.getLoc();
                if (activeChar.getGroundSkillLoc() != null) {
                    loc2 = activeChar.getGroundSkillLoc();
                    activeChar.setGroundSkillLoc(null);
                }
                npc.setReflection(activeChar.getReflection());
                npc.spawnMe(loc2);
                if (this._lifeTime <= 0) break;
                npc.startDeleteTask(this._lifeTime);
            }
        }
    }

    @Override
    public boolean isDebuff() {
        return this.getTargetType() == Skill.SkillTargetType.TARGET_CORPSE;
    }

    public void summon(Player player, Set<Creature> targets, SummonInstance.RestoredSummon restored) {
        NpcTemplate summonTemplate;
        Location loc = null;
        if (restored == null) {
            if (this.getTargetType() == Skill.SkillTargetType.TARGET_CORPSE) {
                for (Creature target : targets) {
                    if (target == null || !target.isDead()) continue;
                    player.getAI().setAttackTarget(null);
                    loc = target.getLoc();
                    if (target.isNpc()) {
                        ((NpcInstance)target).endDecayTask();
                        continue;
                    }
                    if (target.isSummon()) {
                        ((SummonInstance)target).endDecayTask();
                        continue;
                    }
                    return;
                }
            }
        } else if (player.getSkillLevel(restored.skillId, 0) < restored.skillLvl) {
            return;
        }
        if ((summonTemplate = NpcHolder.getInstance().getTemplate(this.getNpcId())) == null) {
            _log.warn("Summon: Template ID " + this.getNpcId() + " is NULL FIX IT!");
            return;
        }
        SummonInstance currentSummon = player.getSummon();
        if (currentSummon != null) {
            currentSummon.unSummon(false);
        }
        SummonInstance summon = new SummonInstance(IdFactory.getInstance().getNextId(), summonTemplate, player, this._lifeTime, this._itemConsumeIdInTime, this._itemConsumeCountInTime, this._itemConsumeDelay, this, this._isSaveableSummon);
        player.setSummon(summon);
        summon.setTitle("%OWNER_NAME%");
        summon.setExpPenalty(this._expPenalty);
        summon.setExp(Experience.getExpForLevel(Math.min(summon.getLevel(), Experience.getMaxAvailableLevel())));
        summon.setHeading(player.getHeading());
        summon.setReflection(player.getReflection());
        summon.setRunning();
        summon.spawnMe(loc == null ? Location.findAroundPosition(player, 50, 70) : loc);
        summon.setFollowMode(true);
        if (summon.getSkillLevel(4140) > 0) {
            summon.altUseSkill(SkillEntry.makeSkillEntry(SkillEntryType.NONE, 4140, summon.getSkillLevel(4140)), player);
        }
        if (summon.getName().equalsIgnoreCase("Shadow")) {
            summon.getStat().addFuncs(new FuncAbsorb(Stats.VAMPIRIC_ATTACK, 64, this, 15.0, StatsSet.simpleStatsSet("chance", 20.0)));
        }
        if (restored == null) {
            summon.setCurrentHpMp(summon.getMaxHp(), summon.getMaxMp(), false);
        } else {
            summon.setCurrentHpMp(restored.curHp, restored.curMp, false);
            summon.setConsumeCountdown(restored.time);
        }
        if (this._summonType == SummonType.SIEGE_SUMMON) {
            summon.setSiegeSummon(true);
            for (SiegeEvent siegeEvent : player.getEvents(SiegeEvent.class)) {
                siegeEvent.addSiegeSummon(player, summon);
            }
        }
        player.getListeners().onSummonServitor(summon);
    }

    private static enum SummonType {
        PET,
        SIEGE_SUMMON,
        TRAP,
        NPC,
        SYMBOL,
        CLONE,
        GROUND_ZONE;

    }
}


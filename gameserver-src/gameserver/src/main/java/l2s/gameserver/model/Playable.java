/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model;

import java.util.Collection;
import java.util.List;
import java.util.Set;
import java.util.concurrent.atomic.AtomicBoolean;
import l2s.commons.lang.reference.HardReference;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.ai.CtrlEvent;
import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.AggroList;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.World;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.actor.basestats.PlayableBaseStats;
import l2s.gameserver.model.actor.flags.PlayableFlags;
import l2s.gameserver.model.entity.boat.Boat;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.impl.DuelEvent;
import l2s.gameserver.model.entity.events.impl.SingleMatchEvent;
import l2s.gameserver.model.instances.ChairInstance;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.items.Inventory;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.RevivePacket;
import l2s.gameserver.network.l2.s2c.SystemMessage;
import l2s.gameserver.skills.AbnormalType;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.TimeStamp;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.templates.CreatureTemplate;
import l2s.gameserver.templates.item.EtcItemTemplate;
import l2s.gameserver.templates.item.WeaponTemplate;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.CHashIntObjectMap;
import org.napile.primitive.pair.IntObjectPair;

public abstract class Playable
extends Creature {
    private boolean _isPendingRevive;
    protected final IntObjectMap<TimeStamp> _sharedGroupReuses = new CHashIntObjectMap();
    protected final AtomicBoolean _isUsingItem = new AtomicBoolean(false);
    private Boat _boat;
    private Location _inBoatPosition;
    private long _nonAggroTime;
    private long _nonPvpTime;

    public Playable(int objectId, CreatureTemplate template) {
        super(objectId, template);
    }

    @SuppressWarnings("unchecked")
    public HardReference<? extends Playable> getRef() {
        return (HardReference<? extends Playable>) super.getRef();
    }

    public abstract Inventory getInventory();

    public abstract long getWearedMask();

    @Override
    public boolean checkPvP(Creature target, SkillEntry skillEntry) {
        Player player = this.getPlayer();
        if (this.isDead() || target == null || player == null || target == this || target == player || player.isMyServitor(target.getObjectId()) || player.isPK()) {
            return false;
        }
        if (skillEntry != null) {
            if (skillEntry.isAltUse()) {
                return false;
            }
            if (skillEntry.getTemplate().getTargetType() == Skill.SkillTargetType.TARGET_UNLOCKABLE) {
                return false;
            }
            if (skillEntry.getTemplate().getTargetType() == Skill.SkillTargetType.TARGET_CHEST) {
                return false;
            }
        }
        for (SingleMatchEvent event : this.getEvents(SingleMatchEvent.class)) {
            if (event.checkPvPFlag(player, target)) continue;
            return false;
        }
        if (this.isInPeaceZone() && target.isInPeaceZone()) {
            return false;
        }
        if (this.isInZoneBattle() && target.isInZoneBattle()) {
            return false;
        }
        if (this.isInSiegeZone() && target.isInSiegeZone()) {
            return false;
        }
        if (skillEntry == null || skillEntry.getTemplate().isDebuff()) {
            if (target.isPK()) {
                return false;
            }
            if (target.isPlayable()) {
                return true;
            }
        } else if (target.getPvpFlag() > 0 || target.isPK() || target.isMonster() && !skillEntry.getTemplate().isNoFlagNoForce()) {
            return true;
        }
        return false;
    }

    public boolean checkTarget(Creature target) {
        Player player = this.getPlayer();
        if (player == null) {
            return false;
        }
        if (target == null || target.isDead()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
            return false;
        }
        if (!this.isInRange(target, 2000)) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOUR_TARGET_IS_OUT_OF_RANGE);
            return false;
        }
        if (target.isInvisible(this) || this.getReflection() != target.getReflection() || !GeoEngine.canSeeTarget(this, target)) {
            player.sendPacket((IBroadcastPacket)SystemMsg.CANNOT_SEE_TARGET);
            return false;
        }
        if (player.isInZone(Zone.ZoneType.epic) != target.isInZone(Zone.ZoneType.epic)) {
            player.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
            return false;
        }
        if (target.isPlayable()) {
            if (!player.getPlayerAccess().PeaceAttack) {
                if (this.isInZoneBattle() != target.isInZoneBattle()) {
                    player.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
                    return false;
                }
                if (this.isInPeaceZone() || target.isInPeaceZone()) {
                    player.sendPacket((IBroadcastPacket)SystemMsg.YOU_MAY_NOT_ATTACK_THIS_TARGET_IN_A_PEACEFUL_ZONE);
                    return false;
                }
            }
            if (player.isInOlympiadMode() && !player.isOlympiadCompStart()) {
                return false;
            }
        }
        if (!target.isAttackable(this)) {
            player.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
            return false;
        }
        if (target.paralizeOnAttack(this) && Config.PARALIZE_ON_RAID_DIFF) {
            this.paralizeMe(target);
            return false;
        }
        return true;
    }

    @Override
    public void doAttack(Creature target) {
        WeaponTemplate weaponItem;
        Player player = this.getPlayer();
        if (player == null) {
            return;
        }
        if (this.isAMuted() || this.isAttackingNow()) {
            player.sendActionFailed();
            return;
        }
        if (player.isInObserverMode()) {
            player.sendActionFailed();
            return;
        }
        if (!this.checkTarget(target)) {
            if (!this.isServitor()) {
                this.getAI().setIntention(CtrlIntention.AI_INTENTION_ACTIVE, null, null);
            }
            player.sendActionFailed();
            return;
        }
        DuelEvent duelEvent = this.getEvent(DuelEvent.class);
        if (duelEvent != null && target.getEvent(DuelEvent.class) != duelEvent) {
            duelEvent.abortDuel(this.getPlayer());
        }
        if ((weaponItem = this.getActiveWeaponTemplate()) != null) {
            double cheapShot;
            boolean isBowOrCrossbow;
            int weaponMpConsume = weaponItem.getMpConsume();
            int[] reducedMPConsume = weaponItem.getReducedMPConsume();
            if (reducedMPConsume[0] > 0 && Rnd.chance((int)reducedMPConsume[0])) {
                weaponMpConsume = reducedMPConsume[1];
            }
            boolean bl = isBowOrCrossbow = weaponItem.getItemType() == WeaponTemplate.WeaponType.BOW || weaponItem.getItemType() == WeaponTemplate.WeaponType.CROSSBOW || weaponItem.getItemType() == WeaponTemplate.WeaponType.TWOHANDCROSSBOW;
            if (isBowOrCrossbow && Rnd.chance((double)(cheapShot = this.getStat().calc(Stats.CHEAP_SHOT, 0.0, target, null)))) {
                weaponMpConsume = 0;
            }
            if (weaponMpConsume > 0) {
                if (this._currentMp < (double)weaponMpConsume) {
                    this.getAI().setIntention(CtrlIntention.AI_INTENTION_ACTIVE, null, null);
                    player.sendPacket((IBroadcastPacket)SystemMsg.NOT_ENOUGH_MP);
                    player.sendActionFailed();
                    return;
                }
                this.reduceCurrentMp(weaponMpConsume, null);
            }
            if (isBowOrCrossbow && !player.checkAndEquipArrows()) {
                this.getAI().setIntention(CtrlIntention.AI_INTENTION_ACTIVE, null, null);
                player.sendPacket((IBroadcastPacket)(player.getActiveWeaponInstance().getItemType() == WeaponTemplate.WeaponType.BOW ? SystemMsg.YOU_HAVE_RUN_OUT_OF_ARROWS : SystemMsg.NOT_ENOUGH_BOLTS));
                player.sendActionFailed();
                return;
            }
        }
        super.doAttack(target);
    }

    @Override
    public boolean doCast(SkillEntry skillEntry, Creature target, boolean forceUse) {
        Skill skill;
        if (skillEntry == null) {
            return false;
        }
        DuelEvent duelEvent = this.getEvent(DuelEvent.class);
        if (duelEvent != null && target.getEvent(DuelEvent.class) != duelEvent) {
            duelEvent.abortDuel(this.getPlayer());
        }
        if ((skill = skillEntry.getTemplate()).getSkillType() == Skill.SkillType.DEBUFF && target.isNpc() && target.isInvulnerable() && !target.isMonster()) {
            this.getPlayer().sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
            return false;
        }
        return super.doCast(skillEntry, target, forceUse);
    }

    @Override
    public void reduceCurrentHp(double damage, Creature attacker, Skill skill, boolean awake, boolean standUp, boolean directHp, boolean canReflectAndAbsorb, boolean transferDamage, boolean isDot, boolean sendReceiveMessage, boolean sendGiveMessage, boolean crit, boolean miss, boolean shld) {
        if (attacker == null || this.isDead() || attacker.isDead() && !isDot) {
            return;
        }
        boolean damageBlocked = this.isDamageBlocked(attacker);
        if (damageBlocked && transferDamage) {
            return;
        }
        if (damageBlocked && attacker != this) {
            if (attacker.isPlayer() && sendGiveMessage) {
                attacker.sendPacket((IBroadcastPacket)SystemMsg.THE_ATTACK_HAS_BEEN_BLOCKED);
            }
            return;
        }
        if (attacker != this && attacker.isPlayable()) {
            Player player = this.getPlayer();
            Player pcAttacker = attacker.getPlayer();
            if (pcAttacker != player && player.isInOlympiadMode() && !player.isOlympiadCompStart()) {
                if (sendGiveMessage) {
                    pcAttacker.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
                }
                return;
            }
            if (this.isInZoneBattle() != attacker.isInZoneBattle()) {
                if (sendGiveMessage) {
                    attacker.getPlayer().sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
                }
                return;
            }
            DuelEvent duelEvent = this.getEvent(DuelEvent.class);
            if (duelEvent != null && attacker.getEvent(DuelEvent.class) != duelEvent) {
                duelEvent.abortDuel(player);
            }
        }
        super.reduceCurrentHp(damage, attacker, skill, awake, standUp, directHp, canReflectAndAbsorb, transferDamage, isDot, sendReceiveMessage, sendGiveMessage, crit, miss, shld);
    }

    @Override
    public boolean isAttackable(Creature attacker) {
        return this.isCtrlAttackable(attacker, true, false);
    }

    @Override
    public boolean isAutoAttackable(Creature attacker) {
        return this.isCtrlAttackable(attacker, false, false);
    }

    public boolean isCtrlAttackable(Creature attacker, boolean force, boolean nextAttackCheck) {
        Player player = this.getPlayer();
        if (attacker == null || player == null || attacker == this || attacker == player && !force || this.isDead() || attacker.isAlikeDead()) {
            return false;
        }
        if (player.isMyServitor(attacker.getObjectId())) {
            return false;
        }
        if (this.isInvisible(attacker) || this.getReflection() != attacker.getReflection()) {
            return false;
        }
        Boat boat = player.getBoat();
        if (boat != null) {
            return false;
        }
        Player pcAttacker = attacker.getPlayer();
        if (this.isPlayer() && pcAttacker == this) {
            return false;
        }
        if (pcAttacker != null && pcAttacker != player) {
            boat = pcAttacker.getBoat();
            if (boat != null) {
                return false;
            }
            if ((player.isInOlympiadMode() || pcAttacker.isInOlympiadMode()) && player.getOlympiadGame() != pcAttacker.getOlympiadGame()) {
                return false;
            }
            if (player.isInOlympiadMode() && !player.isOlympiadCompStart()) {
                return false;
            }
            if (player.isInOlympiadMode() && player.isOlympiadCompStart() && player.getOlympiadSide() == pcAttacker.getOlympiadSide() && !force) {
                return false;
            }
            if (player.isInNonPvpTime()) {
                return false;
            }
            if (!force && player.getParty() != null && player.getParty() == pcAttacker.getParty()) {
                return false;
            }
            if (!force && player.isInParty() && player.getParty().getCommandChannel() != null && pcAttacker.isInParty() && pcAttacker.getParty().getCommandChannel() != null && player.getParty().getCommandChannel() == pcAttacker.getParty().getCommandChannel()) {
                return false;
            }
            for (Event e : attacker.getEvents()) {
                if (e.checkForAttack(this, attacker, null, force) == null) continue;
                return false;
            }
            if (this.isInZoneBattle()) {
                return true;
            }
            if (this.isInPeaceZone()) {
                return false;
            }
            for (Event e : attacker.getEvents()) {
                if (!e.canAttack(this, attacker, null, force, nextAttackCheck)) continue;
                return true;
            }
            if (!force && player.getClan() != null && player.getClan() == pcAttacker.getClan()) {
                return false;
            }
            if (!force && player.getClan() != null && player.getClan().getAlliance() != null && pcAttacker.getClan() != null && pcAttacker.getClan().getAlliance() != null && player.getClan().getAlliance() == pcAttacker.getClan().getAlliance()) {
                return false;
            }
            if (this.isInSiegeZone()) {
                return true;
            }
            if (pcAttacker.atMutualWarWith(player)) {
                return true;
            }
            if (player.isPK()) {
                return true;
            }
            if (player.getPvpFlag() != 0) {
                return !nextAttackCheck;
            }
            return force;
        }
        return true;
    }

    @Override
    public int getKarma() {
        Player player = this.getPlayer();
        return player == null ? 0 : player.getKarma();
    }

    @Override
    public void callSkill(Creature aimingTarget, SkillEntry skillEntry, Set<Creature> targets, boolean useActionSkills, boolean trigger) {
        Player player = this.getPlayer();
        if (player == null) {
            return;
        }
        Skill skill = skillEntry.getTemplate();
        for (Creature target : targets) {
            if (target.isNpc()) {
                if (!trigger && skill.isDebuff() && target.paralizeOnAttack(player) && Config.PARALIZE_ON_RAID_DIFF) {
                    this.paralizeMe(target);
                    return;
                }
                target.getAI().notifyEvent(CtrlEvent.EVT_SEE_SPELL, skill, this, target);
            } else if (target.isPlayable() && player != target && !player.isMyServitor(target.getObjectId())) {
                int aggro = skill.getEffectPoint();
                List<NpcInstance> npcs = World.getAroundNpc(target);
                for (NpcInstance npc : npcs) {
                    AggroList.AggroInfo ai;
                    npc.getAI().notifyEvent(CtrlEvent.EVT_SEE_SPELL, skill, this, target);
                    if (trigger || !useActionSkills || skillEntry.isAltUse() || npc.isDead() || !npc.isInRangeZ(this, 2000)) continue;
                    if (npc.getAggroList().getHate(target) > 0 && !skill.isHandler() && npc.paralizeOnAttack(player)) {
                        Skill revengeSkill;
                        if (Config.PARALIZE_ON_RAID_DIFF && (revengeSkill = SkillHolder.getInstance().getSkill(4215, 1)) != null) {
                            revengeSkill.getEffects(npc, this);
                        }
                        return;
                    }
                    if (aggro <= 0 || (ai = npc.getAggroList().get(target)) == null || ai.hate < 100 || !GeoEngine.canSeeTarget(npc, target)) continue;
                    npc.getAI().notifyEvent(CtrlEvent.EVT_AGGRESSION, this, ai.damage == 0 ? aggro / 2 : aggro);
                }
            }
            if (trigger || !this.checkPvP(target, skillEntry)) continue;
            this.startPvPFlag(target);
        }
        super.callSkill(aimingTarget, skillEntry, targets, useActionSkills, trigger);
    }

    public void broadcastPickUpMsg(ItemInstance item) {
        Player player = this.getPlayer();
        if (item == null || player == null) {
            return;
        }
        if (item.isEquipable() && !(item.getTemplate() instanceof EtcItemTemplate)) {
            int msg_id;
            SystemMessage msg = null;
            String player_name = player.getName();
            if (item.getEnchantLevel() > 0) {
                msg_id = this.isPlayer() ? 1534 : 1536;
                msg = new SystemMessage(msg_id).addString(player_name).addNumber(item.getEnchantLevel()).addItemName(item.getItemId());
            } else {
                msg_id = this.isPlayer() ? 1533 : 1536;
                msg = new SystemMessage(msg_id).addString(player_name).addItemName(item.getItemId());
            }
            for (Player target : World.getAroundObservers(this)) {
                if (this.isInvisible(target)) continue;
                target.sendPacket((IBroadcastPacket)msg);
            }
        }
    }

    public void paralizeMe(Creature effector) {
        Skill revengeSkill = SkillHolder.getInstance().getSkill(4515, 1);
        revengeSkill.getEffects(effector, this);
    }

    public final void setPendingRevive(boolean value) {
        this._isPendingRevive = value;
    }

    public boolean isPendingRevive() {
        return this._isPendingRevive;
    }

    public void doRevive() {
        this.getListeners().onRevive();
        if (!this.isTeleporting()) {
            this.setPendingRevive(false);
            this.setNonAggroTime(System.currentTimeMillis() + Config.NONAGGRO_TIME_ONTELEPORT);
            this.setNonPvpTime(System.currentTimeMillis() + Config.NONPVP_TIME_ONTELEPORT);
            if (this.isSalvation()) {
                this.getAbnormalList().stop(AbnormalType.RESURRECTION_SPECIAL);
                this.setCurrentHp(this.getMaxHp(), true);
                this.setCurrentMp(this.getMaxMp());
                this.setCurrentCp(this.getMaxCp());
            } else {
                this.setCurrentHp(Math.max(1.0, (double)this.getMaxHp() * Config.RESPAWN_RESTORE_HP), true);
                if (Config.RESPAWN_RESTORE_MP >= 0.0) {
                    this.setCurrentMp((double)this.getMaxMp() * Config.RESPAWN_RESTORE_MP);
                }
                if (this.isPlayer() && Config.RESPAWN_RESTORE_CP >= 0.0) {
                    this.setCurrentCp((double)this.getMaxCp() * Config.RESPAWN_RESTORE_CP);
                }
            }
            this.broadcastPacket(new RevivePacket(this));
        } else {
            this.setPendingRevive(true);
        }
    }

    public abstract void doPickupItem(GameObject var1);

    public void sitDown(ChairInstance chair) {
    }

    public void standUp() {
    }

    public boolean isInNonAggroTime() {
        return this._nonAggroTime > System.currentTimeMillis();
    }

    public void setNonAggroTime(long time) {
        this._nonAggroTime = time;
    }

    public boolean isInNonPvpTime() {
        return this._nonPvpTime > System.currentTimeMillis();
    }

    public void setNonPvpTime(long time) {
        this._nonPvpTime = time;
    }

    public boolean isSilentMoving() {
        return this.getFlags().getSilentMoving().get();
    }

    public int getMaxLoad() {
        return 0;
    }

    public int getInventoryLimit() {
        return 0;
    }

    @Override
    public boolean isPlayable() {
        return true;
    }

    public boolean isSharedGroupDisabled(int groupId) {
        TimeStamp sts = this.getSharedGroupReuse(groupId);
        if (sts == null) {
            return false;
        }
        if (sts.hasNotPassed()) {
            return true;
        }
        this._sharedGroupReuses.remove(groupId);
        return false;
    }

    public TimeStamp getSharedGroupReuse(int groupId) {
        return (TimeStamp)this._sharedGroupReuses.get(groupId);
    }

    public void addSharedGroupReuse(int group, TimeStamp stamp) {
        this._sharedGroupReuses.put(group, stamp);
    }

    public Collection<IntObjectPair<TimeStamp>> getSharedGroupReuses() {
        return this._sharedGroupReuses.entrySet();
    }

    public boolean useItem(ItemInstance item, boolean ctrl, boolean sendMsg) {
        return false;
    }

    public int getCurrentLoad() {
        return 0;
    }

    public int getWeightPenalty() {
        return 0;
    }

    @Override
    public boolean isInBoat() {
        return this._boat != null;
    }

    @Override
    public boolean isInShuttle() {
        return this._boat != null && this._boat.isShuttle();
    }

    public Boat getBoat() {
        return this._boat;
    }

    public void setBoat(Boat boat) {
        this._boat = boat;
    }

    public Location getInBoatPosition() {
        return this._inBoatPosition;
    }

    public void setInBoatPosition(Location loc) {
        this._inBoatPosition = loc;
    }

    public int getNameColor() {
        return 0;
    }

    @Override
    public PlayableBaseStats getBaseStats() {
        if (this._baseStats == null) {
            this._baseStats = new PlayableBaseStats(this);
        }
        return (PlayableBaseStats)this._baseStats;
    }

    @Override
    public PlayableFlags getFlags() {
        if (this._statuses == null) {
            this._statuses = new PlayableFlags(this);
        }
        return (PlayableFlags)this._statuses;
    }

    public abstract SkillEntry getAdditionalSSEffect(boolean var1, boolean var2);

    public int getRelation(Player target) {
        Player player = this.getPlayer();
        if (player != null) {
            return player.getRelation(target);
        }
        return 0;
    }
}


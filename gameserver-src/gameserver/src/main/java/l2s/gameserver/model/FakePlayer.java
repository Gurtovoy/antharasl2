package l2s.gameserver.model;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ScheduledFuture;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.ai.CloneAI;
import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.data.xml.holder.SkillAcquireHolder;
import l2s.gameserver.handler.onshiftaction.OnShiftActionHolder;
import l2s.gameserver.listener.actor.OnAttackListener;
import l2s.gameserver.listener.actor.OnMagicUseListener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.World;
import l2s.gameserver.model.actor.CreatureSkillCast;
import l2s.gameserver.model.base.TeamType;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.items.Inventory;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ActionFailPacket;
import l2s.gameserver.network.l2.s2c.AutoAttackStartPacket;
import l2s.gameserver.network.l2.s2c.CIPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.MagicSkillUse;
import l2s.gameserver.network.l2.s2c.updatetype.IUpdateTypeComponent;
import l2s.gameserver.skills.SkillCastingType;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.templates.item.WeaponTemplate;
import l2s.gameserver.templates.player.PlayerTemplate;

public class FakePlayer
extends Playable {
    private final Player _owner;
    private OwnerAttakListener _listener;
    private ScheduledFuture<?> _broadcastCharInfoTask;

    public FakePlayer(int objectId, PlayerTemplate template, Player owner) {
        super(objectId, template);
        this._owner = owner;
        this._ai = new CloneAI(this);
        this._listener = new OwnerAttakListener();
        owner.addListener(this._listener);
        ThreadPoolManager.getInstance().schedule(new DeleteMeTimer(this), 30000L);
    }

    @Override
    public Player getPlayer() {
        return this._owner;
    }

    @Override
    public CloneAI getAI() {
        return (CloneAI)this._ai;
    }

    @Override
    public int getLevel() {
        return this._owner.getLevel();
    }

    @Override
    public ItemInstance getActiveWeaponInstance() {
        return this._owner.getActiveWeaponInstance();
    }

    @Override
    public WeaponTemplate getActiveWeaponTemplate() {
        return this._owner.getActiveWeaponTemplate();
    }

    @Override
    public ItemInstance getSecondaryWeaponInstance() {
        return this._owner.getSecondaryWeaponInstance();
    }

    @Override
    public WeaponTemplate getSecondaryWeaponTemplate() {
        return this._owner.getSecondaryWeaponTemplate();
    }

    public void setFollowMode(boolean state) {
        Player owner = this.getPlayer();
        if (this.getAI().getIntention() == CtrlIntention.AI_INTENTION_IDLE) {
            this.getAI().setIntention(CtrlIntention.AI_INTENTION_FOLLOW, owner, Config.FOLLOW_RANGE);
        }
    }

    @Override
    public void onAction(Player player, boolean shift) {
        if (this.isFrozen()) {
            player.sendPacket((IBroadcastPacket)ActionFailPacket.STATIC);
            return;
        }
        if (shift && OnShiftActionHolder.getInstance().callShiftAction(player, FakePlayer.class, this, true)) {
            return;
        }
        Player owner = this.getPlayer();
        if (player.getTarget() != this) {
            player.setTarget(this);
        } else if (player == owner) {
            player.sendPacket((IBroadcastPacket)new CIPacket(this, player));
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

    @Override
    public void broadcastCharInfo() {
        if (!this.isVisible()) {
            return;
        }
        if (this._broadcastCharInfoTask != null) {
            return;
        }
        this._broadcastCharInfoTask = ThreadPoolManager.getInstance().schedule(new BroadcastCharInfoTask(), Config.BROADCAST_CHAR_INFO_INTERVAL);
    }

    @Override
    public void broadcastCharInfoImpl(IUpdateTypeComponent ... components) {
        for (Player player : World.getAroundObservers(this)) {
            player.sendPacket((IBroadcastPacket)new CIPacket(this, player));
        }
    }

    @Override
    public List<L2GameServerPacket> addPacketList(Player forPlayer, Creature dropper) {
        long animationEndTime;
        SkillEntry castingSkillEntry;
        Creature castingTarget;
        if (this.isInvisible(forPlayer) && forPlayer.getObjectId() != this.getObjectId()) {
            return Collections.emptyList();
        }
        ArrayList<L2GameServerPacket> list = new ArrayList<L2GameServerPacket>();
        list.add(new CIPacket(this, forPlayer));
        CreatureSkillCast skillCast = this.getSkillCast(SkillCastingType.NORMAL);
        if (skillCast.isCastingNow()) {
            castingTarget = skillCast.getTarget();
            castingSkillEntry = skillCast.getSkillEntry();
            animationEndTime = skillCast.getAnimationEndTime();
            if (castingSkillEntry != null && !castingSkillEntry.getTemplate().isNotBroadcastable() && castingTarget != null && castingTarget.isCreature() && animationEndTime > 0L) {
                list.add(new MagicSkillUse(this, castingTarget, castingSkillEntry.getId(), castingSkillEntry.getLevel(), (int)(animationEndTime - System.currentTimeMillis()), 0L, SkillCastingType.NORMAL));
            }
        }
        if ((skillCast = this.getSkillCast(SkillCastingType.NORMAL_SECOND)).isCastingNow()) {
            castingTarget = skillCast.getTarget();
            castingSkillEntry = skillCast.getSkillEntry();
            animationEndTime = skillCast.getAnimationEndTime();
            if (castingSkillEntry != null && !castingSkillEntry.getTemplate().isNotBroadcastable() && castingTarget != null && castingTarget.isCreature() && animationEndTime > 0L) {
                list.add(new MagicSkillUse(this, castingTarget, castingSkillEntry.getId(), castingSkillEntry.getLevel(), (int)(animationEndTime - System.currentTimeMillis()), 0L, SkillCastingType.NORMAL_SECOND));
            }
        }
        if (this.isInCombat()) {
            list.add(new AutoAttackStartPacket(this.getObjectId()));
        }
        if (this.getMovement().isMoving() || this.getMovement().isFollow()) {
            list.add(this.movePacket());
        }
        return list;
    }

    public void notifyOwerStartAttak(Creature targets) {
        this.getAI().Attack(targets, true, false);
    }

    public void notifyOwerStartMagicUse(Creature targets, Skill skill) {
        if (SkillAcquireHolder.getInstance().isSkillPossible(this.getPlayer(), skill)) {
            this.doCast(SkillEntry.makeSkillEntry(SkillEntryType.NONE, skill), targets, true);
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
    public boolean isPlayable() {
        return true;
    }

    @Override
    public Inventory getInventory() {
        return null;
    }

    @Override
    public long getWearedMask() {
        return 0L;
    }

    @Override
    public void doPickupItem(GameObject object) {
    }

    @Override
    public double getCurrentHp() {
        return this._owner.getCurrentHp();
    }

    @Override
    public double getCurrentMp() {
        return this._owner.getCurrentMp();
    }

    @Override
    public int getINT() {
        return this._owner.getINT();
    }

    @Override
    public int getSTR() {
        return this._owner.getSTR();
    }

    @Override
    public int getCON() {
        return this._owner.getCON();
    }

    @Override
    public int getMEN() {
        return this._owner.getMEN();
    }

    @Override
    public int getDEX() {
        return this._owner.getDEX();
    }

    @Override
    public int getWIT() {
        return this._owner.getWIT();
    }

    @Override
    public int getPEvasionRate(Creature target) {
        return this._owner.getPEvasionRate(target);
    }

    @Override
    public int getMEvasionRate(Creature target) {
        return this._owner.getMEvasionRate(target);
    }

    @Override
    public int getPAccuracy() {
        return this._owner.getPAccuracy();
    }

    @Override
    public int getMAccuracy() {
        return this._owner.getMAccuracy();
    }

    @Override
    public int getPCriticalHit(Creature target) {
        return this._owner.getPCriticalHit(target);
    }

    @Override
    public int getMCriticalHit(Creature target, Skill skill) {
        return this._owner.getMCriticalHit(target, skill);
    }

    @Override
    public double getCurrentCp() {
        return this._owner.getCurrentCp();
    }

    @Override
    public int getMAtk(Creature target, Skill skill) {
        return this._owner.getMAtk(target, skill);
    }

    @Override
    public int getMAtkSpd() {
        return this._owner.getMAtkSpd();
    }

    @Override
    public int getMaxCp() {
        return this._owner.getMaxCp();
    }

    @Override
    public int getMaxHp() {
        return this._owner.getMaxHp();
    }

    @Override
    public int getMaxMp() {
        return this._owner.getMaxMp();
    }

    @Override
    public int getMDef(Creature target, Skill skill) {
        return this._owner.getMDef(target, skill);
    }

    @Override
    public int getPAtk(Creature target) {
        return this._owner.getPAtk(target);
    }

    @Override
    public int getPAtkSpd() {
        return this._owner.getPAtkSpd();
    }

    @Override
    public int getPDef(Creature target) {
        return this._owner.getPDef(target);
    }

    @Override
    public int getPhysicalAttackRange() {
        return this._owner.getPhysicalAttackRange();
    }

    @Override
    public int getRandomDamage() {
        return this._owner.getRandomDamage();
    }

    @Override
    public TeamType getTeam() {
        return this._owner.getTeam();
    }

    @Override
    public int getMoveSpeed() {
        return this._owner.getMoveSpeed();
    }

    @Override
    public int getPvpFlag() {
        return this._owner.getPvpFlag();
    }

    @Override
    public int getNameColor() {
        return this._owner.getNameColor();
    }

    @Override
    public int getKarma() {
        return this._owner.getKarma();
    }

    @Override
    public SkillEntry getAdditionalSSEffect(boolean spiritshot, boolean blessed) {
        return this._owner.getAdditionalSSEffect(spiritshot, blessed);
    }

    private class DeleteMeTimer
    implements Runnable {
        private FakePlayer _p;

        public DeleteMeTimer(FakePlayer p) {
            this._p = p;
        }

        @Override
        public void run() {
            this._p.deleteMe();
        }
    }

    private class OwnerAttakListener
    implements OnAttackListener,
    OnMagicUseListener {
        private OwnerAttakListener() {
        }

        @Override
        public void onMagicUse(Creature actor, Skill skill, Creature target, boolean alt) {
            if (target != null && target == FakePlayer.this.getPlayer()) {
                return;
            }
            if (target != null && target instanceof FakePlayer && target.getPlayer() == FakePlayer.this.getPlayer()) {
                return;
            }
            FakePlayer.this.notifyOwerStartMagicUse(target, skill);
        }

        @Override
        public void onAttack(Creature actor, Creature target) {
            if (target != null && target == FakePlayer.this.getPlayer()) {
                return;
            }
            if (target != null && target instanceof FakePlayer && target.getPlayer() == FakePlayer.this.getPlayer()) {
                return;
            }
            FakePlayer.this.notifyOwerStartAttak(target);
        }
    }

    public class BroadcastCharInfoTask
    implements Runnable {
        @Override
        public void run() {
            FakePlayer.this.broadcastCharInfoImpl(new IUpdateTypeComponent[0]);
            FakePlayer.this._broadcastCharInfoTask = null;
        }
    }
}


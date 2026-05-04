/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.instances;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.atomic.AtomicBoolean;
import l2s.commons.geometry.Point2D;
import l2s.commons.geometry.Shape;
import l2s.commons.listener.Listener;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.ai.DoorAI;
import l2s.gameserver.handler.onshiftaction.OnShiftActionHolder;
import l2s.gameserver.listener.actor.door.OnOpenCloseListener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.model.instances.SummonInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.DoorStatusUpdatePacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.StaticObjectPacket;
import l2s.gameserver.templates.DoorTemplate;
import l2s.gameserver.templates.item.WeaponTemplate;

public final class DoorInstance
extends Creature {
    private AtomicBoolean _open = new AtomicBoolean(true);
    private boolean _lockOpen = false;
    private int _upgradeHp;
    protected ScheduledFuture<?> _autoActionTask;

    public DoorInstance(int objectId, DoorTemplate template) {
        super(objectId, template);
    }

    public boolean isUnlockable() {
        return this.getTemplate().isUnlockable();
    }

    @Override
    public String getName() {
        return this.getTemplate().getName();
    }

    @Override
    public int getLevel() {
        return 1;
    }

    public int getDoorId() {
        return this.getTemplate().getId();
    }

    public boolean isOpen() {
        return this._open.get();
    }

    public void scheduleAutoAction(boolean open, long actionDelay) {
        if (this._autoActionTask != null) {
            this._autoActionTask.cancel(false);
            this._autoActionTask = null;
        }
        this._autoActionTask = ThreadPoolManager.getInstance().schedule(new AutoOpenClose(open), actionDelay);
    }

    public int getDamage() {
        int dmg = 6 - (int)Math.ceil(this.getCurrentHpRatio() * 6.0);
        return Math.max(0, Math.min(6, dmg));
    }

    @Override
    public boolean isAutoAttackable(Creature attacker) {
        return this.isAttackable(attacker);
    }

    @Override
    public boolean isAttackable(Creature attacker) {
        if (attacker == null || this.isOpen() || this.isInvulnerable()) {
            return false;
        }
        for (SiegeEvent siegeEvent : this.getEvents(SiegeEvent.class)) {
            switch (this.getDoorType()) {
                case WALL: {
                    if (!attacker.isSummon() || !siegeEvent.containsSiegeSummon((SummonInstance)attacker)) break;
                    return true;
                }
                case DOOR: {
                    Player player = attacker.getPlayer();
                    if (player == null) {
                        return false;
                    }
                    if (siegeEvent.getSiegeClan("defenders", player.getClan()) == null) break;
                    return false;
                }
            }
        }
        return this.getDoorType() != DoorTemplate.DoorType.WALL;
    }

    @Override
    public void sendChanges() {
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
    public void onAction(Player player, boolean shift) {
        if (shift && OnShiftActionHolder.getInstance().callShiftAction(player, DoorInstance.class, this, true)) {
            return;
        }
        if (this != player.getTarget()) {
            player.setTarget(this);
        } else {
            if (this.isAutoAttackable(player)) {
                player.getAI().Attack(this, false, shift);
                return;
            }
            if (!player.checkInteractionDistance(this)) {
                if (player.getAI().getIntention() != CtrlIntention.AI_INTENTION_INTERACT) {
                    player.getAI().setIntention(CtrlIntention.AI_INTENTION_INTERACT, this, null);
                }
                return;
            }
            this.getAI().onEvtTwiceClick(player);
        }
    }

    
    @Override
    public DoorAI getAI() {
        if (this._ai == null) {
            DoorInstance doorInstance = this;
            synchronized (doorInstance) {
                if (this._ai == null) {
                    this._ai = this.getTemplate().getNewAI(this);
                }
            }
        }
        return (DoorAI)this._ai;
    }

    @Override
    public void broadcastStatusUpdate() {
        IBroadcastPacket oe = null;
        for (Player player : World.getAroundObservers(this)) {
            player.sendPacket((IBroadcastPacket)new StaticObjectPacket(this, player));
            player.sendPacket((IBroadcastPacket)new DoorStatusUpdatePacket(this, player));
            if (oe == null) continue;
            player.sendPacket(oe);
        }
    }

    public boolean isLockOpen() {
        return this._lockOpen;
    }

    public void setLockOpen(boolean value) {
        this._lockOpen = value;
    }

    public boolean openMe() {
        return this.openMe(null, true);
    }

    public boolean openMe(Player opener, boolean autoClose) {
        if (!this.setOpen(true)) {
            return false;
        }
        this.broadcastStatusUpdate();
        if (autoClose && this.getTemplate().getCloseTime() > 0) {
            this.scheduleAutoAction(false, (long)this.getTemplate().getCloseTime() * 1000L);
        }
        this.getAI().onEvtOpen(opener);
        for (Listener l : this.getListeners().getListeners()) {
            if (!(l instanceof OnOpenCloseListener)) continue;
            ((OnOpenCloseListener)l).onOpen(this);
        }
        return true;
    }

    public boolean closeMe() {
        return this.closeMe(null, true);
    }

    public boolean closeMe(Player closer, boolean autoOpen) {
        if (!this.setOpen(false)) {
            return false;
        }
        this.broadcastStatusUpdate();
        if (autoOpen && this.getTemplate().getOpenTime() > 0) {
            long openDelay = (long)this.getTemplate().getOpenTime() * 1000L;
            if (this.getTemplate().getRandomTime() > 0) {
                openDelay += (long)Rnd.get((int)0, (int)this.getTemplate().getRandomTime()) * 1000L;
            }
            this.scheduleAutoAction(true, openDelay);
        }
        this.getAI().onEvtClose(closer);
        for (Listener l : this.getListeners().getListeners()) {
            if (!(l instanceof OnOpenCloseListener)) continue;
            ((OnOpenCloseListener)l).onClose(this);
        }
        return true;
    }

    @Override
    public String toString() {
        return "[Door " + this.getDoorId() + "]";
    }

    @Override
    protected void onDeath(Creature killer) {
        this.setOpen(true);
        super.onDeath(killer);
    }

    @Override
    protected void onRevive() {
        super.onRevive();
        this.setOpen(false);
    }

    @Override
    protected void onSpawn() {
        super.onSpawn();
        this.setCurrentHpMp(this.getMaxHp(), this.getMaxMp(), true);
        this.closeMe(null, true);
    }

    @Override
    protected void onDespawn() {
        if (this._autoActionTask != null) {
            this._autoActionTask.cancel(false);
            this._autoActionTask = null;
        }
        super.onDespawn();
    }

    public boolean isHPVisible() {
        return this.getTemplate().isHPVisible();
    }

    @Override
    public int getMaxHp() {
        return super.getMaxHp() + this._upgradeHp;
    }

    public void setUpgradeHp(int hp) {
        this._upgradeHp = hp;
    }

    public int getUpgradeHp() {
        return this._upgradeHp;
    }

    @Override
    public boolean isInvulnerable() {
        if (!this.getTemplate().isHPVisible()) {
            return true;
        }
        for (SiegeEvent siegeEvent : this.getEvents(SiegeEvent.class)) {
            if (!siegeEvent.isInProgress()) continue;
            return false;
        }
        return super.isInvulnerable();
    }

    protected synchronized boolean setOpen(boolean open) {
        if (!open && this.isDead()) {
            return false;
        }
        if (!this._open.compareAndSet(!open, open)) {
            return false;
        }
        if (open) {
            if (!this.deactivateGeoControl()) {
                this._open.set(false);
                return false;
            }
            this.setLoc(this.getTemplate().getLoc());
        } else {
            if (!this.activateGeoControl()) {
                this._open.set(true);
                return false;
            }
            Point2D center = this.getTemplate().getPolygon().getCenter();
            this.setXYZ(center.getX(), center.getY(), this.getZ());
        }
        return true;
    }

    @Override
    public boolean isMovementDisabled() {
        return true;
    }

    @Override
    public boolean isActionsDisabled(boolean withCast) {
        return true;
    }

    @Override
    public boolean isFearImmune() {
        return true;
    }

    @Override
    public boolean isParalyzeImmune() {
        return true;
    }

    @Override
    public boolean isLethalImmune() {
        return true;
    }

    @Override
    public boolean isHealBlocked() {
        return true;
    }

    @Override
    public boolean isEffectImmune(Creature caster) {
        return true;
    }

    @Override
    public List<L2GameServerPacket> addPacketList(Player forPlayer, Creature dropper) {
        ArrayList<L2GameServerPacket> list = new ArrayList<L2GameServerPacket>();
        list.add(new StaticObjectPacket(this, forPlayer));
        list.add(new DoorStatusUpdatePacket(this, forPlayer));
        return list;
    }

    @Override
    public boolean isDoor() {
        return true;
    }

    @Override
    public DoorTemplate getTemplate() {
        return (DoorTemplate)super.getTemplate();
    }

    public DoorTemplate.DoorType getDoorType() {
        return this.getTemplate().getDoorType();
    }

    public int getKey() {
        return this.getTemplate().getKey();
    }

    @Override
    protected Shape makeGeoShape() {
        return this.getTemplate().getPolygon();
    }

    @Override
    protected boolean isGeoControlEnabled() {
        return Config.ALLOW_GEODATA && !this.isOpen();
    }

    @Override
    public boolean isHollowGeo() {
        return false;
    }

    private class AutoOpenClose
    implements Runnable {
        private boolean _open;

        public AutoOpenClose(boolean open) {
            this._open = open;
        }

        @Override
        public void run() {
            if (this._open) {
                DoorInstance.this.openMe(null, true);
            } else {
                DoorInstance.this.closeMe(null, true);
            }
        }
    }
}


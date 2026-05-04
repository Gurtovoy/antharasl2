/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity.events.impl;

import java.util.Iterator;
import java.util.List;
import l2s.commons.collections.JoinedIterator;
import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.listener.actor.player.OnPlayerExitListener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.base.TeamType;
import l2s.gameserver.model.entity.events.EventType;
import l2s.gameserver.model.entity.events.impl.AbstractDuelEvent;
import l2s.gameserver.model.entity.events.impl.SingleMatchEvent;
import l2s.gameserver.model.entity.events.objects.DuelSnapshotObject;
import l2s.gameserver.model.entity.olympiad.Olympiad;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExDuelStart;
import l2s.gameserver.network.l2.s2c.ExDuelUpdateUserInfo;
import l2s.gameserver.network.l2.s2c.PlaySoundPacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;

public abstract class DuelEvent
extends AbstractDuelEvent
implements Iterable<DuelSnapshotObject> {
    protected OnPlayerExitListener _playerExitListener = new OnPlayerExitListenerImpl();
    protected TeamType _winner = TeamType.NONE;
    protected boolean _aborted;
    protected boolean _isInProgress;

    public DuelEvent(MultiValueSet<String> set) {
        super(set);
    }

    protected DuelEvent(int id, String name) {
        super(id, name);
    }

    @Override
    public void initEvent() {
    }

    public abstract void packetSurrender(Player var1);

    @Override
    public abstract void onDie(Player var1);

    public abstract int getDuelType();

    @Override
    public void startEvent() {
        this._isInProgress = true;
        for (DuelSnapshotObject $snapshot : this) {
            if (this.canDuel0($snapshot.getPlayer(), $snapshot.getPlayer(), true) == null) continue;
            this.abortDuel($snapshot.getPlayer());
            return;
        }
        this.updatePlayers(true, false);
        this.sendPackets(new ExDuelStart(this), PlaySoundPacket.B04_S01, SystemMsg.LET_THE_DUEL_BEGIN);
        for (DuelSnapshotObject $snapshot : this) {
            this.sendPacket(new ExDuelUpdateUserInfo($snapshot.getPlayer()), $snapshot.getTeam().revert());
        }
    }

    public void sendPacket(IBroadcastPacket packet, TeamType ... ar) {
        for (TeamType a : ar) {
            List<DuelSnapshotObject> objs = this.getObjects((Object)a);
            for (DuelSnapshotObject obj : objs) {
                obj.getPlayer().sendPacket(packet);
            }
        }
    }

    @Override
    public void sendPacket(IBroadcastPacket packet) {
        this.sendPackets(packet);
    }

    @Override
    public void sendPackets(IBroadcastPacket ... packet) {
        for (DuelSnapshotObject d : this) {
            d.getPlayer().sendPacket(packet);
        }
    }

    public void abortDuel(Player player) {
        this._aborted = true;
        this._winner = TeamType.NONE;
        this.stopEvent(false);
    }

    protected IBroadcastPacket canDuel0(Player requestor, Player target, boolean secondCheck) {
        IBroadcastPacket packet = null;
        if (target.isInCombat()) {
            packet = (IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_CANNOT_DUEL_BECAUSE_C1_IS_CURRENTLY_ENGAGED_IN_BATTLE).addName(target);
        } else if (target.isDead() || target.isAlikeDead() || target.getCurrentHpPercents() < 50.0 || target.getCurrentMpPercents() < 50.0 || target.getCurrentCpPercents() < 50.0) {
            packet = (IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_CANNOT_DUEL_BECAUSE_C1S_HP_OR_MP_IS_BELOW_50).addName(target);
        } else if (!secondCheck && target.containsEvent(DuelEvent.class)) {
            packet = (IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_CANNOT_DUEL_BECAUSE_C1_IS_ALREADY_ENGAGED_IN_A_DUEL).addName(target);
        } else if (secondCheck && !target.containsEvent(this)) {
            packet = (IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_CANNOT_DUEL_BECAUSE_C1_IS_ALREADY_ENGAGED_IN_A_DUEL).addName(target);
        } else if (target.isInZone(Zone.ZoneType.SIEGE)) {
            packet = (IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_CANNOT_DUEL_BECAUSE_C1_IS_PARTICIPATING_IN_A_SIEGE_WAR).addName(target);
        } else if (target.isInOlympiadMode() || Olympiad.isRegisteredInComp(target) || requestor.isInOlympiadMode() || Olympiad.isRegisteredInComp(requestor)) {
            packet = (IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_CANNOT_DUEL_BECAUSE_C1_IS_PARTICIPATING_IN_THE_OLYMPIAD).addName(target);
        } else if (target.isPK() || target.getPvpFlag() > 0) {
            packet = (IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_CANNOT_DUEL_BECAUSE_C1_IS_IN_A_CHAOTIC_STATE).addName(target);
        } else if (target.isInStoreMode()) {
            packet = (IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_CANNOT_DUEL_BECAUSE_C1_IS_CURRENTLY_ENGAGED_IN_A_PRIVATE_STORE_OR_MANUFACTURE).addName(target);
        } else if (target.isMounted() || target.isInBoat()) {
            packet = (IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_CANNOT_DUEL_BECAUSE_C1_IS_CURRENTLY_RIDING_A_BOAT_STEED_OR_STRIDER).addName(target);
        } else if (target.isFishing()) {
            packet = (IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_CANNOT_DUEL_BECAUSE_C1_IS_CURRENTLY_FISHING).addName(target);
        } else if (target.isInZoneBattle() || target.isInPeaceZone() || target.isInWater() || target.isInZone(Zone.ZoneType.no_restart) || target.isInTrainingCamp()) {
            packet = (IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_CANNOT_MAKE_A_CHALLENGE_TO_A_DUEL_BECAUSE_C1_IS_CURRENTLY_IN_A_DUELPROHIBITED_AREA_PEACEFUL_ZONE__SEVEN_SIGNS_ZONE__NEAR_WATER__RESTART_PROHIBITED_AREA).addName(target);
        } else if (!requestor.isInRangeZ(target, secondCheck ? 1200 : 250)) {
            packet = (IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_CANNOT_RECEIVE_A_DUEL_CHALLENGE_BECAUSE_C1_IS_TOO_FAR_AWAY).addName(target);
        } else if (target.isTransformed()) {
            packet = (IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_CANNOT_DUEL_BECAUSE_C1_IS_CURRENTLY_POLYMORPHED).addName(target);
        } else if (!secondCheck && target.containsEvent(SingleMatchEvent.class)) {
            packet = (IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_CANNOT_DUEL_BECAUSE_C1_IS_CURRENTLY_ENGAGED_IN_BATTLE).addName(target);
        }
        return packet;
    }

    protected void updatePlayers(boolean start, boolean teleport) {
        for (DuelSnapshotObject $snapshot : this) {
            if (teleport) {
                $snapshot.teleportBack();
                continue;
            }
            Player player = $snapshot.getPlayer();
            if (start) {
                $snapshot.store();
                player.getFlags().getUndying().start();
                player.setTeam($snapshot.getTeam());
                continue;
            }
            if (player.isUndying()) {
                player.getFlags().getUndying().stop();
            }
            player.removeEvent(this);
            if (!this._aborted) {
                $snapshot.restore();
            }
            player.setTeam(TeamType.NONE);
        }
    }

    @Override
    public void onStatusUpdate(Player player) {
        this.sendPacket(new ExDuelUpdateUserInfo(player), player.getTeam().revert());
    }

    @Override
    public SystemMsg checkForAttack(Creature target, Creature attacker, Skill skill, boolean force) {
        if (target.getTeam() == TeamType.NONE || attacker.getTeam() == TeamType.NONE || target.getTeam() == attacker.getTeam()) {
            return SystemMsg.INVALID_TARGET;
        }
        if (!target.containsEvent(this)) {
            return SystemMsg.INVALID_TARGET;
        }
        return null;
    }

    @Override
    public boolean canAttack(Creature target, Creature attacker, Skill skill, boolean force, boolean nextAttackCheck) {
        if (target.getTeam() == TeamType.NONE || attacker.getTeam() == TeamType.NONE || target.getTeam() == attacker.getTeam()) {
            return false;
        }
        return target.containsEvent(this);
    }

    @Override
    public void onAddEvent(GameObject o) {
        if (o.isPlayer()) {
            o.getPlayer().addListener(this._playerExitListener);
        }
    }

    @Override
    public void onRemoveEvent(GameObject o) {
        if (o.isPlayer()) {
            o.getPlayer().removeListener(this._playerExitListener);
        }
    }

    @Override
    public Iterator<DuelSnapshotObject> iterator() {
        List blue = this.getObjects((Object)TeamType.BLUE);
        List red = this.getObjects((Object)TeamType.RED);
        return new JoinedIterator(new Iterator[]{blue.iterator(), red.iterator()});
    }

    @Override
    public void reCalcNextTime(boolean onInit) {
        this.registerActions();
    }

    @Override
    public EventType getType() {
        return EventType.PVP_EVENT;
    }

    @Override
    public void announce(int id, String value, int time) {
        if (id == 1) {
            this.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THE_DUEL_WILL_BEGIN_IN_S1_SECONDS).addInteger(Math.abs(Integer.parseInt(value))));
        }
    }

    public void playerLost(Player player) {
        player.setTeam(TeamType.NONE);
        for (DuelSnapshotObject $snapshot : this) {
            if ($snapshot.getPlayer() != player) continue;
            $snapshot.setDead();
            break;
        }
        this.checkForWinner();
    }

    protected synchronized void checkForWinner() {
        TeamType winnerTeam = null;
        for (TeamType team : TeamType.VALUES) {
            List<DuelSnapshotObject> objects = this.getObjects((Object)team);
            boolean allDead = true;
            for (DuelSnapshotObject d : objects) {
                if (d.isDead()) continue;
                allDead = false;
            }
            if (!allDead) continue;
            winnerTeam = team.revert();
            break;
        }
        if (winnerTeam != null) {
            this._winner = winnerTeam;
            this.stopEvent(false);
        }
    }

    @Override
    public boolean isInProgress() {
        return this._isInProgress;
    }

    private class OnPlayerExitListenerImpl
    extends SingleMatchEvent.OnDeathFromUndyingListenerImpl
    implements OnPlayerExitListener {
        private OnPlayerExitListenerImpl() {
        }

        @Override
        public void onPlayerExit(Player player) {
            DuelEvent.this.playerLost(player);
        }
    }
}


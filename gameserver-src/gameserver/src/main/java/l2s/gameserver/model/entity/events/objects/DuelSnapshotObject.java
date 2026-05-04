/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity.events.objects;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.geometry.ILocation;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.model.base.TeamType;

public class DuelSnapshotObject {
    private final TeamType _team;
    private Player _player;
    private int _classIndex;
    private Location _returnLoc;
    private double _currentHp;
    private double _currentMp;
    private double _currentCp;
    private List<Abnormal> _abnormals = Collections.emptyList();
    private boolean _isDead;

    public DuelSnapshotObject(Player player, TeamType team, boolean store) {
        this._player = player;
        this._team = team;
        if (store) {
            this.store();
        }
    }

    public void store() {
        this._classIndex = this._player.getActiveSubClass().getIndex();
        this._returnLoc = this._player.getStablePoint() == null ? (this._player.getReflection().getReturnLoc() == null ? this._player.getLoc() : this._player.getReflection().getReturnLoc()) : this._player.getStablePoint();
        this._currentCp = this._player.getCurrentCp();
        this._currentHp = this._player.getCurrentHp();
        this._currentMp = this._player.getCurrentMp();
        this._abnormals = new ArrayList<Abnormal>(this._player.getAbnormalList().values());
    }

    public void restore() {
        if (this._player == null) {
            return;
        }
        for (Abnormal abnormal : this._player.getAbnormalList()) {
            if (!abnormal.isOffensive() || this._abnormals.contains(abnormal)) continue;
            abnormal.exit();
        }
        if (this._classIndex == this._player.getActiveSubClass().getIndex()) {
            this._player.setCurrentCp(this._currentCp);
            this._player.setCurrentHpMp(this._currentHp, this._currentMp);
        } else {
            this._player.setCurrentCp(this._player.getMaxCp());
            this._player.setCurrentHpMp(this._player.getMaxHp(), this._player.getMaxMp());
        }
    }

    public void teleportBack() {
        if (this._player == null) {
            return;
        }
        this._player.setStablePoint(null);
        ThreadPoolManager.getInstance().schedule(() -> {
            this._player.getFlags().getFrozen().stop();
            this._player.teleToLocation((ILocation)this._returnLoc, ReflectionManager.MAIN);
        }, 5000L);
    }

    public void blockUnblock() {
        if (this._player == null) {
            return;
        }
        this._player.block();
        List<Servitor> servitors = this._player.getServitors();
        for (Servitor servitor : servitors) {
            servitor.block();
        }
        ThreadPoolManager.getInstance().schedule(() -> {
            this._player.unblock();
            for (Servitor servitor : servitors) {
                servitor.unblock();
            }
        }, 3000L);
    }

    public Player getPlayer() {
        return this._player;
    }

    public boolean isDead() {
        return this._isDead;
    }

    public void setDead() {
        this._isDead = true;
    }

    public Location getLoc() {
        return this._returnLoc;
    }

    public TeamType getTeam() {
        return this._team;
    }

    public Location getReturnLoc() {
        return this._returnLoc;
    }

    public void clear() {
        this._player = null;
    }
}


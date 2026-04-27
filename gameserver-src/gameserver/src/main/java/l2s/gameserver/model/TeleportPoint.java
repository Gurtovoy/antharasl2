/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.model.entity.Reflection;

public class TeleportPoint {
    private Location _loc;
    private Reflection _reflection = ReflectionManager.MAIN;

    public TeleportPoint(Location loc, Reflection reflection) {
        this._loc = loc;
        this._reflection = reflection;
    }

    public TeleportPoint(Location loc) {
        this._loc = loc;
    }

    public TeleportPoint() {
    }

    public Location getLoc() {
        return this._loc;
    }

    public TeleportPoint setLoc(Location loc) {
        this._loc = loc;
        return this;
    }

    public Reflection getReflection() {
        return this._reflection;
    }

    public TeleportPoint setReflection(Reflection reflection) {
        this._reflection = reflection;
        return this;
    }
}


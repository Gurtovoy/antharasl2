/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.templates.npc;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.network.l2.components.NpcString;

public class WalkerRoutePoint {
    private final Location _loc;
    private final NpcString[] _phrases;
    private final int _socialActionId;
    private final int _delay;
    private final boolean _running;
    private final boolean _teleport;

    public WalkerRoutePoint(Location loc, NpcString[] phrases, int socialActionId, int delay, boolean running, boolean teleport) {
        this._loc = loc;
        this._phrases = phrases;
        this._socialActionId = socialActionId;
        this._delay = delay;
        this._running = running;
        this._teleport = teleport;
    }

    public Location getLocation() {
        return this._loc;
    }

    public NpcString[] getPhrases() {
        return this._phrases;
    }

    public int getSocialActionId() {
        return this._socialActionId;
    }

    public int getDelay() {
        return this._delay;
    }

    public boolean isRunning() {
        return this._running;
    }

    public boolean isTeleport() {
        return this._teleport;
    }
}


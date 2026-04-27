/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.ai;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.ai.DefaultAI;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.instances.RaceManagerInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.MonRaceInfoPacket;

public class RaceManager
extends DefaultAI {
    private boolean thinking = false;
    private List<Player> _knownPlayers = new ArrayList<Player>();

    public RaceManager(NpcInstance actor) {
        super(actor);
        this._attackAITaskDelay = 5000L;
    }

    @Override
    public void run() {
        this.onEvtThink();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    protected void onEvtThink() {
        RaceManagerInstance actor = this.getActor();
        if (actor == null) {
            return;
        }
        MonRaceInfoPacket packet = actor.getPacket();
        if (packet == null) {
            return;
        }
        RaceManager raceManager = this;
        synchronized (raceManager) {
            if (this.thinking) {
                return;
            }
            this.thinking = true;
        }
        try {
            ArrayList<Player> newPlayers = new ArrayList<Player>();
            for (Player player : World.getAroundObservers(actor)) {
                if (player == null) continue;
                newPlayers.add(player);
                if (!this._knownPlayers.contains(player)) {
                    player.sendPacket((IBroadcastPacket)packet);
                }
                this._knownPlayers.remove(player);
            }
            for (Player player : this._knownPlayers) {
                actor.removeKnownPlayer(player);
            }
            this._knownPlayers = newPlayers;
        }
        finally {
            this.thinking = false;
        }
    }

    @Override
    public RaceManagerInstance getActor() {
        return (RaceManagerInstance)super.getActor();
    }
}


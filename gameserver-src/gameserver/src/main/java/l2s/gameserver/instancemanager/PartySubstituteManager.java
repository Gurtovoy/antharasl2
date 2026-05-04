/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.instancemanager;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.Future;
import l2s.commons.threading.SteppingRunnableQueueManager;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Request;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExRegistWaitingSubstituteOk;

public class PartySubstituteManager
extends SteppingRunnableQueueManager {
    private static final PartySubstituteManager _instance = new PartySubstituteManager();
    private final List<Player> waitingPlayers = new CopyOnWriteArrayList<Player>();
    private final List<Player> waitingMembers = new CopyOnWriteArrayList<Player>();

    public void addWaitingPlayer(Player player) {
        this.waitingPlayers.add(player);
    }

    public void removeWaitingPlayer(Player player) {
        this.waitingPlayers.remove(player);
    }

    public void addPartyMember(Player player) {
        this.waitingMembers.add(player);
    }

    public void removePartyMember(Player player) {
        this.waitingMembers.remove(player);
    }

    public static PartySubstituteManager getInstance() {
        return _instance;
    }

    private PartySubstituteManager() {
        super(10000L);
        ThreadPoolManager.getInstance().scheduleAtFixedRate((Runnable)((Object)this), 10000L, 10000L);
        ThreadPoolManager.getInstance().scheduleAtFixedRate(() -> this.purge(), 60000L, 60000L);
        this.scheduleAtFixedRate(() -> {
            if (!this.waitingMembers.isEmpty() && !this.waitingPlayers.isEmpty()) {
                for (Player player : this.waitingMembers) {
                    if (player == null || !player.isOnline() || player.getRequest() != null || !player.isPartySubstituteStarted() || player.getParty() == null) continue;
                    for (Player wait : this.waitingPlayers) {
                        if (wait == null || wait.getParty() != null || wait.getRequest() != null || wait.getClassId() != player.getClassId() || wait.getLevel() != player.getLevel()) continue;
                        new Request(Request.L2RequestType.PARTY_MEMBER_SUBSTITUTE, player, wait).setTimeout(10000L);
                        wait.sendPacket((IBroadcastPacket)new ExRegistWaitingSubstituteOk(null));
                        player.stopSubstituteTask();
                    }
                }
            }
        }, 30000L, 30000L);
    }

    public Future<?> SubstituteSearchTask(Player player) {
        if (player == null) {
            return null;
        }
        this.waitingMembers.add(player);
        return this.schedule(() -> {
            this.waitingMembers.remove(player);
            if (player.getParty() != null) {
                // empty if block
            }
            player.sendUserInfo();
            player.sendMessage("test");
        }, 300000L);
    }
}


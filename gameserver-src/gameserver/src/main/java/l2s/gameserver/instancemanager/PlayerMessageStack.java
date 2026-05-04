/*
 * This file was originally decompiled from L2S rev.[31495].
 * Refactored: replaced HashMap+synchronized with ConcurrentHashMap, fixed singleton,
 * removed CFR decompiler artifacts.
 */
package l2s.gameserver.instancemanager;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.IBroadcastPacket;

public class PlayerMessageStack
{
    private static volatile PlayerMessageStack _instance;
    private static final int MAX_MESSAGES_PER_PLAYER = 100;

    /** Pending messages for offline players. Key = objectId, Value = message queue. */
    private final ConcurrentHashMap<Integer, List<IBroadcastPacket>> _stack = new ConcurrentHashMap<>();

    public static PlayerMessageStack getInstance()
    {
        if (_instance == null)
        {
            synchronized (PlayerMessageStack.class)
            {
                if (_instance == null)
                {
                    _instance = new PlayerMessageStack();
                }
            }
        }
        return _instance;
    }

    /**
     * Sends a message to the player immediately if online,
     * or queues it for delivery when the player logs in.
     */
    public void mailto(int charObjId, IBroadcastPacket message)
    {
        Player player = GameObjectsStorage.getPlayer(charObjId);
        if (player != null)
        {
            player.sendPacket(message);
            return;
        }
        // compute() is atomic in ConcurrentHashMap — no explicit lock needed
        _stack.compute(charObjId, (id, messages) ->
        {
            if (messages == null)
            {
                messages = new ArrayList<>();
            }
            messages.add(message);
            // cap queue size to avoid memory leak for very long offline periods
            while (messages.size() > MAX_MESSAGES_PER_PLAYER)
            {
                messages.remove(0);
            }
            return messages;
        });
    }

    /**
     * Delivers all queued messages to a player who just logged in.
     */
    public void checkMessages(Player player)
    {
        List<IBroadcastPacket> messages = _stack.remove(player.getObjectId());
        if (messages == null || messages.isEmpty())
        {
            return;
        }
        for (IBroadcastPacket message : messages)
        {
            player.sendPacket(message);
        }
    }

    /**
     * @deprecated Use {@link #checkMessages(Player)} instead.
     */
    @Deprecated
    public void CheckMessages(Player player)
    {
        checkMessages(player);
    }

    /**
     * Removes empty queues to prevent memory accumulation.
     */
    public void cleanup()
    {
        Iterator<Map.Entry<Integer, List<IBroadcastPacket>>> it = _stack.entrySet().iterator();
        while (it.hasNext())
        {
            Map.Entry<Integer, List<IBroadcastPacket>> entry = it.next();
            if (entry.getValue() == null || entry.getValue().isEmpty())
            {
                it.remove();
            }
        }
    }
}

/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.entity.events.actions;

import java.util.List;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.EventAction;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.network.l2.components.ChatType;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.NpcString;
import l2s.gameserver.network.l2.s2c.NSPacket;

public class NpcSayAction
implements EventAction {
    private int _npcId;
    private int _range;
    private ChatType _chatType;
    private NpcString _text;

    public NpcSayAction(int npcId, int range, ChatType type, NpcString string) {
        this._npcId = npcId;
        this._range = range;
        this._chatType = type;
        this._text = string;
    }

    @Override
    public void call(Event event) {
        List<NpcInstance> npcs = GameObjectsStorage.getNpcs(true, this._npcId);
        if (npcs.isEmpty()) {
            return;
        }
        for (NpcInstance npc : npcs) {
            for (Player player : World.getAroundObservers(npc)) {
                if (this._range > 0 && !player.isInRangeZ(npc, this._range)) continue;
                this.packet(npc, player);
            }
        }
    }

    private void packet(NpcInstance npc, Player player) {
        player.sendPacket((IBroadcastPacket)new NSPacket(npc, this._chatType, this._text, new String[0]));
    }
}


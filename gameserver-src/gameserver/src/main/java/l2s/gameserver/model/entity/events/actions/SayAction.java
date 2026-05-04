/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity.events.actions;

import java.util.List;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.EventAction;
import l2s.gameserver.network.l2.components.ChatType;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.NpcString;
import l2s.gameserver.network.l2.components.SysString;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SayPacket2;

public class SayAction
implements EventAction {
    private int _range;
    private ChatType _chatType;
    private String _how;
    private NpcString _text;
    private SysString _sysString;
    private SystemMsg _systemMsg;

    protected SayAction(int range, ChatType type) {
        this._range = range;
        this._chatType = type;
    }

    public SayAction(int range, ChatType type, SysString sysString, SystemMsg systemMsg) {
        this(range, type);
        this._sysString = sysString;
        this._systemMsg = systemMsg;
    }

    public SayAction(int range, ChatType type, String how, NpcString string) {
        this(range, type);
        this._text = string;
        this._how = how;
    }

    @Override
    public void call(Event event) {
        List<Player> players = event.broadcastPlayers(this._range);
        for (Player player : players) {
            this.packet(player);
        }
    }

    private void packet(Player player) {
        if (player == null) {
            return;
        }
        SayPacket2 packet = null;
        packet = this._sysString != null ? new SayPacket2(0, this._chatType, this._sysString, this._systemMsg) : new SayPacket2(0, this._chatType, this._how, this._text, new String[0]);
        player.sendPacket((IBroadcastPacket)packet);
    }
}


/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.listener.actor.player.impl;

import l2s.commons.lang.reference.HardReference;
import l2s.gameserver.data.xml.holder.EventHolder;
import l2s.gameserver.listener.actor.player.OnAnswerListener;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.events.EventType;
import l2s.gameserver.model.entity.events.impl.PvPEvent;

public class EventAnswerListner
implements OnAnswerListener {
    private final HardReference<Player> _playerRef;
    private final int _eventId;

    public EventAnswerListner(Player player, int eventId) {
        this._playerRef = player.getRef();
        this._eventId = eventId;
    }

    @Override
    public void sayYes() {
        Player player = (Player)this._playerRef.get();
        if (player == null) {
            return;
        }
        PvPEvent event = (PvPEvent)((Object)EventHolder.getInstance().getEvent(EventType.CUSTOM_PVP_EVENT, this._eventId));
        if (event != null && event.isRegActive()) {
            event.reg(player);
        }
    }

    @Override
    public void sayNo() {
    }
}


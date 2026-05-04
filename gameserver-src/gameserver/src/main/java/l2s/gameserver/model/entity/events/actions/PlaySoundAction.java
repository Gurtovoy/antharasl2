/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity.events.actions;

import java.util.List;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.EventAction;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.PlaySoundPacket;

public class PlaySoundAction
implements EventAction {
    private int _range;
    private String _sound;
    private PlaySoundPacket.Type _type;

    public PlaySoundAction(int range, String s, PlaySoundPacket.Type type) {
        this._range = range;
        this._sound = s;
        this._type = type;
    }

    @Override
    public void call(Event event) {
        GameObject object = event.getCenterObject();
        PlaySoundPacket packet = null;
        packet = object != null ? new PlaySoundPacket(this._type, this._sound, 1, object.getObjectId(), object.getLoc()) : new PlaySoundPacket(this._type, this._sound, 0, 0, 0, 0, 0);
        List<Player> players = event.broadcastPlayers(this._range);
        for (Player player : players) {
            if (player == null) continue;
            player.sendPacket((IBroadcastPacket)packet);
        }
    }
}


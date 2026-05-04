package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.ShortCut;
import l2s.gameserver.network.l2.s2c.ShortCutPacket;

public class ShortCutRegisterPacket
extends ShortCutPacket {
    private ShortCutPacket.ShortcutInfo _shortcutInfo;

    public ShortCutRegisterPacket(Player player, ShortCut sc) {
        this._shortcutInfo = ShortCutRegisterPacket.convert(player, sc);
    }

    @Override
    protected final void writeImpl() {
        this._shortcutInfo.write(this);
    }
}


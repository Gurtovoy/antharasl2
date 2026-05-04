package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.ShortCut;
import l2s.gameserver.network.l2.s2c.ShortCutPacket;

public class ShortCutInitPacket
extends ShortCutPacket {
    private List<ShortCutPacket.ShortcutInfo> _shortCuts = Collections.emptyList();

    public ShortCutInitPacket(Player pl) {
        Collection<ShortCut> shortCuts = pl.getAllShortCuts();
        this._shortCuts = new ArrayList<ShortCutPacket.ShortcutInfo>(shortCuts.size());
        for (ShortCut shortCut : shortCuts) {
            this._shortCuts.add(ShortCutInitPacket.convert(pl, shortCut));
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._shortCuts.size());
        for (ShortCutPacket.ShortcutInfo sc : this._shortCuts) {
            sc.write(this);
        }
    }
}


/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExCuriousHouseObserveList
extends L2GameServerPacket {
    private final List<ArenaInfo> _arenas = new ArrayList<ArenaInfo>();

    public ExCuriousHouseObserveList(int currentId) {
    }

    public ExCuriousHouseObserveList() {
        this(-1);
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._arenas.size());
        for (ArenaInfo arena : this._arenas) {
            this.writeD(arena.id);
            this.writeS(arena.unk);
            this.writeH(arena.status);
            this.writeD(arena.participants);
        }
    }

    private static class ArenaInfo {
        public final int id;
        public final String unk;
        public final int status;
        public final int participants;

        public ArenaInfo(int id, String unk, int status, int participants) {
            this.id = id;
            this.unk = unk;
            this.status = status;
            this.participants = participants;
        }
    }
}


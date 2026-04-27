/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class MonRaceInfoPacket
extends L2GameServerPacket {
    private int _unknown1;
    private int _unknown2;
    private NpcInstance[] _monsters;
    private int[][] _speeds;

    public MonRaceInfoPacket(int unknown1, int unknown2, NpcInstance[] monsters, int[][] speeds) {
        this._unknown1 = unknown1;
        this._unknown2 = unknown2;
        this._monsters = monsters;
        this._speeds = speeds;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._unknown1);
        this.writeD(this._unknown2);
        this.writeD(8);
        for (int i = 0; i < 8; ++i) {
            this.writeD(this._monsters[i].getObjectId());
            this.writeD(this._monsters[i].getNpcId() + 1000000);
            this.writeD(14107);
            this.writeD(181875 + 58 * (7 - i));
            this.writeD(-3566);
            this.writeD(12080);
            this.writeD(181875 + 58 * (7 - i));
            this.writeD(-3566);
            this.writeF(this._monsters[i].getCurrentCollisionHeight());
            this.writeF(this._monsters[i].getCurrentCollisionRadius());
            this.writeD(120);
            for (int j = 0; j < 20; ++j) {
                this.writeC(this._unknown1 == 0 ? this._speeds[i][j] : 0);
            }
            this.writeD(0);
            this.writeD(0);
        }
    }
}


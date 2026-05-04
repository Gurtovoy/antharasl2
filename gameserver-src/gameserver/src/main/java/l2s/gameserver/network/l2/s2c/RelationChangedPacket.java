package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class RelationChangedPacket
extends L2GameServerPacket {
    public static final int RELATION_INSIDE_BATTLEFIELD = 1;
    public static final int RELATION_IN_PVP = 2;
    public static final int RELATION_CHAOTIC = 4;
    public static final int RELATION_IN_PARTY = 8;
    public static final int RELATION_PARTY_LEADER = 16;
    public static final int RELATION_SAME_PARTY = 32;
    public static final int RELATION_IN_PLEDGE = 64;
    public static final int RELATION_PLEDGE_LEADER = 128;
    public static final int RELATION_SAME_PLEDGE = 256;
    public static final int RELATION_SIEGE_PARTICIPANT = 512;
    public static final int RELATION_SIEGE_ATTACKER = 1024;
    public static final int RELATION_SIEGE_ALLY = 2048;
    public static final int RELATION_SIEGE_ENEMY = 4096;
    public static final int RELATION_CLAN_WAR_ATTACKER = 16384;
    public static final int RELATION_CLAN_WAR_ATTACKED = 32768;
    public static final int RELATION_IN_ALLIANCE = 65536;
    public static final int RELATION_ALLIANCE_LEADER = 131072;
    public static final int RELATION_SAME_ALLIANCE = 262144;
    private static final byte SEND_DEFAULT = 1;
    private static final byte SEND_ONE = 2;
    private static final byte SEND_MULTI = 4;
    private byte _mask = 0;
    private final List<RelationChangedData> _datas = new ArrayList<RelationChangedData>(1);

    public RelationChangedPacket() {
    }

    public RelationChangedPacket(Playable about, Player target) {
        this.add(about, target);
    }

    public void add(Playable about, Player target) {
        RelationChangedData data = new RelationChangedData();
        data.objectId = about.getObjectId();
        data.karma = about.getKarma();
        data.pvpFlag = about.getPvpFlag();
        data.isAutoAttackable = about.isAutoAttackable(target);
        data.relation = about.getRelation(target);
        this._datas.add(data);
        if (this._datas.size() > 1) {
            this._mask = (byte)(this._mask | 4);
        } else if (this._datas.size() == 1) {
            this._mask = (byte)(this._mask | 2);
        }
    }

    @Override
    protected void writeImpl() {
        this.writeC(this._mask);
        if ((this._mask & 4) == 4) {
            this.writeH(this._datas.size());
            for (RelationChangedData data : this._datas) {
                this.writeRelation(data);
            }
        } else if ((this._mask & 2) == 2) {
            this.writeRelation(this._datas.get(0));
        } else if ((this._mask & 1) == 1) {
            this.writeD(this._datas.get((int)0).objectId);
        }
    }

    private void writeRelation(RelationChangedData data) {
        this.writeD(data.objectId);
        this.writeD(data.relation);
        this.writeC(data.isAutoAttackable);
        this.writeD(data.karma);
        this.writeC(data.pvpFlag);
    }

    private static class RelationChangedData {
        public int objectId;
        public boolean isAutoAttackable;
        public int relation;
        public int karma;
        public int pvpFlag;

        private RelationChangedData() {
        }
    }
}


package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import l2s.gameserver.data.xml.holder.ResidenceHolder;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.model.entity.residence.Castle;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.tables.ClanTable;

public class ExShowCastleInfo
extends L2GameServerPacket {
    private List<CastleInfo> _infos = Collections.emptyList();

    public ExShowCastleInfo() {
        List<Castle> castles = ResidenceHolder.getInstance().getResidenceList(Castle.class);
        this._infos = new ArrayList<CastleInfo>(castles.size());
        for (Castle castle : castles) {
            boolean inSiege;
            int nextSiege;
            String ownerName = ClanTable.getInstance().getClanName(castle.getOwnerId());
            int id = castle.getId();
            int tax = castle.getSellTaxPercent();
            int side = castle.getResidenceSide().ordinal();
            if (castle.getSiegeEvent() != null) {
                nextSiege = (int)(castle.getSiegeDate().getTimeInMillis() / 1000L);
                inSiege = ((SiegeEvent)((Object)castle.getSiegeEvent())).isInProgress();
            } else {
                nextSiege = 0;
                inSiege = false;
            }
            this._infos.add(new CastleInfo(ownerName, id, tax, nextSiege, inSiege, side));
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._infos.size());
        for (CastleInfo info : this._infos) {
            this.writeD(info._id);
            this.writeS(info._ownerName);
            this.writeD(info._tax);
            this.writeD(info._nextSiege);
            this.writeC(info._inSiege);
            this.writeC(info._side);
        }
        this._infos.clear();
    }

    private static class CastleInfo {
        public String _ownerName;
        public int _id;
        public int _tax;
        public int _nextSiege;
        public int _side;
        public boolean _inSiege;

        public CastleInfo(String ownerName, int id, int tax, int nextSiege, boolean inSiege, int side) {
            this._ownerName = ownerName;
            this._id = id;
            this._tax = tax;
            this._nextSiege = nextSiege;
            this._inSiege = inSiege;
            this._side = side;
        }
    }
}


package l2s.gameserver.network.l2.s2c;

import java.util.Calendar;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.residence.Residence;
import l2s.gameserver.model.pledge.Alliance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class CastleSiegeInfoPacket
extends L2GameServerPacket {
    private int _startTime;
    private int _id;
    private int _ownerObjectId;
    private int _allyId;
    private boolean _isLeader;
    private String _ownerName = "NPC";
    private String _leaderName = "";
    private String _allyName = "";

    public CastleSiegeInfoPacket(Residence residence, Player player) {
        this._id = residence.getId();
        this._ownerObjectId = residence.getOwnerId();
        Clan owner = residence.getOwner();
        if (owner != null) {
            this._isLeader = player.isGM() || owner.getLeaderId(0) == player.getObjectId();
            this._ownerName = owner.getName();
            this._leaderName = owner.getLeaderName(0);
            Alliance ally = owner.getAlliance();
            if (ally != null) {
                this._allyId = ally.getAllyId();
                this._allyName = ally.getAllyName();
            }
        }
        this._startTime = residence.getSiegeEvent() != null ? (int)(residence.getSiegeDate().getTimeInMillis() / 1000L) : 0;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._id);
        this.writeD(this._isLeader ? 1 : 0);
        this.writeD(this._ownerObjectId);
        this.writeS(this._ownerName);
        this.writeS(this._leaderName);
        this.writeD(this._allyId);
        this.writeS(this._allyName);
        this.writeD((int)(Calendar.getInstance().getTimeInMillis() / 1000L));
        this.writeD(this._startTime);
    }
}


package l2s.gameserver.network.l2.s2c;

import java.util.List;
import l2s.gameserver.model.base.TeamType;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExPVPMatchRecord
extends L2GameServerPacket {
    public static final int START = 0;
    public static final int UPDATE = 1;
    public static final int FINISH = 2;
    private int _type;
    private TeamType _winnerTeam;
    private int _blueKills;
    private int _redKills;
    private List<Member> _blueList;
    private List<Member> _redList;

    public ExPVPMatchRecord(int type, TeamType winnerTeam, int blueKills, int redKills, List<Member> blueTeam, List<Member> redTeam) {
        this._type = type;
        this._winnerTeam = winnerTeam;
        this._blueKills = blueKills;
        this._redKills = redKills;
        this._blueList = blueTeam;
        this._redList = redTeam;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._type);
        this.writeD(this._winnerTeam.ordinal());
        this.writeD(this._winnerTeam.revert().ordinal());
        this.writeD(this._blueKills);
        this.writeD(this._redKills);
        this.writeD(this._blueList.size());
        for (Member member : this._blueList) {
            this.writeS(member.name);
            this.writeD(member.kills);
            this.writeD(member.deaths);
        }
        this.writeD(this._redList.size());
        for (Member member : this._redList) {
            this.writeS(member.name);
            this.writeD(member.kills);
            this.writeD(member.deaths);
        }
    }

    public static class Member {
        public String name;
        public int kills;
        public int deaths;

        public Member(String name, int kills, int deaths) {
            this.name = name;
            this.kills = kills;
            this.deaths = deaths;
        }
    }
}


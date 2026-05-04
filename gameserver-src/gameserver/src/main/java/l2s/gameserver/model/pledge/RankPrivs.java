package l2s.gameserver.model.pledge;

public class RankPrivs {
    private int _rank;
    private int _party;
    private int _privs;

    public RankPrivs(int rank, int party, int privs) {
        this._rank = rank;
        this._party = party;
        this._privs = privs;
    }

    public int getRank() {
        return this._rank;
    }

    public int getParty() {
        return this._party;
    }

    public void setParty(int party) {
        this._party = party;
    }

    public int getPrivs() {
        return this._privs;
    }

    public void setPrivs(int privs) {
        this._privs = privs;
    }
}


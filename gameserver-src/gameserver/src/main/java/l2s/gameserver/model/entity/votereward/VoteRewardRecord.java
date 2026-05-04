/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity.votereward;

import l2s.commons.dao.JdbcEntity;
import l2s.commons.dao.JdbcEntityState;
import l2s.gameserver.dao.VoteRewardRecordsDAO;

public class VoteRewardRecord
implements JdbcEntity {
    private final String site;
    private final String identifier;
    private int votes;
    private int lastVoteTime;
    private JdbcEntityState _jdbcEntityState = JdbcEntityState.CREATED;

    public VoteRewardRecord(String site, String identifier, int votes, int lastVoteTime) {
        this.site = site;
        this.identifier = identifier;
        this.votes = votes;
        this.lastVoteTime = lastVoteTime;
    }

    public String getSite() {
        return this.site;
    }

    public String getIdentifier() {
        return this.identifier;
    }

    public int getVotes() {
        return this.votes;
    }

    public int getLastVoteTime() {
        return this.lastVoteTime;
    }

    public void onReceiveReward(int votes, long voteTime) {
        this.votes += votes;
        this.lastVoteTime = (int)(voteTime / 1000L);
        this.setJdbcState(JdbcEntityState.UPDATED);
        this.update();
    }

    public void setJdbcState(JdbcEntityState state) {
        this._jdbcEntityState = state;
    }

    public JdbcEntityState getJdbcState() {
        return this._jdbcEntityState;
    }

    public void save() {
        VoteRewardRecordsDAO.getInstance().save(this);
    }

    public void delete() {
        throw new UnsupportedOperationException();
    }

    public void update() {
        VoteRewardRecordsDAO.getInstance().update(this);
    }
}


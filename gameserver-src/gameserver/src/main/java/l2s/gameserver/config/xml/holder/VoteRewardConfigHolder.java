package l2s.gameserver.config.xml.holder;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.model.entity.votereward.VoteRewardSite;

public final class VoteRewardConfigHolder
extends AbstractHolder {
    private static final VoteRewardConfigHolder INSTANCE = new VoteRewardConfigHolder();
    public static String[] REWARD_COMMANDS = new String[0];
    private final Map<String, VoteRewardSite> voteRewardSites = new HashMap<String, VoteRewardSite>();

    public static VoteRewardConfigHolder getInstance() {
        return INSTANCE;
    }

    public void addVoteRewardSite(VoteRewardSite site) {
        if (this.voteRewardSites.containsKey(site.getName())) {
            this.warn(String.format("Dublicate %s Vote Site registered!", site.getName()));
        }
        this.voteRewardSites.put(site.getName(), site);
    }

    public Collection<VoteRewardSite> getVoteRewardSites() {
        return this.voteRewardSites.values();
    }

    public void callInit() {
        for (VoteRewardSite site : this.voteRewardSites.values()) {
            site.init();
        }
    }

    public void log() {
        this.info(String.format("loaded %d Vote Site(s) count.", this.voteRewardSites.size()));
    }

    public int size() {
        return this.voteRewardSites.size();
    }

    public void clear() {
        this.voteRewardSites.clear();
    }
}


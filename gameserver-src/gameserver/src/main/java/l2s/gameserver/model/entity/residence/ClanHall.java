package l2s.gameserver.model.entity.residence;

import l2s.commons.dao.JdbcEntityState;
import l2s.gameserver.dao.ClanHallDAO;
import l2s.gameserver.data.xml.holder.ResidenceHolder;
import l2s.gameserver.instancemanager.SpawnManager;
import l2s.gameserver.model.entity.residence.ClanHallType;
import l2s.gameserver.model.entity.residence.Residence;
import l2s.gameserver.model.entity.residence.ResidenceType;
import l2s.gameserver.model.entity.residence.clanhall.InstantClanHall;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.templates.StatsSet;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class ClanHall
extends Residence {
    private static final Logger _log = LoggerFactory.getLogger(ClanHall.class);

    public ClanHall(StatsSet set) {
        super(set);
    }

    /**
     * Returns the spawn group name for this clan hall's functional NPCs.
     * Matches the group attribute in spawn XML files, e.g. "the_atramental_barracks_31".
     */
    private String getSpawnGroupName() {
        return getName().toLowerCase().replace(' ', '_') + "_" + getId();
    }

    @Override
    public void init() {
        this.initEvent();
        this.loadData();
        this.loadFunctions();
        this.rewardSkills();
        if (getOwnerId() > 0) {
            String group = getSpawnGroupName();
            _log.info("ClanHall: spawning NPC group '" + group + "' for residence " + getId() + " (owned by clan " + getOwnerId() + ")");
            SpawnManager.getInstance().spawn(group);
        }
    }

    public int getInstantId() {
        return 0;
    }

    @Override
    public void changeOwner(Clan clan) {
        Clan oldOwner = this.getOwner();
        if (oldOwner != null && (clan == null || clan.getClanId() != oldOwner.getClanId())) {
            this.removeSkills();
            oldOwner.setHasHideout(0);
            this.cancelCycleTask();
            SpawnManager.getInstance().despawn(getSpawnGroupName());
        }
        this.setOwner(clan);
        this.removeFunctions();
        if (clan != null) {
            InstantClanHall instantClanHall = ResidenceHolder.getInstance().getResidence(InstantClanHall.class, clan.getHasHideout());
            if (instantClanHall != null) {
                instantClanHall.removeOwner(clan, true);
                clan.broadcastToOnlineMembers(SystemMsg.YOU_HAVE_ACQUIRED_A_CLAN_HALL_OF_HIGHER_VALUE_THAN_THE_PROVISIONAL_CLAN_HALL_THE_PROVISIONAL_CLAN_HALL_OWNERSHIP_WILL_AUTOMATICALLY_BE_FORFEITED);
            }
            clan.setHasHideout(this.getId());
            clan.broadcastClanStatus(true, false, false);
            SpawnManager.getInstance().spawn(getSpawnGroupName());
        }
        this.rewardSkills();
        this.setJdbcState(JdbcEntityState.UPDATED);
        this.update();
    }

    @Override
    public ResidenceType getType() {
        return ResidenceType.CLANHALL;
    }

    @Override
    public int getVisibleFunctionLevel(int level) {
        if (level <= 10) {
            return level;
        }
        return level - 10;
    }

    @Override
    protected void loadData() {
        ClanHallDAO.getInstance().select(this);
    }

    public int getGrade() {
        return 0;
    }

    public void update() {
        ClanHallDAO.getInstance().update(this);
    }

    public int getAuctionLength() {
        return 0;
    }

    public void setAuctionLength(int auctionLength) {
    }

    public String getAuctionDescription() {
        return "";
    }

    public void setAuctionDescription(String auctionDescription) {
    }

    public long getAuctionMinBid() {
        return 0L;
    }

    public void setAuctionMinBid(long auctionMinBid) {
    }

    public int getFeeItemId() {
        return 0;
    }

    public long getRentalFee() {
        return 0L;
    }

    public long getBaseMinBid() {
        return 0L;
    }

    public long getDeposit() {
        return 0L;
    }

    @Override
    public void chanceCycle() {
        super.chanceCycle();
        this.setPaidCycle(this.getPaidCycle() + 1);
    }

    public int getInstantZoneId() {
        return -1;
    }

    public abstract ClanHallType getClanHallType();
}

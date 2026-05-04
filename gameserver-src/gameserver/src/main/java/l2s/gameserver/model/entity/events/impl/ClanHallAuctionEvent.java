package l2s.gameserver.model.entity.events.impl;

import java.util.Arrays;
import java.util.Calendar;
import java.util.List;
import l2s.commons.collections.MultiValueSet;
import l2s.commons.dao.JdbcEntityState;
import l2s.commons.time.cron.SchedulingPattern;
import l2s.gameserver.dao.SiegeClanDAO;
import l2s.gameserver.instancemanager.PlayerMessageStack;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.events.actions.StartStopAction;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.model.entity.events.objects.AuctionSiegeClanObject;
import l2s.gameserver.model.entity.events.objects.SiegeClanObject;
import l2s.gameserver.model.entity.residence.Residence;
import l2s.gameserver.model.entity.residence.clanhall.AuctionClanHall;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.tables.ClanTable;

public class ClanHallAuctionEvent
extends SiegeEvent<AuctionClanHall, AuctionSiegeClanObject> {
    private static final SchedulingPattern START_TIME_PATTERN = new SchedulingPattern("00 15 * * 1");

    public ClanHallAuctionEvent(MultiValueSet<String> set) {
        super(set);
    }

    @Override
    public void reCalcNextTime(boolean onStart) {
        this.clearActions();
        this._onTimeActions.clear();
        Clan owner = ((AuctionClanHall)this.getResidence()).getOwner();
        if (((AuctionClanHall)this.getResidence()).getAuctionLength() == 0 && owner == null) {
            Calendar siegeDate = ((AuctionClanHall)this.getResidence()).getSiegeDate();
            siegeDate.setTimeInMillis(START_TIME_PATTERN.next(System.currentTimeMillis()));
            siegeDate.add(5, 7);
            ((AuctionClanHall)this.getResidence()).setAuctionLength(7);
            ((AuctionClanHall)this.getResidence()).setAuctionMinBid(((AuctionClanHall)this.getResidence()).getBaseMinBid());
            ((AuctionClanHall)this.getResidence()).setJdbcState(JdbcEntityState.UPDATED);
            ((AuctionClanHall)this.getResidence()).update();
            this._onTimeActions.clear();
            this.addOnTimeAction(0, new StartStopAction("event", true));
            this.addOnTimeAction(((AuctionClanHall)this.getResidence()).getAuctionLength() * 86400, new StartStopAction("event", false));
            this.registerActions();
        } else if (((AuctionClanHall)this.getResidence()).getAuctionLength() != 0 || owner == null) {
            Calendar siegeDate = ((AuctionClanHall)this.getResidence()).getSiegeDate();
            if (!onStart && siegeDate.getTimeInMillis() < System.currentTimeMillis()) {
                siegeDate.setTimeInMillis(START_TIME_PATTERN.next(System.currentTimeMillis()));
                siegeDate.add(5, ((AuctionClanHall)this.getResidence()).getAuctionLength());
            }
            this._onTimeActions.clear();
            this.addOnTimeAction(0, new StartStopAction("event", true));
            this.addOnTimeAction(((AuctionClanHall)this.getResidence()).getAuctionLength() * 86400, new StartStopAction("event", false));
            this.registerActions();
        }
    }

    private void generateSiegeDate() {
        Calendar siegeDate = ((AuctionClanHall)this.getResidence()).getSiegeDate();
        siegeDate.setTimeInMillis(new SchedulingPattern("00 " + siegeDate.get(11) + " * * 1").next(System.currentTimeMillis()));
        siegeDate.add(5, ((AuctionClanHall)this.getResidence()).getAuctionLength());
        ((AuctionClanHall)this.getResidence()).setJdbcState(JdbcEntityState.UPDATED);
        ((AuctionClanHall)this.getResidence()).update();
    }

    @Override
    public void stopEvent(boolean force) {
        AuctionSiegeClanObject winnerSiegeClan;
        List<AuctionSiegeClanObject> siegeClanObjects = this.removeObjects("attackers");
        AuctionSiegeClanObject[] clans = siegeClanObjects.toArray(new AuctionSiegeClanObject[siegeClanObjects.size()]);
        Arrays.sort(clans, SiegeClanObject.SiegeClanComparatorImpl.getInstance());
        Clan oldOwner = ((AuctionClanHall)this.getResidence()).getOwner();
        AuctionSiegeClanObject auctionSiegeClanObject = winnerSiegeClan = clans.length > 0 ? clans[0] : null;
        if (winnerSiegeClan != null) {
            SystemMessagePacket msg = (SystemMessagePacket)new SystemMessagePacket(SystemMsg.THE_CLAN_HALL_WHICH_WAS_PUT_UP_FOR_AUCTION_HAS_BEEN_AWARDED_TO_S1_CLAN).addString(winnerSiegeClan.getClan().getName());
            for (AuctionSiegeClanObject siegeClan : siegeClanObjects) {
                Player player = siegeClan.getClan().getLeader().getPlayer();
                if (player != null) {
                    player.sendPacket((IBroadcastPacket)msg);
                } else {
                    PlayerMessageStack.getInstance().mailto(siegeClan.getClan().getLeaderId(), msg);
                }
                if (siegeClan == winnerSiegeClan) continue;
                long returnBid = siegeClan.getParam() - (long)((double)siegeClan.getParam() * 0.1);
                siegeClan.getClan().getWarehouse().addItem(((AuctionClanHall)this.getResidence()).getFeeItemId(), returnBid);
            }
            SiegeClanDAO.getInstance().delete((Residence)this.getResidence());
            if (oldOwner != null) {
                oldOwner.getWarehouse().addItem(((AuctionClanHall)this.getResidence()).getFeeItemId(), ((AuctionClanHall)this.getResidence()).getDeposit() + winnerSiegeClan.getParam());
            }
            ((AuctionClanHall)this.getResidence()).setAuctionLength(0);
            ((AuctionClanHall)this.getResidence()).setAuctionMinBid(0L);
            ((AuctionClanHall)this.getResidence()).setAuctionDescription("");
            ((AuctionClanHall)this.getResidence()).getSiegeDate().setTimeInMillis(0L);
            ((AuctionClanHall)this.getResidence()).getLastSiegeDate().setTimeInMillis(0L);
            ((AuctionClanHall)this.getResidence()).getOwnDate().setTimeInMillis(System.currentTimeMillis());
            ((AuctionClanHall)this.getResidence()).setJdbcState(JdbcEntityState.UPDATED);
            ((AuctionClanHall)this.getResidence()).changeOwner(winnerSiegeClan.getClan());
            ((AuctionClanHall)this.getResidence()).startCycleTask();
        } else {
            if (oldOwner != null) {
                Player player = oldOwner.getLeader().getPlayer();
                if (player != null) {
                    player.sendPacket((IBroadcastPacket)SystemMsg.THE_CLAN_HALL_WHICH_HAD_BEEN_PUT_UP_FOR_AUCTION_WAS_NOT_SOLD_AND_THEREFORE_HAS_BEEN_RELISTED);
                } else {
                    PlayerMessageStack.getInstance().mailto(oldOwner.getLeaderId(), SystemMsg.THE_CLAN_HALL_WHICH_HAD_BEEN_PUT_UP_FOR_AUCTION_WAS_NOT_SOLD_AND_THEREFORE_HAS_BEEN_RELISTED);
                }
            }
            this.generateSiegeDate();
        }
        super.stopEvent(force);
    }

    @Override
    public void findEvent(Player player) {
    }

    @Override
    public AuctionSiegeClanObject newSiegeClan(String type, int clanId, long param, long date) {
        Clan clan = ClanTable.getInstance().getClan(clanId);
        return clan == null ? null : new AuctionSiegeClanObject(type, clan, param, date);
    }

    @Override
    protected long startTimeMillis() {
        return ((AuctionClanHall)this.getResidence()).getSiegeDate().getTimeInMillis() == 0L || ((AuctionClanHall)this.getResidence()).getAuctionLength() == 0 ? 0L : ((AuctionClanHall)this.getResidence()).getSiegeDate().getTimeInMillis() - (long)((AuctionClanHall)this.getResidence()).getAuctionLength() * 86400000L;
    }
}


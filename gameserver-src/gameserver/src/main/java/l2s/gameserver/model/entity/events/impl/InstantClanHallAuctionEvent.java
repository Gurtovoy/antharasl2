package l2s.gameserver.model.entity.events.impl;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Iterator;
import java.util.List;
import l2s.commons.collections.MultiValueSet;
import l2s.commons.dao.JdbcEntityState;
import l2s.commons.util.Rnd;
import l2s.gameserver.dao.SiegeClanDAO;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.events.actions.StartStopAction;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.model.entity.events.objects.SiegeClanObject;
import l2s.gameserver.model.entity.residence.Residence;
import l2s.gameserver.model.entity.residence.clanhall.InstantClanHall;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.components.SystemMsg;

public class InstantClanHallAuctionEvent
extends SiegeEvent<InstantClanHall, SiegeClanObject> {
    private Calendar _endAuctionDate = Calendar.getInstance();

    public InstantClanHallAuctionEvent(MultiValueSet<String> set) {
        super(set);
    }

    @Override
    public int getId() {
        return Residence.getInstantResidenceId(super.getId());
    }

    @Override
    public void reCalcNextTime(boolean onStart) {
        this.clearActions();
        this._onTimeActions.clear();
        this.setEndAuctionDate();
        Calendar siegeDate = ((InstantClanHall)this.getResidence()).getSiegeDate();
        if (this._endAuctionDate.getTimeInMillis() <= System.currentTimeMillis()) {
            if (onStart) {
                this.checkWinners();
            }
            siegeDate.setTimeInMillis(((InstantClanHall)this.getResidence()).getFirstLotteryDate().getTimeInMillis());
            siegeDate.set(7, 7);
            siegeDate.set(11, 0);
            siegeDate.set(12, 1);
            siegeDate.set(13, 0);
            siegeDate.set(14, 0);
            while (siegeDate.getTimeInMillis() <= System.currentTimeMillis()) {
                siegeDate.add(5, ((InstantClanHall)this.getResidence()).getRentalPeriod());
            }
            siegeDate.set(7, 7);
            while (siegeDate.getTimeInMillis() <= System.currentTimeMillis()) {
                siegeDate.add(5, 7);
            }
            ((InstantClanHall)this.getResidence()).setJdbcState(JdbcEntityState.UPDATED);
            ((InstantClanHall)this.getResidence()).update();
            this.setEndAuctionDate();
        }
        this.addOnTimeAction(0, new StartStopAction("event", true));
        this.addOnTimeAction((int)((this._endAuctionDate.getTimeInMillis() - siegeDate.getTimeInMillis()) / 1000L), new StartStopAction("event", false));
        this.registerActions();
    }

    private void setEndAuctionDate() {
        this._endAuctionDate.setTimeInMillis(this.getSiegeDate().getTimeInMillis() + (long)(((InstantClanHall)this.getResidence()).getApplyPeriod() * 60 * 60) * 1000L);
        this._endAuctionDate.set(12, 55);
        this._endAuctionDate.add(11, -1);
        this._endAuctionDate.set(13, 0);
        this._endAuctionDate.set(14, 0);
    }

    @Override
    public void startEvent() {
        for (Clan clan : ((InstantClanHall)this.getResidence()).getOwners()) {
            ((InstantClanHall)this.getResidence()).removeOwner(clan, true);
            clan.setHasHideout(0);
            clan.broadcastClanStatus(true, false, false);
        }
        super.startEvent();
    }

    @Override
    public void stopEvent(boolean force) {
        this.checkWinners();
        this.reCalcNextTime(false);
        super.stopEvent(force);
    }

    private void checkWinners() {
        List<SiegeClanObject> siegeClanObjects = this.removeObjects("attackers");
        if (!siegeClanObjects.isEmpty()) {
            Iterator itr = siegeClanObjects.iterator();
            while (itr.hasNext()) {
                SiegeClanObject siegeClan = (SiegeClanObject)itr.next();
                if (siegeClan.getClan().getHasHideout() == 0) continue;
                itr.remove();
            }
            ArrayList<SiegeClanObject> winnersSiegeClans = new ArrayList<SiegeClanObject>();
            if (siegeClanObjects.size() <= ((InstantClanHall)this.getResidence()).getMaxCount()) {
                winnersSiegeClans.addAll(siegeClanObjects);
            } else {
                while (winnersSiegeClans.size() < ((InstantClanHall)this.getResidence()).getMaxCount()) {
                    SiegeClanObject winnerSiegeClan = (SiegeClanObject)Rnd.get(siegeClanObjects);
                    winnersSiegeClans.add(winnerSiegeClan);
                    siegeClanObjects.remove(winnerSiegeClan);
                }
                for (SiegeClanObject siegeClanObject : siegeClanObjects) {
                    siegeClanObject.getClan().broadcastToOnlineMembers(SystemMsg.YOUR_BID_FOR_THE_PROVISIONAL_CLAN_HALL_LOST);
                    siegeClanObject.getClan().getWarehouse().addItem(57, ((InstantClanHall)this.getResidence()).getRentalFee() * (long)(100 - ((InstantClanHall)this.getResidence()).getCommissionPercent()) / 100L);
                }
            }
            if (!winnersSiegeClans.isEmpty()) {
                for (SiegeClanObject siegeClanObject : winnersSiegeClans) {
                    Clan clan = siegeClanObject.getClan();
                    ((InstantClanHall)this.getResidence()).addOwner(clan, true);
                    clan.setHasHideout(((InstantClanHall)this.getResidence()).getId());
                    clan.broadcastClanStatus(true, false, false);
                    clan.broadcastToOnlineMembers(SystemMsg.YOUR_BID_FOR_THE_PROVISIONAL_CLAN_HALL_WON);
                }
            }
        }
        SiegeClanDAO.getInstance().delete((Residence)this.getResidence());
    }

    @Override
    public void findEvent(Player player) {
    }

    @Override
    public Calendar getSiegeDate() {
        return ((InstantClanHall)this.getResidence()).getSiegeDate();
    }

    public Calendar getEndAuctionDate() {
        return this._endAuctionDate;
    }

    public int getParticipantsCount() {
        return this.getObjects("attackers").size();
    }
}


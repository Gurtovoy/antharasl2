/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.entity.residence.clanhall;

import l2s.gameserver.instancemanager.PlayerMessageStack;
import l2s.gameserver.model.entity.events.impl.ClanHallAuctionEvent;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.model.entity.residence.ClanHallType;
import l2s.gameserver.model.entity.residence.clanhall.NormalClanHall;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.pledge.UnitMember;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.templates.StatsSet;

public class AuctionClanHall
extends NormalClanHall {
    private static final int REWARD_CYCLE = 168;
    private int _auctionLength;
    private long _auctionMinBid;
    private String _auctionDescription = "";
    private final int _grade;
    private final int _feeItemId;
    private final long _rentalFee;
    private final long _minBid;
    private final long _deposit;

    public AuctionClanHall(StatsSet set) {
        super(set);
        this._grade = set.getInteger("grade");
        this._feeItemId = set.getInteger("fee_item_id");
        this._rentalFee = set.getInteger("rental_fee");
        this._minBid = set.getInteger("min_bid");
        this._deposit = set.getInteger("deposit");
    }

    @Override
    public void init() {
        super.init();
        if (this.getSiegeEvent() != null && this.getSiegeEvent().getClass() == ClanHallAuctionEvent.class && this._owner != null && this.getAuctionLength() == 0) {
            this.startCycleTask();
        }
    }

    @Override
    public int getGrade() {
        return this._grade;
    }

    @Override
    public void changeOwner(Clan clan) {
        super.changeOwner(clan);
        if (clan == null && this.getSiegeEvent().getClass() == ClanHallAuctionEvent.class) {
            ((SiegeEvent)((Object)this.getSiegeEvent())).reCalcNextTime(false);
        }
    }

    @Override
    public int getAuctionLength() {
        return this._auctionLength;
    }

    @Override
    public void setAuctionLength(int auctionLength) {
        this._auctionLength = auctionLength;
    }

    @Override
    public String getAuctionDescription() {
        return this._auctionDescription;
    }

    @Override
    public void setAuctionDescription(String auctionDescription) {
        this._auctionDescription = auctionDescription == null ? "" : auctionDescription;
    }

    @Override
    public long getAuctionMinBid() {
        return this._auctionMinBid;
    }

    @Override
    public void setAuctionMinBid(long auctionMinBid) {
        this._auctionMinBid = auctionMinBid;
    }

    @Override
    public int getFeeItemId() {
        return this._feeItemId;
    }

    @Override
    public long getRentalFee() {
        return this._rentalFee;
    }

    @Override
    public long getBaseMinBid() {
        return this._minBid;
    }

    @Override
    public long getDeposit() {
        return this._deposit;
    }

    @Override
    public void chanceCycle() {
        super.chanceCycle();
        if (this.getPaidCycle() >= 168) {
            if (this._owner.getWarehouse().getCountOf(57) > this._rentalFee) {
                this._owner.getWarehouse().destroyItemByItemId(57, this._rentalFee);
                this.setPaidCycle(0);
            } else {
                UnitMember member = this._owner.getLeader();
                if (member.isOnline()) {
                    member.getPlayer().sendPacket((IBroadcastPacket)SystemMsg.THE_CLAN_HALL_FEE_IS_ONE_WEEK_OVERDUE_THEREFORE_THE_CLAN_HALL_OWNERSHIP_HAS_BEEN_REVOKED);
                } else {
                    PlayerMessageStack.getInstance().mailto(member.getObjectId(), SystemMsg.THE_CLAN_HALL_FEE_IS_ONE_WEEK_OVERDUE_THEREFORE_THE_CLAN_HALL_OWNERSHIP_HAS_BEEN_REVOKED.packet(null));
                }
                this.changeOwner(null);
            }
        }
    }

    @Override
    public int getVisibleFunctionLevel(int level) {
        return level;
    }

    @Override
    public ClanHallType getClanHallType() {
        return ClanHallType.AUCTIONABLE;
    }
}


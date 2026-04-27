/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.items;

import java.util.Calendar;
import l2s.gameserver.dao.CharacterDAO;
import l2s.gameserver.model.items.ItemInfo;
import l2s.gameserver.model.items.ItemInstance;

public class CommissionItem
extends ItemInfo {
    private int _ownerId;
    private String _ownerName;
    private int _commissionId;
    private long _commissionPrice;
    private int _registerDate;
    private int _periodDays;

    public CommissionItem(int ownerId) {
        this.setOwnerId(ownerId);
        this.setOwnerName(CharacterDAO.getInstance().getNameByObjectId(ownerId));
    }

    public CommissionItem(ItemInstance item, int ownerId, String ownerName, int commissionId, long commissionPrice, int periodDays) {
        super(item);
        this.setOwnerId(ownerId);
        this.setOwnerName(ownerName);
        this.setCommissionId(commissionId);
        this.setCommissionPrice(commissionPrice);
        Calendar registerDate = Calendar.getInstance();
        registerDate.set(13, 0);
        registerDate.set(14, 0);
        this.setRegisterDate((int)(registerDate.getTimeInMillis() / 1000L));
        this.setPeriodDays(periodDays);
    }

    public String getOwnerName() {
        return this._ownerName;
    }

    public void setOwnerName(String val) {
        this._ownerName = val;
    }

    public int getCommissionId() {
        return this._commissionId;
    }

    public void setCommissionId(int val) {
        this._commissionId = val;
    }

    public long getCommissionPrice() {
        return this._commissionPrice;
    }

    public void setCommissionPrice(long val) {
        this._commissionPrice = val;
    }

    public int getEndPeriodDate() {
        return this._periodDays * 24 * 60 * 60 + this._registerDate;
    }

    public int getRegisterDate() {
        return this._registerDate;
    }

    public void setRegisterDate(int val) {
        this._registerDate = val;
    }

    public int getPeriodDays() {
        return this._periodDays;
    }

    public void setPeriodDays(int val) {
        this._periodDays = val;
    }
}


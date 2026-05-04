/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.item.support.variation;

public class VariationFee {
    private final int _stoneId;
    private final int _feeItemId;
    private final long _feeItemCount;
    private final long _cancelFee;

    public VariationFee(int stoneId, int feeItemId, long feeItemCount, long cancelFee) {
        this._stoneId = stoneId;
        this._feeItemId = feeItemId;
        this._feeItemCount = feeItemCount;
        this._cancelFee = cancelFee;
    }

    public int getStoneId() {
        return this._stoneId;
    }

    public int getFeeItemId() {
        return this._feeItemId;
    }

    public long getFeeItemCount() {
        return this._feeItemCount;
    }

    public long getCancelFee() {
        return this._cancelFee;
    }
}


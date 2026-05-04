/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity.olympiad;

public class Stadia {
    private boolean _freeToUse = true;

    public boolean isFreeToUse() {
        return this._freeToUse;
    }

    public void setStadiaBusy() {
        this._freeToUse = false;
    }

    public void setStadiaFree() {
        this._freeToUse = true;
    }
}


/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.base.Element;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExAttributeEnchantResultPacket
extends L2GameServerPacket {
    private final boolean _isWeapon;
    private final Element _element;
    private final int _oldValue;
    private final int _newValue;
    private final int _usedStones;
    private final int _failedStones;

    public ExAttributeEnchantResultPacket(boolean isWeapon, Element element, int oldValue, int newValue, int usedStones, int failedStones) {
        this._isWeapon = isWeapon;
        this._element = element;
        this._oldValue = oldValue;
        this._newValue = newValue;
        this._usedStones = usedStones;
        this._failedStones = failedStones;
    }

    @Override
    protected final void writeImpl() {
        this.writeH(0);
        this.writeH(0);
        this.writeC(this._isWeapon ? 1 : 0);
        this.writeH(this._element.getId());
        this.writeH(this._oldValue);
        this.writeH(this._newValue);
        this.writeH(this._usedStones);
        this.writeH(this._failedStones);
    }
}


/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.DoorInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public final class DoorStatusUpdatePacket
extends L2GameServerPacket {
    private final int _staticObjectId;
    private final int _objectId;
    private final int _isClosed;
    private final int _isEnemy;
    private final int _maxHp;
    private final int _currentHp;
    private final int _damageGrade;

    public DoorStatusUpdatePacket(DoorInstance door, Player player) {
        this._staticObjectId = door.getDoorId();
        this._objectId = door.getObjectId();
        this._isClosed = door.isOpen() ? 0 : 1;
        this._isEnemy = door.isAutoAttackable(player) ? 1 : 0;
        this._currentHp = (int)door.getCurrentHp();
        this._maxHp = door.getMaxHp();
        this._damageGrade = door.getDamage();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._objectId);
        this.writeD(this._isClosed);
        this.writeD(this._damageGrade);
        this.writeD(this._isEnemy);
        this.writeD(this._staticObjectId);
        this.writeD(this._currentHp);
        this.writeD(this._maxHp);
    }
}


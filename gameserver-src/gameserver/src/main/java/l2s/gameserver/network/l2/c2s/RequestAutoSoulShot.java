/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.handler.items.IItemHandler;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.SoulShotType;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.s2c.ExAutoSoulShot;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class RequestAutoSoulShot
extends L2GameClientPacket {
    private int _itemId;
    private int _action;
    private SoulShotType _type;

    @Override
    protected boolean readImpl() {
        this._itemId = this.readD();
        this._action = this.readD();
        this._type = SoulShotType.VALUES[this.readD()];
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (activeChar.getPrivateStoreType() != 0 || activeChar.isDead()) {
            return;
        }
        if (Config.EX_USE_AUTO_SOUL_SHOT) {
            this.sendPacket((L2GameServerPacket)new ExAutoSoulShot(this._itemId, this._action, this._type));
        }
        activeChar.getInventory().writeLock();
        try {
            ItemInstance item = activeChar.getInventory().getItemByItemId(this._itemId);
            if (item == null) {
                return;
            }
            IItemHandler handler = item.getTemplate().getHandler();
            if (handler == null || !handler.isAutoUse()) {
                return;
            }
            if (this._action == 1 || this._action == 3) {
                if (!activeChar.isAutoShot(this._itemId) && activeChar.manuallyAddAutoShot(this._itemId, this._type, this._action == 3)) {
                    item.getTemplate().useItem(activeChar, item, false, false);
                }
            } else if (activeChar.isAutoShot(this._itemId)) {
                activeChar.manuallyRemoveAutoShot(this._itemId, this._type, this._action == 2);
            }
        }
        finally {
            activeChar.getInventory().writeUnlock();
        }
    }
}


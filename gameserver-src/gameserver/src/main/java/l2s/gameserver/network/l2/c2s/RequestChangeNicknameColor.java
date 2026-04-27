/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.handler.items.impl.NameColorItemHandler;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestChangeNicknameColor
extends L2GameClientPacket {
    private static final int[] COLORS = new int[]{0x9393FF, 8145404, 9959676, 16423662, 16735635, 64672, 10528257, 7903407, 4743829, 0x999999};
    private int _colorNum;
    private int _itemObjectId;
    private String _title;

    @Override
    protected boolean readImpl() {
        this._colorNum = this.readD();
        this._title = this.readS();
        this._itemObjectId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (this._colorNum < 0 || this._colorNum >= COLORS.length) {
            return;
        }
        ItemInstance item = activeChar.getInventory().getItemByObjectId(this._itemObjectId);
        if (item == null) {
            return;
        }
        if (!(item.getTemplate().getHandler() instanceof NameColorItemHandler)) {
            return;
        }
        if (activeChar.consumeItem(item.getItemId(), 1L, true)) {
            activeChar.setTitleColor(COLORS[this._colorNum]);
            activeChar.setTitle(this._title);
            activeChar.broadcastUserInfo(true);
        }
    }
}


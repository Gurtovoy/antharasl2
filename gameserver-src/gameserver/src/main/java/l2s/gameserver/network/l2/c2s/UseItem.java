package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.utils.HtmlUtils;

public class UseItem
extends L2GameClientPacket {
    private int _objectId;
    private boolean _ctrlPressed;

    @Override
    protected boolean readImpl() {
        this._objectId = this.readD();
        this._ctrlPressed = this.readD() == 1;
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        activeChar.setActive();
        ItemInstance item = activeChar.getInventory().getItemByObjectId(this._objectId);
        if (item == null) {
            activeChar.sendActionFailed();
            return;
        }
        if (this._ctrlPressed && (item.isWeapon() || item.isArmor() || item.isAccessory())) {
            boolean hasRestrictions = false;
            StringBuilder sb = new StringBuilder();
            sb.append("<font color=LEVEL>\u041e\u0433\u0440\u0430\u043d\u0438\u0447\u0435\u043d\u0438\u044f:</font>").append("<br1>");
            if ((item.getCustomFlags() & 1) == 1) {
                sb.append("\u041d\u0435\u043b\u044c\u0437\u044f \u0432\u044b\u0431\u0440\u043e\u0441\u0438\u0442\u044c").append("<br1>");
                hasRestrictions = true;
            }
            if ((item.getCustomFlags() & 2) == 2) {
                sb.append("\u041d\u0435\u043b\u044c\u0437\u044f \u043f\u0440\u043e\u0434\u0430\u0442\u044c/\u043e\u0431\u043c\u0435\u043d\u044f\u0442\u044c").append("<br1>");
                hasRestrictions = true;
            }
            if ((item.getCustomFlags() & 4) == 4) {
                sb.append("\u041d\u0435\u043b\u044c\u0437\u044f \u043f\u043e\u043b\u043e\u0436\u0438\u0442\u044c \u043d\u0430 \u0441\u043a\u043b\u0430\u0434").append("<br1>");
                hasRestrictions = true;
            }
            if ((item.getCustomFlags() & 8) == 8) {
                sb.append("\u041d\u0435\u043b\u044c\u0437\u044f \u043a\u0440\u0438\u0441\u0442\u0430\u043b\u0438\u0437\u043e\u0432\u0430\u0442\u044c").append("<br1>");
                hasRestrictions = true;
            }
            if ((item.getCustomFlags() & 0x40) == 64) {
                sb.append("\u041d\u0435\u043b\u044c\u0437\u044f \u043e\u0431\u0440\u0430\u0431\u043e\u0442\u0430\u0442\u044c").append("<br1>");
                hasRestrictions = true;
            }
            if (hasRestrictions) {
                HtmlUtils.sendHtm(activeChar, sb.toString());
                return;
            }
        }
        activeChar.useItem(item, this._ctrlPressed, true);
    }
}


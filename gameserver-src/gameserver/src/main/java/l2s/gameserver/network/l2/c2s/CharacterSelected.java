/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.ban.BanBindType
 *  org.apache.commons.lang3.StringUtils
 */
package l2s.gameserver.network.l2.c2s;

import l2s.commons.ban.BanBindType;
import l2s.gameserver.instancemanager.GameBanManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.s2c.ActionFailPacket;
import l2s.gameserver.network.l2.s2c.CharacterSelectedPacket;
import l2s.gameserver.network.l2.s2c.ExNeedToChangeName;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.utils.AutoBan;
import org.apache.commons.lang3.StringUtils;

public class CharacterSelected
extends L2GameClientPacket {
    private int _charSlot;

    @Override
    protected boolean readImpl() {
        this._charSlot = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        GameClient client = (GameClient)this.getClient();
        if (client.getActiveChar() != null) {
            return;
        }
        if (!client.secondaryAuthed()) {
            this.sendPacket(ActionFailPacket.STATIC);
            return;
        }
        int objId = client.getObjectIdForSlot(this._charSlot);
        if (GameBanManager.getInstance().isBanned(BanBindType.PLAYER, objId) || AutoBan.isBanned(objId)) {
            this.sendPacket(ActionFailPacket.STATIC);
            return;
        }
        Player activeChar = client.loadCharFromDisk(this._charSlot);
        if (activeChar == null) {
            this.sendPacket(ActionFailPacket.STATIC);
            return;
        }
        if (activeChar.getAccessLevel() < 0) {
            activeChar.setAccessLevel(0);
        }
        client.setState(GameClient.GameClientState.IN_GAME);
        activeChar.setOnlineStatus(true);
        activeChar.storeLastIpAndHWID(client.getIpAddr(), client.getHWID());
        String changedOldName = activeChar.getVar("changed_old_name");
        if (changedOldName != null && !StringUtils.isEmpty((CharSequence)changedOldName)) {
            this.sendPacket((L2GameServerPacket)new ExNeedToChangeName(0, 0, changedOldName));
            return;
        }
        this.sendPacket((L2GameServerPacket)new CharacterSelectedPacket(activeChar, client.getSessionKey().playOkID1));
    }
}


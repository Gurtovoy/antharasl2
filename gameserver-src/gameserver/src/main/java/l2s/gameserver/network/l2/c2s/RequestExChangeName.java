/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.apache.commons.lang3.StringUtils
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.dao.CharacterDAO;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.pledge.SubUnit;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.s2c.CharacterSelectedPacket;
import l2s.gameserver.network.l2.s2c.ExNeedToChangeName;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.tables.ClanTable;
import l2s.gameserver.utils.Util;
import org.apache.commons.lang3.StringUtils;

public class RequestExChangeName
extends L2GameClientPacket {
    private int _type;
    private String _newName;
    private int _charSlot;

    @Override
    protected boolean readImpl() {
        this._type = this.readD();
        this._newName = this.readS();
        this._charSlot = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (this._type == 0) {
            String changedOldName = activeChar.getVar("changed_old_name");
            if (changedOldName == null || StringUtils.isEmpty((CharSequence)changedOldName)) {
                activeChar.unsetVar("changed_old_name");
                this.sendPacket((L2GameServerPacket)new CharacterSelectedPacket(activeChar, ((GameClient)this.getClient()).getSessionKey().playOkID1));
                return;
            }
            if (this._newName == null || this._newName.isEmpty()) {
                this.sendPacket((L2GameServerPacket)new ExNeedToChangeName(0, 1, changedOldName));
                return;
            }
            if (!Util.isMatchingRegexp(this._newName, Config.CNAME_TEMPLATE)) {
                this.sendPacket((L2GameServerPacket)new ExNeedToChangeName(0, 1, changedOldName));
                return;
            }
            if (!activeChar.getName().equalsIgnoreCase(this._newName) && CharacterDAO.getInstance().getObjectIdByName(this._newName) > 0) {
                this.sendPacket((L2GameServerPacket)new ExNeedToChangeName(0, 1, changedOldName));
                return;
            }
            activeChar.setName(this._newName);
            activeChar.saveNameToDB();
            activeChar.unsetVar("changed_old_name");
            this.sendPacket((L2GameServerPacket)new CharacterSelectedPacket(activeChar, ((GameClient)this.getClient()).getSessionKey().playOkID1));
        } else if (this._type == 1) {
            String changedOldName = activeChar.getVar("changed_old_pledge_name");
            if (changedOldName == null || StringUtils.isEmpty((CharSequence)changedOldName)) {
                activeChar.unsetVar("changed_old_pledge_name");
                return;
            }
            Clan clan = activeChar.getClan();
            if (clan == null) {
                activeChar.unsetVar("changed_old_pledge_name");
                return;
            }
            SubUnit subUnit = null;
            for (SubUnit s : clan.getAllSubUnits()) {
                if (s.getLeaderObjectId() != activeChar.getObjectId()) continue;
                subUnit = s;
                break;
            }
            if (subUnit == null) {
                activeChar.unsetVar("changed_old_pledge_name");
                return;
            }
            if (!Util.isMatchingRegexp(this._newName, Config.CLAN_NAME_TEMPLATE)) {
                this.sendPacket((L2GameServerPacket)new ExNeedToChangeName(1, 1, changedOldName));
                return;
            }
            for (SubUnit s : clan.getAllSubUnits()) {
                if (!s.getName().equalsIgnoreCase(this._newName)) continue;
                this.sendPacket((L2GameServerPacket)new ExNeedToChangeName(1, 1, changedOldName));
                return;
            }
            if (!subUnit.getName().equalsIgnoreCase(this._newName) && ClanTable.getInstance().getClanByName(this._newName) != null) {
                this.sendPacket((L2GameServerPacket)new ExNeedToChangeName(1, 1, changedOldName));
                return;
            }
            subUnit.setName(this._newName, true);
            clan.broadcastClanStatus(true, true, false);
            activeChar.unsetVar("changed_old_pledge_name");
        }
    }
}


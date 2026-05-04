/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.database.mysql;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.s2c.CharacterDeleteFailPacket;
import l2s.gameserver.network.l2.s2c.CharacterDeleteSuccessPacket;
import l2s.gameserver.network.l2.s2c.CharacterSelectionInfoPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CharacterDelete
extends L2GameClientPacket {
    private static final Logger _log = LoggerFactory.getLogger(CharacterDelete.class);
    private int _charSlot;

    @Override
    protected boolean readImpl() {
        this._charSlot = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        int clan = this.clanStatus();
        int online = this.onlineStatus();
        GameClient client = (GameClient)this.getClient();
        if (clan > 0 || online > 0) {
            if (clan == 2) {
                this.sendPacket((L2GameServerPacket)new CharacterDeleteFailPacket(CharacterDeleteFailPacket.REASON_CLAN_LEADERS_MAY_NOT_BE_DELETED));
            } else if (clan == 1) {
                this.sendPacket((L2GameServerPacket)new CharacterDeleteFailPacket(CharacterDeleteFailPacket.REASON_YOU_MAY_NOT_DELETE_CLAN_MEMBER));
            } else if (online > 0) {
                this.sendPacket((L2GameServerPacket)new CharacterDeleteFailPacket(CharacterDeleteFailPacket.REASON_DELETION_FAILED));
            }
            CharacterSelectionInfoPacket cl = new CharacterSelectionInfoPacket(client);
            this.sendPacket((L2GameServerPacket)cl);
            client.setCharSelection(cl.getCharInfo());
            return;
        }
        try {
            if (Config.CHARACTER_DELETE_AFTER_HOURS == 0) {
                client.deleteChar(this._charSlot);
            } else {
                client.markToDeleteChar(this._charSlot);
            }
        }
        catch (Exception e) {
            _log.error("Error:", (Throwable)e);
        }
        this.sendPacket((L2GameServerPacket)new CharacterDeleteSuccessPacket());
        CharacterSelectionInfoPacket cl = new CharacterSelectionInfoPacket(client);
        this.sendPacket((L2GameServerPacket)cl);
        client.setCharSelection(cl.getCharInfo());
    }

    private int clanStatus() {
        int obj = ((GameClient)this.getClient()).getObjectIdForSlot(this._charSlot);
        if (obj == -1) {
            return 0;
        }
        if (mysql.simple_get_int("clanid", "characters", "obj_Id=" + obj) > 0) {
            if (mysql.simple_get_int("leader_id", "clan_subpledges", "leader_id=" + obj + " AND type = " + 0) > 0) {
                return 2;
            }
            return 1;
        }
        return 0;
    }

    private int onlineStatus() {
        int obj = ((GameClient)this.getClient()).getObjectIdForSlot(this._charSlot);
        if (obj == -1) {
            return 0;
        }
        if (mysql.simple_get_int("online", "characters", "obj_Id=" + obj) > 0) {
            return 1;
        }
        return 0;
    }
}


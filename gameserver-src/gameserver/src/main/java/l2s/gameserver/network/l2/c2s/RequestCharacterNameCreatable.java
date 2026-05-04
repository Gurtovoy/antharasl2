package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.dao.CharacterDAO;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.s2c.ExIsCharNameCreatable;
import l2s.gameserver.utils.Util;

public class RequestCharacterNameCreatable
extends L2GameClientPacket {
    private String _charname;

    @Override
    protected boolean readImpl() {
        this._charname = this.readS();
        return true;
    }

    @Override
    protected void runImpl() {
        if (Config.MAX_CHARACTERS_NUMBER_PER_ACCOUNT != 0 && CharacterDAO.getInstance().accountCharNumber(((GameClient)this.getClient()).getLogin()) >= Config.MAX_CHARACTERS_NUMBER_PER_ACCOUNT) {
            this.sendPacket(ExIsCharNameCreatable.TOO_MANY_CHARACTERS);
            return;
        }
        if (this._charname == null || this._charname.isEmpty()) {
            this.sendPacket(ExIsCharNameCreatable.ENTER_CHAR_NAME__MAX_16_CHARS);
            return;
        }
        if (!Util.isMatchingRegexp(this._charname, Config.CNAME_TEMPLATE)) {
            this.sendPacket(ExIsCharNameCreatable.WRONG_NAME);
            return;
        }
        if (CharacterDAO.getInstance().getObjectIdByName(this._charname) > 0) {
            this.sendPacket(ExIsCharNameCreatable.NAME_ALREADY_EXISTS);
            return;
        }
        this.sendPacket(ExIsCharNameCreatable.SUCCESS);
    }
}


/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.Macro;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;

public class RequestMakeMacro
extends L2GameClientPacket {
    private Macro _macro;

    @Override
    protected boolean readImpl() {
        int _id = this.readD();
        String _name = this.readS(32);
        String _desc = this.readS(64);
        String _acronym = this.readS(4);
        int _icon = this.readD();
        int _count = this.readC();
        if (_count > 12) {
            _count = 12;
        }
        Macro.L2MacroCmd[] commands = new Macro.L2MacroCmd[_count];
        for (int i = 0; i < _count; ++i) {
            int entry = this.readC();
            int type = this.readC();
            int d1 = this.readD();
            int d2 = this.readC();
            String command = this.readS().replace(";", "").replace(",", "");
            commands[i] = new Macro.L2MacroCmd(entry, type, d1, d2, command);
        }
        this._macro = new Macro(_id, _icon, _name, _desc, _acronym, commands);
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (activeChar.getMacroses().getAllMacroses().length > 48) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_MAY_CREATE_UP_TO_48_MACROS);
            return;
        }
        if (this._macro.getName().length() == 0) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.ENTER_THE_NAME_OF_THE_MACRO);
            return;
        }
        if (this._macro.getDescr().length() > 32) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.MACRO_DESCRIPTIONS_MAY_CONTAIN_UP_TO_32_CHARACTERS);
            return;
        }
        activeChar.registerMacro(this._macro);
    }
}


/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.s2c.ActionFailPacket;
import l2s.gameserver.network.l2.s2c.Ex2NDPasswordCheckPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.security.SecondaryPasswordAuth;

public class RequestEx2ndPasswordCheck
extends L2GameClientPacket {
    @Override
    protected boolean readImpl() {
        return true;
    }

    @Override
    protected void runImpl() {
        SecondaryPasswordAuth spa = ((GameClient)this.getClient()).getSecondaryAuth();
        if (Config.EX_SECOND_AUTH_ENABLED && spa == null) {
            this.sendPacket(ActionFailPacket.STATIC);
            return;
        }
        if (!Config.EX_SECOND_AUTH_ENABLED || spa.isAuthed()) {
            this.sendPacket((L2GameServerPacket)new Ex2NDPasswordCheckPacket(2));
            return;
        }
        spa.openDialog();
    }
}


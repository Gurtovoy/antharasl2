/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.s2c.Ex2NDPasswordAckPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.security.SecondaryPasswordAuth;

public class RequestEx2ndPasswordReq
extends L2GameClientPacket {
    private int _changePass;
    private String _password;
    private String _newPassword;

    @Override
    protected boolean readImpl() {
        this._changePass = this.readC();
        this._password = this.readS();
        if (this._changePass == 2) {
            this._newPassword = this.readS();
        }
        return true;
    }

    @Override
    protected void runImpl() {
        if (!Config.EX_SECOND_AUTH_ENABLED) {
            return;
        }
        SecondaryPasswordAuth spa = ((GameClient)this.getClient()).getSecondaryAuth();
        boolean exVal = false;
        if (this._changePass == 0 && !spa.passwordExist()) {
            exVal = spa.savePassword(this._password);
        } else if (this._changePass == 2 && spa.passwordExist()) {
            exVal = spa.changePassword(this._password, this._newPassword);
        }
        if (exVal) {
            ((GameClient)this.getClient()).sendPacket((L2GameServerPacket)new Ex2NDPasswordAckPacket(0));
        }
    }
}


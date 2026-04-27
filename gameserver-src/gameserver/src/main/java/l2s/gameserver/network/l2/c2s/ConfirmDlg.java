/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.napile.primitive.pair.IntObjectPair
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.listener.actor.player.OnAnswerListener;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import org.napile.primitive.pair.IntObjectPair;

public class ConfirmDlg
extends L2GameClientPacket {
    private int _answer;
    private int _requestId;

    @Override
    protected boolean readImpl() {
        this.readD();
        this._answer = this.readD();
        this._requestId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        IntObjectPair<OnAnswerListener> entry = activeChar.getAskListener(true);
        if (entry == null || entry.getKey() != this._requestId) {
            return;
        }
        OnAnswerListener listener = (OnAnswerListener)entry.getValue();
        if (this._answer == 1) {
            listener.sayYes();
        } else {
            listener.sayNo();
        }
    }
}


/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestExEndScenePlayer
extends L2GameClientPacket {
    private int _movieId;

    @Override
    protected boolean readImpl() {
        this._movieId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (!activeChar.isInMovie() || activeChar.getMovieId() != this._movieId) {
            activeChar.sendActionFailed();
            return;
        }
        activeChar.endScenePlayer(false);
    }
}


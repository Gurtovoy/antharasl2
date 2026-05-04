/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.instancemanager.games.MiniGameScoreManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestBR_MiniGameInsertScore
extends L2GameClientPacket {
    private int _score;

    @Override
    protected boolean readImpl() throws Exception {
        this._score = this.readD();
        return true;
    }

    @Override
    protected void runImpl() throws Exception {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null || !Config.EX_JAPAN_MINIGAME) {
            return;
        }
        MiniGameScoreManager.getInstance().insertScore(player, this._score);
    }
}


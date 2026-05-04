/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestExBR_LectureMark
extends L2GameClientPacket {
    public static final int INITIAL_MARK = 1;
    public static final int EVANGELIST_MARK = 2;
    public static final int OFF_MARK = 3;
    private int _mark;

    @Override
    protected boolean readImpl() throws Exception {
        this._mark = this.readC();
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null || !Config.EX_LECTURE_MARK) {
            return;
        }
        switch (this._mark) {
            case 1: 
            case 2: 
            case 3: {
                player.setLectureMark(this._mark);
                player.broadcastUserInfo(true);
            }
        }
    }
}


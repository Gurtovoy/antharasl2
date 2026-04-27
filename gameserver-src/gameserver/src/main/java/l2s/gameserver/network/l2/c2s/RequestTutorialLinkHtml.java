/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.quest.QuestState;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestTutorialLinkHtml
extends L2GameClientPacket {
    private int _unk;
    private String _bypass;

    @Override
    protected boolean readImpl() {
        this._unk = this.readD();
        this._bypass = this.readS();
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        for (QuestState qs : player.getAllQuestsStates()) {
            qs.getQuest().notifyTutorialEvent("LINK", false, this._bypass, qs);
        }
    }
}


/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.utils.MulticlassUtils;

public final class RequestSkillList
extends L2GameClientPacket {
    @Override
    protected boolean readImpl() {
        return true;
    }

    @Override
    protected void runImpl() {
        Player cha = ((GameClient)this.getClient()).getActiveChar();
        if (cha != null) {
            cha.sendSkillList();
            if (Config.MULTICLASS_SYSTEM_SHOW_LEARN_LIST_ON_OPEN_SKILL_LIST) {
                MulticlassUtils.showMulticlassList(cha);
            }
        }
    }
}


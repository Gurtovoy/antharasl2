/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.petition.PetitionMainGroup;
import l2s.gameserver.model.petition.PetitionSubGroup;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExResponseShowContents;

public class RequestExShowStepThree
extends L2GameClientPacket {
    private int _subId;

    @Override
    protected boolean readImpl() {
        this._subId = this.readC();
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null || !Config.EX_NEW_PETITION_SYSTEM) {
            return;
        }
        PetitionMainGroup group = player.getPetitionGroup();
        if (group == null) {
            return;
        }
        PetitionSubGroup subGroup = group.getSubGroup(this._subId);
        if (subGroup == null) {
            return;
        }
        player.sendPacket((IBroadcastPacket)new ExResponseShowContents(subGroup.getDescription(player.getLanguage())));
    }
}


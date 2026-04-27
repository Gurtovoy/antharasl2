/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.instancemanager.PetitionManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.petition.PetitionMainGroup;
import l2s.gameserver.model.petition.PetitionSubGroup;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public final class RequestPetition
extends L2GameClientPacket {
    private String _content;
    private int _type;

    @Override
    protected boolean readImpl() {
        this._content = this.readS();
        this._type = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        if (Config.EX_NEW_PETITION_SYSTEM) {
            PetitionMainGroup group = player.getPetitionGroup();
            if (group == null) {
                return;
            }
            PetitionSubGroup subGroup = group.getSubGroup(this._type);
            if (subGroup == null) {
                return;
            }
            subGroup.getHandler().handle(player, this._type, this._content);
        } else {
            PetitionManager.getInstance().handle(player, this._type, this._content);
        }
    }
}


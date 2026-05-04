/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.PetInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;

public class RequestChangePetName
extends L2GameClientPacket {
    private String _name;

    @Override
    protected boolean readImpl() {
        this._name = this.readS();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        PetInstance pet = activeChar.getPet();
        if (pet == null) {
            return;
        }
        if (pet.isDefaultName()) {
            if (this._name.length() < 1 || this._name.length() > 8) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOUR_PETS_NAME_CAN_BE_UP_TO_8_CHARACTERS_IN_LENGTH);
                return;
            }
            pet.setName(this._name);
            pet.broadcastCharInfo();
            pet.updateControlItem();
        }
    }
}


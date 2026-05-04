/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.PetInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestPetUseItem
extends L2GameClientPacket {
    private int _objectId;

    @Override
    protected boolean readImpl() {
        this._objectId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (activeChar.isActionsDisabled()) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isFishing()) {
            return;
        }
        if (activeChar.isInTrainingCamp()) {
            return;
        }
        PetInstance pet = activeChar.getPet();
        if (pet == null) {
            return;
        }
        ItemInstance item = pet.getInventory().getItemByObjectId(this._objectId);
        if (item == null) {
            return;
        }
        pet.useItem(item, false, true);
    }
}


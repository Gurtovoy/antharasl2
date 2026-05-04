/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.items.attachment;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.attachment.ItemAttachment;

public interface PickableAttachment
extends ItemAttachment {
    public boolean canPickUp(Player var1);

    public void pickUp(Player var1);
}


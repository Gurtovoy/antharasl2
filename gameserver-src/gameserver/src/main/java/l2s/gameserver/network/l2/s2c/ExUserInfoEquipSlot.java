/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.PcInventory;
import l2s.gameserver.network.l2.s2c.AbstractMaskPacket;
import l2s.gameserver.network.l2.s2c.updatetype.InventorySlot;

public class ExUserInfoEquipSlot
extends AbstractMaskPacket<InventorySlot> {
    private final Player _player;
    private final byte[] _masks = new byte[]{0, 0, 0, 0, 0};

    @Override
    protected byte[] getMasks() {
        return this._masks;
    }

    @Override
    protected void onNewMaskAdded(InventorySlot component) {
    }

    public ExUserInfoEquipSlot(Player player) {
        this._player = player;
        this.addComponentType(InventorySlot.VALUES);
    }

    public ExUserInfoEquipSlot(Player player, int slot) {
        this._player = player;
        this.addComponentType(new InventorySlot[]{InventorySlot.valueOf(slot)});
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._player.getObjectId());
        this.writeH(InventorySlot.VALUES.length);
        this.writeB(this._masks);
        PcInventory inventory = this._player.getInventory();
        for (InventorySlot slot : InventorySlot.VALUES) {
            if (!this.containsMask(slot)) continue;
            this.writeH(22);
            this.writeD(inventory.getPaperdollObjectId(slot.getSlot()));
            this.writeD(inventory.getPaperdollItemId(slot.getSlot()));
            this.writeD(inventory.getPaperdollVariation1Id(slot.getSlot()));
            this.writeD(inventory.getPaperdollVariation2Id(slot.getSlot()));
            this.writeD(inventory.getPaperdollVisualId(slot.getSlot()));
        }
    }
}


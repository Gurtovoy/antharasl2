package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class EnchantResultPacket
extends L2GameServerPacket {
    private final int _resultId;
    private final int _crystalId;
    private final long _count;
    private final int _enchantLevel;
    public static final EnchantResultPacket CANCEL = new EnchantResultPacket(2, 0, 0L, 0);
    public static final EnchantResultPacket BLESSED_FAILED = new EnchantResultPacket(3, 0, 0L, 0);
    public static final EnchantResultPacket FAILED_NO_CRYSTALS = new EnchantResultPacket(4, 0, 0L, 0);
    public static final EnchantResultPacket ANCIENT_FAILED = new EnchantResultPacket(5, 0, 0L, 0);

    public EnchantResultPacket(int resultId, int crystalId, long count, int enchantLevel) {
        this._resultId = resultId;
        this._crystalId = crystalId;
        this._count = count;
        this._enchantLevel = enchantLevel;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._resultId);
        this.writeD(this._crystalId);
        this.writeQ(this._count);
        this.writeD(this._enchantLevel);
        this.writeH(0);
        this.writeH(0);
        this.writeH(0);
    }
}


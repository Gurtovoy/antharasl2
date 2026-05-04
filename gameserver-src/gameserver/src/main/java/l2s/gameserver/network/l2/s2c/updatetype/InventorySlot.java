package l2s.gameserver.network.l2.s2c.updatetype;

import l2s.gameserver.network.l2.s2c.updatetype.IUpdateTypeComponent;

public enum InventorySlot implements IUpdateTypeComponent
{
    PENDANT(0),
    REAR(1),
    LEAR(2),
    NECK(3),
    RFINGER(4),
    LFINGER(5),
    HEAD(6),
    RHAND(7),
    LHAND(8),
    GLOVES(9),
    CHEST(10),
    LEGS(11),
    FEET(12),
    CLOAK(13),
    LRHAND(14),
    HAIR(15),
    HAIR2(16),
    RBRACELET(17),
    LBRACELET(18),
    AGATHION_MAIN(19),
    AGATHION_1(20),
    AGATHION_2(21),
    AGATHION_3(22),
    AGATHION_4(23),
    DECO1(24),
    DECO2(25),
    DECO3(26),
    DECO4(27),
    DECO5(28),
    DECO6(29),
    BELT(30),
    BROOCH(31),
    BROOCH_JEWEL(32),
    BROOCH_JEWEL2(33),
    BROOCH_JEWEL3(34),
    BROOCH_JEWEL4(35),
    BROOCH_JEWEL5(36),
    BROOCH_JEWEL6(37);

    public static final InventorySlot[] VALUES;
    private final int _paperdollSlot;

    public static InventorySlot valueOf(int slot) {
        for (InventorySlot s : VALUES) {
            if (s.getSlot() != slot) continue;
            return s;
        }
        return null;
    }

    private InventorySlot(int paperdollSlot) {
        this._paperdollSlot = paperdollSlot;
    }

    public int getSlot() {
        return this._paperdollSlot;
    }

    @Override
    public int getMask() {
        return this.ordinal();
    }

    static {
        VALUES = InventorySlot.values();
    }
}


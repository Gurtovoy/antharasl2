package l2s.gameserver.templates.item;

public enum Bodypart {
    NONE(0L),
    CHEST(1024L),
    BELT(0x10000000L),
    RIGHT_BRACELET(0x100000L),
    LEFT_BRACELET(0x200000L),
    FULL_ARMOR(32768L),
    HEAD(64L),
    HAIR(65536L),
    FACE(262144L),
    HAIR_ALL(524288L),
    PENDANT(1L),
    BACK(8192L),
    NECKLACE(8L),
    LEGS(2048L),
    FEET(4096L),
    GLOVES(512L),
    RIGHT_HAND(128L),
    LEFT_HAND(256L),
    LEFT_RIGHT_HAND(16384L),
    RIGHT_EAR(2L),
    LEFT_EAR(4L),
    RIGHT_FINGER(16L),
    FORMAL_WEAR(131072L),
    TALISMAN(0x400000L),
    LEFT_FINGER(32L),
    BROOCH(0x20000000L),
    JEWEL(0x40000000L),
    AGATHION(0x3000000000L);

    private long _mask;
    private Bodypart _real;

    private Bodypart(long mask) {
        this(mask, null);
    }

    private Bodypart(long mask, Bodypart real) {
        this._mask = mask;
        this._real = real;
    }

    public long mask() {
        return this._mask;
    }

    public Bodypart getReal() {
        return this._real;
    }
}


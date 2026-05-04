package l2s.gameserver.model.actor.instances.player;

public class ShortCut {
    public static final int PAGE_NORMAL_0 = 0;
    public static final int PAGE_NORMAL_1 = 1;
    public static final int PAGE_NORMAL_2 = 2;
    public static final int PAGE_NORMAL_3 = 3;
    public static final int PAGE_NORMAL_4 = 4;
    public static final int PAGE_NORMAL_5 = 5;
    public static final int PAGE_NORMAL_6 = 6;
    public static final int PAGE_NORMAL_7 = 7;
    public static final int PAGE_NORMAL_8 = 8;
    public static final int PAGE_NORMAL_9 = 9;
    public static final int PAGE_NORMAL_10 = 10;
    public static final int PAGE_NORMAL_11 = 11;
    public static final int PAGE_NORMAL_12 = 12;
    public static final int PAGE_NORMAL_13 = 13;
    public static final int PAGE_NORMAL_14 = 14;
    public static final int PAGE_NORMAL_15 = 15;
    public static final int PAGE_NORMAL_16 = 16;
    public static final int PAGE_NORMAL_17 = 17;
    public static final int PAGE_NORMAL_18 = 18;
    public static final int PAGE_NORMAL_19 = 19;
    public static final int PAGE_FLY_TRANSFORM = 20;
    public static final int PAGE_AIRSHIP = 21;
    public static final int PAGE_MAX = 21;
    private final int _slot;
    private final int _page;
    private final ShortCutType _type;
    private final int _id;
    private final int _level;
    private final int _characterType;

    public ShortCut(int slot, int page, ShortCutType type, int id, int level, int characterType) {
        this._slot = slot;
        this._page = page;
        this._type = type;
        this._id = id;
        this._level = level;
        this._characterType = characterType;
    }

    public int getSlot() {
        return this._slot;
    }

    public int getPage() {
        return this._page;
    }

    public ShortCutType getType() {
        return this._type;
    }

    public int getId() {
        return this._id;
    }

    public int getLevel() {
        return this._type != ShortCutType.SKILL ? 0 : this._level;
    }

    public int getCharacterType() {
        return this._characterType;
    }

    public String toString() {
        return "ShortCut: " + this._slot + "/" + this._page + " ( " + (Object)((Object)this._type) + "," + this._id + "," + this._level + "," + this._characterType + ")";
    }

    public static enum ShortCutType {
        NONE,
        ITEM,
        SKILL,
        ACTION,
        MACRO,
        RECIPE,
        TPBOOKMARK;

        public static final ShortCutType[] VALUES;

        static {
            VALUES = ShortCutType.values();
        }
    }
}


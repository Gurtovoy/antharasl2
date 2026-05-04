package l2s.gameserver.skills;

public enum SkillCastingType {
    SIMULTANEOUS(-1),
    NORMAL(0),
    NORMAL_SECOND(1),
    BLUE(2),
    GREEN(3),
    RED(4);

    public static SkillCastingType[] VALUES;
    private final int _clientBarId;

    private SkillCastingType(int clientBarId) {
        this._clientBarId = clientBarId;
    }

    public int getClientBarId() {
        return this._clientBarId;
    }

    static {
        VALUES = SkillCastingType.values();
    }
}


/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.base;

import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.ClassDataHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.ClassLevel;
import l2s.gameserver.model.base.ClassType;
import l2s.gameserver.model.base.ClassType2;
import l2s.gameserver.model.base.Race;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.templates.player.ClassData;

public enum ClassId {
    HUMAN_FIGHTER(ClassType.FIGHTER, Race.HUMAN, null, ClassLevel.NONE, null, new int[0]),
    WARRIOR(ClassType.FIGHTER, Race.HUMAN, HUMAN_FIGHTER, ClassLevel.FIRST, null, 1145),
    GLADIATOR(ClassType.FIGHTER, Race.HUMAN, WARRIOR, ClassLevel.SECOND, ClassType2.WARRIOR, 2627, 2734, 2762),
    WARLORD(ClassType.FIGHTER, Race.HUMAN, WARRIOR, ClassLevel.SECOND, ClassType2.WARRIOR, 2627, 2734, 3276),
    KNIGHT(ClassType.FIGHTER, Race.HUMAN, HUMAN_FIGHTER, ClassLevel.FIRST, null, 1161),
    PALADIN(ClassType.FIGHTER, Race.HUMAN, KNIGHT, ClassLevel.SECOND, ClassType2.KNIGHT, 2633, 2734, 2820),
    DARK_AVENGER(ClassType.FIGHTER, Race.HUMAN, KNIGHT, ClassLevel.SECOND, ClassType2.KNIGHT, 2633, 2734, 3307),
    ROGUE(ClassType.FIGHTER, Race.HUMAN, HUMAN_FIGHTER, ClassLevel.FIRST, null, 1190),
    TREASURE_HUNTER(ClassType.FIGHTER, Race.HUMAN, ROGUE, ClassLevel.SECOND, ClassType2.ROGUE, 2673, 2734, 2809),
    HAWKEYE(ClassType.FIGHTER, Race.HUMAN, ROGUE, ClassLevel.SECOND, ClassType2.ARCHER, 2673, 2734, 3293),
    HUMAN_MAGE(ClassType.MYSTIC, Race.HUMAN, null, ClassLevel.NONE, null, new int[0]),
    WIZARD(ClassType.MYSTIC, Race.HUMAN, HUMAN_MAGE, ClassLevel.FIRST, null, 1292),
    SORCERER(ClassType.MYSTIC, Race.HUMAN, WIZARD, ClassLevel.SECOND, ClassType2.WIZARD, 2674, 2734, 2840),
    NECROMANCER(ClassType.MYSTIC, Race.HUMAN, WIZARD, ClassLevel.SECOND, ClassType2.WIZARD, 2674, 2734, 3307),
    WARLOCK(ClassType.MYSTIC, Race.HUMAN, WIZARD, ClassLevel.SECOND, ClassType2.SUMMONER, 2674, 2734, 3336),
    CLERIC(ClassType.MYSTIC, Race.HUMAN, HUMAN_MAGE, ClassLevel.FIRST, null, 1201),
    BISHOP(ClassType.MYSTIC, Race.HUMAN, CLERIC, ClassLevel.SECOND, ClassType2.HEALER, 2721, 2734, 2820),
    PROPHET(ClassType.MYSTIC, Race.HUMAN, CLERIC, ClassLevel.SECOND, ClassType2.ENCHANTER, 2721, 2734, 2821),
    ELVEN_FIGHTER(ClassType.FIGHTER, Race.ELF, null, ClassLevel.NONE, null, new int[0]),
    ELVEN_KNIGHT(ClassType.FIGHTER, Race.ELF, ELVEN_FIGHTER, ClassLevel.FIRST, null, 1204),
    TEMPLE_KNIGHT(ClassType.FIGHTER, Race.ELF, ELVEN_KNIGHT, ClassLevel.SECOND, ClassType2.KNIGHT, 2633, 3140, 2820),
    SWORDSINGER(ClassType.FIGHTER, Race.ELF, ELVEN_KNIGHT, ClassLevel.SECOND, ClassType2.ENCHANTER, 2627, 3140, 2762),
    ELVEN_SCOUT(ClassType.FIGHTER, Race.ELF, ELVEN_FIGHTER, ClassLevel.FIRST, null, 1217),
    PLAIN_WALKER(ClassType.FIGHTER, Race.ELF, ELVEN_SCOUT, ClassLevel.SECOND, ClassType2.ROGUE, 2673, 3140, 2809),
    SILVER_RANGER(ClassType.FIGHTER, Race.ELF, ELVEN_SCOUT, ClassLevel.SECOND, ClassType2.ARCHER, 2673, 3140, 3293),
    ELVEN_MAGE(ClassType.MYSTIC, Race.ELF, null, ClassLevel.NONE, null, new int[0]),
    ELVEN_WIZARD(ClassType.MYSTIC, Race.ELF, ELVEN_MAGE, ClassLevel.FIRST, null, 1230),
    SPELLSINGER(ClassType.MYSTIC, Race.ELF, ELVEN_WIZARD, ClassLevel.SECOND, ClassType2.WIZARD, 2674, 3140, 2840),
    ELEMENTAL_SUMMONER(ClassType.MYSTIC, Race.ELF, ELVEN_WIZARD, ClassLevel.SECOND, ClassType2.SUMMONER, 2674, 3140, 3336),
    ORACLE(ClassType.MYSTIC, Race.ELF, ELVEN_MAGE, ClassLevel.FIRST, null, 1235),
    ELDER(ClassType.MYSTIC, Race.ELF, ORACLE, ClassLevel.SECOND, ClassType2.HEALER, 2721, 3140, 2820),
    DARK_FIGHTER(ClassType.FIGHTER, Race.DARKELF, null, ClassLevel.NONE, null, new int[0]),
    PALUS_KNIGHT(ClassType.FIGHTER, Race.DARKELF, DARK_FIGHTER, ClassLevel.FIRST, null, 1244),
    SHILLEN_KNIGHT(ClassType.FIGHTER, Race.DARKELF, PALUS_KNIGHT, ClassLevel.SECOND, ClassType2.KNIGHT, 2633, 3172, 3307),
    BLADEDANCER(ClassType.FIGHTER, Race.DARKELF, PALUS_KNIGHT, ClassLevel.SECOND, ClassType2.ENCHANTER, 2627, 3172, 2762),
    ASSASIN(ClassType.FIGHTER, Race.DARKELF, DARK_FIGHTER, ClassLevel.FIRST, null, 1252),
    ABYSS_WALKER(ClassType.FIGHTER, Race.DARKELF, ASSASIN, ClassLevel.SECOND, ClassType2.ROGUE, 2673, 3172, 2809),
    PHANTOM_RANGER(ClassType.FIGHTER, Race.DARKELF, ASSASIN, ClassLevel.SECOND, ClassType2.ARCHER, 2673, 3172, 3293),
    DARK_MAGE(ClassType.MYSTIC, Race.DARKELF, null, ClassLevel.NONE, null, new int[0]),
    DARK_WIZARD(ClassType.MYSTIC, Race.DARKELF, DARK_MAGE, ClassLevel.FIRST, null, 1261),
    SPELLHOWLER(ClassType.MYSTIC, Race.DARKELF, DARK_WIZARD, ClassLevel.SECOND, ClassType2.WIZARD, 2674, 3172, 2840),
    PHANTOM_SUMMONER(ClassType.MYSTIC, Race.DARKELF, DARK_WIZARD, ClassLevel.SECOND, ClassType2.SUMMONER, 2674, 3172, 3336),
    SHILLEN_ORACLE(ClassType.MYSTIC, Race.DARKELF, DARK_MAGE, ClassLevel.FIRST, null, 1270),
    SHILLEN_ELDER(ClassType.MYSTIC, Race.DARKELF, SHILLEN_ORACLE, ClassLevel.SECOND, ClassType2.HEALER, 2721, 3172, 2821),
    ORC_FIGHTER(ClassType.FIGHTER, Race.ORC, null, ClassLevel.NONE, null, new int[0]),
    ORC_RAIDER(ClassType.FIGHTER, Race.ORC, ORC_FIGHTER, ClassLevel.FIRST, null, 1592),
    DESTROYER(ClassType.FIGHTER, Race.ORC, ORC_RAIDER, ClassLevel.SECOND, ClassType2.WARRIOR, 2627, 3203, 3276),
    ORC_MONK(ClassType.FIGHTER, Race.ORC, ORC_FIGHTER, ClassLevel.FIRST, null, 1615),
    TYRANT(ClassType.FIGHTER, Race.ORC, ORC_MONK, ClassLevel.SECOND, ClassType2.WARRIOR, 2627, 3203, 2762),
    ORC_MAGE(ClassType.MYSTIC, Race.ORC, null, ClassLevel.NONE, null, new int[0]),
    ORC_SHAMAN(ClassType.MYSTIC, Race.ORC, ORC_MAGE, ClassLevel.FIRST, null, 1631),
    OVERLORD(ClassType.MYSTIC, Race.ORC, ORC_SHAMAN, ClassLevel.SECOND, ClassType2.ENCHANTER, 2721, 3203, 3390),
    WARCRYER(ClassType.MYSTIC, Race.ORC, ORC_SHAMAN, ClassLevel.SECOND, ClassType2.ENCHANTER, 2721, 3203, 2879),
    DWARVEN_FIGHTER(ClassType.FIGHTER, Race.DWARF, null, ClassLevel.NONE, null, new int[0]),
    SCAVENGER(ClassType.FIGHTER, Race.DWARF, DWARVEN_FIGHTER, ClassLevel.FIRST, null, 1642),
    BOUNTY_HUNTER(ClassType.FIGHTER, Race.DWARF, SCAVENGER, ClassLevel.SECOND, ClassType2.ROGUE, 3119, 3238, 2809),
    ARTISAN(ClassType.FIGHTER, Race.DWARF, DWARVEN_FIGHTER, ClassLevel.FIRST, null, 1635),
    WARSMITH(ClassType.FIGHTER, Race.DWARF, ARTISAN, ClassLevel.SECOND, ClassType2.WARRIOR, 3119, 3238, 2867),
    DUMMY_ENTRY_58,
    DUMMY_ENTRY_59,
    DUMMY_ENTRY_60,
    DUMMY_ENTRY_61,
    DUMMY_ENTRY_62,
    DUMMY_ENTRY_63,
    DUMMY_ENTRY_64,
    DUMMY_ENTRY_65,
    DUMMY_ENTRY_66,
    DUMMY_ENTRY_67,
    DUMMY_ENTRY_68,
    DUMMY_ENTRY_69,
    DUMMY_ENTRY_70,
    DUMMY_ENTRY_71,
    DUMMY_ENTRY_72,
    DUMMY_ENTRY_73,
    DUMMY_ENTRY_74,
    DUMMY_ENTRY_75,
    DUMMY_ENTRY_76,
    DUMMY_ENTRY_77,
    DUMMY_ENTRY_78,
    DUMMY_ENTRY_79,
    DUMMY_ENTRY_80,
    DUMMY_ENTRY_81,
    DUMMY_ENTRY_82,
    DUMMY_ENTRY_83,
    DUMMY_ENTRY_84,
    DUMMY_ENTRY_85,
    DUMMY_ENTRY_86,
    DUMMY_ENTRY_87,
    DUELIST(ClassType.FIGHTER, Race.HUMAN, GLADIATOR, ClassLevel.THIRD, ClassType2.WARRIOR, new int[0]),
    DREADNOUGHT(ClassType.FIGHTER, Race.HUMAN, WARLORD, ClassLevel.THIRD, ClassType2.WARRIOR, new int[0]),
    PHOENIX_KNIGHT(ClassType.FIGHTER, Race.HUMAN, PALADIN, ClassLevel.THIRD, ClassType2.KNIGHT, new int[0]),
    HELL_KNIGHT(ClassType.FIGHTER, Race.HUMAN, DARK_AVENGER, ClassLevel.THIRD, ClassType2.KNIGHT, new int[0]),
    SAGITTARIUS(ClassType.FIGHTER, Race.HUMAN, HAWKEYE, ClassLevel.THIRD, ClassType2.ARCHER, new int[0]),
    ADVENTURER(ClassType.FIGHTER, Race.HUMAN, TREASURE_HUNTER, ClassLevel.THIRD, ClassType2.ROGUE, new int[0]),
    ARCHMAGE(ClassType.MYSTIC, Race.HUMAN, SORCERER, ClassLevel.THIRD, ClassType2.WIZARD, new int[0]),
    SOULTAKER(ClassType.MYSTIC, Race.HUMAN, NECROMANCER, ClassLevel.THIRD, ClassType2.WIZARD, new int[0]),
    ARCANA_LORD(ClassType.MYSTIC, Race.HUMAN, WARLOCK, ClassLevel.THIRD, ClassType2.SUMMONER, new int[0]),
    CARDINAL(ClassType.MYSTIC, Race.HUMAN, BISHOP, ClassLevel.THIRD, ClassType2.HEALER, new int[0]),
    HIEROPHANT(ClassType.MYSTIC, Race.HUMAN, PROPHET, ClassLevel.THIRD, ClassType2.ENCHANTER, new int[0]),
    EVAS_TEMPLAR(ClassType.FIGHTER, Race.ELF, TEMPLE_KNIGHT, ClassLevel.THIRD, ClassType2.KNIGHT, new int[0]),
    SWORD_MUSE(ClassType.FIGHTER, Race.ELF, SWORDSINGER, ClassLevel.THIRD, ClassType2.ENCHANTER, new int[0]),
    WIND_RIDER(ClassType.FIGHTER, Race.ELF, PLAIN_WALKER, ClassLevel.THIRD, ClassType2.ROGUE, new int[0]),
    MOONLIGHT_SENTINEL(ClassType.FIGHTER, Race.ELF, SILVER_RANGER, ClassLevel.THIRD, ClassType2.ARCHER, new int[0]),
    MYSTIC_MUSE(ClassType.MYSTIC, Race.ELF, SPELLSINGER, ClassLevel.THIRD, ClassType2.WIZARD, new int[0]),
    ELEMENTAL_MASTER(ClassType.MYSTIC, Race.ELF, ELEMENTAL_SUMMONER, ClassLevel.THIRD, ClassType2.SUMMONER, new int[0]),
    EVAS_SAINT(ClassType.MYSTIC, Race.ELF, ELDER, ClassLevel.THIRD, ClassType2.HEALER, new int[0]),
    SHILLIEN_TEMPLAR(ClassType.FIGHTER, Race.DARKELF, SHILLEN_KNIGHT, ClassLevel.THIRD, ClassType2.KNIGHT, new int[0]),
    SPECTRAL_DANCER(ClassType.FIGHTER, Race.DARKELF, BLADEDANCER, ClassLevel.THIRD, ClassType2.ENCHANTER, new int[0]),
    GHOST_HUNTER(ClassType.FIGHTER, Race.DARKELF, ABYSS_WALKER, ClassLevel.THIRD, ClassType2.ROGUE, new int[0]),
    GHOST_SENTINEL(ClassType.FIGHTER, Race.DARKELF, PHANTOM_RANGER, ClassLevel.THIRD, ClassType2.ARCHER, new int[0]),
    STORM_SCREAMER(ClassType.MYSTIC, Race.DARKELF, SPELLHOWLER, ClassLevel.THIRD, ClassType2.WIZARD, new int[0]),
    SPECTRAL_MASTER(ClassType.MYSTIC, Race.DARKELF, PHANTOM_SUMMONER, ClassLevel.THIRD, ClassType2.SUMMONER, new int[0]),
    SHILLIEN_SAINT(ClassType.MYSTIC, Race.DARKELF, SHILLEN_ELDER, ClassLevel.THIRD, ClassType2.HEALER, new int[0]),
    TITAN(ClassType.FIGHTER, Race.ORC, DESTROYER, ClassLevel.THIRD, ClassType2.WARRIOR, new int[0]),
    GRAND_KHAVATARI(ClassType.FIGHTER, Race.ORC, TYRANT, ClassLevel.THIRD, ClassType2.WARRIOR, new int[0]),
    DOMINATOR(ClassType.MYSTIC, Race.ORC, OVERLORD, ClassLevel.THIRD, ClassType2.ENCHANTER, new int[0]),
    DOOMCRYER(ClassType.MYSTIC, Race.ORC, WARCRYER, ClassLevel.THIRD, ClassType2.ENCHANTER, new int[0]),
    FORTUNE_SEEKER(ClassType.FIGHTER, Race.DWARF, BOUNTY_HUNTER, ClassLevel.THIRD, ClassType2.ROGUE, new int[0]),
    MAESTRO(ClassType.FIGHTER, Race.DWARF, WARSMITH, ClassLevel.THIRD, ClassType2.WARRIOR, new int[0]);

    public static final ClassId[] VALUES;
    private final Race _race;
    private final ClassId _parent;
    private final ClassId _firstParent;
    private final ClassLevel _level;
    private final ClassType _type;
    private final ClassType2 _type2;
    private final boolean _isDummy;
    private final int[] _changeClassItemIds;

    public static ClassId valueOf(int id) {
        if (id < 0 || id >= VALUES.length) {
            return null;
        }
        ClassId result = VALUES[id];
        if (result != null && !result.isDummy()) {
            return result;
        }
        return null;
    }

    private ClassId() {
        this(null, null, null, null, null, true, new int[0]);
    }

    private ClassId(ClassType classType, Race race, ClassId parent, ClassLevel level, ClassType2 type2, int ... changeClassItemIds) {
        this(classType, race, parent, level, type2, false, changeClassItemIds);
    }

    private ClassId(ClassType classType, Race race, ClassId parent, ClassLevel level, ClassType2 type2, boolean isDummy, int ... changeClassItemIds) {
        this._type = classType;
        this._race = race;
        this._parent = parent;
        this._level = level;
        this._type2 = type2;
        this._isDummy = isDummy;
        this._firstParent = this._parent == null ? this : this._parent.getFirstParent(0);
        this._changeClassItemIds = changeClassItemIds;
    }

    public final int getId() {
        return this.ordinal();
    }

    public final Race getRace() {
        return this._race;
    }

    public final boolean isOfRace(Race race) {
        return this._race == race;
    }

    public final ClassLevel getClassLevel() {
        return this._level;
    }

    public final boolean isOfLevel(ClassLevel level) {
        return this._level == level;
    }

    public final ClassType getType() {
        return this._type;
    }

    public final boolean isOfType(ClassType type) {
        return this._type == type;
    }

    public ClassType2 getType2() {
        return this._type2;
    }

    public final boolean isOfType2(ClassType2 type) {
        return this._type2 == type;
    }

    public final boolean isMage() {
        return this._type.isMagician();
    }

    public final boolean isDummy() {
        return this._isDummy;
    }

    public boolean childOf(ClassId cid) {
        if (this._parent == null) {
            return false;
        }
        if (this._parent == cid) {
            return true;
        }
        return this._parent.childOf(cid);
    }

    public final boolean equalsOrChildOf(ClassId cid) {
        return this == cid || this.childOf(cid);
    }

    public final ClassId getParent(int sex) {
        return this._parent;
    }

    public final ClassId getFirstParent(int sex) {
        return this._firstParent;
    }

    public ClassData getClassData() {
        return ClassDataHolder.getInstance().getClassData(this.getId());
    }

    public double getBaseCp(int level) {
        return this.getClassData().getHpMpCpData(level).getCP();
    }

    public double getBaseHp(int level) {
        return this.getClassData().getHpMpCpData(level).getHP();
    }

    public double getBaseMp(int level) {
        return this.getClassData().getHpMpCpData(level).getMP();
    }

    public final String getName(Player player) {
        if (this.isDummy()) {
            return "N/A";
        }
        if (player == null) {
            return new CustomMessage("l2s.gameserver.model.base.ClassId.name." + this.getId()).toString(Config.DEFAULT_LANG);
        }
        return new CustomMessage("l2s.gameserver.model.base.ClassId.name." + this.getId()).toString(player);
    }

    public int getClassMinLevel(boolean forNextClass) {
        ClassLevel classLevel = this.getClassLevel();
        if (forNextClass) {
            if (classLevel == ClassLevel.THIRD) {
                return -1;
            }
            classLevel = ClassLevel.VALUES[classLevel.ordinal() + 1];
        }
        switch (classLevel) {
            case FIRST: {
                return 20;
            }
            case SECOND: {
                return 40;
            }
            case THIRD: {
                return 76;
            }
        }
        return 1;
    }

    public boolean isLast() {
        return this.isOfLevel(ClassLevel.THIRD);
    }

    public int[] getChangeClassItemIds() {
        return this._changeClassItemIds;
    }

    public static boolean isKnight(int id) {
        if (id >= 0) {
            ClassId classId = VALUES[id];
            if (classId == PALADIN) {
                return true;
            }
            if (classId == PHOENIX_KNIGHT) {
                return true;
            }
            if (classId == DARK_AVENGER) {
                return true;
            }
            if (classId == HELL_KNIGHT) {
                return true;
            }
            if (classId == TEMPLE_KNIGHT) {
                return true;
            }
            if (classId == EVAS_TEMPLAR) {
                return true;
            }
            if (classId == SHILLEN_KNIGHT) {
                return true;
            }
            if (classId == SHILLIEN_TEMPLAR) {
                return true;
            }
        }
        return false;
    }

    public static boolean isDagger(int id) {
        if (id >= 0) {
            ClassId classId = VALUES[id];
            if (classId == TREASURE_HUNTER) {
                return true;
            }
            if (classId == ADVENTURER) {
                return true;
            }
            if (classId == PLAIN_WALKER) {
                return true;
            }
            if (classId == WIND_RIDER) {
                return true;
            }
            if (classId == ABYSS_WALKER) {
                return true;
            }
            if (classId == GHOST_HUNTER) {
                return true;
            }
        }
        return false;
    }

    public static boolean isBow(int id) {
        if (id >= 0) {
            ClassId classId = VALUES[id];
            if (classId == HAWKEYE) {
                return true;
            }
            if (classId == SAGITTARIUS) {
                return true;
            }
            if (classId == SILVER_RANGER) {
                return true;
            }
            if (classId == MOONLIGHT_SENTINEL) {
                return true;
            }
            if (classId == PHANTOM_RANGER) {
                return true;
            }
            if (classId == GHOST_SENTINEL) {
                return true;
            }
        }
        return false;
    }

    public static boolean isDance(int id) {
        if (id >= 0) {
            ClassId classId = VALUES[id];
            if (classId == SWORDSINGER) {
                return true;
            }
            if (classId == SWORD_MUSE) {
                return true;
            }
            if (classId == BLADEDANCER) {
                return true;
            }
            if (classId == SPECTRAL_DANCER) {
                return true;
            }
        }
        return false;
    }

    public static boolean isWizard(int id) {
        if (id >= 0) {
            ClassId classId = VALUES[id];
            if (classId == SORCERER) {
                return true;
            }
            if (classId == ARCHMAGE) {
                return true;
            }
            if (classId == SPELLSINGER) {
                return true;
            }
            if (classId == MYSTIC_MUSE) {
                return true;
            }
            if (classId == SPELLHOWLER) {
                return true;
            }
            if (classId == STORM_SCREAMER) {
                return true;
            }
        }
        return false;
    }

    public static boolean isSummoner(int id) {
        if (id >= 0) {
            ClassId classId = VALUES[id];
            if (classId == WARLOCK) {
                return true;
            }
            if (classId == ARCANA_LORD) {
                return true;
            }
            if (classId == ELEMENTAL_SUMMONER) {
                return true;
            }
            if (classId == ELEMENTAL_MASTER) {
                return true;
            }
            if (classId == PHANTOM_SUMMONER) {
                return true;
            }
            if (classId == SPECTRAL_MASTER) {
                return true;
            }
        }
        return false;
    }

    public static boolean isHalfHealer(int id) {
        if (id >= 0) {
            ClassId classId = VALUES[id];
            if (classId == ELDER) {
                return true;
            }
            if (classId == EVAS_SAINT) {
                return true;
            }
            if (classId == SHILLEN_ELDER) {
                return true;
            }
            if (classId == SHILLIEN_SAINT) {
                return true;
            }
        }
        return false;
    }

    static {
        VALUES = ClassId.values();
    }
}


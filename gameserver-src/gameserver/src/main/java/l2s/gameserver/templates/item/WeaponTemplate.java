package l2s.gameserver.templates.item;

import gnu.trove.set.TIntSet;
import gnu.trove.set.hash.TIntHashSet;
import l2s.gameserver.handler.items.IItemHandler;
import l2s.gameserver.handler.items.ItemHandler;
import l2s.gameserver.skills.SkillTrait;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.stats.funcs.FuncTemplate;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.item.ExItemType;
import l2s.gameserver.templates.item.ItemGrade;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.item.ItemType;
import l2s.gameserver.templates.item.WeaponFightType;

public final class WeaponTemplate
extends ItemTemplate {
    private final int _soulShotCount;
    private final int _spiritShotCount;
    private final int _kamaelConvert;
    private final int _rndDam;
    private final int _atkReuse;
    private final int _mpConsume;
    private final int _atkRange;
    private final int _attackRadius;
    private final int _attackAngle;
    private final boolean _isMagicWeapon;
    private int _critical;
    private final int[] _reducedSoulshot;
    private final int[] _reducedSpiritshot;
    private final int[] _reducedMPConsume;
    private TIntSet _availableEnsouls = null;

    public WeaponTemplate(StatsSet set) {
        super(set);
        this._type = (ItemType)((Object)set.getEnum("type", WeaponType.class));
        this._soulShotCount = set.getInteger("soulshots", 0);
        this._spiritShotCount = set.getInteger("spiritshots", 0);
        this._kamaelConvert = set.getInteger("kamael_convert", 0);
        this._rndDam = set.getInteger("rnd_dam", 0);
        this._atkReuse = set.getInteger("reuse_delay", this._type == WeaponType.BOW ? 1500 : (this._type == WeaponType.CROSSBOW || this._type == WeaponType.TWOHANDCROSSBOW ? 820 : 0));
        this._atkRange = set.getInteger("atk_range", WeaponTemplate.getDefaultAttackRange((WeaponType)this._type));
        String[] damageRange = set.getString("damage_range", "").split(";");
        if (damageRange.length >= 4) {
            this._attackRadius = Integer.parseInt(damageRange[2]);
            this._attackAngle = Integer.parseInt(damageRange[3]);
        } else if (this._type == WeaponType.BOW) {
            this._attackRadius = 10;
            this._attackAngle = 0;
        } else if (this._type == WeaponType.POLE) {
            this._attackRadius = 66;
            this._attackAngle = 120;
        } else {
            this._attackRadius = 40;
            this._attackAngle = 120;
        }
        this._mpConsume = set.getInteger("mp_consume", 0);
        this._isMagicWeapon = set.getBool("is_magic_weapon", false);
        this._reducedSoulshot = set.getIntegerArray("reduced_soulshot", new int[]{0, this._soulShotCount});
        this._reducedSpiritshot = set.getIntegerArray("reduced_spiritshot", new int[]{0, this._spiritShotCount});
        this._reducedMPConsume = set.getIntegerArray("reduced_mp_consume", new int[]{0, this._mpConsume});
        int[] availableEnsouls = set.getIntegerArray("available_ensouls", new int[0]);
        if (availableEnsouls.length > 0) {
            this._availableEnsouls = new TIntHashSet(availableEnsouls);
        }
        if (this._type == WeaponType.NONE) {
            this._type1 = 1;
            this._type2 = 1;
        } else {
            this._type1 = 0;
            this._type2 = 0;
        }
        if (this._type == WeaponType.SWORD && !this._isMagicWeapon) {
            this._exType = ExItemType.SWORD;
        } else if (this._type == WeaponType.SWORD && this._isMagicWeapon) {
            this._exType = ExItemType.MAGIC_SWORD;
        } else if (this._type == WeaponType.DAGGER) {
            this._exType = ExItemType.DAGGER;
        } else if (this._type == WeaponType.RAPIER) {
            this._exType = ExItemType.RAPIER;
        } else if (this._type == WeaponType.BIGSWORD) {
            this._exType = ExItemType.BIG_SWORD;
        } else if (this._type == WeaponType.ANCIENTSWORD) {
            this._exType = ExItemType.ANCIENT_SWORD;
        } else if (this._type == WeaponType.DUAL) {
            this._exType = ExItemType.DUAL_SWORD;
        } else if (this._type == WeaponType.DUALDAGGER) {
            this._exType = ExItemType.DUAL_DAGGER;
        } else if (this._type == WeaponType.BLUNT && !this._isMagicWeapon) {
            this._exType = ExItemType.BLUNT_WEAPON;
        } else if (this._type == WeaponType.BLUNT && this._isMagicWeapon) {
            this._exType = ExItemType.MAGIC_BLUNT_WEAPON;
        } else if (this._type == WeaponType.BIGBLUNT && !this._isMagicWeapon) {
            this._exType = ExItemType.BIG_BLUNT_WEAPON;
        } else if (this._type == WeaponType.BIGBLUNT && this._isMagicWeapon) {
            this._exType = ExItemType.BIG_MAGIC_BLUNT_WEAPON;
        } else if (this._type == WeaponType.DUALBLUNT) {
            this._exType = ExItemType.DUAL_BLUNT_WEAPON;
        } else if (this._type == WeaponType.BOW) {
            this._exType = ExItemType.BOW;
        } else if (this._type == WeaponType.CROSSBOW || this._type == WeaponType.TWOHANDCROSSBOW) {
            this._exType = ExItemType.CROSSBOW;
        } else if (this._type == WeaponType.DUALFIST) {
            this._exType = ExItemType.HAND_TO_HAND;
        } else if (this._type == WeaponType.POLE) {
            this._exType = ExItemType.POLE;
        } else if (this._type == WeaponType.ETC || this._type == WeaponType.ROD) {
            this._exType = ExItemType.OTHER_WEAPON;
        } else if (this._bodyPart == 256L && this._type == WeaponType.NONE) {
            this._exType = ExItemType.SHIELD;
        }
        this.initEnchantFuncs();
    }

    @Override
    public IItemHandler getHandler() {
        return ItemHandler.EQUIPABLE_HANDLER;
    }

    @Override
    public WeaponType getItemType() {
        return (WeaponType)super.getItemType();
    }

    @Override
    public long getItemMask() {
        return this.getItemType().mask();
    }

    public int getSoulShotCount() {
        return this._soulShotCount;
    }

    public int getSpiritShotCount() {
        return this._spiritShotCount;
    }

    public int getCritical() {
        return this._critical;
    }

    public int getRandomDamage() {
        return this._rndDam;
    }

    public int getAttackReuseDelay() {
        return this._atkReuse;
    }

    public int getMpConsume() {
        return this._mpConsume;
    }

    public int getAttackRange() {
        return this._atkRange;
    }

    public int getAttackRadius() {
        return this._attackRadius;
    }

    public int getAttackAngle() {
        return this._attackAngle;
    }

    public static int getDefaultAttackRange(WeaponType type) {
        switch (type) {
            case BOW: {
                return 460;
            }
            case CROSSBOW: 
            case TWOHANDCROSSBOW: {
                return 360;
            }
            case POLE: {
                return 80;
            }
        }
        return 40;
    }

    @Override
    public void attachFunc(FuncTemplate f) {
        if (f._stat == Stats.BASE_P_CRITICAL_RATE && f._order == 8) {
            this._critical = (int)Math.round(f._value / 10.0);
        }
        super.attachFunc(f);
    }

    public int getKamaelConvert() {
        return this._kamaelConvert;
    }

    @Override
    public boolean isMagicWeapon() {
        return this._isMagicWeapon;
    }

    public int[] getReducedSoulshot() {
        return this._reducedSoulshot;
    }

    public int[] getReducedSpiritshot() {
        return this._reducedSpiritshot;
    }

    public int[] getReducedMPConsume() {
        return this._reducedMPConsume;
    }

    @Override
    public WeaponFightType getWeaponFightType() {
        if (this._isMagicWeapon) {
            return WeaponFightType.MAGE;
        }
        return WeaponFightType.WARRIOR;
    }

    @Override
    public boolean canBeEnsoul(int ensoulId) {
        if (!this.isWeapon()) {
            return false;
        }
        if (this._availableEnsouls == null ? this.getGrade().ordinal() < ItemGrade.D.ordinal() : !this._availableEnsouls.contains(ensoulId)) {
            return false;
        }
        return this.isEnsoulable();
    }

    public static enum WeaponType implements ItemType
    {
        NONE("Shield", SkillTrait.NONE),
        SWORD("Sword", SkillTrait.SWORD),
        BLUNT("Blunt", SkillTrait.BLUNT),
        DAGGER("Dagger", SkillTrait.DAGGER),
        BOW("Bow", SkillTrait.BOW),
        POLE("Pole", SkillTrait.POLE),
        ETC("Etc", SkillTrait.ETC),
        FIST("Fist", SkillTrait.FIST),
        DUAL("Dual Sword", SkillTrait.DUAL),
        DUALFIST("Dual Fist", SkillTrait.DUALFIST),
        BIGSWORD("Big Sword", SkillTrait.SWORD),
        PET("Pet", SkillTrait.FIST),
        ROD("Rod", SkillTrait.NONE),
        BIGBLUNT("Big Blunt", SkillTrait.BLUNT),
        CROSSBOW("Crossbow", SkillTrait.CROSSBOW),
        RAPIER("Rapier", SkillTrait.RAPIER),
        ANCIENTSWORD("Ancient Sword", SkillTrait.ANCIENTSWORD),
        DUALDAGGER("Dual Dagger", SkillTrait.DUALDAGGER),
        TWOHANDCROSSBOW("Two Hand Crossbow", SkillTrait.TWOHANDCROSSBOW),
        DUALBLUNT("Dual Blunt", SkillTrait.DUALBLUNT),
        MAGIC("Magic", null);

        public static final WeaponType[] VALUES;
        private final long _mask = 1L << this.ordinal() + 1000;
        private final String _name;
        private final SkillTrait _trait;

        private WeaponType(String name, SkillTrait trait) {
            this._name = name;
            this._trait = trait;
        }

        @Override
        public long mask() {
            return this._mask;
        }

        @Override
        public IItemHandler getHandler() {
            return ItemHandler.EQUIPABLE_HANDLER;
        }

        public SkillTrait getTrait() {
            return this._trait;
        }

        @Override
        public ExItemType getExType() {
            return null;
        }

        public String toString() {
            return this._name;
        }

        static {
            VALUES = WeaponType.values();
        }
    }
}


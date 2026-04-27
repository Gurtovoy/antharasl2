/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.skills;

import l2s.gameserver.Config;
import l2s.gameserver.skills.SkillTraitType;
import l2s.gameserver.stats.Stats;

public enum SkillTrait {
    UNK_0(SkillTraitType.NONE, null, null),
    SWORD(SkillTraitType.WEAPON, Stats.ATTACK_TRAIT_SWORD, Stats.DEFENCE_TRAIT_SWORD),
    BLUNT(SkillTraitType.WEAPON, Stats.ATTACK_TRAIT_BLUNT, Stats.DEFENCE_TRAIT_BLUNT),
    DAGGER(SkillTraitType.WEAPON, Stats.ATTACK_TRAIT_DAGGER, Stats.DEFENCE_TRAIT_DAGGER),
    POLE(SkillTraitType.WEAPON, Stats.ATTACK_TRAIT_POLE, Stats.DEFENCE_TRAIT_POLE),
    FIST(SkillTraitType.WEAPON, Stats.ATTACK_TRAIT_FIST, Stats.DEFENCE_TRAIT_FIST),
    BOW(SkillTraitType.WEAPON, Stats.ATTACK_TRAIT_BOW, Stats.DEFENCE_TRAIT_BOW),
    ETC(SkillTraitType.WEAPON, Stats.ATTACK_TRAIT_ETC, Stats.DEFENCE_TRAIT_ETC),
    UNK_8(SkillTraitType.NONE, null, null),
    POISON(SkillTraitType.RESISTANCE, Stats.ATTACK_TRAIT_POISON, Stats.DEFENCE_TRAIT_POISON){

        @Override
        public double getAttackMod() {
            return Config.ATTACK_TRAIT_POISON_MOD;
        }

        @Override
        public double getDefenceMod() {
            return Config.DEFENCE_TRAIT_POISON_MOD;
        }
    }
    ,
    HOLD(SkillTraitType.RESISTANCE, Stats.ATTACK_TRAIT_HOLD, Stats.DEFENCE_TRAIT_HOLD){

        @Override
        public double getAttackMod() {
            return Config.ATTACK_TRAIT_HOLD_MOD;
        }

        @Override
        public double getDefenceMod() {
            return Config.DEFENCE_TRAIT_HOLD_MOD;
        }
    }
    ,
    BLEED(SkillTraitType.RESISTANCE, Stats.ATTACK_TRAIT_BLEED, Stats.DEFENCE_TRAIT_BLEED){

        @Override
        public double getAttackMod() {
            return Config.ATTACK_TRAIT_BLEED_MOD;
        }

        @Override
        public double getDefenceMod() {
            return Config.DEFENCE_TRAIT_BLEED_MOD;
        }
    }
    ,
    SLEEP(SkillTraitType.RESISTANCE, Stats.ATTACK_TRAIT_SLEEP, Stats.DEFENCE_TRAIT_SLEEP){

        @Override
        public double getAttackMod() {
            return Config.ATTACK_TRAIT_SLEEP_MOD;
        }

        @Override
        public double getDefenceMod() {
            return Config.DEFENCE_TRAIT_SLEEP_MOD;
        }
    }
    ,
    SHOCK(SkillTraitType.RESISTANCE, Stats.ATTACK_TRAIT_SHOCK, Stats.DEFENCE_TRAIT_SHOCK){

        @Override
        public double getAttackMod() {
            return Config.ATTACK_TRAIT_SHOCK_MOD;
        }

        @Override
        public double getDefenceMod() {
            return Config.DEFENCE_TRAIT_SHOCK_MOD;
        }
    }
    ,
    DERANGEMENT(SkillTraitType.RESISTANCE, Stats.ATTACK_TRAIT_DERANGEMENT, Stats.DEFENCE_TRAIT_DERANGEMENT){

        @Override
        public double getAttackMod() {
            return Config.ATTACK_TRAIT_DERANGEMENT_MOD;
        }

        @Override
        public double getDefenceMod() {
            return Config.DEFENCE_TRAIT_DERANGEMENT_MOD;
        }
    }
    ,
    BUG_WEAKNESS(SkillTraitType.WEAKNESS, Stats.ATTACK_TRAIT_BUG_WEAKNESS, Stats.DEFENCE_TRAIT_BUG_WEAKNESS),
    ANIMAL_WEAKNESS(SkillTraitType.WEAKNESS, Stats.ATTACK_TRAIT_ANIMAL_WEAKNESS, Stats.DEFENCE_TRAIT_ANIMAL_WEAKNESS),
    PLANT_WEAKNESS(SkillTraitType.WEAKNESS, Stats.ATTACK_TRAIT_PLANT_WEAKNESS, Stats.DEFENCE_TRAIT_PLANT_WEAKNESS),
    BEAST_WEAKNESS(SkillTraitType.WEAKNESS, Stats.ATTACK_TRAIT_BEAST_WEAKNESS, Stats.DEFENCE_TRAIT_BEAST_WEAKNESS),
    DRAGON_WEAKNESS(SkillTraitType.WEAKNESS, Stats.ATTACK_TRAIT_DRAGON_WEAKNESS, Stats.DEFENCE_TRAIT_DRAGON_WEAKNESS),
    PARALYZE(SkillTraitType.RESISTANCE, Stats.ATTACK_TRAIT_PARALYZE, Stats.DEFENCE_TRAIT_PARALYZE){

        @Override
        public double getAttackMod() {
            return Config.ATTACK_TRAIT_PARALYZE_MOD;
        }

        @Override
        public double getDefenceMod() {
            return Config.DEFENCE_TRAIT_PARALYZE_MOD;
        }
    }
    ,
    DUAL(SkillTraitType.WEAPON, Stats.ATTACK_TRAIT_DUAL, Stats.DEFENCE_TRAIT_DUAL),
    DUALFIST(SkillTraitType.WEAPON, Stats.ATTACK_TRAIT_DUALFIST, Stats.DEFENCE_TRAIT_DUALFIST),
    BOSS(SkillTraitType.RESISTANCE, Stats.ATTACK_TRAIT_BOSS, Stats.DEFENCE_TRAIT_BOSS){

        @Override
        public double getAttackMod() {
            return Config.ATTACK_TRAIT_BOSS_MOD;
        }

        @Override
        public double getDefenceMod() {
            return Config.DEFENCE_TRAIT_BOSS_MOD;
        }
    }
    ,
    GIANT_WEAKNESS(SkillTraitType.WEAKNESS, Stats.ATTACK_TRAIT_GIANT_WEAKNESS, Stats.DEFENCE_TRAIT_GIANT_WEAKNESS),
    CONSTRUCT_WEAKNESS(SkillTraitType.WEAKNESS, Stats.ATTACK_TRAIT_CONSTRUCT_WEAKNESS, Stats.DEFENCE_TRAIT_CONSTRUCT_WEAKNESS),
    DEATH(SkillTraitType.RESISTANCE, Stats.ATTACK_TRAIT_DEATH, Stats.DEFENCE_TRAIT_DEATH){

        @Override
        public double getAttackMod() {
            return Config.ATTACK_TRAIT_DEATH_MOD;
        }

        @Override
        public double getDefenceMod() {
            return Config.DEFENCE_TRAIT_DEATH_MOD;
        }
    }
    ,
    VALAKAS(SkillTraitType.WEAKNESS, Stats.ATTACK_TRAIT_VALAKAS, Stats.DEFENCE_TRAIT_VALAKAS),
    UNK_28(SkillTraitType.WEAKNESS, null, null),
    UNK_29(SkillTraitType.RESISTANCE, null, null),
    ROOT_PHYSICALLY(SkillTraitType.RESISTANCE, Stats.ATTACK_TRAIT_ROOT_PHYSICALLY, Stats.DEFENCE_TRAIT_ROOT_PHYSICALLY){

        @Override
        public double getAttackMod() {
            return Config.ATTACK_TRAIT_ROOT_PHYSICALLY_MOD;
        }

        @Override
        public double getDefenceMod() {
            return Config.DEFENCE_TRAIT_ROOT_PHYSICALLY_MOD;
        }
    }
    ,
    UNK_31(SkillTraitType.RESISTANCE, null, null),
    RAPIER(SkillTraitType.WEAPON, Stats.ATTACK_TRAIT_RAPIER, Stats.DEFENCE_TRAIT_RAPIER),
    CROSSBOW(SkillTraitType.WEAPON, Stats.ATTACK_TRAIT_CROSSBOW, Stats.DEFENCE_TRAIT_CROSSBOW),
    ANCIENTSWORD(SkillTraitType.WEAPON, Stats.ATTACK_TRAIT_ANCIENTSWORD, Stats.DEFENCE_TRAIT_ANCIENTSWORD),
    TURN_STONE(SkillTraitType.RESISTANCE, Stats.ATTACK_TRAIT_TURN_STONE, Stats.DEFENCE_TRAIT_TURN_STONE){

        @Override
        public double getAttackMod() {
            return Config.ATTACK_TRAIT_TURN_STONE_MOD;
        }

        @Override
        public double getDefenceMod() {
            return Config.DEFENCE_TRAIT_TURN_STONE_MOD;
        }
    }
    ,
    GUST(SkillTraitType.RESISTANCE, Stats.ATTACK_TRAIT_GUST, Stats.DEFENCE_TRAIT_GUST){

        @Override
        public double getAttackMod() {
            return Config.ATTACK_TRAIT_GUST_MOD;
        }

        @Override
        public double getDefenceMod() {
            return Config.DEFENCE_TRAIT_GUST_MOD;
        }
    }
    ,
    PHYSICAL_BLOCKADE(SkillTraitType.RESISTANCE, Stats.ATTACK_TRAIT_PHYSICAL_BLOCKADE, Stats.DEFENCE_TRAIT_PHYSICAL_BLOCKADE){

        @Override
        public double getAttackMod() {
            return Config.ATTACK_TRAIT_PHYSICAL_BLOCKADE_MOD;
        }

        @Override
        public double getDefenceMod() {
            return Config.DEFENCE_TRAIT_PHYSICAL_BLOCKADE_MOD;
        }
    }
    ,
    TARGET(SkillTraitType.RESISTANCE, Stats.ATTACK_TRAIT_TARGET, Stats.DEFENCE_TRAIT_TARGET){

        @Override
        public double getAttackMod() {
            return Config.ATTACK_TRAIT_TARGET_MOD;
        }

        @Override
        public double getDefenceMod() {
            return Config.DEFENCE_TRAIT_TARGET_MOD;
        }
    }
    ,
    PHYSICAL_WEAKNESS(SkillTraitType.RESISTANCE, Stats.ATTACK_TRAIT_PHYSICAL_WEAKNESS, Stats.DEFENCE_TRAIT_PHYSICAL_WEAKNESS){

        @Override
        public double getAttackMod() {
            return Config.ATTACK_TRAIT_PHYSICAL_WEAKNESS_MOD;
        }

        @Override
        public double getDefenceMod() {
            return Config.DEFENCE_TRAIT_PHYSICAL_WEAKNESS_MOD;
        }
    }
    ,
    MAGICAL_WEAKNESS(SkillTraitType.RESISTANCE, Stats.ATTACK_TRAIT_MAGICAL_WEAKNESS, Stats.DEFENCE_TRAIT_MAGICAL_WEAKNESS){

        @Override
        public double getAttackMod() {
            return Config.ATTACK_TRAIT_MAGICAL_WEAKNESS_MOD;
        }

        @Override
        public double getDefenceMod() {
            return Config.DEFENCE_TRAIT_MAGICAL_WEAKNESS_MOD;
        }
    }
    ,
    DUALDAGGER(SkillTraitType.WEAPON, Stats.ATTACK_TRAIT_DUALDAGGER, Stats.DEFENCE_TRAIT_DUALDAGGER),
    DUALBLUNT(SkillTraitType.WEAPON, Stats.ATTACK_TRAIT_DUALBLUNT, Stats.DEFENCE_TRAIT_DUALBLUNT),
    KNOCKBACK(SkillTraitType.RESISTANCE, Stats.ATTACK_TRAIT_KNOCKBACK, Stats.DEFENCE_TRAIT_KNOCKBACK){

        @Override
        public double getAttackMod() {
            return Config.ATTACK_TRAIT_KNOCKBACK_MOD;
        }

        @Override
        public double getDefenceMod() {
            return Config.DEFENCE_TRAIT_KNOCKBACK_MOD;
        }
    }
    ,
    KNOCKDOWN(SkillTraitType.RESISTANCE, Stats.ATTACK_TRAIT_KNOCKDOWN, Stats.DEFENCE_TRAIT_KNOCKDOWN){

        @Override
        public double getAttackMod() {
            return Config.ATTACK_TRAIT_KNOCKDOWN_MOD;
        }

        @Override
        public double getDefenceMod() {
            return Config.DEFENCE_TRAIT_KNOCKDOWN_MOD;
        }
    }
    ,
    PULL(SkillTraitType.RESISTANCE, Stats.ATTACK_TRAIT_PULL, Stats.DEFENCE_TRAIT_PULL){

        @Override
        public double getAttackMod() {
            return Config.ATTACK_TRAIT_PULL_MOD;
        }

        @Override
        public double getDefenceMod() {
            return Config.DEFENCE_TRAIT_PULL_MOD;
        }
    }
    ,
    HATE(SkillTraitType.RESISTANCE, Stats.ATTACK_TRAIT_HATE, Stats.DEFENCE_TRAIT_HATE){

        @Override
        public double getAttackMod() {
            return Config.ATTACK_TRAIT_HATE_MOD;
        }

        @Override
        public double getDefenceMod() {
            return Config.DEFENCE_TRAIT_HATE_MOD;
        }
    }
    ,
    AGGRESSION(SkillTraitType.RESISTANCE, Stats.ATTACK_TRAIT_AGGRESSION, Stats.DEFENCE_TRAIT_AGGRESSION){

        @Override
        public double getAttackMod() {
            return Config.ATTACK_TRAIT_AGGRESSION_MOD;
        }

        @Override
        public double getDefenceMod() {
            return Config.DEFENCE_TRAIT_AGGRESSION_MOD;
        }
    }
    ,
    AIRBIND(SkillTraitType.RESISTANCE, Stats.ATTACK_TRAIT_AIRBIND, Stats.DEFENCE_TRAIT_AIRBIND){

        @Override
        public double getAttackMod() {
            return Config.ATTACK_TRAIT_AIRBIND_MOD;
        }

        @Override
        public double getDefenceMod() {
            return Config.DEFENCE_TRAIT_AIRBIND_MOD;
        }
    }
    ,
    DISARM(SkillTraitType.RESISTANCE, Stats.ATTACK_TRAIT_DISARM, Stats.DEFENCE_TRAIT_DISARM){

        @Override
        public double getAttackMod() {
            return Config.ATTACK_TRAIT_DISARM_MOD;
        }

        @Override
        public double getDefenceMod() {
            return Config.DEFENCE_TRAIT_DISARM_MOD;
        }
    }
    ,
    DEPORT(SkillTraitType.RESISTANCE, Stats.ATTACK_TRAIT_DEPORT, Stats.DEFENCE_TRAIT_DEPORT){

        @Override
        public double getAttackMod() {
            return Config.ATTACK_TRAIT_DEPORT_MOD;
        }

        @Override
        public double getDefenceMod() {
            return Config.DEFENCE_TRAIT_DEPORT_MOD;
        }
    }
    ,
    CHANGEBODY(SkillTraitType.RESISTANCE, Stats.ATTACK_TRAIT_CHANGEBODY, Stats.DEFENCE_TRAIT_CHANGEBODY){

        @Override
        public double getAttackMod() {
            return Config.ATTACK_TRAIT_CHANGEBODY_MOD;
        }

        @Override
        public double getDefenceMod() {
            return Config.DEFENCE_TRAIT_CHANGEBODY_MOD;
        }
    }
    ,
    TWOHANDCROSSBOW(SkillTraitType.WEAPON, Stats.ATTACK_TRAIT_TWOHANDCROSSBOW, Stats.DEFENCE_TRAIT_TWOHANDCROSSBOW),
    NONE(SkillTraitType.NONE, null, null);

    public static final SkillTrait[] VALUES;
    private final SkillTraitType _type;
    private final Stats _attack;
    private final Stats _defence;

    private SkillTrait(SkillTraitType type, Stats attack, Stats defence) {
        this._type = type;
        this._attack = attack;
        this._defence = defence;
    }

    public int getId() {
        return this.ordinal();
    }

    public SkillTraitType getType() {
        return this._type;
    }

    public Stats getAttack() {
        return this._attack;
    }

    public Stats getDefence() {
        return this._defence;
    }

    public double getAttackMod() {
        return 1.0;
    }

    public double getDefenceMod() {
        return 1.0;
    }

    static {
        VALUES = SkillTrait.values();
    }
}


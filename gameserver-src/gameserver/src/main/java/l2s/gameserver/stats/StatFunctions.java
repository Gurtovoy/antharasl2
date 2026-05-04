package l2s.gameserver.stats;

import l2s.gameserver.Config;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.Mount;
import l2s.gameserver.model.base.BaseStats;
import l2s.gameserver.model.base.ClassLevel;
import l2s.gameserver.model.base.ClassType2;
import l2s.gameserver.model.base.Element;
import l2s.gameserver.model.base.Race;
import l2s.gameserver.model.instances.PetInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.Formulas;
import l2s.gameserver.stats.StatModifierType;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.stats.conditions.ConditionPlayerState;
import l2s.gameserver.stats.funcs.Func;
import l2s.gameserver.templates.item.WeaponTemplate;

public class StatFunctions {
    public static void addPredefinedFuncs(Creature cha) {
        if (cha.isDoor()) {
            return;
        }
        if (cha.isPlayer()) {
            cha.getStat().addFuncs(FuncMultRegenResting.getFunc(Stats.REGENERATE_CP_RATE));
            cha.getStat().addFuncs(FuncMultRegenStanding.getFunc(Stats.REGENERATE_CP_RATE));
            cha.getStat().addFuncs(FuncMultRegenRunning.getFunc(Stats.REGENERATE_CP_RATE));
            cha.getStat().addFuncs(FuncMultRegenResting.getFunc(Stats.REGENERATE_HP_RATE));
            cha.getStat().addFuncs(FuncMultRegenStanding.getFunc(Stats.REGENERATE_HP_RATE));
            cha.getStat().addFuncs(FuncMultRegenRunning.getFunc(Stats.REGENERATE_HP_RATE));
            cha.getStat().addFuncs(FuncMultRegenResting.getFunc(Stats.REGENERATE_MP_RATE));
            cha.getStat().addFuncs(FuncMultRegenStanding.getFunc(Stats.REGENERATE_MP_RATE));
            cha.getStat().addFuncs(FuncMultRegenRunning.getFunc(Stats.REGENERATE_MP_RATE));
            cha.getStat().addFuncs(FuncHennaSTR.func);
            cha.getStat().addFuncs(FuncHennaDEX.func);
            cha.getStat().addFuncs(FuncHennaINT.func);
            cha.getStat().addFuncs(FuncHennaMEN.func);
            cha.getStat().addFuncs(FuncHennaCON.func);
            cha.getStat().addFuncs(FuncHennaWIT.func);
            cha.getStat().addFuncs(FuncInventory.func);
            cha.getStat().addFuncs(FuncWarehouse.func);
            cha.getStat().addFuncs(FuncTradeLimit.func);
            cha.getStat().addFuncs(FuncSDefPlayers.func);
            cha.getStat().addFuncs(FuncMaxHpLimit.func);
            cha.getStat().addFuncs(FuncMaxMpLimit.func);
            cha.getStat().addFuncs(FuncMaxCpLimit.func);
            cha.getStat().addFuncs(FuncRunSpdLimit.func);
            cha.getStat().addFuncs(FuncRunSpdLimit.func);
            cha.getStat().addFuncs(FuncPDefLimit.func);
            cha.getStat().addFuncs(FuncMDefLimit.func);
            cha.getStat().addFuncs(FuncPAtkLimit.func);
            cha.getStat().addFuncs(FuncMAtkLimit.func);
            cha.getStat().addFuncs(FuncMaxLoadMul.func);
            cha.getStat().addFuncs(FuncBreathMul.func);
            cha.getStat().addFuncs(FuncCpRegenMul.func);
            cha.getStat().addFuncs(FuncPAtkSpeedPenalty.func);
            cha.getStat().addFuncs(FuncMaxCpMul.func);
        }
        cha.getStat().addFuncs(FuncRunSpeedMul.func);
        cha.getStat().addFuncs(FuncMaxHpMul.func);
        cha.getStat().addFuncs(FuncMaxMpMul.func);
        cha.getStat().addFuncs(FuncHpRegenMul.func);
        cha.getStat().addFuncs(FuncMpRegenMul.func);
        if (cha.isPet()) {
            cha.getStat().addFuncs(FuncMpRegenPenalty.func);
            cha.getStat().addFuncs(FuncHpRegenPenalty.func);
        }
        if (cha.isPlayer() || cha.isPet()) {
            cha.getStat().addFuncs(FuncMoveSpeedPenalty.func);
        }
        cha.getStat().addFuncs(FuncPAtkMul.func);
        cha.getStat().addFuncs(FuncMAtkMul.func);
        cha.getStat().addFuncs(FuncPDefMul.func);
        cha.getStat().addFuncs(FuncMDefMul.func);
        if (cha.isSummon()) {
            cha.getStat().addFuncs(FuncAttributeAttackSet.getFunc(Element.FIRE));
            cha.getStat().addFuncs(FuncAttributeAttackSet.getFunc(Element.WATER));
            cha.getStat().addFuncs(FuncAttributeAttackSet.getFunc(Element.EARTH));
            cha.getStat().addFuncs(FuncAttributeAttackSet.getFunc(Element.WIND));
            cha.getStat().addFuncs(FuncAttributeAttackSet.getFunc(Element.HOLY));
            cha.getStat().addFuncs(FuncAttributeAttackSet.getFunc(Element.UNHOLY));
            cha.getStat().addFuncs(FuncAttributeDefenceSet.getFunc(Element.FIRE));
            cha.getStat().addFuncs(FuncAttributeDefenceSet.getFunc(Element.WATER));
            cha.getStat().addFuncs(FuncAttributeDefenceSet.getFunc(Element.EARTH));
            cha.getStat().addFuncs(FuncAttributeDefenceSet.getFunc(Element.WIND));
            cha.getStat().addFuncs(FuncAttributeDefenceSet.getFunc(Element.HOLY));
            cha.getStat().addFuncs(FuncAttributeDefenceSet.getFunc(Element.UNHOLY));
        }
        cha.getStat().addFuncs(FuncPAccuracyAdd.func);
        cha.getStat().addFuncs(FuncMAccuracyAdd.func);
        cha.getStat().addFuncs(FuncPEvasionAdd.func);
        cha.getStat().addFuncs(FuncMEvasionAdd.func);
        cha.getStat().addFuncs(FuncPAtkSpeedMul.func);
        cha.getStat().addFuncs(FuncMAtkSpeedMul.func);
        cha.getStat().addFuncs(FuncSDefInit.func);
        cha.getStat().addFuncs(FuncSDefAll.func);
        cha.getStat().addFuncs(FuncPAtkSpdLimit.func);
        cha.getStat().addFuncs(FuncMAtkSpdLimit.func);
        cha.getStat().addFuncs(FuncCAtkLimit.func);
        cha.getStat().addFuncs(FuncPEvasionLimit.func);
        cha.getStat().addFuncs(FuncMEvasionLimit.func);
        cha.getStat().addFuncs(FuncPAccuracyLimit.func);
        cha.getStat().addFuncs(FuncMAccuracyLimit.func);
        cha.getStat().addFuncs(FuncPCritLimit.func);
        cha.getStat().addFuncs(FuncMCritLimit.func);
        cha.getStat().addFuncs(FuncMCriticalRateMul.func);
        cha.getStat().addFuncs(FuncPCriticalRateMul.func);
        cha.getStat().addFuncs(FuncPDamageResists.func);
        cha.getStat().addFuncs(FuncMDamageResists.func);
        cha.getStat().addFuncs(FuncAttributeAttackInit.getFunc(Element.FIRE));
        cha.getStat().addFuncs(FuncAttributeAttackInit.getFunc(Element.WATER));
        cha.getStat().addFuncs(FuncAttributeAttackInit.getFunc(Element.EARTH));
        cha.getStat().addFuncs(FuncAttributeAttackInit.getFunc(Element.WIND));
        cha.getStat().addFuncs(FuncAttributeAttackInit.getFunc(Element.HOLY));
        cha.getStat().addFuncs(FuncAttributeAttackInit.getFunc(Element.UNHOLY));
        cha.getStat().addFuncs(FuncAttributeDefenceInit.getFunc(Element.FIRE));
        cha.getStat().addFuncs(FuncAttributeDefenceInit.getFunc(Element.WATER));
        cha.getStat().addFuncs(FuncAttributeDefenceInit.getFunc(Element.EARTH));
        cha.getStat().addFuncs(FuncAttributeDefenceInit.getFunc(Element.WIND));
        cha.getStat().addFuncs(FuncAttributeDefenceInit.getFunc(Element.HOLY));
        cha.getStat().addFuncs(FuncAttributeDefenceInit.getFunc(Element.UNHOLY));
    }

    private static class FuncPAtkSpeedPenalty
    extends Func {
        static final FuncPAtkSpeedPenalty func = new FuncPAtkSpeedPenalty();

        private FuncPAtkSpeedPenalty() {
            super(Stats.POWER_ATTACK_SPEED, 256, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            Player player;
            if (env.character.isPlayer() && (player = env.character.getPlayer()).isMounted() && player.getMount().isHungry()) {
                env.value *= 0.5;
            }
        }
    }

    private static class FuncMoveSpeedPenalty
    extends Func {
        static final FuncMoveSpeedPenalty func = new FuncMoveSpeedPenalty();

        private FuncMoveSpeedPenalty() {
            super(Stats.RUN_SPEED, 256, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            PetInstance pet;
            if (env.character.isPlayer()) {
                Mount mount;
                Player player = env.character.getPlayer();
                if (player.isMounted() && ((mount = player.getMount()).isHungry() || mount.getLevel() - player.getLevel() >= 10)) {
                    env.value *= 0.5;
                }
            } else if (env.character.isPet() && ((pet = (PetInstance)env.character).isHungry() || pet.getWeightPenalty() >= 2)) {
                env.value *= 0.5;
            }
        }
    }

    private static class FuncMpRegenPenalty
    extends Func {
        static final FuncMpRegenPenalty func = new FuncMpRegenPenalty();

        private FuncMpRegenPenalty() {
            super(Stats.REGENERATE_MP_RATE, 256, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            if (env.character.isPet()) {
                PetInstance pet = (PetInstance)env.character;
                if (pet.getWeightPenalty() == 1 || pet.getWeightPenalty() == 2) {
                    env.value *= 0.5;
                } else if (pet.getWeightPenalty() == 3) {
                    env.value = 0.0;
                }
            }
        }
    }

    private static class FuncHpRegenPenalty
    extends Func {
        static final FuncHpRegenPenalty func = new FuncHpRegenPenalty();

        private FuncHpRegenPenalty() {
            super(Stats.REGENERATE_HP_RATE, 256, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            if (env.character.isPet()) {
                PetInstance pet = (PetInstance)env.character;
                if (pet.getWeightPenalty() == 1 || pet.getWeightPenalty() == 2) {
                    env.value *= 0.5;
                } else if (pet.getWeightPenalty() == 3) {
                    env.value = 0.0;
                }
            }
        }
    }

    private static class FuncCpRegenMul
    extends Func {
        static final FuncCpRegenMul func = new FuncCpRegenMul();

        private FuncCpRegenMul() {
            super(Stats.REGENERATE_CP_RATE, 16, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            env.value *= BaseStats.CON.calcBonus(env.character);
        }
    }

    private static class FuncMpRegenMul
    extends Func {
        static final FuncMpRegenMul func = new FuncMpRegenMul();

        private FuncMpRegenMul() {
            super(Stats.REGENERATE_MP_RATE, 16, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            env.value *= BaseStats.MEN.calcBonus(env.character);
            if (env.character.isSummon()) {
                env.value *= 2.0;
            }
        }
    }

    private static class FuncHpRegenMul
    extends Func {
        static final FuncHpRegenMul func = new FuncHpRegenMul();

        private FuncHpRegenMul() {
            super(Stats.REGENERATE_HP_RATE, 16, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            env.value *= BaseStats.CON.calcBonus(env.character);
            if (env.character.isSummon()) {
                env.value *= 2.0;
            }
        }
    }

    private static class FuncBreathMul
    extends Func {
        static final FuncBreathMul func = new FuncBreathMul();

        private FuncBreathMul() {
            super(Stats.BREATH, 16, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            env.value *= BaseStats.CON.calcBonus(env.character);
        }
    }

    private static class FuncMaxLoadMul
    extends Func {
        static final FuncMaxLoadMul func = new FuncMaxLoadMul();

        private FuncMaxLoadMul() {
            super(Stats.MAX_LOAD, 16, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            env.value *= BaseStats.CON.calcBonus(env.character) * Config.MAXLOAD_MODIFIER;
        }
    }

    private static class FuncAttributeDefenceSet
    extends Func {
        static final Func[] func = new FuncAttributeDefenceSet[Element.VALUES.length];

        static Func getFunc(Element element) {
            return func[element.getId()];
        }

        private FuncAttributeDefenceSet(Stats stat) {
            super(stat, 16, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            if (env.character.getPlayer().getClassId().getType2() == ClassType2.SUMMONER) {
                env.value = env.character.getPlayer().getStat().calc(this.stat, 0.0);
            }
        }

        static {
            for (int i = 0; i < Element.VALUES.length; ++i) {
                FuncAttributeDefenceSet.func[i] = new FuncAttributeDefenceSet(Element.VALUES[i].getDefence());
            }
        }
    }

    private static class FuncAttributeAttackSet
    extends Func {
        static final Func[] func = new FuncAttributeAttackSet[Element.VALUES.length];

        static Func getFunc(Element element) {
            return func[element.getId()];
        }

        private FuncAttributeAttackSet(Stats stat) {
            super(stat, 16, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            if (env.character.getPlayer().getClassId().getType2() == ClassType2.SUMMONER) {
                env.value = env.character.getPlayer().getStat().calc(this.stat, 0.0);
            }
        }

        static {
            for (int i = 0; i < Element.VALUES.length; ++i) {
                FuncAttributeAttackSet.func[i] = new FuncAttributeAttackSet(Element.VALUES[i].getAttack());
            }
        }
    }

    private static class FuncAttributeDefenceInit
    extends Func {
        static final Func[] func = new FuncAttributeDefenceInit[Element.VALUES.length];
        private Element element;

        static Func getFunc(Element element) {
            return func[element.getId()];
        }

        private FuncAttributeDefenceInit(Element element) {
            super(element.getDefence(), 1, null);
            this.element = element;
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            env.value += (double)env.character.getBaseStats().getAttributeDefence()[this.element.getId()];
        }

        static {
            for (int i = 0; i < Element.VALUES.length; ++i) {
                FuncAttributeDefenceInit.func[i] = new FuncAttributeDefenceInit(Element.VALUES[i]);
            }
        }
    }

    private static class FuncAttributeAttackInit
    extends Func {
        static final Func[] func = new FuncAttributeAttackInit[Element.VALUES.length];
        private Element element;

        static Func getFunc(Element element) {
            return func[element.getId()];
        }

        private FuncAttributeAttackInit(Element element) {
            super(element.getAttack(), 1, null);
            this.element = element;
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            env.value += (double)env.character.getBaseStats().getAttributeAttack()[this.element.getId()];
        }

        static {
            for (int i = 0; i < Element.VALUES.length; ++i) {
                FuncAttributeAttackInit.func[i] = new FuncAttributeAttackInit(Element.VALUES[i]);
            }
        }
    }

    private static class FuncMCritLimit
    extends Func {
        static final Func func = new FuncMCritLimit();

        private FuncMCritLimit() {
            super(Stats.BASE_M_CRITICAL_RATE, 256, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            if (Config.LIM_MCRIT > 0) {
                env.value = Math.min((double)Config.LIM_MCRIT, env.value);
            }
        }
    }

    private static class FuncPCritLimit
    extends Func {
        static final Func func = new FuncPCritLimit();

        private FuncPCritLimit() {
            super(Stats.BASE_P_CRITICAL_RATE, 256, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            if (Config.LIM_CRIT > 0) {
                env.value = Math.min(env.character.getStat().calc(Stats.P_CRIT_RATE_LIMIT, Config.LIM_CRIT), env.value);
            }
        }
    }

    private static class FuncMAccuracyLimit
    extends Func {
        static final Func func = new FuncMAccuracyLimit();

        private FuncMAccuracyLimit() {
            super(Stats.M_ACCURACY_COMBAT, 256, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            if (Config.LIM_ACCURACY > 0) {
                env.value = Math.min((double)Config.LIM_ACCURACY, env.value);
            }
        }
    }

    private static class FuncPAccuracyLimit
    extends Func {
        static final Func func = new FuncPAccuracyLimit();

        private FuncPAccuracyLimit() {
            super(Stats.P_ACCURACY_COMBAT, 256, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            if (Config.LIM_ACCURACY > 0) {
                env.value = Math.min((double)Config.LIM_ACCURACY, env.value);
            }
        }
    }

    private static class FuncMEvasionLimit
    extends Func {
        static final Func func = new FuncMEvasionLimit();

        private FuncMEvasionLimit() {
            super(Stats.M_EVASION_RATE, 256, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            if (Config.LIM_EVASION > 0) {
                env.value = Math.min((double)Config.LIM_EVASION, env.value);
            }
        }
    }

    private static class FuncPEvasionLimit
    extends Func {
        static final Func func = new FuncPEvasionLimit();

        private FuncPEvasionLimit() {
            super(Stats.P_EVASION_RATE, 256, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            if (Config.LIM_EVASION > 0) {
                env.value = Math.min((double)Config.LIM_EVASION, env.value);
            }
        }
    }

    private static class FuncCAtkLimit
    extends Func {
        static final Func func = new FuncCAtkLimit();

        private FuncCAtkLimit() {
            super(Stats.CRITICAL_DAMAGE, 256, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            if (Config.LIM_CRIT_DAM > 0) {
                env.value = Math.min((double)Config.LIM_CRIT_DAM / 2.0, env.value);
            }
        }
    }

    private static class FuncMAtkSpdLimit
    extends Func {
        static final Func func = new FuncMAtkSpdLimit();

        private FuncMAtkSpdLimit() {
            super(Stats.MAGIC_ATTACK_SPEED, 256, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            if (Config.LIM_MATK_SPD > 0) {
                env.value = Math.min((double)Config.LIM_MATK_SPD, env.value);
            }
        }
    }

    private static class FuncPAtkSpdLimit
    extends Func {
        static final Func func = new FuncPAtkSpdLimit();

        private FuncPAtkSpdLimit() {
            super(Stats.POWER_ATTACK_SPEED, 256, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            if (Config.LIM_PATK_SPD > 0) {
                env.value = Math.min((double)Config.LIM_PATK_SPD, env.value);
            }
        }
    }

    private static class FuncMAtkLimit
    extends Func {
        static final Func func = new FuncMAtkLimit();

        private FuncMAtkLimit() {
            super(Stats.MAGIC_ATTACK, 256, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            if (Config.LIM_MATK > 0) {
                env.value = Math.min((double)Config.LIM_MATK, env.value);
            }
        }
    }

    private static class FuncPAtkLimit
    extends Func {
        static final Func func = new FuncPAtkLimit();

        private FuncPAtkLimit() {
            super(Stats.POWER_ATTACK, 256, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            if (Config.LIM_PATK > 0) {
                env.value = Math.min((double)Config.LIM_PATK, env.value);
            }
        }
    }

    private static class FuncMDefLimit
    extends Func {
        static final Func func = new FuncMDefLimit();

        private FuncMDefLimit() {
            super(Stats.MAGIC_DEFENCE, 256, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            if (Config.LIM_MDEF > 0) {
                env.value = Math.min((double)Config.LIM_MDEF, env.value);
            }
        }
    }

    private static class FuncPDefLimit
    extends Func {
        static final Func func = new FuncPDefLimit();

        private FuncPDefLimit() {
            super(Stats.POWER_DEFENCE, 256, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            if (Config.LIM_PDEF > 0) {
                env.value = Math.min((double)Config.LIM_PDEF, env.value);
            }
        }
    }

    private static class FuncRunSpdLimit
    extends Func {
        static final Func func = new FuncRunSpdLimit();

        private FuncRunSpdLimit() {
            super(Stats.RUN_SPEED, 256, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            if (Config.LIM_MOVE > 0) {
                env.value = Math.min((double)Config.LIM_MOVE, env.value);
            }
        }
    }

    private static class FuncMaxCpLimit
    extends Func {
        static final Func func = new FuncMaxCpLimit();

        private FuncMaxCpLimit() {
            super(Stats.MAX_CP, 256, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            if (Config.CP_LIMIT > 0) {
                env.value = Math.min(env.character.getStat().calc(Stats.PLAYER_MAX_CP_LIMIT, Config.CP_LIMIT), env.value);
            }
        }
    }

    private static class FuncMaxMpLimit
    extends Func {
        static final Func func = new FuncMaxMpLimit();

        private FuncMaxMpLimit() {
            super(Stats.MAX_MP, 256, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            if (Config.MP_LIMIT > 0) {
                env.value = Math.min(env.character.getStat().calc(Stats.PLAYER_MAX_MP_LIMIT, Config.MP_LIMIT), env.value);
            }
        }
    }

    private static class FuncMaxHpLimit
    extends Func {
        static final Func func = new FuncMaxHpLimit();

        private FuncMaxHpLimit() {
            super(Stats.MAX_HP, 256, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            if (Config.HP_LIMIT > 0) {
                env.value = Math.min(env.character.getStat().calc(Stats.PLAYER_MAX_HP_LIMIT, Config.HP_LIMIT), env.value);
            }
        }
    }

    private static class FuncRunSpeedMul
    extends Func {
        static final FuncRunSpeedMul func = new FuncRunSpeedMul();

        private FuncRunSpeedMul() {
            super(Stats.RUN_SPEED, 32, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            int gmSpeed;
            if (env.character.getStat().calc(Stats.SPEED_ON_DEX_DEPENDENCE) > 0.0) {
                env.value *= BaseStats.DEX.calcBonus(env.character);
            }
            if ((gmSpeed = env.character.getGmSpeed()) > 0) {
                double baseSpeed = env.character.isRunning() ? (env.character.isMounted() ? env.character.getBaseStats().getRideRunSpd() : (env.character.isFlying() ? env.character.getBaseStats().getFlyRunSpd() : (env.character.isInWater() ? env.character.getBaseStats().getWaterRunSpd() : env.character.getBaseStats().getRunSpd()))) : (env.character.isMounted() ? env.character.getBaseStats().getRideWalkSpd() : (env.character.isFlying() ? env.character.getBaseStats().getFlyWalkSpd() : (env.character.isInWater() ? env.character.getBaseStats().getWaterWalkSpd() : env.character.getBaseStats().getWalkSpd())));
                env.value += baseSpeed * (double)gmSpeed;
            }
        }
    }

    private static class FuncSDefPlayers
    extends Func {
        static final FuncSDefPlayers func = new FuncSDefPlayers();

        private FuncSDefPlayers() {
            super(Stats.SHIELD_RATE, 32, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            if (env.value == 0.0) {
                return;
            }
            Creature cha = env.character;
            ItemInstance shld = ((Player)cha).getInventory().getPaperdollItem(8);
            if (shld == null || shld.getItemType() != WeaponTemplate.WeaponType.NONE) {
                return;
            }
            env.value *= BaseStats.CON.calcBonus(env.character);
        }
    }

    private static class FuncSDefAll
    extends Func {
        static final FuncSDefAll func = new FuncSDefAll();

        private FuncSDefAll() {
            super(Stats.SHIELD_RATE, 32, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            if (env.value == 0.0) {
                return;
            }
            Creature target = env.target;
            if (target != null) {
                switch (target.getBaseStats().getAttackType()) {
                    case BOW: 
                    case CROSSBOW: 
                    case TWOHANDCROSSBOW: {
                        env.value += 30.0;
                        break;
                    }
                    case DAGGER: 
                    case DUALDAGGER: {
                        env.value += 12.0;
                    }
                }
            }
        }
    }

    private static class FuncSDefInit
    extends Func {
        static final Func func = new FuncSDefInit();

        private FuncSDefInit() {
            super(Stats.SHIELD_RATE, 1, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            Creature cha = env.character;
            env.value = cha.getBaseStats().getShldRate();
        }
    }

    private static class FuncTradeLimit
    extends Func {
        static final FuncTradeLimit func = new FuncTradeLimit();

        private FuncTradeLimit() {
            super(Stats.TRADE_LIMIT, 1, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            Player _cha = (Player)env.character;
            env.value = _cha.getRace() == Race.DWARF ? (double)Config.MAX_PVTSTORE_SLOTS_DWARF : (double)Config.MAX_PVTSTORE_SLOTS_OTHER;
        }
    }

    private static class FuncWarehouse
    extends Func {
        static final FuncWarehouse func = new FuncWarehouse();

        private FuncWarehouse() {
            super(Stats.STORAGE_LIMIT, 1, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            Player player = (Player)env.character;
            env.value = player.getRace() == Race.DWARF ? (double)Config.WAREHOUSE_SLOTS_DWARF : (double)Config.WAREHOUSE_SLOTS_NO_DWARF;
            env.value += (double)player.getExpandWarehouse();
        }
    }

    private static class FuncInventory
    extends Func {
        static final FuncInventory func = new FuncInventory();

        private FuncInventory() {
            super(Stats.INVENTORY_LIMIT, 1, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            Player player = (Player)env.character;
            env.value = player.isGM() ? (double)Config.INVENTORY_MAXIMUM_GM : (player.getRace() == Race.DWARF ? (double)Config.INVENTORY_MAXIMUM_DWARF : (double)Config.INVENTORY_MAXIMUM_NO_DWARF);
            env.value += (double)player.getExpandInventory();
            env.value = Math.min(env.value, (double)Config.SERVICES_EXPAND_INVENTORY_MAX);
        }
    }

    private static class FuncMDamageResists
    extends Func {
        static final FuncMDamageResists func = new FuncMDamageResists();

        private FuncMDamageResists() {
            super(Stats.INFLICTS_M_DAMAGE_POWER, 48, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            if (env.target.isRaid() && !env.target.isArenaRaid() && Math.abs(env.character.getLevel() - env.target.getLevel()) > Config.RAID_MAX_LEVEL_DIFF) {
                env.value = 1.0;
                return;
            }
            env.value = Formulas.calcDamageResists(env.skill, env.character, env.target, env.value);
        }
    }

    private static class FuncPDamageResists
    extends Func {
        static final FuncPDamageResists func = new FuncPDamageResists();

        private FuncPDamageResists() {
            super(Stats.INFLICTS_P_DAMAGE_POWER, 48, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            if (env.target.isRaid() && !env.target.isArenaRaid() && env.character.getLevel() - env.target.getLevel() > Config.RAID_MAX_LEVEL_DIFF) {
                env.value = 1.0;
                return;
            }
            env.value = Formulas.calcDamageResists(env.skill, env.character, env.target, env.value);
        }
    }

    private static class FuncMaxMpMul
    extends Func {
        static final FuncMaxMpMul func = new FuncMaxMpMul();

        private FuncMaxMpMul() {
            super(Stats.MAX_MP, 32, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            env.value *= BaseStats.MEN.calcBonus(env.character);
        }
    }

    private static class FuncMaxCpMul
    extends Func {
        static final FuncMaxCpMul func = new FuncMaxCpMul();

        private FuncMaxCpMul() {
            super(Stats.MAX_CP, 32, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            env.value *= BaseStats.CON.calcBonus(env.character);
        }
    }

    private static class FuncMaxHpMul
    extends Func {
        static final FuncMaxHpMul func = new FuncMaxHpMul();

        private FuncMaxHpMul() {
            super(Stats.MAX_HP, 32, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            env.value *= BaseStats.CON.calcBonus(env.character);
        }
    }

    private static class FuncHennaWIT
    extends Func {
        static final FuncHennaWIT func = new FuncHennaWIT();

        private FuncHennaWIT() {
            super(Stats.STAT_WIT, 16, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            Player pc = (Player)env.character;
            if (pc != null) {
                env.value = Math.max(1.0, env.value + (double)pc.getHennaList().getWIT());
            }
        }
    }

    private static class FuncHennaCON
    extends Func {
        static final FuncHennaCON func = new FuncHennaCON();

        private FuncHennaCON() {
            super(Stats.STAT_CON, 16, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            Player pc = (Player)env.character;
            if (pc != null) {
                env.value = Math.max(1.0, env.value + (double)pc.getHennaList().getCON());
            }
        }
    }

    private static class FuncHennaMEN
    extends Func {
        static final FuncHennaMEN func = new FuncHennaMEN();

        private FuncHennaMEN() {
            super(Stats.STAT_MEN, 16, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            Player pc = (Player)env.character;
            if (pc != null) {
                env.value = Math.max(1.0, env.value + (double)pc.getHennaList().getMEN());
            }
        }
    }

    private static class FuncHennaINT
    extends Func {
        static final FuncHennaINT func = new FuncHennaINT();

        private FuncHennaINT() {
            super(Stats.STAT_INT, 16, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            Player pc = (Player)env.character;
            if (pc != null) {
                env.value = Math.max(1.0, env.value + (double)pc.getHennaList().getINT());
            }
        }
    }

    private static class FuncHennaDEX
    extends Func {
        static final FuncHennaDEX func = new FuncHennaDEX();

        private FuncHennaDEX() {
            super(Stats.STAT_DEX, 16, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            Player pc = (Player)env.character;
            if (pc != null) {
                env.value = Math.max(1.0, env.value + (double)pc.getHennaList().getDEX());
            }
        }
    }

    private static class FuncHennaSTR
    extends Func {
        static final FuncHennaSTR func = new FuncHennaSTR();

        private FuncHennaSTR() {
            super(Stats.STAT_STR, 16, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            Player pc = (Player)env.character;
            if (pc != null) {
                env.value = Math.max(1.0, env.value + (double)pc.getHennaList().getSTR());
            }
        }
    }

    private static class FuncMAtkSpeedMul
    extends Func {
        static final FuncMAtkSpeedMul func = new FuncMAtkSpeedMul();

        private FuncMAtkSpeedMul() {
            super(Stats.MAGIC_ATTACK_SPEED, 32, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            env.value *= BaseStats.WIT.calcBonus(env.character);
        }
    }

    private static class FuncPAtkSpeedMul
    extends Func {
        static final FuncPAtkSpeedMul func = new FuncPAtkSpeedMul();

        private FuncPAtkSpeedMul() {
            super(Stats.POWER_ATTACK_SPEED, 32, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            env.value *= BaseStats.DEX.calcBonus(env.character);
        }
    }

    private static class FuncMCriticalRateMul
    extends Func {
        static final FuncMCriticalRateMul func = new FuncMCriticalRateMul();

        private FuncMCriticalRateMul() {
            super(Stats.BASE_M_CRITICAL_RATE, 16, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            env.value *= BaseStats.WIT.calcBonus(env.character);
            env.value *= 0.01 * env.character.getStat().calc(Stats.M_CRITICAL_RATE, env.target, env.skill);
        }
    }

    private static class FuncPCriticalRateMul
    extends Func {
        static final FuncPCriticalRateMul func = new FuncPCriticalRateMul();

        private FuncPCriticalRateMul() {
            super(Stats.BASE_P_CRITICAL_RATE, 16, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            env.value *= BaseStats.DEX.calcBonus(env.character);
            env.value *= 0.01 * env.character.getStat().calc(Stats.P_CRITICAL_RATE, env.target, env.skill);
        }
    }

    private static class FuncMEvasionAdd
    extends Func {
        static final FuncMEvasionAdd func = new FuncMEvasionAdd();

        private FuncMEvasionAdd() {
            super(Stats.M_EVASION_RATE, 16, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            env.value += Math.sqrt(env.character.getWIT()) * 3.0 + (double)(env.character.getLevel() * 2);
        }
    }

    private static class FuncPEvasionAdd
    extends Func {
        static final FuncPEvasionAdd func = new FuncPEvasionAdd();

        private FuncPEvasionAdd() {
            super(Stats.P_EVASION_RATE, 16, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            env.value += Math.sqrt(env.character.getDEX()) * 5.0 + (double)env.character.getLevel();
            int level = env.character.getLevel();
            if (level > 69) {
                env.value += (double)level - 69.0;
            }
            if (level > 77) {
                env.value += 1.0;
            }
            if (level > 80) {
                env.value += 2.0;
            }
            if (level > 87) {
                env.value += 1.0;
            }
            if (level > 92) {
                env.value += 1.0;
            }
            if (level > 97) {
                env.value += 1.0;
            }
        }
    }

    private static class FuncMAccuracyAdd
    extends Func {
        static final FuncMAccuracyAdd func = new FuncMAccuracyAdd();

        private FuncMAccuracyAdd() {
            super(Stats.M_ACCURACY_COMBAT, 16, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            env.value += Math.sqrt(env.character.getWIT()) * 3.0 + (double)(env.character.getLevel() * 2);
        }
    }

    private static class FuncPAccuracyAdd
    extends Func {
        static final FuncPAccuracyAdd func = new FuncPAccuracyAdd();

        private FuncPAccuracyAdd() {
            super(Stats.P_ACCURACY_COMBAT, 16, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            int level;
            env.value += Math.sqrt(env.character.getDEX()) * 5.0 + (double)env.character.getLevel();
            if (env.character.isServitor()) {
                env.value = env.value + (env.character.getLevel() < 60 ? 4.0 : 5.0);
            }
            if ((level = env.character.getLevel()) > 69) {
                env.value += (double)level - 69.0;
            }
            if (level > 77) {
                env.value += 1.0;
            }
            if (level > 80) {
                env.value += 2.0;
            }
            if (level > 87) {
                env.value += 1.0;
            }
            if (level > 92) {
                env.value += 1.0;
            }
            if (level > 97) {
                env.value += 1.0;
            }
        }
    }

    private static class FuncMDefMul
    extends Func {
        static final FuncMDefMul func = new FuncMDefMul();

        private FuncMDefMul() {
            super(Stats.MAGIC_DEFENCE, 32, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            env.value *= BaseStats.MEN.calcBonus(env.character) * env.character.getLevelBonus();
        }
    }

    private static class FuncPDefMul
    extends Func {
        static final FuncPDefMul func = new FuncPDefMul();

        private FuncPDefMul() {
            super(Stats.POWER_DEFENCE, 32, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            env.value *= env.character.getLevelBonus();
        }
    }

    private static class FuncMAtkMul
    extends Func {
        static final FuncMAtkMul func = new FuncMAtkMul();

        private FuncMAtkMul() {
            super(Stats.MAGIC_ATTACK, 32, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            double ib = BaseStats.INT.calcBonus(env.character);
            double lvlb = env.character.getLevelBonus();
            env.value *= lvlb * lvlb * ib * ib;
        }
    }

    private static class FuncPAtkMul
    extends Func {
        static final FuncPAtkMul func = new FuncPAtkMul();

        private FuncPAtkMul() {
            super(Stats.POWER_ATTACK, 32, null);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            env.value *= BaseStats.STR.calcBonus(env.character) * env.character.getLevelBonus();
        }
    }

    private static class FuncMultRegenRunning
    extends Func {
        static final FuncMultRegenRunning[] func = new FuncMultRegenRunning[Stats.NUM_STATS];

        static Func getFunc(Stats stat) {
            int pos = stat.ordinal();
            if (func[pos] == null) {
                FuncMultRegenRunning.func[pos] = new FuncMultRegenRunning(stat);
            }
            return func[pos];
        }

        private FuncMultRegenRunning(Stats stat) {
            super(stat, 48, null);
            this.setCondition(new ConditionPlayerState(ConditionPlayerState.CheckPlayerState.RUNNING, true));
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            env.value *= 0.7;
        }
    }

    private static class FuncMultRegenStanding
    extends Func {
        static final FuncMultRegenStanding[] func = new FuncMultRegenStanding[Stats.NUM_STATS];

        static Func getFunc(Stats stat) {
            int pos = stat.ordinal();
            if (func[pos] == null) {
                FuncMultRegenStanding.func[pos] = new FuncMultRegenStanding(stat);
            }
            return func[pos];
        }

        private FuncMultRegenStanding(Stats stat) {
            super(stat, 48, null);
            this.setCondition(new ConditionPlayerState(ConditionPlayerState.CheckPlayerState.STANDING, true));
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            env.value *= 1.1;
        }
    }

    private static class FuncMultRegenResting
    extends Func {
        static final FuncMultRegenResting[] func = new FuncMultRegenResting[Stats.NUM_STATS];

        static Func getFunc(Stats stat) {
            int pos = stat.ordinal();
            if (func[pos] == null) {
                FuncMultRegenResting.func[pos] = new FuncMultRegenResting(stat);
            }
            return func[pos];
        }

        private FuncMultRegenResting(Stats stat) {
            super(stat, 48, null);
            this.setCondition(new ConditionPlayerState(ConditionPlayerState.CheckPlayerState.RESTING, true));
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            env.value = env.character.isPlayer() && env.character.getLevel() <= 40 && ((Player)env.character).getClassLevel().ordinal() < ClassLevel.SECOND.ordinal() && this.stat == Stats.REGENERATE_HP_RATE ? (env.value *= 6.0) : (env.value *= 1.5);
        }
    }
}


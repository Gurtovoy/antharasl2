/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.base;

import l2s.gameserver.data.xml.holder.BaseStatsBonusHolder;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.templates.BaseStatsBonus;

public enum BaseStats {
    STR{

        @Override
        public final int getStat(Creature actor) {
            return actor == null ? 1 : actor.getSTR();
        }
    }
    ,
    INT{

        @Override
        public final int getStat(Creature actor) {
            return actor == null ? 1 : actor.getINT();
        }
    }
    ,
    DEX{

        @Override
        public final int getStat(Creature actor) {
            return actor == null ? 1 : actor.getDEX();
        }
    }
    ,
    WIT{

        @Override
        public final int getStat(Creature actor) {
            return actor == null ? 1 : actor.getWIT();
        }
    }
    ,
    CON{

        @Override
        public final int getStat(Creature actor) {
            return actor == null ? 1 : actor.getCON();
        }
    }
    ,
    MEN{

        @Override
        public final int getStat(Creature actor) {
            return actor == null ? 1 : actor.getMEN();
        }
    }
    ,
    NONE;

    public static final BaseStats[] VALUES;
    public static final int MAX_STAT_VALUE = 100;

    public int getStat(Creature actor) {
        return 1;
    }

    public double calcBonus(Creature actor) {
        Player player;
        if (actor == null) {
            return 1.0;
        }
        int value = this.getStat(actor);
        if (actor.isPlayer() && (player = actor.getPlayer()).isTransformed() && player.getTransform().getBaseStatBonus(value, this) != 0.0) {
            return player.getTransform().getBaseStatBonus(value, this);
        }
        BaseStatsBonus bonus = BaseStatsBonusHolder.getInstance().getBaseStatsBonus(value);
        if (bonus == null) {
            return 1.0;
        }
        return bonus.get(this);
    }

    static {
        VALUES = BaseStats.values();
    }
}


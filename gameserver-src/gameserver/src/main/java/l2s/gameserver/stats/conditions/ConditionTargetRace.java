/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.Creature;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;
import l2s.gameserver.templates.npc.NpcTemplate;

public class ConditionTargetRace
extends Condition {
    private final int _race;

    public ConditionTargetRace(String race) {
        if (race.equalsIgnoreCase("Undead")) {
            this._race = 1;
        } else if (race.equalsIgnoreCase("MagicCreatures")) {
            this._race = 2;
        } else if (race.equalsIgnoreCase("Beasts")) {
            this._race = 3;
        } else if (race.equalsIgnoreCase("Animals")) {
            this._race = 4;
        } else if (race.equalsIgnoreCase("Plants")) {
            this._race = 5;
        } else if (race.equalsIgnoreCase("Humanoids")) {
            this._race = 6;
        } else if (race.equalsIgnoreCase("Spirits")) {
            this._race = 7;
        } else if (race.equalsIgnoreCase("Angels")) {
            this._race = 8;
        } else if (race.equalsIgnoreCase("Demons")) {
            this._race = 9;
        } else if (race.equalsIgnoreCase("Dragons")) {
            this._race = 10;
        } else if (race.equalsIgnoreCase("Giants")) {
            this._race = 11;
        } else if (race.equalsIgnoreCase("Bugs")) {
            this._race = 12;
        } else if (race.equalsIgnoreCase("Fairies")) {
            this._race = 13;
        } else if (race.equalsIgnoreCase("Humans")) {
            this._race = 14;
        } else if (race.equalsIgnoreCase("Elves")) {
            this._race = 15;
        } else if (race.equalsIgnoreCase("DarkElves")) {
            this._race = 16;
        } else if (race.equalsIgnoreCase("Orcs")) {
            this._race = 17;
        } else if (race.equalsIgnoreCase("Dwarves")) {
            this._race = 18;
        } else if (race.equalsIgnoreCase("Others")) {
            this._race = 19;
        } else if (race.equalsIgnoreCase("NonLivingBeings")) {
            this._race = 20;
        } else if (race.equalsIgnoreCase("SiegeWeapons")) {
            this._race = 21;
        } else if (race.equalsIgnoreCase("DefendingArmy")) {
            this._race = 22;
        } else if (race.equalsIgnoreCase("Mercenaries")) {
            this._race = 23;
        } else if (race.equalsIgnoreCase("UnknownCreature")) {
            this._race = 24;
        } else if (race.equalsIgnoreCase("Kamael")) {
            this._race = 25;
        } else {
            throw new IllegalArgumentException("ConditionTargetRace: Invalid race name: " + race);
        }
    }

    @Override
    protected boolean testImpl(Env env) {
        Creature target = env.target;
        return target != null && target.getTemplate() != null && (target.isSummon() || target.isNpc()) && this._race == ((NpcTemplate)target.getTemplate()).getRace();
    }
}


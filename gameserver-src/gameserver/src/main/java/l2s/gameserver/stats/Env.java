/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.stats;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.items.ItemInstance;

public final class Env {
    public Creature character;
    public Creature target;
    public ItemInstance item;
    public Skill skill;
    public double value;
    public boolean reflected;

    public Env() {
    }

    public Env(Creature cha, Creature tar, Skill sk) {
        this.character = cha;
        this.target = tar;
        this.skill = sk;
    }
}


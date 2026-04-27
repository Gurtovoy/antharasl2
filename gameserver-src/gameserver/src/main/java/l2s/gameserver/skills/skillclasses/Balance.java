/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.skills.skillclasses;

import java.util.Set;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.templates.StatsSet;

public class Balance
extends Skill {
    public Balance(StatsSet set) {
        super(set);
    }

    @Override
    public void onEndCast(Creature activeChar, Set<Creature> targets) {
        super.onEndCast(activeChar, targets);
        double summaryCurrentHp = 0.0;
        int summaryMaximumHp = 0;
        for (Creature target : targets) {
            if (target == null || target.isAlikeDead()) continue;
            summaryCurrentHp += target.getCurrentHp();
            summaryMaximumHp += target.getMaxHp();
        }
        double percent = summaryCurrentHp / (double)summaryMaximumHp;
        for (Creature target : targets) {
            if (target == null || target.isAlikeDead()) continue;
            double hp = (double)target.getMaxHp() * percent;
            if (hp > target.getCurrentHp()) {
                double limit = target.getStat().calc(Stats.HP_LIMIT, null, null) * (double)target.getMaxHp() / 100.0;
                if (!(target.getCurrentHp() < limit)) continue;
                target.setCurrentHp(Math.min(hp, limit), false);
                continue;
            }
            target.setCurrentHp(Math.max(1.01, hp), false);
        }
    }
}


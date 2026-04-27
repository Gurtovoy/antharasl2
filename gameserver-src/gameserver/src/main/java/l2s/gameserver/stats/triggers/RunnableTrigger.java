/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.stats.triggers;

import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.model.Creature;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.stats.triggers.TriggerInfo;

public class RunnableTrigger
implements Runnable {
    private final TriggerInfo _trigger;
    private final Creature _creature;
    private final int _delay;

    public RunnableTrigger(Creature creature, TriggerInfo trigger) {
        this._creature = creature;
        this._trigger = trigger;
        int delay = 0;
        SkillEntry skillEntry = this._trigger.getSkill();
        if (skillEntry != null) {
            delay = skillEntry.getTemplate().getReuseDelay();
        }
        if (this._trigger.getDelay() > delay) {
            delay = this._trigger.getDelay();
        }
        if (delay <= 0) {
            delay = 1000;
        }
        this._delay = delay;
    }

    @Override
    public void run() {
        if (this._creature.getTriggers() == null) {
            return;
        }
        if (!this._creature.getTriggers().get(this._trigger.getType()).contains(this._trigger)) {
            return;
        }
        this._creature.useTriggerSkill(this._creature, null, this._trigger, null, 0.0);
        this.schedule();
    }

    public void schedule() {
        ThreadPoolManager.getInstance().schedule(this, this._delay);
    }
}


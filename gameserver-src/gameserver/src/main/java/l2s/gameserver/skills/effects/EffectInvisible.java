package l2s.gameserver.skills.effects;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.templates.skill.EffectTemplate;

public final class EffectInvisible
extends EffectHandler {
    public EffectInvisible(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Abnormal abnormal, Creature effector, Creature effected) {
        Player player;
        return !effected.isPlayer() || (player = effected.getPlayer()).getActiveWeaponFlagAttachment() == null;
    }

    @Override
    public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
        if (!effected.isPlayer()) {
            return;
        }
        effected.startInvisible(this, true);
    }

    @Override
    public void onExit(Abnormal abnormal, Creature effector, Creature effected) {
        if (effected.isPlayer()) {
            effected.stopInvisible(this, true);
            for (Servitor servitor : effected.getServitors()) {
                servitor.getAbnormalList().stop(this.getSkill(), false);
            }
        } else if (effected.isServitor()) {
            effected.getPlayer().getAbnormalList().stop(this.getSkill(), false);
        }
    }
}


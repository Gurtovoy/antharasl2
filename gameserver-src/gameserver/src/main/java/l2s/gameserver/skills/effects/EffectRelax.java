/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.effects;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.templates.skill.EffectTemplate;

public class EffectRelax
extends EffectHandler {
    public EffectRelax(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Abnormal abnormal, Creature effector, Creature effected) {
        if (!effected.isPlayer()) {
            return false;
        }
        Player player = effected.getPlayer();
        if (player == null) {
            return false;
        }
        if (player.isMounted()) {
            player.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addSkillName(this.getSkill().getId(), this.getSkill().getLevel()));
            return false;
        }
        return true;
    }

    @Override
    public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
        Player player = effected.getPlayer();
        if (player.getMovement().isMoving()) {
            player.getMovement().stopMove();
        }
        player.sitDown(null);
    }

    @Override
    public boolean onActionTime(Abnormal abnormal, Creature effector, Creature effected) {
        Player player = effected.getPlayer();
        if (player.isAlikeDead() || player == null) {
            return false;
        }
        if (!player.isSitting()) {
            return false;
        }
        if (player.isCurrentHpFull() && this.getSkill().isToggle()) {
            effected.sendPacket((IBroadcastPacket)SystemMsg.THAT_SKILL_HAS_BEEN_DEACTIVATED_AS_HP_WAS_FULLY_RECOVERED);
            return false;
        }
        double manaDam = this.getValue();
        if (manaDam > effected.getCurrentMp() && this.getSkill().isToggle()) {
            player.sendPacket(new IBroadcastPacket[]{SystemMsg.NOT_ENOUGH_MP, new SystemMessagePacket(SystemMsg.THE_EFFECT_OF_S1_HAS_BEEN_REMOVED).addSkillName(this.getSkill().getId(), this.getSkill().getDisplayLevel())});
            return false;
        }
        effected.reduceCurrentMp(manaDam, null);
        return true;
    }
}


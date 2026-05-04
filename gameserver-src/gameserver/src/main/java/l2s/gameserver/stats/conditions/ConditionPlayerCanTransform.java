/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.data.xml.holder.TransformTemplateHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.base.TransformType;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;
import l2s.gameserver.templates.player.transform.TransformTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ConditionPlayerCanTransform
extends Condition {
    private static final Logger _log = LoggerFactory.getLogger(ConditionPlayerCanTransform.class);
    private final int _transformId;

    public ConditionPlayerCanTransform(int transformId) {
        this._transformId = transformId;
    }

    @Override
    protected boolean testImpl(Env env) {
        if (!env.character.isPlayer()) {
            return false;
        }
        Player player = env.character.getPlayer();
        Skill skill = env.skill;
        if (player.getActiveWeaponFlagAttachment() != null) {
            player.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addSkillName(skill));
            return false;
        }
        if (player.isTransformed()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_ALREADY_POLYMORPHED_AND_CANNOT_POLYMORPH_AGAIN);
            return false;
        }
        TransformTemplate template = TransformTemplateHolder.getInstance().getTemplate(player.getSex(), this._transformId);
        if (template == null) {
            _log.warn(this.getClass().getSimpleName() + ": Cannot find transformation template for skill ID[" + skill.getId() + "], LEVEL[" + skill.getLevel() + "]!");
            return false;
        }
        if (template.getType() == TransformType.FLYING && (player.getX() > -166168 || player.getZ() <= 0 || player.getZ() >= 6000 || player.hasServitor() || !player.getReflection().isMain())) {
            player.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addSkillName(skill));
            return false;
        }
        if (player.isInWater()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_POLYMORPH_INTO_THE_DESIRED_FORM_IN_WATER);
            return false;
        }
        if (player.isMounted()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_POLYMORPH_WHILE_RIDING_A_PET);
            return false;
        }
        if (player.isTransformImmune() || player.getAbnormalList().contains(1411)) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_POLYMORPH_WHILE_UNDER_THE_EFFECT_OF_A_SPECIAL_SKILL);
            return false;
        }
        if (player.isInBoat()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_POLYMORPH_WHILE_RIDING_A_BOAT);
            return false;
        }
        if (player.getPet() != null && template.getType() != TransformType.MODE_CHANGE) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_POLYMORPH_WHEN_YOU_HAVE_SUMMONED_A_SERVITORPET);
            return false;
        }
        return true;
    }
}


package l2s.gameserver.skills.effects.instant;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.SkillCoolTimePacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.effects.instant.i_abstract_effect;
import l2s.gameserver.templates.skill.EffectTemplate;

public final class i_reset_skill_reuse
extends i_abstract_effect {
    private final int _skillId = this.getParams().getInteger("id");

    public i_reset_skill_reuse(EffectTemplate template) {
        super(template);
    }

    @Override
    public void instantUse(Creature effector, Creature effected, boolean reflected) {
        SkillEntry skill = effected.getKnownSkill(this._skillId);
        if (skill != null) {
            effected.enableSkill(skill.getTemplate());
            if (effected.isPlayer()) {
                Player player = effected.getPlayer();
                player.sendPacket((IBroadcastPacket)new SkillCoolTimePacket(player));
            }
        }
    }
}


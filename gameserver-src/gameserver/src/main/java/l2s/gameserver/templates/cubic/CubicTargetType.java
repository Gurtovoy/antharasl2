/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.templates.cubic;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.actor.instances.player.Cubic;
import l2s.gameserver.templates.cubic.CubicSkillInfo;

public enum CubicTargetType {
    BY_SKILL{

        @Override
        public Creature getTarget(Cubic cubic, CubicSkillInfo skillInfo) {
            throw new UnsupportedOperationException(this.getClass().getName() + " not implemented BY_SKILL:getTarget(Cubic,Skill)");
        }
    }
    ,
    TARGET{

        @Override
        public Creature getTarget(Cubic cubic, CubicSkillInfo skillInfo) {
            Player player = cubic.getOwner();
            Skill skill = skillInfo.getSkill();
            if (skill.isDebuff() && !player.isInCombat()) {
                return null;
            }
            GameObject object = player.getTarget();
            if (object != null && object.isCreature()) {
                Creature target = (Creature)object;
                if (target.isDead()) {
                    return null;
                }
                if (target.isDoor() && !skillInfo.isCanAttackDoor()) {
                    return null;
                }
                if (!(!skill.isDebuff() || target.isInCombat() && target.isAutoAttackable(cubic.getOwner()))) {
                    return null;
                }
                if (!cubic.canCastSkill(target, skill, false)) {
                    return null;
                }
                return target;
            }
            return null;
        }
    }
    ,
    HEAL{

        @Override
        public Creature getTarget(Cubic cubic, CubicSkillInfo skillInfo) {
            Player player = cubic.getOwner();
            Skill skill = skillInfo.getSkill();
            if (player.getParty() == null) {
                if (player.isDead()) {
                    return null;
                }
                if (player.isCurrentHpFull()) {
                    return null;
                }
                if (!cubic.canCastSkill(player, skill, false)) {
                    return null;
                }
                return player;
            }
            Player target = null;
            double currentHp = 2.147483647E9;
            for (Player member : player.getParty()) {
                if (member == null || member.isDead() || member.isCurrentHpFull() || member.getCurrentHp() >= currentHp || !cubic.canCastSkill(member, skill, true)) continue;
                currentHp = member.getCurrentHp();
                target = member;
            }
            return target;
        }
    }
    ,
    MANA_HEAL{

        @Override
        public Creature getTarget(Cubic cubic, CubicSkillInfo skillInfo) {
            Player player = cubic.getOwner();
            Skill skill = skillInfo.getSkill();
            if (player.getParty() == null) {
                if (player.isDead()) {
                    return null;
                }
                if (player.isCurrentMpFull()) {
                    return null;
                }
                if (!cubic.canCastSkill(player, skill, false)) {
                    return null;
                }
                return player;
            }
            Player target = null;
            double currentMp = 2.147483647E9;
            for (Player member : player.getParty().getPartyMembers()) {
                if (member == null || member.isDead() || member.isCurrentMpFull() || member.getCurrentMp() >= currentMp || !cubic.canCastSkill(member, skill, true)) continue;
                currentMp = member.getCurrentMp();
                target = member;
            }
            return target;
        }
    }
    ,
    MASTER{

        @Override
        public Creature getTarget(Cubic cubic, CubicSkillInfo skillInfo) {
            Skill skill;
            Player player = cubic.getOwner();
            if (!cubic.canCastSkill(player, skill = skillInfo.getSkill(), false)) {
                return null;
            }
            return player;
        }
    };


    public abstract Creature getTarget(Cubic var1, CubicSkillInfo var2);
}


/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.effects;

import java.util.ArrayList;
import l2s.commons.util.Rnd;
import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.model.instances.SummonInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.templates.skill.EffectTemplate;

public class EffectDiscord
extends EffectHandler {
    public EffectDiscord(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Abnormal abnormal, Creature effector, Creature effected) {
        boolean multitargets = this.getSkill().isAoE();
        if (!effected.isMonster()) {
            if (!multitargets) {
                effector.sendPacket((IBroadcastPacket)SystemMsg.THAT_IS_AN_INCORRECT_TARGET);
            }
            return false;
        }
        if (effected.isFearImmune()) {
            if (!multitargets) {
                effector.sendPacket((IBroadcastPacket)SystemMsg.THAT_IS_AN_INCORRECT_TARGET);
            }
            return false;
        }
        Player player = effected.getPlayer();
        if (player != null && effected.isSummon()) {
            for (SiegeEvent siegeEvent : player.getEvents(SiegeEvent.class)) {
                if (!siegeEvent.containsSiegeSummon((SummonInstance)effected)) continue;
                if (!multitargets) {
                    effector.sendPacket((IBroadcastPacket)SystemMsg.THAT_IS_AN_INCORRECT_TARGET);
                }
                return false;
            }
        }
        if (effected.isInPeaceZone()) {
            if (!multitargets) {
                effector.sendPacket((IBroadcastPacket)SystemMsg.YOU_MAY_NOT_ATTACK_IN_A_PEACEFUL_ZONE);
            }
            return false;
        }
        int skilldiff = effected.getLevel() - this.getSkill().getMagicLevel();
        int lvldiff = effected.getLevel() - effector.getLevel();
        if (skilldiff > 10 || skilldiff > 5 && Rnd.chance((int)30) || Rnd.chance((int)(Math.abs(lvldiff) * 2))) {
            if (!multitargets) {
                effector.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_HAS_FAILED).addSkillName(this.getSkill()));
            }
            return false;
        }
        return true;
    }

    @Override
    public boolean isHidden() {
        return true;
    }

    @Override
    public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
        effected.getFlags().getConfused().start(this);
        this.onActionTime(abnormal, effector, effected);
    }

    @Override
    public void onExit(Abnormal abnormal, Creature effector, Creature effected) {
        if (effected.getFlags().getConfused().stop(this)) {
            effected.abortAttack(true, true);
            effected.abortCast(true, true);
            effected.getMovement().stopMove();
            effected.getAI().setAttackTarget(null);
            effected.setWalking();
            effected.getAI().setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
        }
    }

    @Override
    public boolean onActionTime(Abnormal abnormal, Creature effector, Creature effected) {
        ArrayList<Creature> targetList = new ArrayList<Creature>();
        for (Creature character : effected.getAroundCharacters(900, 200)) {
            if (!character.isNpc() || character == effected) continue;
            targetList.add(character);
        }
        if (targetList.isEmpty()) {
            return true;
        }
        Creature target = (Creature)targetList.get(Rnd.get((int)targetList.size()));
        effected.setRunning();
        effected.getAI().Attack(target, true, false);
        return false;
    }
}


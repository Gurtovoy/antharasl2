/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.effects;

import l2s.gameserver.ai.CtrlEvent;
import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.templates.skill.EffectTemplate;

public class EffectLaksis
extends EffectHandler {
    public EffectLaksis(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Abnormal abnormal, Creature effector, Creature effected) {
        return effected.isPlayer();
    }

    @Override
    public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
        Player caster = effector.getPlayer();
        for (Creature cha : caster.getAroundCharacters(this.getSkill().getAffectRange(), 200)) {
            int fanAffectRange = this.getSkill().getFanRange()[2];
            if (fanAffectRange > 0 && cha.isInRange(caster, fanAffectRange)) continue;
            if (cha.isPlayer()) {
                boolean heal = false;
                if (!cha.isPlayer()) continue;
                Player player = (Player)effector;
                Player target = (Player)cha;
                if (player.getParty() != null && (player.isInSameParty(target) || player.isInSameChannel(target))) {
                    heal = true;
                }
                if (player.getClan() != null && !player.isInPeaceZone() && (player.isInSameClan(target) || player.isInSameAlly(target))) {
                    heal = true;
                }
                if (heal) {
                    if (target == null || target.isDead()) continue;
                    double powerCP = this.getValue();
                    double powerHP = this.getValue();
                    powerCP = Math.min(powerCP, (double)target.getMaxCp() - target.getCurrentCp());
                    powerHP = Math.min(powerHP, (double)target.getMaxHp() - target.getCurrentHp());
                    if (powerCP < 0.0) {
                        powerCP = 0.0;
                    }
                    if (powerHP < 0.0) {
                        powerHP = 0.0;
                    }
                    if (target.getCurrentCp() < (double)target.getMaxCp()) {
                        target.setCurrentCp(powerCP + target.getCurrentCp());
                        target.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_CP_HAS_BEEN_RESTORED).addInteger((long)powerCP));
                        continue;
                    }
                    target.setCurrentHp(powerHP + target.getCurrentHp(), false);
                    target.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_HP_HAS_BEEN_RESTORED).addInteger((long)powerHP));
                    continue;
                }
                if (target == null || target.isDead() || target.getPvpFlag() <= 0 && !target.isAutoAttackable(player) || target.isInPeaceZone()) continue;
                if (player.getPvpFlag() == 0) {
                    player.startPvPFlag(null);
                }
                double damage = this.getValue();
                target.reduceCurrentHp(damage, player, this.getSkill(), true, true, false, true, false, false, true);
                continue;
            }
            if (!cha.isMonster() || cha.isInPeaceZone()) continue;
            double damage = this.getValue();
            cha.reduceCurrentHp(damage, caster, this.getSkill(), true, true, false, true, false, false, true);
            cha.getAI().notifyEvent(CtrlEvent.EVT_ATTACKED, caster, this.getSkill(), damage);
        }
    }
}


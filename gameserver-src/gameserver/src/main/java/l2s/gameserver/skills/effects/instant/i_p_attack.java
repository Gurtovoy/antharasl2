package l2s.gameserver.skills.effects.instant;

import l2s.gameserver.model.Creature;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.FinishRotatingPacket;
import l2s.gameserver.network.l2.s2c.StartRotatingPacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.effects.instant.i_abstract_effect;
import l2s.gameserver.stats.Formulas;
import l2s.gameserver.templates.skill.EffectTemplate;

public class i_p_attack
extends i_abstract_effect {
    private final boolean _directHp = this.getParams().getBool("directHp", false);
    private final boolean _turner = this.getParams().getBool("turner", false);
    private final boolean _blow = this.getParams().getBool("blow", false);
    private final boolean _static = this.getParams().getBool("static", false);

    public i_p_attack(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Creature effector, Creature effected) {
        return !effected.isDead();
    }

    @Override
    public void instantUse(Creature effector, Creature effected, boolean reflected) {
        if (this._turner && !effected.isInvulnerable()) {
            effected.broadcastPacket(new StartRotatingPacket(effected, effected.getHeading(), 1, 65535));
            effected.broadcastPacket(new FinishRotatingPacket(effected, effector.getHeading(), 65535));
            effected.setHeading(effector.getHeading());
            effected.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1S_EFFECT_CAN_BE_FELT).addSkillName(this.getSkill()));
        }
        Creature realTarget = reflected ? effector : effected;
        double power = this.getValue();
        if (this.getSkill().getId() == 10300 && realTarget.isMonster() && !realTarget.isRaid()) {
            power = realTarget.getCurrentHp() - 1.0;
        }
        if (this._static) {
            realTarget.reduceCurrentHp(power, effector, this.getSkill(), true, true, this._directHp, true, false, false, power != 0.0, true, false, false, false);
            return;
        }
        Formulas.AttackInfo info = Formulas.calcSkillPDamage(effector, realTarget, this.getSkill(), power, this._blow, this.getSkill().isSSPossible());
        if (info == null) {
            return;
        }
        realTarget.reduceCurrentHp(info.damage, effector, this.getSkill(), true, true, this._directHp, true, false, false, this.getTemplate().isInstant() && power != 0.0, this.getTemplate().isInstant(), info.crit || info.blow, false, false);
        if (!info.miss || info.damage >= 1.0) {
            double lethalDmg = Formulas.calcLethalDamage(effector, realTarget, this.getSkill());
            if (lethalDmg > 0.0) {
                realTarget.reduceCurrentHp(lethalDmg, effector, this.getSkill(), true, true, false, false, false, false, false);
            } else if (!reflected) {
                realTarget.doCounterAttack(this.getSkill(), effector, this._blow);
            }
        }
    }
}


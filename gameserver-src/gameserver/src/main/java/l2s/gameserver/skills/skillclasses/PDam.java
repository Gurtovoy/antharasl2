package l2s.gameserver.skills.skillclasses;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.FinishRotatingPacket;
import l2s.gameserver.network.l2.s2c.StartRotatingPacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.stats.Formulas;
import l2s.gameserver.templates.StatsSet;

public class PDam
extends Skill {
    private final boolean _directHp;
    private final boolean _turner;
    private final boolean _blow;
    private final boolean _static;

    public PDam(StatsSet set) {
        super(set);
        this._directHp = set.getBool("directHp", false);
        this._turner = set.getBool("turner", false);
        this._blow = set.getBool("blow", false);
        this._static = set.getBool("static", false);
    }

    @Override
    public boolean calcCriticalBlow(Creature caster, Creature target) {
        if (this._blow) {
            return Formulas.calcBlow(caster, target, this);
        }
        return false;
    }

    @Override
    protected void useSkill(Creature activeChar, Creature target, boolean reflected) {
        if (target.isDead()) {
            return;
        }
        if (this._turner && !target.isInvulnerable()) {
            target.broadcastPacket(new StartRotatingPacket(target, target.getHeading(), 1, 65535));
            target.broadcastPacket(new FinishRotatingPacket(target, activeChar.getHeading(), 65535));
            target.setHeading(activeChar.getHeading());
            target.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1S_EFFECT_CAN_BE_FELT).addSkillName(this));
        }
        Creature realTarget = reflected ? activeChar : target;
        double power = this.getPower();
        if (this._static) {
            realTarget.reduceCurrentHp(power, activeChar, this, true, true, this._directHp, true, false, false, power != 0.0, true, false, false, false);
            return;
        }
        Formulas.AttackInfo info = Formulas.calcSkillPDamage(activeChar, realTarget, this, power, this._blow, this.isSSPossible());
        if (info == null) {
            return;
        }
        realTarget.reduceCurrentHp(info.damage, activeChar, this, true, true, this._directHp, true, false, false, power != 0.0, true, info.crit || info.blow, false, false);
        if (!info.miss || info.damage >= 1.0) {
            double lethalDmg = Formulas.calcLethalDamage(activeChar, realTarget, this);
            if (lethalDmg > 0.0) {
                realTarget.reduceCurrentHp(lethalDmg, activeChar, this, true, true, false, false, false, false, false);
            } else if (!reflected) {
                realTarget.doCounterAttack(this, activeChar, this._blow);
            }
        }
    }
}


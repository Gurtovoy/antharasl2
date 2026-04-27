/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.napile.primitive.pair.IntObjectPair
 */
package l2s.gameserver.skills.skillclasses;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import l2s.gameserver.listener.actor.player.OnAnswerListener;
import l2s.gameserver.listener.actor.player.impl.ReviveAnswerListener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.base.BaseStats;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.instances.PetInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.AbnormalType;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.templates.StatsSet;
import org.napile.primitive.pair.IntObjectPair;

public class Resurrect
extends Skill {
    public static List<Event> GLOBAL = new ArrayList<Event>();
    private final boolean _canPet;

    public Resurrect(StatsSet set) {
        super(set);
        this._canPet = set.getBool("canPet", false);
    }

    @Override
    public boolean checkCondition(SkillEntry skillEntry, Creature activeChar, Creature target, boolean forceUse, boolean dontMove, boolean first, boolean sendMsg, boolean trigger) {
        if (!super.checkCondition(skillEntry, activeChar, target, forceUse, dontMove, first, sendMsg, trigger)) {
            return false;
        }
        if (!activeChar.isPlayer()) {
            return false;
        }
        if (target == null || target != activeChar && !target.isDead()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THAT_IS_AN_INCORRECT_TARGET);
            return false;
        }
        Player player = (Player)activeChar;
        Player pcTarget = target.getPlayer();
        if (pcTarget == null) {
            player.sendPacket((IBroadcastPacket)SystemMsg.THAT_IS_AN_INCORRECT_TARGET);
            return false;
        }
        if (player.isInOlympiadMode() || pcTarget.isInOlympiadMode()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.THAT_IS_AN_INCORRECT_TARGET);
            return false;
        }
        if (this.oneTarget()) {
            ReviveAnswerListener reviveAsk;
            IntObjectPair<OnAnswerListener> ask;
            if (target.getAbnormalList().contains(AbnormalType.BLOCK_RESURRECTION)) {
                player.sendPacket((IBroadcastPacket)SystemMsg.THAT_IS_AN_INCORRECT_TARGET);
                return false;
            }
            ArrayList<Event> events = new ArrayList<Event>(GLOBAL.size() + 2);
            events.addAll(GLOBAL);
            events.addAll(target.getZoneEvents());
            for (Event e : events) {
                if (e.canResurrect(activeChar, target, forceUse, false)) continue;
                player.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addSkillName(this));
                return false;
            }
            if (target.isPet()) {
                ask = pcTarget.getAskListener(false);
                ReviveAnswerListener reviveAnswerListener = reviveAsk = ask != null && ask.getValue() instanceof ReviveAnswerListener ? (ReviveAnswerListener)ask.getValue() : null;
                if (reviveAsk != null) {
                    if (reviveAsk.isForPet()) {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.RESURRECTION_HAS_ALREADY_BEEN_PROPOSED);
                    } else {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.A_PET_CANNOT_BE_RESURRECTED_WHILE_ITS_OWNER_IS_IN_THE_PROCESS_OF_RESURRECTING);
                    }
                    return false;
                }
                if (!this._canPet && this.getTargetType() != Skill.SkillTargetType.TARGET_ONE_SERVITOR) {
                    player.sendPacket((IBroadcastPacket)SystemMsg.THAT_IS_AN_INCORRECT_TARGET);
                    return false;
                }
            } else if (target.isPlayer()) {
                ask = pcTarget.getAskListener(false);
                ReviveAnswerListener reviveAnswerListener = reviveAsk = ask != null && ask.getValue() instanceof ReviveAnswerListener ? (ReviveAnswerListener)ask.getValue() : null;
                if (reviveAsk != null) {
                    if (reviveAsk.isForPet()) {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.WHILE_A_PET_IS_BEING_RESURRECTED_IT_CANNOT_HELP_IN_RESURRECTING_ITS_MASTER);
                    } else {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.RESURRECTION_HAS_ALREADY_BEEN_PROPOSED);
                    }
                    return false;
                }
                if (this.getTargetType() == Skill.SkillTargetType.TARGET_ONE_SERVITOR) {
                    player.sendPacket((IBroadcastPacket)SystemMsg.THAT_IS_AN_INCORRECT_TARGET);
                    return false;
                }
            }
        }
        return true;
    }

    @Override
    protected void useSkill(Creature activeChar, Creature target, boolean reflected) {
        double wit_bonus;
        if (!activeChar.isPlayer()) {
            return;
        }
        Player targetPlayer = target.getPlayer();
        if (targetPlayer == null) {
            return;
        }
        double percent = this.getPower();
        if (percent < 100.0 && !this.isHandler() && (percent += (wit_bonus = this.getPower() * (BaseStats.WIT.calcBonus(activeChar) - 1.0)) > 20.0 ? 20.0 : wit_bonus) > 90.0) {
            percent = 90.0;
        }
        if (target.isPet() && this._canPet) {
            if (targetPlayer == activeChar) {
                ((PetInstance)target).doRevive(percent);
            } else {
                targetPlayer.reviveRequest((Player)activeChar, percent, true);
            }
        } else if (target.isPlayer()) {
            ReviveAnswerListener reviveAsk;
            if (this.getTargetType() == Skill.SkillTargetType.TARGET_ONE_SERVITOR) {
                return;
            }
            IntObjectPair<OnAnswerListener> ask = targetPlayer.getAskListener(false);
            ReviveAnswerListener reviveAnswerListener = reviveAsk = ask != null && ask.getValue() instanceof ReviveAnswerListener ? (ReviveAnswerListener)ask.getValue() : null;
            if (reviveAsk != null) {
                return;
            }
            targetPlayer.reviveRequest(activeChar.getPlayer(), percent, false);
        }
    }

    @Override
    public Set<Creature> getTargets(SkillEntry skillEntry, Creature activeChar, Creature aimingTarget, boolean forceUse) {
        if (this.oneTarget()) {
            return super.getTargets(skillEntry, activeChar, aimingTarget, forceUse);
        }
        Set<Creature> list = super.getTargets(skillEntry, activeChar, aimingTarget, forceUse);
        Iterator<Creature> iterator = list.iterator();
        while (iterator.hasNext()) {
            Creature target = iterator.next();
            ArrayList<Event> events = new ArrayList<Event>(GLOBAL.size() + 2);
            events.addAll(GLOBAL);
            events.addAll(target.getZoneEvents());
            for (Event e : events) {
                if (e.canResurrect(activeChar, target, true, true)) continue;
                iterator.remove();
            }
        }
        return list;
    }
}


/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.handler.effects;

import java.lang.reflect.Constructor;
import java.util.HashMap;
import java.util.Map;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.skills.effects.EffectAbsorbDamageToEffector;
import l2s.gameserver.skills.effects.EffectAbsorbDamageToMp;
import l2s.gameserver.skills.effects.EffectAbsorbDamageToSummon;
import l2s.gameserver.skills.effects.EffectAddSkills;
import l2s.gameserver.skills.effects.EffectAgathionResurrect;
import l2s.gameserver.skills.effects.EffectArmorBreaker;
import l2s.gameserver.skills.effects.EffectBetray;
import l2s.gameserver.skills.effects.EffectBuff;
import l2s.gameserver.skills.effects.EffectCPDamPercent;
import l2s.gameserver.skills.effects.EffectCPDrain;
import l2s.gameserver.skills.effects.EffectCharge;
import l2s.gameserver.skills.effects.EffectCharmOfCourage;
import l2s.gameserver.skills.effects.EffectCurseOfLifeFlow;
import l2s.gameserver.skills.effects.EffectDamageBlock;
import l2s.gameserver.skills.effects.EffectDamageHealToEffector;
import l2s.gameserver.skills.effects.EffectDeathImmunity;
import l2s.gameserver.skills.effects.EffectDestroySummon;
import l2s.gameserver.skills.effects.EffectDisarm;
import l2s.gameserver.skills.effects.EffectDiscord;
import l2s.gameserver.skills.effects.EffectDispelOnHit;
import l2s.gameserver.skills.effects.EffectDistortedSpace;
import l2s.gameserver.skills.effects.EffectEffectImmunity;
import l2s.gameserver.skills.effects.EffectEnervation;
import l2s.gameserver.skills.effects.EffectFakeDeath;
import l2s.gameserver.skills.effects.EffectFear;
import l2s.gameserver.skills.effects.EffectFlyUp;
import l2s.gameserver.skills.effects.EffectGrow;
import l2s.gameserver.skills.effects.EffectHPDamPercent;
import l2s.gameserver.skills.effects.EffectHPDrain;
import l2s.gameserver.skills.effects.EffectHate;
import l2s.gameserver.skills.effects.EffectHealBlock;
import l2s.gameserver.skills.effects.EffectHpToOne;
import l2s.gameserver.skills.effects.EffectIgnoreSkill;
import l2s.gameserver.skills.effects.EffectInterrupt;
import l2s.gameserver.skills.effects.EffectInvisible;
import l2s.gameserver.skills.effects.EffectInvulnerable;
import l2s.gameserver.skills.effects.EffectKnockBack;
import l2s.gameserver.skills.effects.EffectKnockDown;
import l2s.gameserver.skills.effects.EffectLDManaDamOverTime;
import l2s.gameserver.skills.effects.EffectLaksis;
import l2s.gameserver.skills.effects.EffectLockInventory;
import l2s.gameserver.skills.effects.EffectMPDamPercent;
import l2s.gameserver.skills.effects.EffectMPDrain;
import l2s.gameserver.skills.effects.EffectManaDamOverTime;
import l2s.gameserver.skills.effects.EffectMeditation;
import l2s.gameserver.skills.effects.EffectMoveToEffector;
import l2s.gameserver.skills.effects.EffectMutation;
import l2s.gameserver.skills.effects.EffectMute;
import l2s.gameserver.skills.effects.EffectMuteAll;
import l2s.gameserver.skills.effects.EffectMuteAttack;
import l2s.gameserver.skills.effects.EffectMuteChance;
import l2s.gameserver.skills.effects.EffectMutePhisycal;
import l2s.gameserver.skills.effects.EffectNegateMark;
import l2s.gameserver.skills.effects.EffectParalyze;
import l2s.gameserver.skills.effects.EffectPetrification;
import l2s.gameserver.skills.effects.EffectRelax;
import l2s.gameserver.skills.effects.EffectRestoreCP;
import l2s.gameserver.skills.effects.EffectRestoreHP;
import l2s.gameserver.skills.effects.EffectRestoreMP;
import l2s.gameserver.skills.effects.EffectSalvation;
import l2s.gameserver.skills.effects.EffectServitorShare;
import l2s.gameserver.skills.effects.EffectShadowStep;
import l2s.gameserver.skills.effects.EffectSilentMove;
import l2s.gameserver.skills.effects.EffectSleep;
import l2s.gameserver.skills.effects.EffectStun;
import l2s.gameserver.skills.effects.EffectThrowHorizontal;
import l2s.gameserver.skills.effects.EffectThrowUp;
import l2s.gameserver.skills.effects.EffectTransformation;
import l2s.gameserver.skills.effects.EffectVisualTransformation;
import l2s.gameserver.skills.effects.EffectVitality;
import l2s.gameserver.skills.effects.consume.c_mp;
import l2s.gameserver.skills.effects.consume.c_mp_by_level;
import l2s.gameserver.skills.effects.instant.i_add_hate;
import l2s.gameserver.skills.effects.instant.i_align_direction;
import l2s.gameserver.skills.effects.instant.i_call_random_skill;
import l2s.gameserver.skills.effects.instant.i_call_skill;
import l2s.gameserver.skills.effects.instant.i_death_link;
import l2s.gameserver.skills.effects.instant.i_delete_hate;
import l2s.gameserver.skills.effects.instant.i_delete_hate_of_me;
import l2s.gameserver.skills.effects.instant.i_dispel_all;
import l2s.gameserver.skills.effects.instant.i_dispel_by_category;
import l2s.gameserver.skills.effects.instant.i_dispel_by_slot;
import l2s.gameserver.skills.effects.instant.i_dispel_by_slot_myself;
import l2s.gameserver.skills.effects.instant.i_dispel_by_slot_probability;
import l2s.gameserver.skills.effects.instant.i_fishing_shot;
import l2s.gameserver.skills.effects.instant.i_get_agro;
import l2s.gameserver.skills.effects.instant.i_get_exp;
import l2s.gameserver.skills.effects.instant.i_hp_drain;
import l2s.gameserver.skills.effects.instant.i_m_attack;
import l2s.gameserver.skills.effects.instant.i_my_summon_kill;
import l2s.gameserver.skills.effects.instant.i_p_attack;
import l2s.gameserver.skills.effects.instant.i_p_hit;
import l2s.gameserver.skills.effects.instant.i_pledge_reputation;
import l2s.gameserver.skills.effects.instant.i_randomize_hate;
import l2s.gameserver.skills.effects.instant.i_refresh_instance;
import l2s.gameserver.skills.effects.instant.i_reset_skill_reuse;
import l2s.gameserver.skills.effects.instant.i_set_skill;
import l2s.gameserver.skills.effects.instant.i_soul_shot;
import l2s.gameserver.skills.effects.instant.i_sp;
import l2s.gameserver.skills.effects.instant.i_spirit_shot;
import l2s.gameserver.skills.effects.instant.i_spoil;
import l2s.gameserver.skills.effects.instant.i_summon_agathion;
import l2s.gameserver.skills.effects.instant.i_summon_cubic;
import l2s.gameserver.skills.effects.instant.i_summon_soul_shot;
import l2s.gameserver.skills.effects.instant.i_summon_spirit_shot;
import l2s.gameserver.skills.effects.instant.i_target_cancel;
import l2s.gameserver.skills.effects.instant.i_target_me;
import l2s.gameserver.skills.effects.instant.i_unsummon_agathion;
import l2s.gameserver.skills.effects.permanent.p_attack_trait;
import l2s.gameserver.skills.effects.permanent.p_block_buff_slot;
import l2s.gameserver.skills.effects.permanent.p_block_chat;
import l2s.gameserver.skills.effects.permanent.p_block_debuff;
import l2s.gameserver.skills.effects.permanent.p_block_escape;
import l2s.gameserver.skills.effects.permanent.p_block_move;
import l2s.gameserver.skills.effects.permanent.p_block_party;
import l2s.gameserver.skills.effects.permanent.p_block_target;
import l2s.gameserver.skills.effects.permanent.p_critical_damage;
import l2s.gameserver.skills.effects.permanent.p_defence_trait;
import l2s.gameserver.skills.effects.permanent.p_get_item_by_exp;
import l2s.gameserver.skills.effects.permanent.p_heal_effect;
import l2s.gameserver.skills.effects.permanent.p_magic_critical_dmg;
import l2s.gameserver.skills.effects.permanent.p_max_cp;
import l2s.gameserver.skills.effects.permanent.p_max_hp;
import l2s.gameserver.skills.effects.permanent.p_max_mp;
import l2s.gameserver.skills.effects.permanent.p_passive;
import l2s.gameserver.skills.effects.permanent.p_preserve_abnormal;
import l2s.gameserver.skills.effects.permanent.p_raid_berserk;
import l2s.gameserver.skills.effects.permanent.p_skill_critical_damage;
import l2s.gameserver.skills.effects.permanent.p_target_me;
import l2s.gameserver.skills.effects.permanent.p_violet_boy;
import l2s.gameserver.skills.effects.tick.t_hp;
import l2s.gameserver.skills.effects.tick.t_hp_magic;
import l2s.gameserver.templates.skill.EffectTemplate;
import org.apache.commons.lang3.StringUtils;

public class EffectHandlerHolder
extends AbstractHolder {
    private static final EffectHandlerHolder _instance = new EffectHandlerHolder();
    private Map<String, Constructor<? extends EffectHandler>> _handlerConstructors = new HashMap<String, Constructor<? extends EffectHandler>>();

    public static EffectHandlerHolder getInstance() {
        return _instance;
    }

    private EffectHandlerHolder() {
        this.registerHandler(EffectAddSkills.class);
        this.registerHandler(EffectAgathionResurrect.class);
        this.registerHandler(EffectBetray.class);
        this.registerHandler(EffectBuff.class);
        this.registerHandler(EffectDamageBlock.class);
        this.registerHandler(EffectDistortedSpace.class);
        this.registerHandler(EffectCharge.class);
        this.registerHandler(EffectCharmOfCourage.class);
        this.registerHandler(EffectCPDamPercent.class);
        this.registerHandler(EffectDamageHealToEffector.class);
        this.registerHandler(EffectDestroySummon.class);
        this.registerHandler(EffectDeathImmunity.class);
        this.registerHandler(EffectDisarm.class);
        this.registerHandler(EffectDiscord.class);
        this.registerHandler(EffectDispelOnHit.class);
        this.registerHandler(EffectEffectImmunity.class);
        this.registerHandler(EffectEnervation.class);
        this.registerHandler(EffectFakeDeath.class);
        this.registerHandler(EffectFear.class);
        this.registerHandler(EffectMoveToEffector.class);
        this.registerHandler(EffectGrow.class);
        this.registerHandler(EffectHate.class);
        this.registerHandler(EffectHealBlock.class);
        this.registerHandler(EffectHPDamPercent.class);
        this.registerHandler(EffectHpToOne.class);
        this.registerHandler(EffectIgnoreSkill.class);
        this.registerHandler(EffectInterrupt.class);
        this.registerHandler(EffectInvulnerable.class);
        this.registerHandler(EffectInvisible.class);
        this.registerHandler(EffectLockInventory.class);
        this.registerHandler(EffectCurseOfLifeFlow.class);
        this.registerHandler(EffectLaksis.class);
        this.registerHandler(EffectLDManaDamOverTime.class);
        this.registerHandler(EffectManaDamOverTime.class);
        this.registerHandler(EffectMeditation.class);
        this.registerHandler(EffectMPDamPercent.class);
        this.registerHandler(EffectMute.class);
        this.registerHandler(EffectMuteChance.class);
        this.registerHandler(EffectMuteAll.class);
        this.registerHandler(EffectMutation.class);
        this.registerHandler(EffectMuteAttack.class);
        this.registerHandler(EffectMutePhisycal.class);
        this.registerHandler(EffectNegateMark.class);
        this.registerHandler(EffectParalyze.class);
        this.registerHandler(EffectPetrification.class);
        this.registerHandler(EffectRelax.class);
        this.registerHandler(EffectSalvation.class);
        this.registerHandler(EffectServitorShare.class);
        this.registerHandler(EffectSilentMove.class);
        this.registerHandler(EffectSleep.class);
        this.registerHandler(EffectStun.class);
        this.registerHandler(EffectKnockDown.class);
        this.registerHandler(EffectKnockBack.class);
        this.registerHandler(EffectFlyUp.class);
        this.registerHandler(EffectThrowHorizontal.class);
        this.registerHandler(EffectThrowUp.class);
        this.registerHandler(EffectTransformation.class);
        this.registerHandler(EffectVisualTransformation.class);
        this.registerHandler(EffectVitality.class);
        this.registerHandler(EffectShadowStep.class);
        this.registerHandler(EffectRestoreCP.class);
        this.registerHandler(EffectRestoreHP.class);
        this.registerHandler(EffectRestoreMP.class);
        this.registerHandler(EffectCPDrain.class);
        this.registerHandler(EffectHPDrain.class);
        this.registerHandler(EffectMPDrain.class);
        this.registerHandler(EffectAbsorbDamageToEffector.class);
        this.registerHandler(EffectAbsorbDamageToMp.class);
        this.registerHandler(EffectAbsorbDamageToSummon.class);
        this.registerHandler(EffectArmorBreaker.class);
        this.registerHandler(c_mp.class);
        this.registerHandler(c_mp_by_level.class);
        this.registerHandler(i_add_hate.class);
        this.registerHandler(i_align_direction.class);
        this.registerHandler(i_call_random_skill.class);
        this.registerHandler(i_call_skill.class);
        this.registerHandler(i_dispel_all.class);
        this.registerHandler(i_dispel_by_category.class);
        this.registerHandler(i_dispel_by_slot.class);
        this.registerHandler(i_dispel_by_slot_myself.class);
        this.registerHandler(i_dispel_by_slot_probability.class);
        this.registerHandler(i_death_link.class);
        this.registerHandler(i_delete_hate.class);
        this.registerHandler(i_delete_hate_of_me.class);
        this.registerHandler(i_fishing_shot.class);
        this.registerHandler(i_get_agro.class);
        this.registerHandler(i_get_exp.class);
        this.registerHandler(i_hp_drain.class);
        this.registerHandler(i_m_attack.class);
        this.registerHandler(i_my_summon_kill.class);
        this.registerHandler(i_p_attack.class);
        this.registerHandler(i_p_hit.class);
        this.registerHandler(i_pledge_reputation.class);
        this.registerHandler(i_randomize_hate.class);
        this.registerHandler(i_refresh_instance.class);
        this.registerHandler(i_reset_skill_reuse.class);
        this.registerHandler(i_set_skill.class);
        this.registerHandler(i_sp.class);
        this.registerHandler(i_soul_shot.class);
        this.registerHandler(i_spirit_shot.class);
        this.registerHandler(i_spoil.class);
        this.registerHandler(i_summon_agathion.class);
        this.registerHandler(i_summon_cubic.class);
        this.registerHandler(i_summon_soul_shot.class);
        this.registerHandler(i_summon_spirit_shot.class);
        this.registerHandler(i_target_cancel.class);
        this.registerHandler(i_target_me.class);
        this.registerHandler(i_unsummon_agathion.class);
        this.registerHandler(p_attack_trait.class);
        this.registerHandler(p_block_buff_slot.class);
        this.registerHandler(p_block_chat.class);
        this.registerHandler(p_block_debuff.class);
        this.registerHandler(p_block_escape.class);
        this.registerHandler(p_block_move.class);
        this.registerHandler(p_block_party.class);
        this.registerHandler(p_block_target.class);
        this.registerHandler(p_critical_damage.class);
        this.registerHandler(p_defence_trait.class);
        this.registerHandler(p_get_item_by_exp.class);
        this.registerHandler(p_heal_effect.class);
        this.registerHandler(p_magic_critical_dmg.class);
        this.registerHandler(p_max_cp.class);
        this.registerHandler(p_max_hp.class);
        this.registerHandler(p_max_mp.class);
        this.registerHandler(p_passive.class);
        this.registerHandler(p_preserve_abnormal.class);
        this.registerHandler(p_raid_berserk.class);
        this.registerHandler(p_skill_critical_damage.class);
        this.registerHandler(p_target_me.class);
        this.registerHandler(p_violet_boy.class);
        this.registerHandler(t_hp.class);
        this.registerHandler(t_hp_magic.class);
    }

    public void registerHandler(Class<? extends EffectHandler> handlerClass) {
        String name = EffectHandler.getName(handlerClass);
        if (this._handlerConstructors.containsKey(name)) {
            this.warn("EffectHandlerHolder: Dublicate handler registered! Handler: CLASS[" + handlerClass.getSimpleName() + "], NAME[" + name + "]");
            return;
        }
        try {
            this._handlerConstructors.put(name, handlerClass.getConstructor(EffectTemplate.class));
        }
        catch (Exception e) {
            this.error("EffectHandlerHolder: Error while loading handler: " + e, e);
        }
    }

    public EffectHandler makeHandler(String handlerName, EffectTemplate template) {
        if (StringUtils.isEmpty((CharSequence)handlerName)) {
            return new EffectHandler(template);
        }
        Constructor<? extends EffectHandler> constructor = this._handlerConstructors.get(handlerName.toLowerCase());
        if (constructor == null) {
            this.warn("EffectHandlerHolder: Not found handler: " + handlerName);
            return new EffectHandler(template);
        }
        try {
            return constructor.newInstance(template);
        }
        catch (Exception e) {
            this.error("EffectHandlerHolder: Error while making handler: " + e, e);
            return new EffectHandler(template);
        }
    }

    public int size() {
        return this._handlerConstructors.size();
    }

    public void clear() {
        this._handlerConstructors.clear();
    }
}


/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.skills.effects;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.listener.actor.player.OnPlayerSummonServitorListener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.StatModifierType;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.stats.funcs.Func;
import l2s.gameserver.stats.funcs.FuncTemplate;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.skill.EffectTemplate;

public class EffectServitorShare
extends EffectHandler {
    private final OnPlayerSummonServitorListener _listener = new OnPlayerSummonServitorListenerImpl();

    public EffectServitorShare(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Abnormal abnormal, Creature effector, Creature effected) {
        return effected.isPlayer();
    }

    @Override
    public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
        effected.addListener(this._listener);
        for (Servitor servitor : effected.getServitors()) {
            this._listener.onSummonServitor(null, servitor);
        }
    }

    @Override
    public void onExit(Abnormal abnormal, Creature effector, Creature effected) {
        effected.removeListener(this._listener);
        for (Servitor servitor : effected.getServitors()) {
            servitor.getStat().removeFuncsByOwner(this);
            servitor.updateStats();
        }
    }

    @Override
    public Func[] getStatFuncs() {
        return Func.EMPTY_FUNC_ARRAY;
    }

    private class OnPlayerSummonServitorListenerImpl
    implements OnPlayerSummonServitorListener {
        private OnPlayerSummonServitorListenerImpl() {
        }

        @Override
        public void onSummonServitor(Player player, Servitor servitor) {
            FuncTemplate[] funcTemplates = EffectServitorShare.this.getTemplate().getAttachedFuncs();
            Func[] funcs = new Func[funcTemplates.length];
            for (int i = 0; i < funcs.length; ++i) {
                funcs[i] = new FuncShare(funcTemplates[i]._stat, funcTemplates[i]._order, EffectServitorShare.this, funcTemplates[i]._value, StatsSet.EMPTY);
            }
            servitor.getStat().addFuncs(funcs);
            servitor.updateStats();
        }
    }

    public static class FuncShare
    extends Func {
        public FuncShare(Stats stat, int order, Object owner, double value, StatsSet params) {
            super(stat, order, owner, value, params);
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            double val = 0.0;
            switch (this.stat) {
                case MAX_HP: {
                    val = env.character.getPlayer().getMaxHp();
                    break;
                }
                case MAX_MP: {
                    val = env.character.getPlayer().getMaxMp();
                    break;
                }
                case POWER_ATTACK: {
                    val = env.character.getPlayer().getPAtk(null);
                    break;
                }
                case MAGIC_ATTACK: {
                    val = env.character.getPlayer().getMAtk(null, null);
                    break;
                }
                case POWER_DEFENCE: {
                    val = env.character.getPlayer().getPDef(null);
                    break;
                }
                case MAGIC_DEFENCE: {
                    val = env.character.getPlayer().getMDef(null, null);
                    break;
                }
                case POWER_ATTACK_SPEED: {
                    val = env.character.getPlayer().getPAtkSpd();
                    break;
                }
                case MAGIC_ATTACK_SPEED: {
                    val = env.character.getPlayer().getMAtkSpd();
                    break;
                }
                case BASE_P_CRITICAL_RATE: {
                    val = env.character.getPlayer().getPCriticalHit(null);
                    break;
                }
                case BASE_M_CRITICAL_RATE: {
                    val = env.character.getPlayer().getMCriticalHit(null, null);
                    break;
                }
                case PVP_PHYS_DMG_BONUS: 
                case PVP_PHYS_SKILL_DMG_BONUS: 
                case PVP_MAGIC_SKILL_DMG_BONUS: 
                case PVP_PHYS_DEFENCE_BONUS: 
                case PVP_PHYS_SKILL_DEFENCE_BONUS: 
                case PVP_MAGIC_SKILL_DEFENCE_BONUS: 
                case PVE_PHYS_DMG_BONUS: 
                case PVE_PHYS_SKILL_DMG_BONUS: 
                case PVE_MAGIC_SKILL_DMG_BONUS: 
                case PVE_PHYS_DEFENCE_BONUS: 
                case PVE_PHYS_SKILL_DEFENCE_BONUS: 
                case PVE_MAGIC_SKILL_DEFENCE_BONUS: {
                    val = env.character.getPlayer().getStat().calc(this.stat, 1.0) - 1.0;
                    break;
                }
                default: {
                    val = env.character.getPlayer().getStat().calc(this.stat, this.stat.getInit());
                }
            }
            env.value += val * this.value;
        }
    }
}


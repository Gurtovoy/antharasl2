/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.listener.Listener
 *  l2s.commons.listener.ListenerList
 */
package l2s.gameserver.model.actor.listener;

import l2s.commons.listener.Listener;
import l2s.commons.listener.ListenerList;
import l2s.gameserver.ai.CtrlEvent;
import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.listener.actor.OnActorAct;
import l2s.gameserver.listener.actor.OnAttackHitListener;
import l2s.gameserver.listener.actor.OnAttackListener;
import l2s.gameserver.listener.actor.OnChangeCurrentCpListener;
import l2s.gameserver.listener.actor.OnChangeCurrentHpListener;
import l2s.gameserver.listener.actor.OnChangeCurrentMpListener;
import l2s.gameserver.listener.actor.OnCurrentHpDamageListener;
import l2s.gameserver.listener.actor.OnDeathFromUndyingListener;
import l2s.gameserver.listener.actor.OnDeathListener;
import l2s.gameserver.listener.actor.OnKillListener;
import l2s.gameserver.listener.actor.OnMagicHitListener;
import l2s.gameserver.listener.actor.OnMagicUseListener;
import l2s.gameserver.listener.actor.OnMoveListener;
import l2s.gameserver.listener.actor.OnReviveListener;
import l2s.gameserver.listener.actor.ai.OnAiEventListener;
import l2s.gameserver.listener.actor.ai.OnAiIntentionListener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;

public class CharListenerList
extends ListenerList<Creature> {
    static final ListenerList<Creature> global = new ListenerList();
    protected final Creature actor;

    public CharListenerList(Creature actor) {
        this.actor = actor;
    }

    public Creature getActor() {
        return this.actor;
    }

    public static final boolean addGlobal(Listener<Creature> listener) {
        return global.add(listener);
    }

    public static final boolean removeGlobal(Listener<Creature> listener) {
        return global.remove(listener);
    }

    public void onAiIntention(CtrlIntention intention, Object arg0, Object arg1) {
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnAiIntentionListener.class.isInstance(listener)) continue;
                ((OnAiIntentionListener)listener).onAiIntention(this.getActor(), intention, arg0, arg1);
            }
        }
    }

    public void onAiEvent(CtrlEvent evt, Object[] args) {
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnAiEventListener.class.isInstance(listener)) continue;
                ((OnAiEventListener)listener).onAiEvent(this.getActor(), evt, args);
            }
        }
    }

    public void onAttack(Creature target) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnAttackListener.class.isInstance(listener)) continue;
                ((OnAttackListener)listener).onAttack(this.getActor(), target);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnAttackListener.class.isInstance(listener)) continue;
                ((OnAttackListener)listener).onAttack(this.getActor(), target);
            }
        }
    }

    public void onAttackHit(Creature attacker) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnAttackHitListener.class.isInstance(listener)) continue;
                ((OnAttackHitListener)listener).onAttackHit(this.getActor(), attacker);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnAttackHitListener.class.isInstance(listener)) continue;
                ((OnAttackHitListener)listener).onAttackHit(this.getActor(), attacker);
            }
        }
    }

    public void onMagicUse(Skill skill, Creature target, boolean alt) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnMagicUseListener.class.isInstance(listener)) continue;
                ((OnMagicUseListener)listener).onMagicUse(this.getActor(), skill, target, alt);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnMagicUseListener.class.isInstance(listener)) continue;
                ((OnMagicUseListener)listener).onMagicUse(this.getActor(), skill, target, alt);
            }
        }
    }

    public void onMagicHit(Skill skill, Creature caster) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnMagicHitListener.class.isInstance(listener)) continue;
                ((OnMagicHitListener)listener).onMagicHit(this.getActor(), skill, caster);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnMagicHitListener.class.isInstance(listener)) continue;
                ((OnMagicHitListener)listener).onMagicHit(this.getActor(), skill, caster);
            }
        }
    }

    public void onDeath(Creature killer) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnDeathListener.class.isInstance(listener)) continue;
                ((OnDeathListener)listener).onDeath(this.getActor(), killer);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnDeathListener.class.isInstance(listener)) continue;
                ((OnDeathListener)listener).onDeath(this.getActor(), killer);
            }
        }
    }

    public void onKill(Creature victim) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnKillListener.class.isInstance(listener) || ((OnKillListener)listener).ignorePetOrSummon()) continue;
                ((OnKillListener)listener).onKill(this.getActor(), victim);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnKillListener.class.isInstance(listener) || ((OnKillListener)listener).ignorePetOrSummon()) continue;
                ((OnKillListener)listener).onKill(this.getActor(), victim);
            }
        }
    }

    public void onKillIgnorePetOrSummon(Creature victim) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnKillListener.class.isInstance(listener) || !((OnKillListener)listener).ignorePetOrSummon()) continue;
                ((OnKillListener)listener).onKill(this.getActor(), victim);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnKillListener.class.isInstance(listener) || !((OnKillListener)listener).ignorePetOrSummon()) continue;
                ((OnKillListener)listener).onKill(this.getActor(), victim);
            }
        }
    }

    public void onCurrentHpDamage(double damage, Creature attacker, Skill skill) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnCurrentHpDamageListener.class.isInstance(listener)) continue;
                ((OnCurrentHpDamageListener)listener).onCurrentHpDamage(this.getActor(), damage, attacker, skill);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnCurrentHpDamageListener.class.isInstance(listener)) continue;
                ((OnCurrentHpDamageListener)listener).onCurrentHpDamage(this.getActor(), damage, attacker, skill);
            }
        }
    }

    public void onChangeCurrentCp(double oldCp, double newCp) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnChangeCurrentCpListener.class.isInstance(listener)) continue;
                ((OnChangeCurrentCpListener)listener).onChangeCurrentCp(this.getActor(), oldCp, newCp);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnChangeCurrentCpListener.class.isInstance(listener)) continue;
                ((OnChangeCurrentCpListener)listener).onChangeCurrentCp(this.getActor(), oldCp, newCp);
            }
        }
    }

    public void onChangeCurrentHp(double oldHp, double newHp) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnChangeCurrentHpListener.class.isInstance(listener)) continue;
                ((OnChangeCurrentHpListener)listener).onChangeCurrentHp(this.getActor(), oldHp, newHp);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnChangeCurrentHpListener.class.isInstance(listener)) continue;
                ((OnChangeCurrentHpListener)listener).onChangeCurrentHp(this.getActor(), oldHp, newHp);
            }
        }
    }

    public void onChangeCurrentMp(double oldMp, double newMp) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnChangeCurrentMpListener.class.isInstance(listener)) continue;
                ((OnChangeCurrentMpListener)listener).onChangeCurrentMp(this.getActor(), oldMp, newMp);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnChangeCurrentMpListener.class.isInstance(listener)) continue;
                ((OnChangeCurrentMpListener)listener).onChangeCurrentMp(this.getActor(), oldMp, newMp);
            }
        }
    }

    public void onDeathFromUndying(Creature killer) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnDeathFromUndyingListener.class.isInstance(listener)) continue;
                ((OnDeathFromUndyingListener)listener).onDeathFromUndying(this.getActor(), killer);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnDeathFromUndyingListener.class.isInstance(listener)) continue;
                ((OnDeathFromUndyingListener)listener).onDeathFromUndying(this.getActor(), killer);
            }
        }
    }

    public void onRevive() {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!(listener instanceof OnReviveListener)) continue;
                ((OnReviveListener)listener).onRevive(this.getActor());
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!(listener instanceof OnReviveListener)) continue;
                ((OnReviveListener)listener).onRevive(this.getActor());
            }
        }
    }

    public void onMove(Location loc) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnMoveListener.class.isInstance(listener)) continue;
                ((OnMoveListener)listener).onMove(this.getActor(), loc);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnMoveListener.class.isInstance(listener)) continue;
                ((OnMoveListener)listener).onMove(this.getActor(), loc);
            }
        }
    }

    public void onAct(String act, Object ... args) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnActorAct.class.isInstance(listener)) continue;
                ((OnActorAct)listener).onAct(this.getActor(), act, args);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnActorAct.class.isInstance(listener)) continue;
                ((OnActorAct)listener).onAct(this.getActor(), act, args);
            }
        }
    }
}


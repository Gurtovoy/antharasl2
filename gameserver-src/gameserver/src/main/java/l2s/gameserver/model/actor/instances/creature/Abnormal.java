/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.actor.instances.creature;

import java.util.Collection;
import java.util.Iterator;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicInteger;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.listener.actor.OnAttackListener;
import l2s.gameserver.listener.actor.OnMagicUseListener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.AbnormalStatusUpdatePacket;
import l2s.gameserver.network.l2.s2c.ExAbnormalStatusUpdateFromTargetPacket;
import l2s.gameserver.network.l2.s2c.ExMagicAttackInfo;
import l2s.gameserver.network.l2.s2c.ExOlympiadSpelledInfoPacket;
import l2s.gameserver.network.l2.s2c.PartySpelledPacket;
import l2s.gameserver.network.l2.s2c.ShortBuffStatusUpdatePacket;
import l2s.gameserver.network.l2.s2c.SystemMessage;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.AbnormalEffect;
import l2s.gameserver.skills.AbnormalType;
import l2s.gameserver.skills.EffectUseType;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.triggers.TriggerType;
import l2s.gameserver.taskmanager.EffectTaskManager;
import l2s.gameserver.templates.skill.EffectTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class Abnormal
implements Runnable,
Comparable<Abnormal> {
    private static final Logger _log = LoggerFactory.getLogger(Abnormal.class);
    private static final int SUSPENDED = -1;
    private static final int STARTING = 0;
    private static final int ACTING = 1;
    private static final int FINISHED = 2;
    private final Creature _effector;
    private final Creature _effected;
    private final Skill _skill;
    private final Env _env;
    private final EffectUseType _useType;
    private final Collection<EffectHandler> _effects = new ConcurrentLinkedQueue<EffectHandler>();
    private final AtomicInteger _state;
    private final boolean _saveable;
    private Future<?> _effectTask;
    private long _startTimeMillis = Long.MAX_VALUE;
    private int _duration;
    private int _timeLeft;
    private ActionDispelListener _listener;

    public Abnormal(Creature effector, Creature effected, Skill skill, EffectUseType useType, boolean saveable) {
        this._effector = effector;
        this._effected = effected;
        this._skill = skill;
        this._env = new Env(effector, effected, skill);
        this._useType = useType;
        this._timeLeft = this._duration = Math.min(Integer.MAX_VALUE, Math.max(0, this.getSkill().getAbnormalTime() < 0 ? Integer.MAX_VALUE : this.getSkill().getAbnormalTime()));
        this._state = new AtomicInteger(0);
        this._saveable = saveable;
        for (EffectTemplate template : this.getSkill().getEffectTemplates(this.getUseType())) {
            if (template.isInstant() || !this.isOfUseType(template.getUseType()) || !template.getTargetType().checkTarget(effected)) continue;
            this._effects.add(template.getHandler().getImpl());
        }
    }

    public Abnormal(Creature effector, Creature effected, Abnormal abnormal) {
        this(effector, effected, abnormal.getSkill(), abnormal.getUseType(), true);
    }

    public Env getEnv() {
        return this._env;
    }

    public Skill getSkill() {
        return this._skill;
    }

    public AbnormalType getAbnormalType() {
        return this.getSkill().getAbnormalType();
    }

    public int getAbnormalLvl() {
        return this.getSkill().getAbnormalLvl();
    }

    public Creature getEffector() {
        return this._effector;
    }

    public Creature getEffected() {
        return this._effected;
    }

    public boolean isReflected() {
        return this._env.reflected;
    }

    public long getStartTime() {
        return this._startTimeMillis;
    }

    public int getTimeLeft() {
        return this._timeLeft;
    }

    public void setTimeLeft(int value) {
        this._timeLeft = Math.max(0, Math.min(value, this._duration));
    }

    public boolean isTimeLeft() {
        return this.getTimeLeft() > 0;
    }

    public Collection<EffectHandler> getEffects() {
        return this._effects;
    }

    public boolean isActive() {
        return this.getState() == 1;
    }

    public boolean isSuspended() {
        return this.getState() == -1;
    }

    public boolean checkAbnormalType(AbnormalType abnormal) {
        AbnormalType abnormalType = this.getAbnormalType();
        if (abnormalType == AbnormalType.NONE) {
            return false;
        }
        return abnormal == abnormalType;
    }

    public boolean checkAbnormalType(Abnormal effect) {
        return this.checkAbnormalType(effect.getAbnormalType());
    }

    public boolean isFinished() {
        return this.getState() == 2;
    }

    private int getState() {
        return this._state.get();
    }

    private boolean setState(int oldState, int newState) {
        return this._state.compareAndSet(oldState, newState);
    }

    private boolean checkCondition() {
        for (EffectHandler effect : this.getEffects()) {
            if (!effect.checkConditionImpl(this, this.getEffector(), this.getEffected())) {
                return false;
            }
            int chance = effect.getTemplate().getChance();
            if (chance < 0 || Rnd.chance((int)chance)) continue;
            return false;
        }
        return true;
    }

    private boolean checkActingCondition() {
        for (EffectHandler effect : this.getEffects()) {
            if (effect.checkActingConditionImpl(this, this.getEffector(), this.getEffected())) continue;
            return false;
        }
        return true;
    }

    private void onStart() {
        if (this.getSkill().isAbnormalCancelOnAction() && this.getEffected().isPlayable()) {
            this._listener = new ActionDispelListener();
            this.getEffected().addListener(this._listener);
        }
        if (this.getEffected().isPlayer() && !this.getSkill().canUseTeleport()) {
            this.getEffected().getPlayer().getPlayerAccess().UseTeleport = false;
        }
        for (AbnormalEffect abnormal : this.getSkill().getAbnormalEffects()) {
            this.getEffected().startAbnormalEffect(abnormal);
        }
        for (EffectHandler effect : this.getEffects()) {
            effect.onStart(this, this.getEffector(), this.getEffected());
            this.getEffected().getStat().addFuncs(effect.getStatFuncs());
            this.getEffected().addTriggers(effect.getTemplate());
            this.getEffected().useTriggers((GameObject)this.getEffected(), TriggerType.ON_START_EFFECT, null, this.getSkill(), effect.getTemplate(), 0.0);
        }
    }

    private void onExit() {
        if (this.getSkill().isAbnormalCancelOnAction()) {
            this.getEffected().removeListener(this._listener);
        }
        if (this.getEffected().isPlayer()) {
            if (this.checkAbnormalType(AbnormalType.HP_RECOVER)) {
                this.getEffected().sendPacket((IBroadcastPacket)new ShortBuffStatusUpdatePacket());
            }
            if (!this.getSkill().canUseTeleport() && !this.getEffected().getPlayer().getPlayerAccess().UseTeleport) {
                this.getEffected().getPlayer().getPlayerAccess().UseTeleport = true;
            }
        }
        for (AbnormalEffect abnormal : this.getSkill().getAbnormalEffects()) {
            if (abnormal == AbnormalEffect.NONE) continue;
            this.getEffected().stopAbnormalEffect(abnormal);
        }
        for (EffectHandler effect : this.getEffects()) {
            effect.onExit(this, this.getEffector(), this.getEffected());
            this.getEffected().getStat().removeFuncsByOwner(effect);
            this.getEffected().removeTriggers(effect.getTemplate());
            this.getEffected().useTriggers((GameObject)this.getEffected(), TriggerType.ON_EXIT_EFFECT, null, this.getSkill(), effect.getTemplate(), 0.0);
        }
    }

    private void stopEffectTask() {
        if (this._effectTask != null) {
            this._effectTask.cancel(false);
            this._effectTask = null;
        }
    }

    private void startEffectTask() {
        if (this._effectTask == null) {
            this._startTimeMillis = System.currentTimeMillis();
            this._effectTask = EffectTaskManager.getInstance().scheduleAtFixedRate(this, 1000L, 1000L);
        }
    }

    public void restart() {
        this._timeLeft = this.getDuration();
        this.stopEffectTask();
        this.startEffectTask();
    }

    public boolean apply(Creature aimingTarget) {
        if (this._effects.isEmpty()) {
            return false;
        }
        if (this.getEffected().isDead() && !this.getSkill().isPreservedOnDeath()) {
            return false;
        }
        if (!this.checkCondition()) {
            return false;
        }
        if (this.getEffector() != this.getEffected() && this.isOfUseType(EffectUseType.NORMAL)) {
            if (this.getEffected().isEffectImmune(this.getEffector())) {
                return false;
            }
            if (this.getEffected().isBuffImmune() && !this.isOffensive() || this.getEffected().isDebuffImmune() && this.isOffensive()) {
                for (Abnormal abnormal : this.getEffected().getAbnormalList()) {
                    if (abnormal.checkDebuffImmunity()) break;
                }
                if (!this.isHidden() && !this.getSkill().isHideStartMessage() && this.getEffected() == aimingTarget) {
                    this.getEffector().sendPacket((IBroadcastPacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.C1_HAS_RESISTED_YOUR_S2).addName(this.getEffected())).addSkillName(this.getSkill().getDisplayId(), this.getSkill().getDisplayLevel()));
                    this.getEffector().sendPacket((IBroadcastPacket)new ExMagicAttackInfo(this.getEffector().getObjectId(), this.getEffected().getObjectId(), 6));
                }
                return false;
            }
        }
        if (!this.getEffected().getAbnormalList().add(this)) {
            return false;
        }
        if (!this.isHidden() && !this.getSkill().isHideStartMessage()) {
            this.getEffected().sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1S_EFFECT_CAN_BE_FELT).addSkillName(this.getDisplayId(), this.getDisplayLevel()));
        }
        return true;
    }

    
    public void suspend() {
        if (this.setState(0, -1)) {
            this.startEffectTask();
        } else if (this.setState(1, -1)) {
            Abnormal abnormal = this;
            synchronized (abnormal) {
                this.onExit();
            }
        }
    }

    
    public void start() {
        if (this.setState(-1, 1)) {
            Abnormal abnormal = this;
            synchronized (abnormal) {
                this.onStart();
            }
        }
        if (this.setState(0, 1)) {
            Abnormal abnormal = this;
            synchronized (abnormal) {
                this.onStart();
                this.startEffectTask();
            }
        }
    }

    
    @Override
    public void run() {
        --this._timeLeft;
        if (this.getState() == -1) {
            if (this.isTimeLeft()) {
                return;
            }
            this.exit();
            return;
        }
        boolean successActing = true;
        if (this.getState() == 1 && this.isTimeLeft() && this.checkActingCondition()) {
            for (EffectHandler effect : this.getEffects()) {
                if (this.getTimeLeft() % effect.getInterval() != 0 || (successActing = effect.onActionTime(this, this.getEffector(), this.getEffected()))) continue;
                break;
            }
            if (successActing) {
                return;
            }
        }
        if (this.getDuration() == Integer.MAX_VALUE && this.checkActingCondition()) {
            for (EffectHandler effect : this.getEffects()) {
                if (this.getDuration() % effect.getInterval() != 0 || (successActing = effect.onActionTime(this, this.getEffector(), this.getEffected()))) continue;
                break;
            }
            if (successActing) {
                this._timeLeft = this.getDuration();
                return;
            }
        }
        if (this.setState(1, 2)) {
            if (this.checkActingCondition()) {
                for (EffectHandler effect : this.getEffects()) {
                    if (this.getDuration() % effect.getInterval() != 0) continue;
                    effect.onActionTime(this, this.getEffector(), this.getEffected());
                }
            }
            Object iterator = this;
            synchronized (iterator) {
                this.stopEffectTask();
                this.onExit();
            }
            boolean lastEffect = this.getEffected().getAbnormalList().getCount(this.getSkill()) == 1;
            boolean msg = successActing && !this.isHidden() && lastEffect;
            this.getEffected().getAbnormalList().remove(this);
            if (msg) {
                this.getEffected().sendPacket((IBroadcastPacket)new SystemMessage(92).addSkillName(this.getDisplayId(), this.getDisplayLevel()));
            }
            if (lastEffect) {
                this.getSkill().onAbnormalTimeEnd(this.getEffector(), this.getEffected());
            }
            for (EffectHandler effect : this.getEffects()) {
                this.getEffected().useTriggers((GameObject)this.getEffected(), TriggerType.ON_FINISH_EFFECT, null, this.getSkill(), effect.getTemplate(), 0.0);
            }
        }
    }

    
    public void exit() {
        if (this.setState(0, 2)) {
            this.getEffected().getAbnormalList().remove(this);
        } else if (this.setState(-1, 2)) {
            this.stopEffectTask();
        } else if (this.setState(1, 2)) {
            Abnormal abnormal = this;
            synchronized (abnormal) {
                this.stopEffectTask();
                this.onExit();
            }
            this.getEffected().getAbnormalList().remove(this);
        }
    }

    public void addIcon(AbnormalStatusUpdatePacket abnormalStatus) {
        if (!this.isActive() || this.isHidden()) {
            return;
        }
        int duration = this.isHideTime() ? -1 : this.getTimeLeft();
        abnormalStatus.addEffect(this.getDisplayId(), this.getDisplayLevel(), this.getAbnormalType().getClientId(), duration);
    }

    public void addIcon(ExAbnormalStatusUpdateFromTargetPacket abnormalStatus) {
        if (!this.isActive() || this.isHidden()) {
            return;
        }
        int duration = this.isHideTime() ? -1 : this.getTimeLeft();
        abnormalStatus.addEffect(this.getEffector().getObjectId(), this.getDisplayId(), this.getDisplayLevel(), this.getAbnormalType().getClientId(), duration);
    }

    public void addPartySpelledIcon(PartySpelledPacket ps) {
        if (!this.isActive() || this.isHidden()) {
            return;
        }
        int duration = this.isHideTime() ? -1 : this.getTimeLeft();
        ps.addPartySpelledEffect(this.getDisplayId(), this.getDisplayLevel(), this.getAbnormalType().getClientId(), duration);
    }

    public void addOlympiadSpelledIcon(Player player, ExOlympiadSpelledInfoPacket os) {
        if (!this.isActive() || this.isHidden()) {
            return;
        }
        int duration = this.isHideTime() ? -1 : this.getTimeLeft();
        os.addSpellRecivedPlayer(player);
        os.addEffect(this.getDisplayId(), this.getDisplayLevel(), this.getAbnormalType().getClientId(), duration);
    }

    @Override
    public int compareTo(Abnormal obj) {
        if (obj.equals(this)) {
            return 0;
        }
        return 1;
    }

    public boolean isCancelable() {
        return this.getSkill().isCancelable() && !this.isHidden();
    }

    public boolean isSelfDispellable() {
        return this.getSkill().isSelfDispellable() && !this.isHidden();
    }

    public int getId() {
        return this.getSkill().getId();
    }

    public int getLevel() {
        return this.getSkill().getLevel();
    }

    public int getDisplayId() {
        return this.getSkill().getDisplayId();
    }

    public int getDisplayLevel() {
        return this.getSkill().getDisplayLevel();
    }

    public String toString() {
        return "Skill: " + this.getSkill() + ", state: " + this.getState() + ", active : " + this.isActive();
    }

    public boolean checkBlockedAbnormalType(AbnormalType abnormal) {
        for (EffectHandler effect : this.getEffects()) {
            if (!effect.checkBlockedAbnormalType(this, this.getEffector(), this.getEffected(), abnormal)) continue;
            return true;
        }
        return false;
    }

    public boolean checkDebuffImmunity() {
        for (EffectHandler effect : this.getEffects()) {
            if (!effect.checkDebuffImmunity(this, this.getEffector(), this.getEffected())) continue;
            return true;
        }
        return false;
    }

    public boolean isHidden() {
        if (this.getDisplayId() < 0) {
            return true;
        }
        for (EffectHandler effect : this.getEffects()) {
            if (!effect.isHidden()) continue;
            return true;
        }
        return false;
    }

    public boolean isSaveable() {
        if (!this._saveable || !this.getSkill().isSaveable() || this.getTimeLeft() < Config.ALT_SAVE_EFFECTS_REMAINING_TIME || this.isHidden()) {
            return false;
        }
        for (EffectHandler effect : this.getEffects()) {
            if (effect.isSaveable()) continue;
            return false;
        }
        return true;
    }

    public EffectUseType getUseType() {
        return this._useType;
    }

    public boolean isOfUseType(EffectUseType useType) {
        return this._useType == useType;
    }

    public boolean isOffensive() {
        if (this.isOfUseType(EffectUseType.SELF)) {
            return this.getSkill().isSelfDebuff();
        }
        return this.getSkill().isDebuff();
    }

    public int getDuration() {
        return this._duration;
    }

    public void setDuration(int value) {
        this._timeLeft = this._duration = Math.min(Integer.MAX_VALUE, Math.max(0, value));
    }

    public boolean isHideTime() {
        return this.getSkill().isAbnormalHideTime() || this.getDuration() == Integer.MAX_VALUE;
    }

    private class ActionDispelListener
    implements OnAttackListener,
    OnMagicUseListener {
        private ActionDispelListener() {
        }

        @Override
        public void onMagicUse(Creature actor, Skill skill, Creature target, boolean alt) {
            if (Abnormal.this.getSkill().isDoNotDispelOnSelfBuff() && !skill.isDebuff()) {
                return;
            }
            Abnormal.this.exit();
        }

        @Override
        public void onAttack(Creature actor, Creature target) {
            Abnormal.this.exit();
        }
    }
}


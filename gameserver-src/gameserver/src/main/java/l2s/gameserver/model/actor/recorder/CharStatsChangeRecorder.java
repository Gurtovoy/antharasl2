/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.actor.recorder;

import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;
import java.util.concurrent.atomic.AtomicBoolean;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.base.TeamType;
import l2s.gameserver.skills.AbnormalEffect;

public class CharStatsChangeRecorder<T extends Creature> {
    public static final int BROADCAST_CHAR_INFO = 1;
    public static final int SEND_CHAR_INFO = 2;
    public static final int SEND_STATUS_INFO = 4;
    public static final int SEND_ABNORMAL_INFO = 8;
    public static final int SEND_TRANSFORMATION_INFO = 16;
    public static final int FORCE_BROADCAST_CHAR_INFO = 32;
    protected final T _activeChar;
    private AtomicBoolean _blocked = new AtomicBoolean();
    protected int _level;
    protected int _pAccuracy;
    protected int _mAccuracy;
    protected int _attackSpeed;
    protected int _castSpeed;
    protected int _pCriticalHit;
    protected int _mCriticalHit;
    protected int _pEvasion;
    protected int _mEvasion;
    protected int _magicAttack;
    protected int _magicDefence;
    protected int _maxHp;
    protected int _maxMp;
    protected int _physicAttack;
    protected int _physicDefence;
    protected int _moveSpeed;
    protected int _visualTransformId;
    protected double _collisionRadius;
    protected double _collisionHeight;
    protected Set<AbnormalEffect> _abnormalEffects = new CopyOnWriteArraySet<AbnormalEffect>();
    protected TeamType _team;
    protected int _changes;

    public CharStatsChangeRecorder(T actor) {
        this._activeChar = actor;
    }

    protected int set(int flag, int oldValue, int newValue) {
        if (oldValue != newValue) {
            this._changes |= flag;
        }
        return newValue;
    }

    protected long set(int flag, long oldValue, long newValue) {
        if (oldValue != newValue) {
            this._changes |= flag;
        }
        return newValue;
    }

    protected double set(int flag, double oldValue, double newValue) {
        if (oldValue != newValue) {
            this._changes |= flag;
        }
        return newValue;
    }

    protected String set(int flag, String oldValue, String newValue) {
        if (!oldValue.equals(newValue)) {
            this._changes |= flag;
        }
        return newValue;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    protected Set<AbnormalEffect> set(int flag, Set<AbnormalEffect> oldValue, Set<AbnormalEffect> newValue) {
        Set<AbnormalEffect> set = oldValue;
        synchronized (set) {
            if (oldValue.size() != newValue.size() || !newValue.equals(oldValue)) {
                this._changes |= flag;
                oldValue.clear();
                oldValue.addAll(newValue);
            }
        }
        return oldValue;
    }

    protected <E extends Enum<E>> E set(int flag, E oldValue, E newValue) {
        if (oldValue != newValue) {
            this._changes |= flag;
        }
        return newValue;
    }

    protected void refreshStats() {
        this._pAccuracy = this.set(2, this._pAccuracy, ((Creature)this._activeChar).getPAccuracy());
        this._mAccuracy = this.set(2, this._mAccuracy, ((Creature)this._activeChar).getMAccuracy());
        this._attackSpeed = this.set(1, this._attackSpeed, ((Creature)this._activeChar).getPAtkSpd());
        this._castSpeed = this.set(1, this._castSpeed, ((Creature)this._activeChar).getMAtkSpd());
        this._pCriticalHit = this.set(2, this._pCriticalHit, ((Creature)this._activeChar).getPCriticalHit(null));
        this._mCriticalHit = this.set(2, this._mCriticalHit, ((Creature)this._activeChar).getMCriticalHit(null, null));
        this._pEvasion = this.set(2, this._pEvasion, ((Creature)this._activeChar).getPEvasionRate(null));
        this._mEvasion = this.set(2, this._mEvasion, ((Creature)this._activeChar).getMEvasionRate(null));
        this._moveSpeed = this.set(1, this._moveSpeed, ((Creature)this._activeChar).getMoveSpeed());
        this._physicAttack = this.set(2, this._physicAttack, ((Creature)this._activeChar).getPAtk(null));
        this._physicDefence = this.set(2, this._physicDefence, ((Creature)this._activeChar).getPDef(null));
        this._magicAttack = this.set(2, this._magicAttack, ((Creature)this._activeChar).getMAtk(null, null));
        this._magicDefence = this.set(2, this._magicDefence, ((Creature)this._activeChar).getMDef(null, null));
        this._maxHp = this.set(4, this._maxHp, ((Creature)this._activeChar).getMaxHp());
        this._maxMp = this.set(4, this._maxMp, ((Creature)this._activeChar).getMaxMp());
        this._level = this.set(2, this._level, ((Creature)this._activeChar).getLevel());
        this._abnormalEffects = this.set(8, this._abnormalEffects, ((Creature)this._activeChar).getAbnormalEffects());
        this._visualTransformId = this.set(16, this._visualTransformId, ((Creature)this._activeChar).getVisualTransformId());
        this._collisionRadius = this.set(32, this._collisionRadius, ((GameObject)this._activeChar).getCurrentCollisionRadius());
        this._collisionHeight = this.set(32, this._collisionHeight, ((GameObject)this._activeChar).getCurrentCollisionHeight());
        this._team = this.set(1, this._team, ((Creature)this._activeChar).getTeam());
    }

    public final void sendChanges() {
        if (this._blocked.get()) {
            return;
        }
        this.refreshStats();
        this.onSendChanges();
        this._changes = 0;
    }

    protected void onSendChanges() {
        if ((this._changes & 4) == 4) {
            ((Creature)this._activeChar).broadcastStatusUpdate();
        }
    }

    public void block() {
        this._blocked.compareAndSet(false, true);
    }

    public void unblock() {
        this._blocked.compareAndSet(true, false);
    }
}


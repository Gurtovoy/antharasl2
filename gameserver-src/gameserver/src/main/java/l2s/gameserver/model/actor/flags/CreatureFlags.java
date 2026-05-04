package l2s.gameserver.model.actor.flags;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.actor.flags.flag.DefaultFlag;
import l2s.gameserver.model.actor.flags.flag.UndyingFlag;

public class CreatureFlags {
    private final Creature _owner;
    private final DefaultFlag _afraid = new DefaultFlag();
    private final DefaultFlag _muted = new DefaultFlag();
    private final DefaultFlag _pmuted = new DefaultFlag();
    private final DefaultFlag _amuted = new DefaultFlag();
    private final DefaultFlag _paralyzed = new DefaultFlag();
    private final DefaultFlag _sleeping = new DefaultFlag();
    private final DefaultFlag _stunned = new DefaultFlag();
    private final DefaultFlag _immobilized = new DefaultFlag();
    private final DefaultFlag _confused = new DefaultFlag();
    private final DefaultFlag _frozen = new DefaultFlag();
    private final DefaultFlag _knockDowned = new DefaultFlag();
    private final DefaultFlag _knockBacked = new DefaultFlag();
    private final DefaultFlag _flyUp = new DefaultFlag();
    private final DefaultFlag _healBlocked = new DefaultFlag();
    private final DefaultFlag _damageBlocked = new DefaultFlag();
    private final DefaultFlag _buffImmunity = new DefaultFlag();
    private final DefaultFlag _debuffImmunity = new DefaultFlag();
    private final DefaultFlag _effectImmunity = new DefaultFlag();
    private final DefaultFlag _deathImmunity = new DefaultFlag();
    private final DefaultFlag _distortedSpace = new DefaultFlag();
    private final DefaultFlag _invisible = new DefaultFlag();
    private final DefaultFlag _invulnerable = new DefaultFlag();
    private final DefaultFlag _weaponEquipBlocked = new DefaultFlag();
    private final UndyingFlag _undying = new UndyingFlag();

    public CreatureFlags(Creature owner) {
        this._owner = owner;
    }

    public DefaultFlag getAfraid() {
        return this._afraid;
    }

    public DefaultFlag getMuted() {
        return this._muted;
    }

    public DefaultFlag getPMuted() {
        return this._pmuted;
    }

    public DefaultFlag getAMuted() {
        return this._amuted;
    }

    public DefaultFlag getParalyzed() {
        return this._paralyzed;
    }

    public DefaultFlag getSleeping() {
        return this._sleeping;
    }

    public DefaultFlag getStunned() {
        return this._stunned;
    }

    public DefaultFlag getImmobilized() {
        return this._immobilized;
    }

    public DefaultFlag getConfused() {
        return this._confused;
    }

    public DefaultFlag getFrozen() {
        return this._frozen;
    }

    public DefaultFlag getKnockDowned() {
        return this._knockDowned;
    }

    public DefaultFlag getKnockBacked() {
        return this._knockBacked;
    }

    public DefaultFlag getFlyUp() {
        return this._flyUp;
    }

    public DefaultFlag getHealBlocked() {
        return this._healBlocked;
    }

    public DefaultFlag getDamageBlocked() {
        return this._damageBlocked;
    }

    public DefaultFlag getBuffImmunity() {
        return this._buffImmunity;
    }

    public DefaultFlag getDebuffImmunity() {
        return this._debuffImmunity;
    }

    public DefaultFlag getEffectImmunity() {
        return this._effectImmunity;
    }

    public DefaultFlag getDeathImmunity() {
        return this._deathImmunity;
    }

    public DefaultFlag getDistortedSpace() {
        return this._distortedSpace;
    }

    public DefaultFlag getInvisible() {
        return this._invisible;
    }

    public DefaultFlag getInvulnerable() {
        return this._invulnerable;
    }

    public DefaultFlag getWeaponEquipBlocked() {
        return this._weaponEquipBlocked;
    }

    public UndyingFlag getUndying() {
        return this._undying;
    }
}


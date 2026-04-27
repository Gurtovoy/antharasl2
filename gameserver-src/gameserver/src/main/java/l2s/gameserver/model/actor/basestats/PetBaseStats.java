/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.actor.basestats;

import l2s.gameserver.model.actor.basestats.PlayableBaseStats;
import l2s.gameserver.model.instances.PetInstance;

public class PetBaseStats
extends PlayableBaseStats {
    public PetBaseStats(PetInstance owner) {
        super(owner);
    }

    @Override
    public PetInstance getOwner() {
        return (PetInstance)this._owner;
    }

    @Override
    public double getHpMax() {
        return this.getOwner().getData().getHP(this.getOwner().getLevel());
    }

    @Override
    public double getMpMax() {
        return this.getOwner().getData().getMP(this.getOwner().getLevel());
    }

    @Override
    public double getHpReg() {
        return this.getOwner().getData().getHPRegen(this.getOwner().getLevel());
    }

    @Override
    public double getMpReg() {
        return this.getOwner().getData().getMPRegen(this.getOwner().getLevel());
    }

    @Override
    public double getPAtk() {
        return this.getOwner().getData().getPAtk(this.getOwner().getLevel());
    }

    @Override
    public double getMAtk() {
        return this.getOwner().getData().getMAtk(this.getOwner().getLevel());
    }

    @Override
    public double getPDef() {
        return this.getOwner().getData().getPDef(this.getOwner().getLevel());
    }

    @Override
    public double getMDef() {
        return this.getOwner().getData().getMDef(this.getOwner().getLevel());
    }
}


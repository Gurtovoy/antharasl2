/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.collections.MultiValueSet
 */
package l2s.gameserver.model.instances.residences;

import java.util.Set;
import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.data.xml.holder.NpcHolder;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.Spawner;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.templates.npc.NpcTemplate;

public abstract class SiegeToggleNpcInstance
extends NpcInstance {
    private NpcInstance _fakeInstance;
    private int _maxHp;

    public SiegeToggleNpcInstance(int objectId, NpcTemplate template, MultiValueSet<String> set) {
        super(objectId, template, set);
        this.setHasChatWindow(false);
    }

    public void setMaxHp(int maxHp) {
        this._maxHp = maxHp;
    }

    public void setZoneList(Set<String> set) {
    }

    public void register(Spawner spawn) {
    }

    public void initFake(int fakeNpcId) {
        this._fakeInstance = NpcHolder.getInstance().getTemplate(fakeNpcId).getNewInstance();
        this._fakeInstance.setCurrentHpMp(1.0, this._fakeInstance.getMaxMp());
        this._fakeInstance.setHasChatWindow(false);
    }

    public abstract void onDeathImpl(Creature var1);

    @Override
    protected void onReduceCurrentHp(double damage, Creature attacker, Skill skill, boolean awake, boolean standUp, boolean directHp, boolean isDot) {
        this.setCurrentHp(Math.max(this.getCurrentHp() - damage, 0.0), false);
        if (this.getCurrentHp() < 0.5) {
            this.doDie(attacker);
            this.onDeathImpl(attacker);
            this.decayMe();
            this._fakeInstance.spawnMe(this.getLoc());
        }
    }

    @Override
    public boolean isAutoAttackable(Creature attacker) {
        if (attacker == null) {
            return false;
        }
        Player player = attacker.getPlayer();
        if (player == null) {
            return false;
        }
        for (SiegeEvent siegeEvent : this.getEvents(SiegeEvent.class)) {
            if (!siegeEvent.isInProgress() || siegeEvent.getSiegeClan("defenders", player.getClan()) != null) continue;
            return true;
        }
        return false;
    }

    @Override
    public boolean isAttackable(Creature attacker) {
        return this.isAutoAttackable(attacker);
    }

    @Override
    public boolean isPeaceNpc() {
        return false;
    }

    @Override
    public boolean hasRandomAnimation() {
        return false;
    }

    @Override
    public boolean isFearImmune() {
        return true;
    }

    @Override
    public boolean isParalyzeImmune() {
        return true;
    }

    @Override
    public boolean isLethalImmune() {
        return true;
    }

    public void decayFake() {
        this._fakeInstance.decayMe();
    }

    @Override
    public int getMaxHp() {
        return this._maxHp;
    }

    @Override
    protected void onDecay() {
        this.decayMe();
        this._spawnAnimation = 2;
    }

    @Override
    public Clan getClan() {
        return null;
    }
}


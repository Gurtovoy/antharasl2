/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.instances;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.ScheduledFuture;
import l2s.commons.lang.reference.HardReference;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.model.instances.MonsterInstance;
import l2s.gameserver.network.l2.s2c.AutoAttackStartPacket;
import l2s.gameserver.network.l2.s2c.CIPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.npc.NpcTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DecoyInstance
extends MonsterInstance {
    private static final Logger _log = LoggerFactory.getLogger(DecoyInstance.class);
    private HardReference<Player> _playerRef;
    private int _lifeTime;
    private int _timeRemaining;
    private ScheduledFuture<?> _decoyLifeTask;
    private ScheduledFuture<?> _hateSpam;

    public DecoyInstance(int objectId, NpcTemplate template, Player owner, int lifeTime) {
        super(objectId, template, StatsSet.EMPTY);
        this._playerRef = owner.getRef();
        this._timeRemaining = this._lifeTime = lifeTime;
        int skilllevel = this.getNpcId() < 13257 ? this.getNpcId() - 13070 : this.getNpcId() - 13250;
        this._decoyLifeTask = ThreadPoolManager.getInstance().scheduleAtFixedRate(new DecoyLifetime(), 1000L, 1000L);
        this._hateSpam = ThreadPoolManager.getInstance().scheduleAtFixedRate(new HateSpam(SkillEntry.makeSkillEntry(SkillEntryType.NONE, 5272, skilllevel)), 1000L, 3000L);
    }

    @Override
    protected void onDeath(Creature killer) {
        super.onDeath(killer);
        if (this._hateSpam != null) {
            this._hateSpam.cancel(false);
            this._hateSpam = null;
        }
        this._lifeTime = 0;
    }

    public void unSummon() {
        if (this._decoyLifeTask != null) {
            this._decoyLifeTask.cancel(false);
            this._decoyLifeTask = null;
        }
        if (this._hateSpam != null) {
            this._hateSpam.cancel(false);
            this._hateSpam = null;
        }
        this.deleteMe();
    }

    public void decTimeRemaining(int value) {
        this._timeRemaining -= value;
    }

    public int getTimeRemaining() {
        return this._timeRemaining;
    }

    @Override
    public int getLifeTime() {
        return this._lifeTime;
    }

    @Override
    public Player getPlayer() {
        return this._playerRef == null ? null : (Player)this._playerRef.get();
    }

    @Override
    public boolean isAutoAttackable(Creature attacker) {
        Player owner = this.getPlayer();
        return owner != null && owner.isAutoAttackable(attacker);
    }

    @Override
    public boolean isAttackable(Creature attacker) {
        Player owner = this.getPlayer();
        return owner != null && owner.isAttackable(attacker);
    }

    @Override
    protected void onDelete() {
        Player owner = this.getPlayer();
        if (owner != null) {
            owner.removeDecoy(this);
        }
        super.onDelete();
    }

    @Override
    public void onAction(Player player, boolean shift) {
        if (player.getTarget() != this) {
            player.setTarget(this);
        } else if (this.isAutoAttackable(player)) {
            player.getAI().Attack(this, false, shift);
        }
    }

    @Override
    public double getCollisionRadius() {
        Player player = this.getPlayer();
        if (player == null) {
            return 0.0;
        }
        return player.getCollisionRadius();
    }

    @Override
    public double getCollisionHeight() {
        Player player = this.getPlayer();
        if (player == null) {
            return 0.0;
        }
        return player.getCollisionHeight();
    }

    @Override
    public List<L2GameServerPacket> addPacketList(Player forPlayer, Creature dropper) {
        if (!this.isInCombat()) {
            return Collections.singletonList(new CIPacket(this, forPlayer));
        }
        ArrayList<L2GameServerPacket> list = new ArrayList<L2GameServerPacket>(2);
        list.add(new CIPacket(this, forPlayer));
        list.add(new AutoAttackStartPacket(this.objectId));
        return list;
    }

    @Override
    public boolean isPeaceNpc() {
        return false;
    }

    public void transferOwnerBuffs() {
        Collection<Abnormal> abnormals = this.getPlayer().getAbnormalList().values();
        for (Abnormal a : abnormals) {
            Skill skill = a.getSkill();
            if (a.isOffensive() || skill.isToggle() || skill.isCubicSkill()) continue;
            Abnormal abnormal = new Abnormal(a.getEffector(), this, a);
            abnormal.setDuration(a.getDuration());
            abnormal.setTimeLeft(a.getTimeLeft());
            this.getAbnormalList().add(abnormal);
        }
    }

    class HateSpam
    implements Runnable {
        private SkillEntry _skillEntry;

        HateSpam(SkillEntry skillEntry) {
            this._skillEntry = skillEntry;
        }

        @Override
        public void run() {
            DecoyInstance.this.setTarget(DecoyInstance.this);
            DecoyInstance.this.doCast(this._skillEntry, DecoyInstance.this, true);
        }
    }

    class DecoyLifetime
    implements Runnable {
        DecoyLifetime() {
        }

        @Override
        public void run() {
            DecoyInstance.this.decTimeRemaining(1000);
            double newTimeRemaining = DecoyInstance.this.getTimeRemaining();
            if (newTimeRemaining < 0.0) {
                DecoyInstance.this.unSummon();
            }
        }
    }
}


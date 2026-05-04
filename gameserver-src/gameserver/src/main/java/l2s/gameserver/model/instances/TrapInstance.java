/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.instances;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.concurrent.ScheduledFuture;
import l2s.commons.lang.reference.HardReference;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.NpcInfoPacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.taskmanager.EffectTaskManager;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.npc.NpcTemplate;

public final class TrapInstance
extends NpcInstance {
    private final HardReference<? extends Creature> _ownerRef;
    private final SkillEntry _skillEntry;
    private ScheduledFuture<?> _targetTask;
    private boolean _detected;

    public TrapInstance(int objectId, NpcTemplate template, Creature owner, SkillEntry skillEntry) {
        this(objectId, template, owner, skillEntry, owner.getLoc());
    }

    public TrapInstance(int objectId, NpcTemplate template, Creature owner, SkillEntry skillEntry, Location loc) {
        super(objectId, template, StatsSet.EMPTY);
        this._ownerRef = owner.getRef();
        this._skillEntry = skillEntry;
        this.setReflection(owner.getReflection());
        this.setLevel(owner.getLevel());
        this.setTitle(owner.getName());
        this.setLoc(loc);
    }

    @Override
    public boolean isTrap() {
        return true;
    }

    public Creature getOwner() {
        return (Creature)this._ownerRef.get();
    }

    public SkillEntry getSkillEntry() {
        return this._skillEntry;
    }

    @Override
    protected void onSpawn() {
        super.onSpawn();
        this.startDeleteTask(120000L);
        this._targetTask = EffectTaskManager.getInstance().scheduleAtFixedRate(new CastTask(this), 250L, 250L);
    }

    @Override
    public void broadcastCharInfo() {
        if (!this.isDetected()) {
            return;
        }
        super.broadcastCharInfo();
    }

    @Override
    protected void onDelete() {
        Creature owner = this.getOwner();
        if (owner != null && owner.isPlayer()) {
            ((Player)owner).removeTrap(this);
        }
        if (this._targetTask != null) {
            this._targetTask.cancel(false);
        }
        this._targetTask = null;
        super.onDelete();
    }

    public boolean isDetected() {
        return this._detected;
    }

    public void setDetected(boolean detected) {
        this._detected = detected;
    }

    @Override
    public int getPAtk(Creature target) {
        Creature owner = this.getOwner();
        return owner == null ? 0 : owner.getPAtk(target);
    }

    @Override
    public int getMAtk(Creature target, Skill skill) {
        Creature owner = this.getOwner();
        return owner == null ? 0 : owner.getMAtk(target, skill);
    }

    @Override
    public boolean hasRandomAnimation() {
        return false;
    }

    @Override
    public boolean isAutoAttackable(Creature attacker) {
        return false;
    }

    @Override
    public boolean isAttackable(Creature attacker) {
        return false;
    }

    @Override
    public void showChatWindow(Player player, int val, boolean firstTalk, Object ... arg) {
    }

    @Override
    public void showChatWindow(Player player, String filename, boolean firstTalk, Object ... replace) {
    }

    @Override
    public void onBypassFeedback(Player player, String command) {
    }

    @Override
    public void onAction(Player player, boolean shift) {
        if (player.getTarget() != this) {
            player.setTarget(this);
        }
        player.sendActionFailed();
    }

    @Override
    public List<L2GameServerPacket> addPacketList(Player forPlayer, Creature dropper) {
        if (!this.isDetected() && this.getOwner() != forPlayer) {
            return Collections.emptyList();
        }
        ArrayList<L2GameServerPacket> list = new ArrayList<L2GameServerPacket>();
        list.add(new NpcInfoPacket(this, (Creature)forPlayer).init());
        return list;
    }

    public void selfDestroy() {
        Creature owner = this.getOwner();
        if (owner == null) {
            return;
        }
        if (this._skillEntry == null) {
            System.out.println("Trap Skill For Trap: " + this.getNpcId() + "");
            return;
        }
        for (Creature target : this.getAroundCharacters(this._skillEntry.getTemplate().getAffectRange(), 250)) {
            int fanAffectRange;
            if (target == owner || this._skillEntry == null || (fanAffectRange = this._skillEntry.getTemplate().getFanRange()[2]) > 0 && target.isInRange(owner, fanAffectRange) || this._skillEntry.checkTarget(owner, target, null, false, false) != null) continue;
            HashSet<Creature> targets = new HashSet<Creature>();
            if (this._skillEntry.getTemplate().getTargetType() != Skill.SkillTargetType.TARGET_AREA) {
                targets.add(target);
            } else {
                for (Creature t : this.getAroundCharacters(this._skillEntry.getTemplate().getAffectRange(), 128)) {
                    fanAffectRange = this._skillEntry.getTemplate().getFanRange()[2];
                    if (fanAffectRange > 0 && t.isInRange(owner, fanAffectRange) || this._skillEntry.checkTarget(owner, t, null, false, false) != null) continue;
                    targets.add(target);
                }
            }
            this._skillEntry.onEndCast(this, targets);
            if (target.isPlayer()) {
                target.sendMessage(new CustomMessage("common.Trap"));
            }
            this.deleteMe();
            break;
        }
    }

    private static class CastTask
    implements Runnable {
        private HardReference<NpcInstance> _trapRef;

        public CastTask(TrapInstance trap) {
            this._trapRef = trap.getRef();
        }

        @Override
        public void run() {
            TrapInstance trap = (TrapInstance)this._trapRef.get();
            if (trap == null) {
                return;
            }
            Creature owner = trap.getOwner();
            if (owner == null) {
                return;
            }
            SkillEntry skillEntry = trap.getSkillEntry();
            if (skillEntry == null) {
                System.out.println("Trap Skill For Trap: " + trap.getNpcId() + "");
                return;
            }
            for (Creature target : trap.getAroundCharacters(50, 50)) {
                if (target == owner || skillEntry.checkTarget(owner, target, null, false, false) != null) continue;
                HashSet<Creature> targets = new HashSet<Creature>();
                if (skillEntry.getTemplate().getTargetType() != Skill.SkillTargetType.TARGET_AREA) {
                    targets.add(target);
                } else {
                    for (Creature t : trap.getAroundCharacters(skillEntry.getTemplate().getAffectRange(), 128)) {
                        int fanAffectRange = skillEntry.getTemplate().getFanRange()[2];
                        if (fanAffectRange > 0 && t.isInRange(owner, fanAffectRange) || skillEntry.checkTarget(owner, t, null, false, false) != null) continue;
                        targets.add(target);
                    }
                }
                skillEntry.onEndCast(trap, targets);
                if (target.isPlayer()) {
                    target.sendMessage(new CustomMessage("common.Trap"));
                }
                trap.deleteMe();
                break;
            }
        }
    }
}


/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.collections.MultiValueSet
 *  l2s.commons.string.StringArrayUtils
 */
package l2s.gameserver.model.instances;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ScheduledFuture;
import l2s.commons.collections.MultiValueSet;
import l2s.commons.string.StringArrayUtils;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.templates.npc.NpcTemplate;

public class SymbolInstance
extends NpcInstance {
    private static final String DESPAWN_TIME_PARAMETER = "despawn_time";
    private static final String SKILL_DELAY_PARAMETER = "skill_delay";
    private static final String UNION_SKILL_PARAMETER = "union_skill";
    private final int _despawnTime;
    private final int _skillDelay;
    private final List<SkillEntry> _unionSkills = new ArrayList<SkillEntry>();
    private ScheduledFuture<?> _castTask;
    private int _usedSkillIndx = 0;

    public SymbolInstance(int objectId, NpcTemplate template, MultiValueSet<String> set) {
        super(objectId, template, set);
        this._despawnTime = this.getParameter(DESPAWN_TIME_PARAMETER, 120) * 1000 + 100;
        this._skillDelay = this.getParameter(SKILL_DELAY_PARAMETER, 1) * 1000;
        String skillsStr = this.getParameter(UNION_SKILL_PARAMETER, null);
        if (skillsStr != null) {
            int[][] skills;
            for (int[] skill : skills = StringArrayUtils.stringToIntArray2X((String)skillsStr, (String)";", (String)"-")) {
                if (skill.length < 2) continue;
                this._unionSkills.add(SkillEntry.makeSkillEntry(SkillEntryType.NONE, skill[0], skill[1]));
            }
        }
    }

    @Override
    public void setOwner(Player owner) {
        super.setOwner(owner);
        if (owner != null) {
            this.setLevel(owner.getLevel());
            this.setTitle(owner.getName());
        }
    }

    @Override
    protected void onSpawn() {
        super.onSpawn();
        this.startDeleteTask(this._despawnTime);
        if (this._unionSkills != null && !this._unionSkills.isEmpty()) {
            this._castTask = ThreadPoolManager.getInstance().scheduleAtFixedRate(new SkillCast(), this._skillDelay, this._skillDelay);
        }
    }

    @Override
    protected void onDelete() {
        Player owner = this.getPlayer();
        if (owner != null) {
            owner.setSymbol(null);
        }
        if (this._castTask != null) {
            this._castTask.cancel(false);
            this._castTask = null;
        }
        super.onDelete();
    }

    @Override
    public void onCastEndTime(SkillEntry skillEntry, Creature aimingTarget, Set<Creature> targets, boolean success) {
        super.onCastEndTime(skillEntry, aimingTarget, targets, success);
        ++this._usedSkillIndx;
        if (this._usedSkillIndx >= this._unionSkills.size()) {
            this._usedSkillIndx = 0;
        }
        if (this._usedSkillIndx == 0) {
            return;
        }
        this.doCast(this._unionSkills.get(this._usedSkillIndx), null, false);
    }

    @Override
    public int getPAtk(Creature target) {
        Player owner = this.getPlayer();
        return owner == null ? 0 : owner.getPAtk(target);
    }

    @Override
    public int getMAtk(Creature target, Skill skill) {
        Player owner = this.getPlayer();
        return owner == null ? 0 : owner.getMAtk(target, skill);
    }

    @Override
    public boolean hasRandomAnimation() {
        return false;
    }

    @Override
    public boolean isImmobilized() {
        return true;
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
    public Clan getClan() {
        return null;
    }

    @Override
    public boolean isHasChatWindow() {
        return false;
    }

    @Override
    public boolean isInvulnerable() {
        return !this.isTargetable(null);
    }

    @Override
    public boolean isEffectImmune(Creature caster) {
        return true;
    }

    @Override
    public boolean isSymbolInstance() {
        return true;
    }

    private class SkillCast
    implements Runnable {
        private SkillCast() {
        }

        @Override
        public void run() {
            if (SymbolInstance.this.isDead()) {
                if (SymbolInstance.this._castTask != null) {
                    SymbolInstance.this._castTask.cancel(false);
                    SymbolInstance.this._castTask = null;
                }
                return;
            }
            SymbolInstance.this.doCast((SkillEntry)SymbolInstance.this._unionSkills.get(0), null, false);
        }
    }
}


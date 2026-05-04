/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.instances;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.Future;
import l2s.commons.string.StringArrayUtils;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.data.xml.holder.PetDataHolder;
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.model.actor.instances.creature.AbnormalList;
import l2s.gameserver.model.instances.PetInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.stats.Formulas;
import l2s.gameserver.templates.npc.NpcTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class PetBabyInstance
extends PetInstance {
    private static final Logger _log = LoggerFactory.getLogger(PetBabyInstance.class);
    private Future<?> _actionTask;
    private boolean _buffEnabled = true;
    private final TIntObjectMap<List<Skill>> _activeSkills = new TIntObjectHashMap();
    private final TIntObjectMap<List<Skill>> _buffSkills = new TIntObjectHashMap();
    private static final int HealTrick = 4717;
    private static final int GreaterHealTrick = 4718;
    private static final int GreaterHeal = 5195;
    private static final int BattleHeal = 5590;
    private static final int Recharge = 5200;

    public PetBabyInstance(int objectId, NpcTemplate template, Player owner, ItemInstance control, long exp) {
        super(objectId, template, owner, control, exp);
        this.parseSkills();
    }

    public PetBabyInstance(int objectId, NpcTemplate template, Player owner, ItemInstance control) {
        super(objectId, template, owner, control);
        this.parseSkills();
    }

    private void parseSkills() {
        for (int step = 0; step < 10; ++step) {
            int skillLevel;
            int[][] skillsData;
            String data;
            int buff;
            ArrayList<Skill> skills = (ArrayList<Skill>)this._activeSkills.get(step);
            for (buff = 1; buff < 10 && (data = this.getTemplate().getAIParams().getString("step" + step + "_skill0" + buff, null)) != null; ++buff) {
                if (skills == null) {
                    skills = new ArrayList<Skill>();
                    this._activeSkills.put(step, skills);
                }
                for (int[] skillData : skillsData = StringArrayUtils.stringToIntArray2X((String)data, (String)";", (String)"-")) {
                    skillLevel = skillData.length > 1 ? skillData[1] : 1;
                    skills.add(SkillHolder.getInstance().getSkill(skillData[0], skillLevel));
                }
            }
            skills = (ArrayList<Skill>)(List)this._buffSkills.get(step);
            for (buff = 1; buff < 10 && (data = this.getTemplate().getAIParams().getString("step" + step + "_buff0" + buff, null)) != null; ++buff) {
                if (skills == null) {
                    skills = new ArrayList();
                    this._buffSkills.put(step, skills);
                }
                for (int[] skillData : skillsData = StringArrayUtils.stringToIntArray2X((String)data, (String)";", (String)"-")) {
                    skillLevel = skillData.length > 1 ? skillData[1] : 1;
                    skills.add(SkillHolder.getInstance().getSkill(skillData[0], skillLevel));
                }
            }
        }
    }

    @Override
    public List<Skill> getActiveSkills() {
        for (int step = this.getSteep(); step >= 0; --step) {
            List skills = (List)this._activeSkills.get(step);
            if (skills == null) continue;
            return skills;
        }
        return Collections.emptyList();
    }

    @Override
    public int getActiveSkillLevel(int skillId) {
        for (Skill skill : this.getActiveSkills()) {
            if (skill.getId() != skillId) continue;
            return skill.getLevel();
        }
        return super.getActiveSkillLevel(skillId);
    }

    public List<Skill> getBuffs() {
        for (int step = this.getSteep(); step >= 0; --step) {
            List skills = (List)this._buffSkills.get(step);
            if (skills == null) continue;
            return skills;
        }
        return Collections.emptyList();
    }

    private Skill getHealSkill(int hpPercent) {
        if (PetDataHolder.isImprovedBabyPet(this.getNpcId())) {
            if (hpPercent < 90) {
                if (hpPercent < 33) {
                    Skill skill = SkillHolder.getInstance().getSkill(5590, 1);
                    return SkillHolder.getInstance().getSkill(5590, Math.min(this.getSteep(), skill.getMaxLevel()));
                }
                if (this.getNpcId() != 16035) {
                    Skill skill = SkillHolder.getInstance().getSkill(5195, 1);
                    return SkillHolder.getInstance().getSkill(5195, Math.min(this.getSteep(), skill.getMaxLevel()));
                }
            }
        } else if (PetDataHolder.isBabyPet(this.getNpcId())) {
            if (hpPercent < 90) {
                if (hpPercent < 33) {
                    Skill skill = SkillHolder.getInstance().getSkill(4718, 1);
                    return SkillHolder.getInstance().getSkill(4718, Math.min(this.getSteep(), skill.getMaxLevel()));
                }
                Skill skill = SkillHolder.getInstance().getSkill(4717, 1);
                return SkillHolder.getInstance().getSkill(4717, Math.min(this.getSteep(), skill.getMaxLevel()));
            }
        } else {
            switch (this.getNpcId()) {
                case 16045: 
                case 16052: {
                    if (hpPercent >= 70) break;
                    if (hpPercent < 30) {
                        Skill skill = SkillHolder.getInstance().getSkill(5590, 1);
                        return SkillHolder.getInstance().getSkill(5590, Math.min(this.getSteep(), skill.getMaxLevel()));
                    }
                    Skill skill = SkillHolder.getInstance().getSkill(5195, 1);
                    return SkillHolder.getInstance().getSkill(5195, Math.min(this.getSteep(), skill.getMaxLevel()));
                }
                case 16046: 
                case 16051: {
                    if (hpPercent >= 30) break;
                    Skill skill = SkillHolder.getInstance().getSkill(5590, 1);
                    return SkillHolder.getInstance().getSkill(5590, Math.min(this.getSteep(), skill.getMaxLevel()));
                }
            }
        }
        return null;
    }

    private Skill getManaHealSkill(int mpPercent) {
        switch (this.getNpcId()) {
            case 16035: {
                if (mpPercent >= 66) break;
                Skill skill = SkillHolder.getInstance().getSkill(5200, 1);
                return SkillHolder.getInstance().getSkill(5200, Math.min(this.getSteep(), skill.getMaxLevel()));
            }
            case 16046: 
            case 16051: {
                if (mpPercent >= 50) break;
                Skill skill = SkillHolder.getInstance().getSkill(5200, 1);
                return SkillHolder.getInstance().getSkill(5200, Math.min(this.getSteep(), skill.getMaxLevel()));
            }
        }
        return null;
    }

    public Skill onActionTask() {
        try {
            Player owner = this.getPlayer();
            if (!(owner.isDead() || owner.isInvulnerable() || this.isCastingNow())) {
                Object skillEntry;
                if (this.getAbnormalList().contains(5753)) {
                    return null;
                }
                if (this.getAbnormalList().contains(5771)) {
                    return null;
                }
                Skill skill = null;
                if (!Config.ALT_PET_HEAL_BATTLE_ONLY || owner.isInCombat()) {
                    double curMp;
                    double curHp = owner.getCurrentHpPercents();
                    if (Rnd.chance((double)((100.0 - curHp) / 3.0))) {
                        skill = this.getHealSkill((int)curHp);
                    }
                    if (skill == null && Rnd.chance((double)((100.0 - (curMp = owner.getCurrentMpPercents())) / 2.0))) {
                        skill = this.getManaHealSkill((int)curMp);
                    }
                    if ((skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.SERVITOR, skill)) != null && ((SkillEntry)skillEntry).checkCondition(this, owner, false, !this.isFollowMode(), true)) {
                        this.setTarget(owner);
                        this.getAI().Cast((SkillEntry)skillEntry, owner, false, !this.isFollowMode());
                        return skill;
                    }
                }
                if (owner.isInOfflineMode() || owner.getAbnormalList().contains(5771)) {
                    return null;
                }
                block2: for (Skill buff : this.getBuffs()) {
                    if (this.getCurrentMp() < buff.getMpConsume2()) continue;
                    for (Abnormal ef : owner.getAbnormalList()) {
                        if (!this.checkEffect(ef, buff)) continue;
                        continue block2;
                    }
                    skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.SERVITOR, buff);
                    if (((SkillEntry)skillEntry).checkCondition(this, owner, false, !this.isFollowMode(), true)) {
                        this.setTarget(owner);
                        this.getAI().Cast((SkillEntry)skillEntry, owner, false, !this.isFollowMode());
                        return buff;
                    }
                    return null;
                }
            }
        }
        catch (Throwable e) {
            _log.warn("Pet [#" + this.getNpcId() + "] a buff task error has occurred: " + e);
            _log.error("", e);
        }
        return null;
    }

    private boolean checkEffect(Abnormal abnormal, Skill skill) {
        if (abnormal == null) {
            return false;
        }
        if (abnormal.checkBlockedAbnormalType(skill.getAbnormalType())) {
            return true;
        }
        if (!AbnormalList.checkAbnormalType(abnormal.getSkill(), skill)) {
            return false;
        }
        if (abnormal.getAbnormalLvl() < skill.getAbnormalLvl()) {
            return false;
        }
        return abnormal.getTimeLeft() > 10;
    }

    public synchronized void stopBuffTask() {
        if (this._actionTask != null) {
            this._actionTask.cancel(false);
            this._actionTask = null;
        }
    }

    public synchronized void startBuffTask() {
        if (this._actionTask != null) {
            this.stopBuffTask();
        }
        if (this._actionTask == null && !this.isDead()) {
            this._actionTask = ThreadPoolManager.getInstance().schedule(new ActionTask(), 5000L);
        }
    }

    public boolean isBuffEnabled() {
        return this._buffEnabled;
    }

    public void triggerBuff() {
        this._buffEnabled = !this._buffEnabled;
    }

    @Override
    protected void onDeath(Creature killer) {
        this.stopBuffTask();
        super.onDeath(killer);
    }

    @Override
    public void doRevive() {
        super.doRevive();
        this.startBuffTask();
    }

    @Override
    public void unSummon(boolean logout) {
        this.stopBuffTask();
        super.unSummon(logout);
    }

    public int getSteep() {
        if (PetDataHolder.isSpecialPet(this.getNpcId())) {
            if (this.getLevel() < 10) {
                return 0;
            }
            if (this.getLevel() < 20) {
                return 1;
            }
            if (this.getLevel() < 30) {
                return 2;
            }
            if (this.getLevel() < 40) {
                return 3;
            }
            if (this.getLevel() < 50) {
                return 4;
            }
            if (this.getLevel() < 60) {
                return 5;
            }
            if (this.getLevel() < 70) {
                return 6;
            }
            if (this.getLevel() >= 70) {
                return 7;
            }
        } else {
            if (this.getLevel() < 60) {
                return 0;
            }
            if (this.getLevel() < 65) {
                return 1;
            }
            if (this.getLevel() < 70) {
                return 2;
            }
            if (this.getLevel() < 75) {
                return 3;
            }
            if (this.getLevel() < 80) {
                return 4;
            }
            if (this.getLevel() >= 80) {
                return 5;
            }
        }
        return 0;
    }

    @Override
    public int getSoulshotConsumeCount() {
        return 1;
    }

    @Override
    public int getSpiritshotConsumeCount() {
        return 1;
    }

    class ActionTask
    implements Runnable {
        ActionTask() {
        }

        @Override
        public void run() {
            Skill skill = PetBabyInstance.this.onActionTask();
            PetBabyInstance.this._actionTask = ThreadPoolManager.getInstance().schedule(new ActionTask(), skill == null ? 1000L : (long)Formulas.calcSkillCastSpd(PetBabyInstance.this, skill, skill.getHitTime()));
        }
    }
}


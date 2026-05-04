/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.actor.instances.creature;

import gnu.trove.set.TIntSet;
import gnu.trove.set.hash.TIntHashSet;
import java.util.Collection;
import java.util.Iterator;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import l2s.gameserver.Config;
import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.skills.AbnormalType;
import l2s.gameserver.skills.EffectUseType;
import l2s.gameserver.skills.SkillInfo;
import l2s.gameserver.skills.skillclasses.Transformation;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.stats.funcs.FuncTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class AbnormalList
implements Iterable<Abnormal> {
    private static final Logger _log = LoggerFactory.getLogger(AbnormalList.class);
    public static final int NONE_SLOT_TYPE = -1;
    public static final int BUFF_SLOT_TYPE = 0;
    public static final int MUSIC_SLOT_TYPE = 1;
    public static final int TRIGGER_SLOT_TYPE = 2;
    public static final int DEBUFF_SLOT_TYPE = 3;
    private final Collection<Abnormal> _abnormals = new ConcurrentLinkedQueue<Abnormal>();
    private final Creature _owner;
    private final Lock _addAbnormalLock = new ReentrantLock();

    public AbnormalList(Creature owner) {
        this._owner = owner;
    }

    @Override
    public Iterator<Abnormal> iterator() {
        return this._abnormals.iterator();
    }

    public boolean contains(int skillId) {
        if (this._abnormals.isEmpty()) {
            return false;
        }
        for (Abnormal abnormal : this._abnormals) {
            if (abnormal.getSkill().getId() != skillId) continue;
            return true;
        }
        return false;
    }

    public boolean contains(SkillInfo skillInfo) {
        if (skillInfo == null) {
            return false;
        }
        return this.contains(skillInfo.getId());
    }

    public boolean contains(AbnormalType type) {
        if (type == null) {
            return false;
        }
        for (Abnormal abnormal : this._abnormals) {
            if (abnormal.getAbnormalType() != type) continue;
            return true;
        }
        return false;
    }

    public Collection<Abnormal> values() {
        return this._abnormals;
    }

    public Abnormal[] toArray() {
        return this._abnormals.toArray(new Abnormal[this._abnormals.size()]);
    }

    public int getCount(int skillId) {
        int result = 0;
        if (this._abnormals.isEmpty()) {
            return 0;
        }
        for (Abnormal abnormal : this._abnormals) {
            if (abnormal.getSkill().getId() != skillId) continue;
            ++result;
        }
        return result;
    }

    public int getCount(SkillInfo skillInfo) {
        if (skillInfo == null) {
            return 0;
        }
        return this.getCount(skillInfo.getId());
    }

    public int getCount(AbnormalType type) {
        int result = 0;
        if (this._abnormals.isEmpty()) {
            return 0;
        }
        for (Abnormal abnormal : this._abnormals) {
            if (type != abnormal.getAbnormalType()) continue;
            ++result;
        }
        return result;
    }

    public int getAbnormalLevel(AbnormalType type) {
        int result = -1;
        if (this._abnormals.isEmpty()) {
            return -1;
        }
        for (Abnormal abnormal : this._abnormals) {
            if (type != abnormal.getAbnormalType() || result > abnormal.getAbnormalLvl()) continue;
            result = abnormal.getAbnormalLvl();
        }
        return result;
    }

    public int size() {
        return this._abnormals.size();
    }

    public boolean isEmpty() {
        return this._abnormals.isEmpty();
    }

    private void checkSlotLimit(Abnormal newAbnormal) {
        if (this._abnormals.isEmpty()) {
            return;
        }
        int slotType = AbnormalList.getSlotType(newAbnormal);
        if (slotType == -1) {
            return;
        }
        int size = 0;
        TIntHashSet skillIds = new TIntHashSet();
        for (Abnormal e : this._abnormals) {
            int subType;
            if (e.getSkill().equals(newAbnormal.getSkill())) {
                return;
            }
            if (skillIds.contains(e.getSkill().getId()) || (subType = AbnormalList.getSlotType(e)) != slotType) continue;
            ++size;
            skillIds.add(e.getSkill().getId());
        }
        int limit = 0;
        switch (slotType) {
            case 0: {
                limit = this._owner.getBuffLimit();
                break;
            }
            case 1: {
                limit = Config.ALT_MUSIC_LIMIT;
                break;
            }
            case 3: {
                limit = Config.ALT_DEBUFF_LIMIT;
                break;
            }
            case 2: {
                limit = Config.ALT_TRIGGER_LIMIT;
            }
        }
        if (size < limit) {
            return;
        }
        for (Abnormal e : this._abnormals) {
            if (AbnormalList.getSlotType(e) != slotType) continue;
            this.stop(e.getSkill().getId());
            break;
        }
    }

    public static int getSlotType(Abnormal e) {
        if (e.getSkill().getBuffSlotType() == -2) {
            if (e.isHidden() || e.getSkill().isPassive() || e.getSkill().isToggle() || e.getSkill() instanceof Transformation || e.checkAbnormalType(AbnormalType.HP_RECOVER)) {
                return -1;
            }
            if (e.isOffensive()) {
                return 3;
            }
            if (e.getSkill().isMusic()) {
                return 1;
            }
            if (e.getSkill().isTrigger()) {
                return 2;
            }
            return 0;
        }
        return e.getSkill().getBuffSlotType();
    }

    public static boolean checkAbnormalType(Skill skill1, Skill skill2) {
        if (skill1.getId() == skill2.getId()) {
            return true;
        }
        AbnormalType abnormalType1 = skill1.getAbnormalType();
        if (abnormalType1 == AbnormalType.NONE) {
            return false;
        }
        AbnormalType abnormalType2 = skill2.getAbnormalType();
        if (abnormalType2 == AbnormalType.NONE) {
            return false;
        }
        return abnormalType1 == abnormalType2;
    }

    
    public boolean add(Abnormal abnormal) {
        if (!abnormal.isTimeLeft()) {
            return false;
        }
        Skill skill = abnormal.getSkill();
        if (skill == null) {
            return false;
        }
        boolean success = false;
        try {
            if (!this._addAbnormalLock.tryLock(1000L, TimeUnit.MILLISECONDS)) {
                boolean bl = false;
                return bl;
            }
            this._owner.getStatsRecorder().block();
            try {
                boolean suspended;
                double cp;
                double mp;
                double hp;
                block44: {
                    block42: {
                        Iterator<Abnormal> iterator;
                        AbnormalType abnormalType;
                        block48: {
                            Iterator<Abnormal> iterator2;
                            block46: {
                                block47: {
                                    block45: {
                                        hp = this._owner.getCurrentHp();
                                        mp = this._owner.getCurrentMp();
                                        cp = this._owner.getCurrentCp();
                                        suspended = false;
                                        if (this._abnormals.isEmpty() || !abnormal.isOfUseType(EffectUseType.NORMAL) && !abnormal.isOfUseType(EffectUseType.SELF)) break block44;
                                        if (!skill.isToggle()) break block45;
                                        if (this.contains(skill)) {
                                            boolean bl = false;
                                            return bl;
                                        }
                                        if (!skill.isToggleGrouped() || skill.getToggleGroupId() <= 0) break block44;
                                        iterator2 = this._abnormals.iterator();
                                        break block46;
                                    }
                                    abnormalType = abnormal.getAbnormalType();
                                    if (abnormalType != AbnormalType.NONE) break block47;
                                    for (Abnormal a : this._abnormals) {
                                        if (a.getSkill().getId() != skill.getId()) continue;
                                        if (skill.getLevel() < a.getSkill().getLevel()) {
                                            boolean bl = false;
                                            return bl;
                                        }
                                        a.exit();
                                    }
                                    break block42;
                                }
                                iterator = this._abnormals.iterator();
                                break block48;
                            }
                            while (iterator2.hasNext()) {
                                Abnormal abnormal2 = (Abnormal)iterator2.next();
                                if (!abnormal2.getSkill().isToggleGrouped() || skill.getToggleGroupId() != abnormal2.getSkill().getToggleGroupId() || this._owner.isDualCastEnable() && abnormal2.getSkill().getToggleGroupId() == 1) continue;
                                abnormal2.exit();
                            }
                            break block44;
                        }
                        while (iterator.hasNext()) {
                            Abnormal a;
                            a = iterator.next();
                            if (a.checkBlockedAbnormalType(abnormalType)) {
                                boolean bl = false;
                                return bl;
                            }
                            if (abnormal.checkBlockedAbnormalType(a.getAbnormalType())) {
                                a.exit();
                                continue;
                            }
                            if (a.getEffector() != abnormal.getEffector() && abnormal.getAbnormalType().isStackable() || !AbnormalList.checkAbnormalType(a.getSkill(), skill)) continue;
                            if (a.getSkill().isIrreplaceableBuff()) {
                                boolean bl = false;
                                return bl;
                            }
                            if (abnormal.getAbnormalLvl() < a.getAbnormalLvl()) {
                                if (a.getSkill().isAbnormalInstant() && !skill.isAbnormalInstant()) {
                                    suspended = true;
                                    break;
                                } else {
                                    boolean bl = false;
                                    return bl;
                                }
                            }
                            if (!a.getSkill().isAbnormalInstant() && skill.isAbnormalInstant()) {
                                a.suspend();
                            } else {
                                a.exit();
                            }
                            break;
                        }
                    }
                    this.checkSlotLimit(abnormal);
                }
                if (success = this._abnormals.add(abnormal)) {
                    if (!suspended) {
                        abnormal.start();
                    } else {
                        abnormal.suspend();
                    }
                }
                for (EffectHandler effectHandler : abnormal.getEffects()) {
                    for (FuncTemplate ft : effectHandler.getTemplate().getAttachedFuncs()) {
                        if (ft._stat == Stats.MAX_HP) {
                            this._owner.setCurrentHp(hp, false);
                            continue;
                        }
                        if (ft._stat == Stats.MAX_MP) {
                            this._owner.setCurrentMp(mp);
                            continue;
                        }
                        if (ft._stat != Stats.MAX_CP) continue;
                        this._owner.setCurrentCp(cp);
                    }
                }
            }
            finally {
                this._owner.getStatsRecorder().unblock();
            }
            this._owner.updateStats();
            this._owner.updateAbnormalIcons();
            return success;
        }
        catch (InterruptedException e) {
            _log.error("Error while adding new abnormal: " + e, (Throwable)e);
            boolean bl = false;
            return bl;
        }
        finally {
            this._addAbnormalLock.unlock();
        }
    }

    public void remove(Abnormal abnormal) {
        if (abnormal == null) {
            return;
        }
        if (this._abnormals.remove(abnormal)) {
            if (abnormal.getSkill().isAbnormalInstant()) {
                for (Abnormal a : this._abnormals) {
                    if (a.getAbnormalType() != abnormal.getAbnormalType() || !a.isSuspended()) continue;
                    a.start();
                    break;
                }
            }
            this._owner.updateStats();
            this._owner.updateAbnormalIcons();
        }
    }

    public int stopAll() {
        if (this._abnormals.isEmpty()) {
            return 0;
        }
        int removed = 0;
        for (Abnormal a : this._abnormals) {
            if (this._owner.isSpecialAbnormal(a.getSkill())) continue;
            a.exit();
            ++removed;
        }
        return removed;
    }

    public int stop(int skillId, int skillLvl) {
        if (this._abnormals.isEmpty()) {
            return 0;
        }
        int removed = 0;
        for (Abnormal a : this._abnormals) {
            if (a.getSkill().getId() != skillId || a.getSkill().getLevel() != skillLvl) continue;
            a.exit();
            ++removed;
        }
        return removed;
    }

    public int stop(int skillId) {
        if (this._abnormals.isEmpty()) {
            return 0;
        }
        int removed = 0;
        for (Abnormal a : this._abnormals) {
            if (a.getSkill().getId() != skillId) continue;
            a.exit();
            ++removed;
        }
        return removed;
    }

    public int stop(TIntSet skillIds) {
        if (this._abnormals.isEmpty()) {
            return 0;
        }
        int removed = 0;
        for (Abnormal a : this._abnormals) {
            if (!skillIds.contains(a.getSkill().getId())) continue;
            a.exit();
            ++removed;
        }
        return removed;
    }

    public int stop(AbnormalType type) {
        if (this._abnormals.isEmpty()) {
            return 0;
        }
        int removed = 0;
        for (Abnormal a : this._abnormals) {
            if (a.getAbnormalType() != type) continue;
            a.exit();
            ++removed;
        }
        return removed;
    }

    public int stop(SkillInfo skillInfo, boolean checkLevel) {
        if (skillInfo == null) {
            return 0;
        }
        if (checkLevel) {
            return this.stop(skillInfo.getId(), skillInfo.getLevel());
        }
        return this.stop(skillInfo.getId());
    }

    @Deprecated
    public int stop(String name) {
        if (this._abnormals.isEmpty()) {
            return 0;
        }
        TIntHashSet skillIds = new TIntHashSet();
        block0: for (Abnormal abnormal : this._abnormals) {
            for (EffectHandler effect : abnormal.getEffects()) {
                if (!effect.getName().equalsIgnoreCase(name)) continue;
                skillIds.add(effect.getSkill().getId());
                continue block0;
            }
        }
        int removed = 0;
        for (Abnormal abnormal : this._abnormals) {
            if (!skillIds.contains(abnormal.getSkill().getId())) continue;
            abnormal.exit();
            ++removed;
        }
        return removed;
    }
}


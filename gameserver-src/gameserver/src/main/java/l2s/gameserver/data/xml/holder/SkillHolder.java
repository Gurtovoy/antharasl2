/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.data.xml.AbstractHolder
 *  org.napile.primitive.maps.IntIntMap
 *  org.napile.primitive.maps.IntObjectMap
 *  org.napile.primitive.maps.impl.HashIntIntMap
 *  org.napile.primitive.maps.impl.HashIntObjectMap
 */
package l2s.gameserver.data.xml.holder;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.model.Skill;
import l2s.gameserver.utils.SkillUtils;
import org.napile.primitive.maps.IntIntMap;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.HashIntIntMap;
import org.napile.primitive.maps.impl.HashIntObjectMap;

public final class SkillHolder
extends AbstractHolder {
    private static final SkillHolder _instance = new SkillHolder();
    private final IntObjectMap<Skill> _skills = new HashIntObjectMap();
    private final IntObjectMap<Skill> _skillsByIndex = new HashIntObjectMap();
    private final IntObjectMap<List<Skill>> _skillsById = new HashIntObjectMap();
    private final IntObjectMap<IntIntMap> _cachedHashCodes = new HashIntObjectMap();
    private final AtomicInteger _lastHashCode = new AtomicInteger(0);

    public static SkillHolder getInstance() {
        return _instance;
    }

    public int getHashCode(int skillId, int skillLevel) {
        int index;
        IntIntMap hashCodes = (IntIntMap)this._cachedHashCodes.get(skillId);
        if (hashCodes == null) {
            hashCodes = new HashIntIntMap();
            this._cachedHashCodes.put(skillId, hashCodes);
        }
        if ((index = hashCodes.get(skillLevel)) == 0) {
            index = this._lastHashCode.incrementAndGet();
            hashCodes.put(skillLevel, index);
        }
        return index;
    }

    public void addSkill(Skill skill) {
        this._skills.put(skill.hashCode(), skill);
        ArrayList<Skill> skills = (ArrayList<Skill>)this._skillsById.get(skill.getId());
        if (skills == null) {
            skills = new ArrayList<Skill>();
            this._skillsById.put(skill.getId(), skills);
        }
        skills.add(skill);
        this._skillsByIndex.put(SkillUtils.getSkillPTSHash(skill.getId(), skills.size()), skill);
    }

    public Skill getSkillByIndex(int id, int index) {
        return (Skill)this._skillsByIndex.get(SkillUtils.getSkillPTSHash(id, index));
    }

    public Skill getSkill(int hashCode) {
        return (Skill)this._skills.get(hashCode);
    }

    public Skill getSkill(int id, int level) {
        return this.getSkill(this.getHashCode(id, level));
    }

    public List<Skill> getSkills(int id) {
        return (List)this._skillsById.get(id);
    }

    public Collection<Skill> getSkills() {
        return this._skills.valueCollection();
    }

    public void callInit() {
        for (Skill skill : this.getSkills()) {
            skill.init();
        }
    }

    public int size() {
        return this._skills.size();
    }

    public void clear() {
        this._skills.clear();
        this._skillsByIndex.clear();
        this._skillsById.clear();
    }
}


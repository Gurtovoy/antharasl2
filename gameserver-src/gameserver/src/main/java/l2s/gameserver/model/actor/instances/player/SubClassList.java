/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.model.actor.instances.player;

import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.TreeMap;
import l2s.gameserver.dao.CharacterSubclassDAO;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.SubClass;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SubClassList
implements Iterable<SubClass> {
    private static final Logger _log = LoggerFactory.getLogger(SubClassList.class);
    public static final int MAX_SUB_COUNT = 4;
    private final TreeMap<Integer, SubClass> _listByIndex = new TreeMap();
    private final TreeMap<Integer, SubClass> _listByClassId = new TreeMap();
    private final Player _owner;
    private SubClass _baseSubClass = null;
    private SubClass _activeSubClass = null;

    public SubClassList(Player owner) {
        this._owner = owner;
    }

    public boolean restore() {
        this._listByIndex.clear();
        this._listByClassId.clear();
        List<SubClass> subclasses = CharacterSubclassDAO.getInstance().restore(this._owner);
        if (subclasses.isEmpty()) {
            _log.warn("SubClassList:restore: Could not restore any sub-classes! Player: " + this._owner.getName() + "(" + this._owner.getObjectId() + ")");
            return false;
        }
        int index = 2;
        for (SubClass sub : subclasses) {
            if (sub == null) continue;
            if (this.size() >= 4) {
                _log.warn("SubClassList:restore: Limit is subclass! Player: " + this._owner.getName() + "(" + this._owner.getObjectId() + ")");
                break;
            }
            if (sub.isActive()) {
                this._activeSubClass = sub;
            }
            if (sub.isBase()) {
                this._baseSubClass = sub;
                sub.setIndex(1);
            } else {
                sub.setIndex(index);
                ++index;
            }
            if (this._listByIndex.containsKey(sub.getIndex())) {
                _log.warn("SubClassList:restore: Duplicate index in player subclasses! Player: " + this._owner.getName() + "(" + this._owner.getObjectId() + ")");
            }
            this._listByIndex.put(sub.getIndex(), sub);
            if (this._listByClassId.containsKey(sub.getClassId())) {
                _log.warn("SubClassList:restore: Duplicate class_id in player subclasses! Player: " + this._owner.getName() + "(" + this._owner.getObjectId() + ")");
            }
            this._listByClassId.put(sub.getClassId(), sub);
        }
        if (this._baseSubClass == null) {
            _log.warn("SubClassList:restore: Could not restore base sub-class! Player: " + this._owner.getName() + "(" + this._owner.getObjectId() + ")");
            return false;
        }
        if (this._activeSubClass == null) {
            this._activeSubClass = this._baseSubClass;
            this._activeSubClass.setActive(true);
            _log.warn("SubClassList:restore: Could not restore active sub-class! Base class applied to active sub-class. Player: " + this._owner.getName() + "(" + this._owner.getObjectId() + ")");
        }
        if (this._listByIndex.size() != this._listByClassId.size()) {
            _log.warn("SubClassList:restore: The size of the lists do not match! Player: " + this._owner.getName() + "(" + this._owner.getObjectId() + ")");
        }
        return true;
    }

    @Override
    public Iterator<SubClass> iterator() {
        return this._listByIndex.values().iterator();
    }

    public Collection<SubClass> values() {
        return this._listByIndex.values();
    }

    public SubClass getByClassId(int classId) {
        return this._listByClassId.get(classId);
    }

    public SubClass getByIndex(int index) {
        return this._listByIndex.get(index);
    }

    public void removeByClassId(int classId) {
        if (!this._listByClassId.containsKey(classId)) {
            return;
        }
        int index = this._listByClassId.get(classId).getIndex();
        this._listByIndex.remove(index);
        this._listByClassId.remove(classId);
    }

    public SubClass getActiveSubClass() {
        return this._activeSubClass;
    }

    public SubClass getBaseSubClass() {
        return this._baseSubClass;
    }

    public boolean isBaseClassActive() {
        return this._activeSubClass == this._baseSubClass;
    }

    public boolean haveSubClasses() {
        return this.size() > 1;
    }

    public boolean changeSubClassId(int oldClassId, int newClassId) {
        if (!this._listByClassId.containsKey(oldClassId)) {
            return false;
        }
        if (this._listByClassId.containsKey(newClassId)) {
            return false;
        }
        SubClass sub = this._listByClassId.get(oldClassId);
        sub.setClassId(newClassId);
        this._listByClassId.remove(oldClassId);
        this._listByClassId.put(sub.getClassId(), sub);
        return true;
    }

    public boolean add(SubClass sub) {
        if (sub == null) {
            return false;
        }
        if (this.size() >= 4) {
            return false;
        }
        if (this._listByClassId.containsKey(sub.getClassId())) {
            return false;
        }
        int index = 1;
        while (this._listByIndex.containsKey(index)) {
            ++index;
        }
        sub.setIndex(index);
        this._listByIndex.put(sub.getIndex(), sub);
        this._listByClassId.put(sub.getClassId(), sub);
        return true;
    }

    public SubClass changeActiveSubClass(int classId) {
        SubClass sub = this._listByClassId.get(classId);
        if (sub == null) {
            return null;
        }
        if (this._activeSubClass != null) {
            this._activeSubClass.setActive(false);
        }
        sub.setActive(true);
        this._activeSubClass = sub;
        return sub;
    }

    public boolean containsClassId(int classId) {
        return this._listByClassId.containsKey(classId);
    }

    public int size() {
        return this._listByIndex.size();
    }

    public String toString() {
        return "SubClassList[owner=" + this._owner.getName() + "]";
    }
}


package l2s.gameserver.templates.npc;

import gnu.trove.list.TIntList;
import gnu.trove.list.array.TIntArrayList;
import java.util.ArrayList;
import java.util.List;

public class Faction {
    public static final String none = "none";
    public static final Faction NONE = new Faction("none", 0);
    private final String _namesStr;
    private List<String> _names = new ArrayList<String>();
    private final int _range;
    private TIntList _ignoreNpcIds = new TIntArrayList();

    public Faction(String names, int range) {
        this._namesStr = names;
        for (String name : names.split(";")) {
            if (name == null || name.isEmpty() || name.equals(none)) continue;
            this._names.add(name.toLowerCase());
        }
        this._range = range;
    }

    public int getRange() {
        return this._range;
    }

    public void addIgnoreNpcId(int npcId) {
        this._ignoreNpcIds.add(npcId);
    }

    public boolean isIgnoreNpcId(int npcId) {
        return this._ignoreNpcIds.contains(npcId);
    }

    public boolean isNone() {
        return this._names.isEmpty();
    }

    public boolean containsName(String name) {
        for (String n : this._names) {
            if (!n.equalsIgnoreCase(name)) continue;
            return true;
        }
        return false;
    }

    public boolean equals(Faction faction) {
        if (this.isNone()) {
            return false;
        }
        for (String name : this._names) {
            if (!faction.containsName(name)) continue;
            return true;
        }
        return false;
    }

    public boolean equals(Object o) {
        if (o == this) {
            return true;
        }
        if (o == null) {
            return false;
        }
        if (o.getClass() != this.getClass()) {
            return false;
        }
        return this.equals((Faction)o);
    }

    public int hashCode() {
        return 7 * this._namesStr.hashCode() + 23210;
    }

    public String toString() {
        return this._namesStr;
    }
}


package l2s.gameserver.templates;

import l2s.commons.collections.MultiValueSet;

public class StatsSet
extends MultiValueSet<String> {
    private static final long serialVersionUID = -2209589233655930756L;
    public static final StatsSet EMPTY = new StatsSet(){

        public Object put(String a, Object a2) {
            throw new UnsupportedOperationException();
        }
    };

    public static StatsSet simpleStatsSet(String key, Object value) {
        StatsSet statsSet = new StatsSet();
        statsSet.put(key, value);
        return statsSet;
    }

    public StatsSet() {
    }

    public StatsSet(StatsSet set) {
        super((MultiValueSet)set);
    }

    public StatsSet clone() {
        return new StatsSet(this);
    }
}


/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  gnu.trove.list.array.TIntArrayList
 *  gnu.trove.map.hash.TIntObjectHashMap
 */
package l2s.commons.util;

import gnu.trove.list.array.TIntArrayList;
import gnu.trove.map.hash.TIntObjectHashMap;

public class TroveUtils {
    private static final TIntObjectHashMap EMPTY_INT_OBJECT_MAP = new TIntObjectHashMapEmpty();
    public static final TIntArrayList EMPTY_INT_ARRAY_LIST = new TIntArrayListEmpty();

    public static <V> TIntObjectHashMap<V> emptyIntObjectMap() {
        return EMPTY_INT_OBJECT_MAP;
    }

    private static class TIntArrayListEmpty
    extends TIntArrayList {
        TIntArrayListEmpty() {
            super(0);
        }

        public boolean add(int val) {
            throw new UnsupportedOperationException();
        }
    }

    private static class TIntObjectHashMapEmpty<V>
    extends TIntObjectHashMap<V> {
        TIntObjectHashMapEmpty() {
            super(0);
        }

        public V put(int key, V value) {
            throw new UnsupportedOperationException();
        }

        public V putIfAbsent(int key, V value) {
            throw new UnsupportedOperationException();
        }
    }
}


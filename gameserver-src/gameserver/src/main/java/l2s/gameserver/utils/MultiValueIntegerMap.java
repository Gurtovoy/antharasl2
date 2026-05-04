/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.utils;

import gnu.trove.TIntCollection;
import gnu.trove.impl.sync.TSynchronizedIntList;
import gnu.trove.impl.sync.TSynchronizedIntObjectMap;
import gnu.trove.iterator.TIntObjectIterator;
import gnu.trove.list.TIntList;
import gnu.trove.list.array.TIntArrayList;
import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import gnu.trove.set.TIntSet;
import java.util.Collection;

public class MultiValueIntegerMap {
    private TIntObjectMap<TIntList> map = new TSynchronizedIntObjectMap((TIntObjectMap)new TIntObjectHashMap());

    public TIntSet keySet() {
        return this.map.keySet();
    }

    public Collection<TIntList> values() {
        return this.map.valueCollection();
    }

    public TIntList allValues() {
        TIntArrayList result = new TIntArrayList();
        TIntObjectIterator iterator = this.map.iterator();
        while (iterator.hasNext()) {
            iterator.advance();
            result.addAll((TIntCollection)iterator.value());
        }
        return result;
    }

    public TIntObjectIterator<TIntList> iterator() {
        return this.map.iterator();
    }

    public TIntList remove(int key) {
        return (TIntList)this.map.remove(key);
    }

    public TIntList get(int key) {
        return (TIntList)this.map.get(key);
    }

    public boolean containsKey(Integer key) {
        return this.map.containsKey(key.intValue());
    }

    public void clear() {
        this.map.clear();
    }

    public int size() {
        return this.map.size();
    }

    public boolean isEmpty() {
        return this.map.isEmpty();
    }

    public Integer remove(Integer key, Integer value) {
        TIntList valuesForKey = (TIntList)this.map.get(key.intValue());
        if (valuesForKey == null) {
            return null;
        }
        boolean removed = valuesForKey.remove(value.intValue());
        if (!removed) {
            return null;
        }
        if (valuesForKey.isEmpty()) {
            this.remove(key);
        }
        return value;
    }

    public int removeValue(int value) {
        TIntArrayList toRemove = new TIntArrayList(1);
        TIntObjectIterator iterator = this.map.iterator();
        while (iterator.hasNext()) {
            iterator.advance();
            ((TIntList)iterator.value()).remove(value);
            if (!((TIntList)iterator.value()).isEmpty()) continue;
            toRemove.add(iterator.key());
        }
        for (int key : toRemove.toArray()) {
            this.remove(key);
        }
        return value;
    }

    public Integer put(int key, int value) {
        TIntList coll = (TIntList)this.map.get(key);
        if (coll == null) {
            coll = new TSynchronizedIntList((TIntList)new TIntArrayList());
            this.map.put(key, coll);
        }
        coll.add(value);
        return value;
    }

    public boolean containsValue(int value) {
        TIntObjectIterator iterator = this.map.iterator();
        while (iterator.hasNext()) {
            iterator.advance();
            if (!((TIntList)iterator.value()).contains(value)) continue;
            return true;
        }
        return false;
    }

    public boolean containsValue(int key, int value) {
        TIntList coll = (TIntList)this.map.get(key);
        return coll != null && coll.contains(value);
    }

    public int size(Integer key) {
        TIntList coll = (TIntList)this.map.get(key.intValue());
        if (coll == null) {
            return 0;
        }
        return coll.size();
    }

    public boolean putAll(int key, TIntCollection values) {
        if (values == null || values.size() == 0) {
            return false;
        }
        boolean result = false;
        TIntList coll = (TIntList)this.map.get(key);
        if (coll == null) {
            coll = new TSynchronizedIntList((TIntList)new TIntArrayList());
            coll.addAll(values);
            if (coll.size() > 0) {
                this.map.put(key, coll);
                result = true;
            }
        } else {
            result = coll.addAll(values);
        }
        return result;
    }

    public int totalSize() {
        int total = 0;
        TIntObjectIterator iterator = this.map.iterator();
        while (iterator.hasNext()) {
            iterator.advance();
            total += ((TIntList)iterator.value()).size();
        }
        return total;
    }
}


/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.handler.bypass;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;
import l2s.commons.data.xml.AbstractHolder;
import org.apache.commons.lang3.tuple.ImmutablePair;
import org.apache.commons.lang3.tuple.Pair;

public class BypassHolder
extends AbstractHolder {
    private static final BypassHolder _instance = new BypassHolder();
    private Map<String, Pair<Object, Method>> _bypasses = new HashMap<String, Pair<Object, Method>>();

    public static BypassHolder getInstance() {
        return _instance;
    }

    public void registerBypass(String bypass, Object o, Method method) {
        Pair<Object, Method> old = this._bypasses.put(bypass, (Pair<Object, Method>)new ImmutablePair(o, (Object)method));
        if (old != null) {
            this.warn("Duplicate bypass: " + bypass + " old: (" + old.getKey().getClass().getName() + ":" + ((Method)old.getRight()).getName() + "), new: (" + o.getClass().getName() + ":" + method.getName() + ")");
        }
    }

    public Pair<Object, Method> getBypass(String name) {
        return this._bypasses.get(name);
    }

    public int size() {
        return this._bypasses.size();
    }

    public void clear() {
        this._bypasses.clear();
    }
}


/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  gnu.trove.map.hash.TIntObjectHashMap
 *  l2s.commons.data.xml.AbstractHolder
 */
package l2s.gameserver.data.xml.holder;

import gnu.trove.map.hash.TIntObjectHashMap;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.templates.player.ClassData;

public final class ClassDataHolder
extends AbstractHolder {
    private static final ClassDataHolder _instance = new ClassDataHolder();
    private final TIntObjectHashMap<ClassData> _classDataList = new TIntObjectHashMap();

    public static ClassDataHolder getInstance() {
        return _instance;
    }

    public void addClassData(ClassData classData) {
        this._classDataList.put(classData.getClassId(), classData);
    }

    public ClassData getClassData(int classId) {
        return (ClassData)this._classDataList.get(classId);
    }

    public int size() {
        return this._classDataList.size();
    }

    public void clear() {
        this._classDataList.clear();
    }
}


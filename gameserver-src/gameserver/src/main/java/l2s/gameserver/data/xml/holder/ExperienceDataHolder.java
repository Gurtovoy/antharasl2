/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.holder;

import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.templates.ExperienceData;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.HashIntObjectMap;

public final class ExperienceDataHolder
extends AbstractHolder {
    private static final ExperienceDataHolder _instance = new ExperienceDataHolder();
    private final IntObjectMap<ExperienceData> _data = new HashIntObjectMap();
    private int _maxLevel = 0;

    public static ExperienceDataHolder getInstance() {
        return _instance;
    }

    public void addData(ExperienceData data) {
        int level = data.getLevel();
        this._data.put(level, data);
        if (level > this._maxLevel) {
            this._maxLevel = level;
        }
    }

    public ExperienceData getData(int level) {
        return (ExperienceData)this._data.get(level);
    }

    public boolean containsData(int level) {
        return this._data.containsKey(level);
    }

    public int getMaxLevel() {
        return this._maxLevel - 1;
    }

    public int size() {
        return this._data.size();
    }

    public void clear() {
        this._data.clear();
    }
}


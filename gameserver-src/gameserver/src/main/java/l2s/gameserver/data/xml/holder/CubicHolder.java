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
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.templates.cubic.CubicTemplate;

public final class CubicHolder
extends AbstractHolder {
    private static CubicHolder _instance = new CubicHolder();
    private final TIntObjectHashMap<CubicTemplate> _cubics = new TIntObjectHashMap(10);

    public static CubicHolder getInstance() {
        return _instance;
    }

    private CubicHolder() {
    }

    public void addCubicTemplate(CubicTemplate template) {
        this._cubics.put(SkillHolder.getInstance().getHashCode(template.getId(), template.getLevel()), template);
    }

    public CubicTemplate getTemplate(int id, int level) {
        return (CubicTemplate)this._cubics.get(SkillHolder.getInstance().getHashCode(id, level));
    }

    public int size() {
        return this._cubics.size();
    }

    public void clear() {
        this._cubics.clear();
    }
}


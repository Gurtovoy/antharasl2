/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.data.xml.AbstractHolder
 *  org.napile.primitive.maps.IntObjectMap
 *  org.napile.primitive.maps.impl.HashIntObjectMap
 */
package l2s.gameserver.data.xml.holder;

import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.templates.OptionDataTemplate;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.HashIntObjectMap;

public final class OptionDataHolder
extends AbstractHolder {
    private static final OptionDataHolder _instance = new OptionDataHolder();
    private IntObjectMap<OptionDataTemplate> _templates = new HashIntObjectMap();

    public static OptionDataHolder getInstance() {
        return _instance;
    }

    public void addTemplate(OptionDataTemplate template) {
        this._templates.put(template.getId(), template);
    }

    public OptionDataTemplate getTemplate(int id) {
        return (OptionDataTemplate)this._templates.get(id);
    }

    public int size() {
        return this._templates.size();
    }

    public void clear() {
        this._templates.clear();
    }
}


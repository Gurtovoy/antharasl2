/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  gnu.trove.map.TIntObjectMap
 *  gnu.trove.map.hash.TIntObjectHashMap
 *  l2s.commons.data.xml.AbstractHolder
 */
package l2s.gameserver.data.xml.holder;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.model.base.ResidenceFunctionType;
import l2s.gameserver.templates.residence.ResidenceFunctionTemplate;

public final class ResidenceFunctionsHolder
extends AbstractHolder {
    private static final ResidenceFunctionsHolder _instance = new ResidenceFunctionsHolder();
    private final TIntObjectMap<ResidenceFunctionTemplate> _templates = new TIntObjectHashMap();
    private final Map<ResidenceFunctionType, TIntObjectMap<ResidenceFunctionTemplate>> _templatesByTypeAndLevel = new HashMap<ResidenceFunctionType, TIntObjectMap<ResidenceFunctionTemplate>>(ResidenceFunctionType.VALUES.length);

    public static ResidenceFunctionsHolder getInstance() {
        return _instance;
    }

    public void addTemplate(ResidenceFunctionTemplate template) {
        this._templates.put(template.getId(), template);
        TIntObjectHashMap<ResidenceFunctionTemplate> templates = (TIntObjectHashMap<ResidenceFunctionTemplate>)this._templatesByTypeAndLevel.get(template.getType());
        if (templates == null) {
            templates = new TIntObjectHashMap();
            this._templatesByTypeAndLevel.put(template.getType(), (TIntObjectMap<ResidenceFunctionTemplate>)templates);
        }
        templates.put(template.getLevel(), template);
    }

    public ResidenceFunctionTemplate getTemplate(int id) {
        return (ResidenceFunctionTemplate)this._templates.get(id);
    }

    public Collection<ResidenceFunctionTemplate> getTemplates() {
        return this._templates.valueCollection();
    }

    public ResidenceFunctionTemplate getTemplate(ResidenceFunctionType type, int level) {
        TIntObjectMap<ResidenceFunctionTemplate> templates = this._templatesByTypeAndLevel.get(type);
        if (templates == null) {
            return null;
        }
        return (ResidenceFunctionTemplate)templates.get(level);
    }

    public Collection<ResidenceFunctionTemplate> getTemplates(ResidenceFunctionType type) {
        TIntObjectMap<ResidenceFunctionTemplate> templates = this._templatesByTypeAndLevel.get(type);
        if (templates == null) {
            return Collections.emptyList();
        }
        return templates.valueCollection();
    }

    public int size() {
        return this._templates.size();
    }

    public void clear() {
        this._templates.clear();
        this._templatesByTypeAndLevel.clear();
    }
}


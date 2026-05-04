/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.holder;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.model.base.Sex;
import l2s.gameserver.templates.player.transform.TransformTemplate;

public final class TransformTemplateHolder
extends AbstractHolder {
    private static final TransformTemplateHolder _instance = new TransformTemplateHolder();
    private TIntObjectMap<TIntObjectMap<TransformTemplate>> _templates = new TIntObjectHashMap();

    public TransformTemplateHolder() {
        for (Sex sex : Sex.VALUES) {
            this._templates.put(sex.ordinal(), new TIntObjectHashMap());
        }
    }

    public static TransformTemplateHolder getInstance() {
        return _instance;
    }

    public void addTemplate(Sex sex, TransformTemplate template) {
        ((TIntObjectMap)this._templates.get(sex.ordinal())).put(template.getId(), template);
    }

    public TransformTemplate getTemplate(Sex sex, int id) {
        return (TransformTemplate)((TIntObjectMap)this._templates.get(sex.ordinal())).get(id);
    }

    public int size() {
        int size = 0;
        for (Sex sex : Sex.VALUES) {
            size += ((TIntObjectMap)this._templates.get(sex.ordinal())).size();
        }
        return size;
    }

    public void clear() {
        this._templates.clear();
    }
}


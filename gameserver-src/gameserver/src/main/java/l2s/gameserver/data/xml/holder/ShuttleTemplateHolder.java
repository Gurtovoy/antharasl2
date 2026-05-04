package l2s.gameserver.data.xml.holder;

import gnu.trove.map.hash.TIntObjectHashMap;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.templates.ShuttleTemplate;

public final class ShuttleTemplateHolder
extends AbstractHolder {
    private static final ShuttleTemplateHolder _instance = new ShuttleTemplateHolder();
    private TIntObjectHashMap<ShuttleTemplate> _templates = new TIntObjectHashMap();

    public static ShuttleTemplateHolder getInstance() {
        return _instance;
    }

    public void addTemplate(ShuttleTemplate template) {
        this._templates.put(template.getId(), template);
    }

    public ShuttleTemplate getTemplate(int id) {
        return (ShuttleTemplate)this._templates.get(id);
    }

    public int size() {
        return this._templates.size();
    }

    public void clear() {
        this._templates.clear();
    }
}


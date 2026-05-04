/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.holder;

import java.util.HashMap;
import java.util.Map;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.templates.agathion.AgathionTemplate;

public final class AgathionHolder
extends AbstractHolder {
    private static AgathionHolder _instance = new AgathionHolder();
    private final Map<Integer, AgathionTemplate> agathions = new HashMap<Integer, AgathionTemplate>();
    private final Map<Integer, AgathionTemplate> agathionsByItemId = new HashMap<Integer, AgathionTemplate>();

    public static AgathionHolder getInstance() {
        return _instance;
    }

    private AgathionHolder() {
    }

    public void addAgathionTemplate(AgathionTemplate template) {
        this.agathions.put(template.getId(), template);
        for (int itemId : template.getItemIds()) {
            this.agathionsByItemId.put(itemId, template);
        }
    }

    public AgathionTemplate getTemplate(int id) {
        return this.agathions.get(id);
    }

    public AgathionTemplate getTemplateByItemId(int itemId) {
        return this.agathionsByItemId.get(itemId);
    }

    public int size() {
        return this.agathions.size();
    }

    public void clear() {
        this.agathions.clear();
    }
}


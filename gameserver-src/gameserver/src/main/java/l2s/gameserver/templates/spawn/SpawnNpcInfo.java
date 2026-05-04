/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.spawn;

import java.util.List;
import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.data.xml.holder.NpcHolder;
import l2s.gameserver.templates.npc.MinionData;
import l2s.gameserver.templates.npc.NpcTemplate;

public class SpawnNpcInfo {
    private final NpcTemplate _template;
    private final int _max;
    private final MultiValueSet<String> _parameters;
    private final List<MinionData> _minions;

    public SpawnNpcInfo(int npcId, int max, MultiValueSet<String> set, List<MinionData> minions) {
        this._template = NpcHolder.getInstance().getTemplate(npcId);
        this._max = max;
        this._parameters = set;
        this._minions = minions;
    }

    public NpcTemplate getTemplate() {
        return this._template;
    }

    public int getMax() {
        return this._max;
    }

    public MultiValueSet<String> getParameters() {
        return this._parameters;
    }

    public List<MinionData> getMinionData() {
        return this._minions;
    }
}


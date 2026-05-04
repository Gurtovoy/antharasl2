/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.agathion;

import l2s.gameserver.templates.cubic.CubicTargetType;
import l2s.gameserver.templates.cubic.CubicTemplate;
import l2s.gameserver.templates.cubic.CubicUseUpType;

public class AgathionTemplate
extends CubicTemplate {
    private final int _npcId;
    private final int[] _itemIds;
    private final int _energy;
    private final int _maxEnergy;

    public AgathionTemplate(int npcId, int id, int duration, int delay, int maxCount, CubicUseUpType useUp, double power, CubicTargetType targetType, int[] itemIds, int energy, int maxEnergy) {
        super(id, 1, 1, duration, delay, maxCount, useUp, power, targetType);
        this._npcId = npcId;
        this._itemIds = itemIds;
        this._energy = energy;
        this._maxEnergy = maxEnergy;
    }

    public int getNpcId() {
        return this._npcId;
    }

    public int[] getItemIds() {
        return this._itemIds;
    }

    public int getEnergy() {
        return this._energy;
    }

    public int getMaxEnergy() {
        return this._maxEnergy;
    }
}


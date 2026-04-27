/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.templates.npc;

import l2s.gameserver.geometry.Territory;
import l2s.gameserver.templates.StatsSet;

public class MinionData {
    private final int _npcId;
    private final int _minionAmount;
    private final int _respawnTime;
    private final Territory _territory;
    private StatsSet _parameters = StatsSet.EMPTY;

    public MinionData(int npcId, String aiType, int minionAmount, int respawnTime, Territory territory) {
        this._npcId = npcId;
        this._minionAmount = minionAmount;
        this._respawnTime = respawnTime;
        this._territory = territory;
        if (aiType != null) {
            this._parameters = new StatsSet();
            this._parameters.set("ai_type", aiType);
        }
    }

    public int getMinionId() {
        return this._npcId;
    }

    public int getAmount() {
        return this._minionAmount;
    }

    public int getRespawnTime() {
        return this._respawnTime;
    }

    public Territory getTerritory() {
        return this._territory;
    }

    public StatsSet getParameters() {
        return this._parameters;
    }
}


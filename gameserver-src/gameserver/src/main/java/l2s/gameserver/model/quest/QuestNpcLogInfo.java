/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.quest;

public class QuestNpcLogInfo {
    private final int[] _npcIds;
    private final String _varName;
    private final int _maxCount;
    private final int _npcStringId;

    public QuestNpcLogInfo(int[] npcIds, String varName, int maxCount, int npcStringId) {
        this._npcIds = npcIds;
        this._varName = varName;
        this._maxCount = maxCount;
        this._npcStringId = npcStringId;
    }

    public int[] getNpcIds() {
        return this._npcIds;
    }

    public String getVarName() {
        return this._varName;
    }

    public int getMaxCount() {
        return this._maxCount;
    }

    public int getNpcStringId() {
        return this._npcStringId;
    }
}


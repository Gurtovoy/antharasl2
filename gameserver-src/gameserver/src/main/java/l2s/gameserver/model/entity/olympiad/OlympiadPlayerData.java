/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.entity.olympiad;

import l2s.gameserver.model.entity.olympiad.Olympiad;

public abstract class OlympiadPlayerData {
    private final int _objectId;
    private String _name;
    private int _classId;

    public OlympiadPlayerData(int objectId, String name, int classId) {
        this._objectId = objectId;
        this.setName(name);
        this.setClassId(classId);
    }

    public int getObjectId() {
        return this._objectId;
    }

    public String getName() {
        return this._name;
    }

    public void setName(String value) {
        this._name = value;
    }

    public int getClassId() {
        return this._classId;
    }

    public void setClassId(int value) {
        this._classId = Olympiad.convertParticipantClassId(value);
    }
}


/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.actor.instances.player;

public class Block {
    private final int _objectId;
    private String _name;
    private String _memo;

    public Block(int objectId, String name) {
        this(objectId, name, "");
    }

    public Block(int objectId, String name, String memo) {
        this._objectId = objectId;
        this._name = name;
        this._memo = memo;
    }

    public int getObjectId() {
        return this._objectId;
    }

    public String getName() {
        return this._name;
    }

    public String getMemo() {
        return this._memo;
    }

    public void setMemo(String val) {
        this._memo = val;
    }
}


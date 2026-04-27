/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PlaySoundPacket
extends L2GameServerPacket {
    public static final L2GameServerPacket SIEGE_VICTORY = new PlaySoundPacket("Siege_Victory");
    public static final L2GameServerPacket B04_S01 = new PlaySoundPacket("B04_S01");
    public static final L2GameServerPacket HB01 = new PlaySoundPacket(Type.MUSIC, "HB01", 0, 0, 0, 0, 0);
    public static final L2GameServerPacket BROKEN_KEY = new PlaySoundPacket("ItemSound2.broken_key");
    private Type _type;
    private String _soundFile;
    private int _hasCenterObject;
    private int _objectId;
    private int _x;
    private int _y;
    private int _z;

    public PlaySoundPacket(String soundFile) {
        this(Type.SOUND, soundFile, 0, 0, 0, 0, 0);
    }

    public PlaySoundPacket(Type type, String soundFile, int c, int objectId, Location loc) {
        this(type, soundFile, c, objectId, loc == null ? 0 : loc.x, loc == null ? 0 : loc.y, loc == null ? 0 : loc.z);
    }

    public PlaySoundPacket(Type type, String soundFile, int c, int objectId, int x, int y, int z) {
        this._type = type;
        this._soundFile = soundFile;
        this._hasCenterObject = c;
        this._objectId = objectId;
        this._x = x;
        this._y = y;
        this._z = z;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._type.ordinal());
        this.writeS(this._soundFile);
        this.writeD(this._hasCenterObject);
        this.writeD(this._objectId);
        this.writeD(this._x);
        this.writeD(this._y);
        this.writeD(this._z);
    }

    public static enum Type {
        SOUND,
        MUSIC,
        VOICE,
        NPC_VOICE;

    }
}


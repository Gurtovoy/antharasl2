package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExShowBeautyMenuPacket
extends L2GameServerPacket {
    public static final int CHANGE_STYLE = 0;
    public static final int RESTORE_STYLE = 1;
    private final int _type;
    private final int _hairStyle;
    private final int _hairColor;
    private final int _face;

    public ExShowBeautyMenuPacket(Player player, int type) {
        this._type = type;
        this._hairStyle = player.getBeautyHairStyle() > 0 ? player.getBeautyHairStyle() : player.getHairStyle();
        this._hairColor = player.getBeautyHairColor() > 0 ? player.getBeautyHairColor() : player.getHairColor();
        this._face = player.getBeautyFace() > 0 ? player.getBeautyFace() : player.getFace();
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._type);
        this.writeD(this._hairStyle);
        this.writeD(this._hairColor);
        this.writeD(this._face);
    }
}


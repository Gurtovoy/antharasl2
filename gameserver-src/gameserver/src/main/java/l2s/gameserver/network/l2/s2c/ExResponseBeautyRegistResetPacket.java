/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.utils.ItemFunctions;

public class ExResponseBeautyRegistResetPacket
extends L2GameServerPacket {
    public static final int FAILURE = 0;
    public static final int SUCCESS = 1;
    public static final int CHANGE = 0;
    public static final int RESTORE = 1;
    private final int _type;
    private final int _result;
    private final int _hairStyle;
    private final int _hairColor;
    private final int _face;
    private final long _adena;
    private final long _coins;

    public ExResponseBeautyRegistResetPacket(Player player, int type, int result) {
        this._type = type;
        this._result = result;
        this._hairStyle = player.getBeautyHairStyle() > 0 ? player.getBeautyHairStyle() : player.getHairStyle();
        this._hairColor = player.getBeautyHairColor() > 0 ? player.getBeautyHairColor() : player.getHairColor();
        this._face = player.getBeautyFace() > 0 ? player.getBeautyFace() : player.getFace();
        this._adena = player.getAdena();
        this._coins = ItemFunctions.getItemCount(player, Config.BEAUTY_SHOP_COIN_ITEM_ID);
    }

    @Override
    protected void writeImpl() {
        this.writeQ(this._adena);
        this.writeQ(this._coins);
        this.writeD(this._type);
        this.writeD(this._result);
        this.writeD(this._hairStyle);
        this.writeD(this._face);
        this.writeD(this._hairColor);
    }
}


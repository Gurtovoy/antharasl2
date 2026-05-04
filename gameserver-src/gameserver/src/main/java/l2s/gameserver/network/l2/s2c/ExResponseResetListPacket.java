package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.utils.ItemFunctions;

public class ExResponseResetListPacket
extends L2GameServerPacket {
    private int _hairStyle;
    private int _hairColor;
    private int _face;
    private long _adena;
    private long _coins;

    public ExResponseResetListPacket(Player player) {
        this._hairStyle = player.getHairStyle();
        this._hairColor = player.getHairColor();
        this._face = player.getFace();
        this._adena = player.getAdena();
        this._coins = ItemFunctions.getItemCount(player, Config.BEAUTY_SHOP_COIN_ITEM_ID);
    }

    @Override
    protected void writeImpl() {
        this.writeQ(this._adena);
        this.writeQ(this._coins);
        this.writeD(this._hairStyle);
        this.writeD(this._face);
        this.writeD(this._hairColor);
    }
}


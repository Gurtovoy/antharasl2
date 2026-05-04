package l2s.gameserver.network.l2.s2c;

import java.util.Collection;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ManufactureItem;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class RecipeShopSellListPacket
extends L2GameServerPacket {
    private int objId;
    private int curMp;
    private int maxMp;
    private long adena;
    private Collection<ManufactureItem> createList;

    public RecipeShopSellListPacket(Player buyer, Player manufacturer) {
        this.objId = manufacturer.getObjectId();
        this.curMp = (int)manufacturer.getCurrentMp();
        this.maxMp = manufacturer.getMaxMp();
        this.adena = buyer.getAdena();
        this.createList = manufacturer.getCreateList().values();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this.objId);
        this.writeD(this.curMp);
        this.writeD(this.maxMp);
        this.writeQ(this.adena);
        this.writeD(this.createList.size());
        for (ManufactureItem mi : this.createList) {
            this.writeD(mi.getRecipeId());
            this.writeD(0);
            this.writeQ(mi.getCost());
        }
    }
}


package l2s.gameserver.network.l2.s2c;

import java.util.Collection;
import java.util.Iterator;
import java.util.Map;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ManufactureItem;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.item.RecipeTemplate;

public class RecipeShopManageListPacket
extends L2GameServerPacket {
    private Map<Integer, ManufactureItem> createList;
    private Collection<RecipeTemplate> recipes;
    private int sellerId;
    private long adena;
    private boolean isDwarven;

    public RecipeShopManageListPacket(Player seller, boolean isDwarvenCraft) {
        this.sellerId = seller.getObjectId();
        this.adena = seller.getAdena();
        this.isDwarven = isDwarvenCraft;
        this.recipes = this.isDwarven ? seller.getDwarvenRecipeBook() : seller.getCommonRecipeBook();
        this.createList = seller.getCreateList();
        Iterator<Map.Entry<Integer, ManufactureItem>> iterator = this.createList.entrySet().iterator();
        while (iterator.hasNext()) {
            Map.Entry<Integer, ManufactureItem> entry = iterator.next();
            ManufactureItem mi = entry.getValue();
            if (seller.findRecipe(mi.getRecipeId())) continue;
            iterator.remove();
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this.sellerId);
        this.writeD((int)Math.min(this.adena, Integer.MAX_VALUE));
        this.writeD(this.isDwarven ? 0 : 1);
        this.writeD(this.recipes.size());
        int i = 1;
        for (RecipeTemplate recipe : this.recipes) {
            this.writeD(recipe.getId());
            this.writeD(i++);
        }
        this.writeD(this.createList.size());
        for (ManufactureItem mi : this.createList.values()) {
            this.writeD(mi.getRecipeId());
            this.writeD(0);
            this.writeQ(mi.getCost());
        }
    }
}


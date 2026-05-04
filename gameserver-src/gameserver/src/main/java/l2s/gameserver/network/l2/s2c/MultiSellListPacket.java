package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.model.MultiSellListContainer;
import l2s.gameserver.model.base.MultiSellEntry;
import l2s.gameserver.model.base.MultiSellIngredient;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.item.ItemTemplate;

public class MultiSellListPacket
extends L2GameServerPacket {
    private final int _page;
    private final int _finished;
    private final int _listId;
    private final int _type;
    private final List<MultiSellEntry> _list;

    public MultiSellListPacket(MultiSellListContainer list, int page, int finished) {
        this._list = list.getEntries();
        this._listId = list.getListId();
        this._type = list.getType().ordinal();
        this._page = page;
        this._finished = finished;
    }

    @Override
    protected final void writeImpl() {
        this.writeC(0);
        this.writeD(this._listId);
        this.writeC(0);
        this.writeD(this._page);
        this.writeD(this._finished);
        this.writeD(Config.MULTISELL_SIZE);
        this.writeD(this._list.size());
        this.writeC(0);
        this.writeC(this._type);
        this.writeD(32);
        for (MultiSellEntry ent : this._list) {
            int itemId;
            int i;
            List<MultiSellIngredient> ingredients = MultiSellListPacket.fixIngredients(ent.getIngredients());
            this.writeD(ent.getEntryId());
            this.writeC(!ent.getProduction().isEmpty() && ent.getProduction().get(0).isStackable() ? 1 : 0);
            this.writeH(0);
            this.writeD(0);
            this.writeD(0);
            this.writeItemElements();
            int saCount = 0;
            this.writeC(0);
            for (i = 0; i < saCount; ++i) {
                this.writeD(0);
            }
            this.writeC(0);
            for (i = 0; i < saCount; ++i) {
                this.writeD(0);
            }
            this.writeH(ent.getProduction().size());
            this.writeH(ingredients.size());
            for (MultiSellIngredient prod : ent.getProduction()) {
                int i2;
                itemId = prod.getItemId();
                ItemTemplate template = itemId > 0 ? ItemHolder.getInstance().getTemplate(prod.getItemId()) : null;
                this.writeD(itemId);
                this.writeQ(itemId > 0 ? template.getBodyPart() : 0L);
                this.writeH(itemId > 0 ? template.getType2() : 0);
                this.writeQ(prod.getItemCount());
                this.writeH(prod.getItemEnchant());
                this.writeD(prod.getChance());
                this.writeD(0);
                this.writeD(0);
                this.writeItemElements(prod);
                this.writeC(0);
                for (i2 = 0; i2 < saCount; ++i2) {
                    this.writeD(0);
                }
                this.writeC(0);
                for (i2 = 0; i2 < saCount; ++i2) {
                    this.writeD(0);
                }
            }
            for (MultiSellIngredient i3 : ingredients) {
                int s;
                itemId = i3.getItemId();
                ItemTemplate item = itemId > 0 ? ItemHolder.getInstance().getTemplate(i3.getItemId()) : null;
                this.writeD(itemId);
                this.writeH(itemId > 0 ? item.getType2() : 65535);
                this.writeQ(i3.getItemCount());
                this.writeH(i3.getItemEnchant());
                this.writeD(0);
                this.writeD(0);
                this.writeItemElements(i3);
                this.writeC(0);
                for (s = 0; s < saCount; ++s) {
                    this.writeD(0);
                }
                this.writeC(0);
                for (s = 0; s < saCount; ++s) {
                    this.writeD(0);
                }
            }
        }
    }

    private static List<MultiSellIngredient> fixIngredients(List<MultiSellIngredient> ingredients) {
        int needFix = 0;
        for (MultiSellIngredient ingredient : ingredients) {
            if (ingredient.getItemCount() <= Integer.MAX_VALUE) continue;
            ++needFix;
        }
        if (needFix == 0) {
            return ingredients;
        }
        ArrayList<MultiSellIngredient> result = new ArrayList<MultiSellIngredient>(ingredients.size() + needFix);
        for (MultiSellIngredient ingredient : ingredients) {
            ingredient = ingredient.clone();
            while (ingredient.getItemCount() > Integer.MAX_VALUE) {
                MultiSellIngredient temp = ingredient.clone();
                temp.setItemCount(2000000000L);
                result.add(temp);
                ingredient.setItemCount(ingredient.getItemCount() - 2000000000L);
            }
            if (ingredient.getItemCount() <= 0L) continue;
            result.add(ingredient);
        }
        return result;
    }
}


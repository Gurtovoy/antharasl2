/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.item;

import java.util.ArrayList;
import java.util.Collection;
import l2s.commons.util.Rnd;
import l2s.gameserver.templates.item.data.ChancedItemData;
import l2s.gameserver.templates.item.data.ItemData;
import org.apache.commons.lang3.ArrayUtils;

public final class RecipeTemplate {
    private final int _id;
    private final int _level;
    private final int _mpConsume;
    private final int _successRate;
    private final int _itemId;
    private final boolean _isCommon;
    private final Collection<ItemData> _materials = new ArrayList<ItemData>();
    private final Collection<ChancedItemData> _products = new ArrayList<ChancedItemData>();
    private final Collection<ItemData> _npcFee = new ArrayList<ItemData>();

    public RecipeTemplate(int id, int level, int mpConsume, int successRate, int itemId, boolean isCommon) {
        this._id = id;
        this._level = level;
        this._mpConsume = mpConsume;
        this._successRate = successRate;
        this._itemId = itemId;
        this._isCommon = isCommon;
    }

    public int getId() {
        return this._id;
    }

    public int getLevel() {
        return this._level;
    }

    public int getMpConsume() {
        return this._mpConsume;
    }

    public int getSuccessRate() {
        return this._successRate;
    }

    public int getItemId() {
        return this._itemId;
    }

    public boolean isCommon() {
        return this._isCommon;
    }

    public void addMaterial(ItemData material) {
        this._materials.add(material);
    }

    public ItemData[] getMaterials() {
        return this._materials.toArray(new ItemData[this._materials.size()]);
    }

    public void addProduct(ChancedItemData product) {
        this._products.add(product);
    }

    public ChancedItemData[] getProducts() {
        return this._products.toArray(new ChancedItemData[this._products.size()]);
    }

    public ChancedItemData getRandomProduct() {
        int chancesAmount = 0;
        for (ChancedItemData product : this._products) {
            chancesAmount = (int)((double)chancesAmount + product.getChance());
        }
        if (Rnd.chance((int)chancesAmount)) {
            ChancedItemData[] successProducts = new ChancedItemData[]{};
            while (successProducts.length == 0) {
                for (ChancedItemData product : this._products) {
                    if (!Rnd.chance((double)product.getChance())) continue;
                    successProducts = (ChancedItemData[])ArrayUtils.add(successProducts, product);
                }
            }
            return successProducts[Rnd.get((int)successProducts.length)];
        }
        return null;
    }

    public void addNpcFee(ItemData fee) {
        this._npcFee.add(fee);
    }

    public ItemData[] getNpcFee() {
        return this._npcFee.toArray(new ItemData[this._npcFee.size()]);
    }
}


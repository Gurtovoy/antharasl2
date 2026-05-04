package l2s.gameserver.model.base;

import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.model.base.Element;
import l2s.gameserver.model.items.ItemAttributes;

public class MultiSellIngredient
implements Cloneable {
    private int _itemId;
    private long _itemCount;
    private int _itemEnchant;
    private int _chance;
    private ItemAttributes _itemAttributes;
    private boolean _mantainIngredient;
    private int _flags;
    private int _durability;

    public MultiSellIngredient(int itemId, long itemCount) {
        this(itemId, itemCount, 0, -1, -1, 0);
    }

    public MultiSellIngredient(int itemId, long itemCount, int chance) {
        this(itemId, itemCount, chance, -1, -1, 0);
    }

    public MultiSellIngredient(int itemId, long itemCount, int chance, int flags, int durability, int enchant) {
        this._itemId = itemId;
        this._itemCount = itemCount;
        this._chance = chance;
        this._flags = flags;
        this._durability = durability;
        this._itemEnchant = enchant;
        this._mantainIngredient = false;
        this._itemAttributes = new ItemAttributes();
    }

    public MultiSellIngredient clone() {
        MultiSellIngredient mi = new MultiSellIngredient(this._itemId, this._itemCount, this._chance);
        mi.setItemEnchant(this._itemEnchant);
        mi.setMantainIngredient(this._mantainIngredient);
        mi.setItemAttributes(this._itemAttributes.clone());
        return mi;
    }

    public void setItemId(int itemId) {
        this._itemId = itemId;
    }

    public int getItemId() {
        return this._itemId;
    }

    public void setItemCount(long itemCount) {
        this._itemCount = itemCount;
    }

    public long getItemCount() {
        return this._itemCount;
    }

    public boolean isStackable() {
        return this._itemId <= 0 || ItemHolder.getInstance().getTemplate(this._itemId).isStackable();
    }

    public void setItemEnchant(int itemEnchant) {
        this._itemEnchant = itemEnchant;
    }

    public int getItemEnchant() {
        return this._itemEnchant;
    }

    public void setFlags(int value) {
        this._flags = value;
    }

    public int getFlags() {
        return this._flags;
    }

    public void setDurablity(int value) {
        this._durability = value;
    }

    public int getDurability() {
        return this._durability;
    }

    public ItemAttributes getItemAttributes() {
        return this._itemAttributes;
    }

    public void setItemAttributes(ItemAttributes attr) {
        this._itemAttributes = attr;
    }

    public void setChance(int val) {
        this._chance = val;
    }

    public int getChance() {
        return this._chance;
    }

    public int hashCode() {
        int prime = 31;
        int result = 1;
        result = 31 * result + (int)(this._itemCount ^ this._itemCount >>> 32);
        for (Element e : Element.VALUES) {
            result = 31 * result + this._itemAttributes.getValue(e);
        }
        result = 31 * result + this._itemEnchant;
        result = 31 * result + this._itemId;
        return result;
    }

    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (this.getClass() != obj.getClass()) {
            return false;
        }
        MultiSellIngredient other = (MultiSellIngredient)obj;
        if (this._itemId != other._itemId) {
            return false;
        }
        if (this._itemCount != other._itemCount) {
            return false;
        }
        if (this._itemEnchant != other._itemEnchant) {
            return false;
        }
        for (Element e : Element.VALUES) {
            if (this._itemAttributes.getValue(e) == other._itemAttributes.getValue(e)) continue;
            return false;
        }
        return true;
    }

    public boolean getMantainIngredient() {
        return this._mantainIngredient;
    }

    public void setMantainIngredient(boolean mantainIngredient) {
        this._mantainIngredient = mantainIngredient;
    }
}


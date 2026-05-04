package l2s.gameserver.model.base;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.model.base.MultiSellIngredient;

public class MultiSellEntry {
    private int _entryId;
    private List<MultiSellIngredient> _ingredients = new ArrayList<MultiSellIngredient>();
    private List<MultiSellIngredient> _production = new ArrayList<MultiSellIngredient>();
    private long _tax;

    public MultiSellEntry() {
    }

    public MultiSellEntry(int id) {
        this._entryId = id;
    }

    public void setEntryId(int entryId) {
        this._entryId = entryId;
    }

    public int getEntryId() {
        return this._entryId;
    }

    public void addIngredient(MultiSellIngredient ingredient) {
        this._ingredients.add(ingredient);
    }

    public List<MultiSellIngredient> getIngredients() {
        return this._ingredients;
    }

    public void addProduct(MultiSellIngredient ingredient) {
        this._production.add(ingredient);
    }

    public List<MultiSellIngredient> getProduction() {
        return this._production;
    }

    public long getTax() {
        return this._tax;
    }

    public void setTax(long tax) {
        this._tax = tax;
    }

    public int hashCode() {
        return this._entryId;
    }

    public MultiSellEntry clone() {
        MultiSellEntry ret = new MultiSellEntry(this._entryId);
        for (MultiSellIngredient i : this._ingredients) {
            ret.addIngredient(i.clone());
        }
        for (MultiSellIngredient i : this._production) {
            ret.addProduct(i.clone());
        }
        return ret;
    }
}


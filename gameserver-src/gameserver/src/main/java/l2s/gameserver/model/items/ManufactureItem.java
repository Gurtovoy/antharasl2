/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.items;

public class ManufactureItem {
    private final int _recipeId;
    private final long _cost;

    public ManufactureItem(int recipeId, long cost) {
        this._recipeId = recipeId;
        this._cost = cost;
    }

    public int getRecipeId() {
        return this._recipeId;
    }

    public long getCost() {
        return this._cost;
    }

    public boolean equals(Object o) {
        if (o == this) {
            return true;
        }
        if (o == null) {
            return false;
        }
        if (o.getClass() != this.getClass()) {
            return false;
        }
        return ((ManufactureItem)o).getRecipeId() == this.getRecipeId();
    }

    public int hashCode() {
        return 17 * this._recipeId + 11021;
    }
}


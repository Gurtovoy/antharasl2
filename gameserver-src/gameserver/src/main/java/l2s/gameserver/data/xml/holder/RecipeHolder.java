package l2s.gameserver.data.xml.holder;

import gnu.trove.map.hash.TIntObjectHashMap;
import java.util.ArrayList;
import java.util.Collection;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.templates.item.RecipeTemplate;

public final class RecipeHolder
extends AbstractHolder {
    private static final RecipeHolder _instance = new RecipeHolder();
    private final TIntObjectHashMap<RecipeTemplate> _listByRecipeId = new TIntObjectHashMap();
    private final TIntObjectHashMap<RecipeTemplate> _listByRecipeItem = new TIntObjectHashMap();

    public static RecipeHolder getInstance() {
        return _instance;
    }

    public void addRecipe(RecipeTemplate recipe) {
        this._listByRecipeId.put(recipe.getId(), recipe);
        this._listByRecipeItem.put(recipe.getItemId(), recipe);
    }

    public RecipeTemplate getRecipeByRecipeId(int id) {
        return (RecipeTemplate)this._listByRecipeId.get(id);
    }

    public RecipeTemplate getRecipeByRecipeItem(int id) {
        return (RecipeTemplate)this._listByRecipeItem.get(id);
    }

    public Collection<RecipeTemplate> getRecipes() {
        ArrayList<RecipeTemplate> result = new ArrayList<RecipeTemplate>(this.size());
        for (int key : this._listByRecipeId.keys()) {
            result.add((RecipeTemplate)this._listByRecipeId.get(key));
        }
        return result;
    }

    public int size() {
        return this._listByRecipeId.size();
    }

    public void clear() {
        this._listByRecipeId.clear();
        this._listByRecipeItem.clear();
    }
}


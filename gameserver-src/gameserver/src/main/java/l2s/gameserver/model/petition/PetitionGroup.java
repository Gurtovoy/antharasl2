package l2s.gameserver.model.petition;

import java.util.HashMap;
import java.util.Map;
import l2s.gameserver.utils.Language;

public abstract class PetitionGroup {
    private final Map<Language, String> _name = new HashMap<Language, String>(Language.VALUES.length);
    private final Map<Language, String> _description = new HashMap<Language, String>(Language.VALUES.length);
    private final int _id;

    public PetitionGroup(int id) {
        this._id = id;
    }

    public int getId() {
        return this._id;
    }

    public String getName(Language lang) {
        return this._name.get(lang);
    }

    public void setName(Language lang, String name) {
        this._name.put(lang, name);
    }

    public String getDescription(Language lang) {
        return this._description.get(lang);
    }

    public void setDescription(Language lang, String name) {
        this._description.put(lang, name);
    }
}


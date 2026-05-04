package l2s.gameserver.model;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.model.base.MultiSellEntry;

public class MultiSellListContainer {
    private int _listId;
    private boolean _showall = true;
    private boolean keep_enchanted = false;
    private boolean is_dutyfree = false;
    private boolean nokey = false;
    private List<MultiSellEntry> entries = new ArrayList<MultiSellEntry>();
    private MultisellType _type = MultisellType.NORMAL;

    public void setListId(int listId) {
        this._listId = listId;
    }

    public int getListId() {
        return this._listId;
    }

    public void setShowAll(boolean bool) {
        this._showall = bool;
    }

    public boolean isShowAll() {
        return this._showall;
    }

    public void setNoTax(boolean bool) {
        this.is_dutyfree = bool;
    }

    public boolean isNoTax() {
        return this.is_dutyfree;
    }

    public void setNoKey(boolean bool) {
        this.nokey = bool;
    }

    public boolean isNoKey() {
        return this.nokey;
    }

    public void setKeepEnchant(boolean bool) {
        this.keep_enchanted = bool;
    }

    public boolean isKeepEnchant() {
        return this.keep_enchanted;
    }

    public void setType(MultisellType val) {
        this._type = val;
    }

    public MultisellType getType() {
        return this._type;
    }

    public void addEntry(MultiSellEntry e) {
        this.entries.add(e);
    }

    public List<MultiSellEntry> getEntries() {
        return this.entries;
    }

    public boolean isEmpty() {
        return this.entries.isEmpty();
    }

    public static enum MultisellType {
        NORMAL,
        CHANCED;

    }
}


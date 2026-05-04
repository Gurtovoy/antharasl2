package l2s.gameserver.data.xml.holder;

import java.util.ArrayList;
import java.util.List;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.templates.item.support.SynthesisData;

public final class SynthesisDataHolder
extends AbstractHolder {
    private static final SynthesisDataHolder _instance = new SynthesisDataHolder();
    private List<SynthesisData> _data = new ArrayList<SynthesisData>();

    public static SynthesisDataHolder getInstance() {
        return _instance;
    }

    public void addData(SynthesisData data) {
        this._data.add(data);
    }

    public SynthesisData[] getDatas() {
        return this._data.toArray(new SynthesisData[this._data.size()]);
    }

    public int size() {
        return this._data.size();
    }

    public void clear() {
        this._data.clear();
    }
}


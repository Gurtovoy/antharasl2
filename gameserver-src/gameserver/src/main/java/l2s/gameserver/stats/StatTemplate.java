package l2s.gameserver.stats;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import l2s.commons.lang.ArrayUtils;
import l2s.gameserver.stats.funcs.Func;
import l2s.gameserver.stats.funcs.FuncTemplate;
import l2s.gameserver.stats.triggers.TriggerInfo;

public class StatTemplate {
    protected FuncTemplate[] _funcTemplates = FuncTemplate.EMPTY_ARRAY;
    protected List<TriggerInfo> _triggerList = Collections.emptyList();

    public List<TriggerInfo> getTriggerList() {
        return this._triggerList;
    }

    public void addTrigger(TriggerInfo f) {
        if (this._triggerList.isEmpty()) {
            this._triggerList = new ArrayList<TriggerInfo>(4);
        }
        this._triggerList.add(f);
    }

    public void attachFunc(FuncTemplate f) {
        this._funcTemplates = (FuncTemplate[])ArrayUtils.add((Object[])this._funcTemplates, (Object)f);
    }

    public void attachFuncs(FuncTemplate ... funcs) {
        for (FuncTemplate f : funcs) {
            this.attachFunc(f);
        }
    }

    public FuncTemplate[] getAttachedFuncs() {
        return this._funcTemplates;
    }

    public FuncTemplate[] removeAttachedFuncs() {
        FuncTemplate[] funcs = this._funcTemplates;
        this._funcTemplates = FuncTemplate.EMPTY_ARRAY;
        return funcs;
    }

    public Func[] getStatFuncs(Object owner) {
        if (this._funcTemplates.length == 0) {
            return Func.EMPTY_FUNC_ARRAY;
        }
        Func[] funcs = new Func[this._funcTemplates.length];
        for (int i = 0; i < funcs.length; ++i) {
            funcs[i] = this._funcTemplates[i].getFunc(owner);
        }
        return funcs;
    }
}


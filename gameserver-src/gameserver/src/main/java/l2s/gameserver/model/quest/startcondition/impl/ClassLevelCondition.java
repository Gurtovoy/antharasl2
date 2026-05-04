package l2s.gameserver.model.quest.startcondition.impl;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.ClassLevel;
import l2s.gameserver.model.quest.startcondition.ICheckStartCondition;
import org.apache.commons.lang3.ArrayUtils;

public class ClassLevelCondition
implements ICheckStartCondition {
    private final ClassLevel[] _classLevels;

    public ClassLevelCondition(ClassLevel ... classLevels) {
        this._classLevels = classLevels;
    }

    @Override
    public boolean checkCondition(Player player) {
        return ArrayUtils.contains((Object[])this._classLevels, (Object)((Object)player.getClassLevel()));
    }
}


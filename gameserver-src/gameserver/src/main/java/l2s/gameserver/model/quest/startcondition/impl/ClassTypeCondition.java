/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.quest.startcondition.impl;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.ClassType;
import l2s.gameserver.model.quest.startcondition.ICheckStartCondition;

public class ClassTypeCondition
implements ICheckStartCondition {
    private final ClassType _type;

    public ClassTypeCondition(ClassType type) {
        this._type = type;
    }

    @Override
    public boolean checkCondition(Player player) {
        return player.getClassId().isOfType(this._type);
    }
}


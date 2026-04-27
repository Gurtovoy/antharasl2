/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.apache.commons.lang3.ArrayUtils
 */
package l2s.gameserver.model.quest.startcondition.impl;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.model.quest.startcondition.ICheckStartCondition;
import org.apache.commons.lang3.ArrayUtils;

public class ClassIdCondition
implements ICheckStartCondition {
    private int[] _classId;

    public ClassIdCondition(int ... classId) {
        this._classId = classId;
    }

    public ClassIdCondition(ClassId ... classIds) {
        this._classId = new int[classIds.length];
        for (int i = 0; i < classIds.length; ++i) {
            this._classId[i] = classIds[i].getId();
        }
    }

    @Override
    public boolean checkCondition(Player player) {
        return ArrayUtils.contains((int[])this._classId, (int)player.getClassId().getId());
    }
}


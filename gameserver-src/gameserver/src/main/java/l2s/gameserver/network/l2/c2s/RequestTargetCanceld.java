/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.skills.SkillCastingType;
import l2s.gameserver.skills.SkillEntry;

public class RequestTargetCanceld
extends L2GameClientPacket {
    private int _unselect;

    @Override
    protected boolean readImpl() {
        this._unselect = this.readH();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (activeChar.getAggressionTarget() != null) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isLockedTarget()) {
            activeChar.sendActionFailed();
            return;
        }
        if (this._unselect == 0) {
            SkillEntry skillEntry = null;
            if (activeChar.getSkillCast(SkillCastingType.NORMAL).isCastingNow()) {
                skillEntry = activeChar.getSkillCast(SkillCastingType.NORMAL).getSkillEntry();
            }
            SkillEntry dualSkillEntry = null;
            if (activeChar.getSkillCast(SkillCastingType.NORMAL_SECOND).isCastingNow()) {
                dualSkillEntry = activeChar.getSkillCast(SkillCastingType.NORMAL_SECOND).getSkillEntry();
            }
            if (skillEntry != null || dualSkillEntry != null) {
                boolean force;
                boolean bl = force = skillEntry != null && (skillEntry.getTemplate().isHandler() || skillEntry.getTemplate().getHitTime() > 1000);
                if (!force) {
                    force = dualSkillEntry != null && (dualSkillEntry.getTemplate().isHandler() || dualSkillEntry.getTemplate().getHitTime() > 1000);
                }
                activeChar.abortCast(force, false);
            } else if (activeChar.getTarget() != null) {
                activeChar.setTarget(null);
            }
        } else if (activeChar.getTarget() != null) {
            activeChar.setTarget(null);
        }
    }
}


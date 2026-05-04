/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.s2c.ValidateLocationPacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.utils.PositionUtils;

public class RequestExMagicSkillUseGround
extends L2GameClientPacket {
    private Location _loc = new Location();
    private int _skillId;
    private boolean _ctrlPressed;
    private boolean _shiftPressed;

    @Override
    protected boolean readImpl() {
        this._loc.x = this.readD();
        this._loc.y = this.readD();
        this._loc.z = this.readD();
        this._skillId = this.readD();
        this._ctrlPressed = this.readD() != 0;
        this._shiftPressed = this.readC() != 0;
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (activeChar.isOutOfControl()) {
            activeChar.sendActionFailed();
            return;
        }
        Skill skill = SkillHolder.getInstance().getSkill(this._skillId, activeChar.getSkillLevel(this._skillId));
        if (skill != null) {
            if (activeChar.isTransformed() && !activeChar.getAllSkills().contains(skill)) {
                return;
            }
            Creature target = skill.getAimingTarget(activeChar, activeChar.getTarget());
            activeChar.setHeading(PositionUtils.calculateHeadingFrom(activeChar.getX(), activeChar.getY(), this._loc.x, this._loc.y));
            activeChar.broadcastPacketToOthers(new ValidateLocationPacket(activeChar));
            activeChar.setGroundSkillLoc(this._loc);
            activeChar.getAI().Cast(SkillEntry.makeSkillEntry(SkillEntryType.NONE, skill), target, this._ctrlPressed, this._shiftPressed);
        } else {
            activeChar.sendActionFailed();
        }
    }
}


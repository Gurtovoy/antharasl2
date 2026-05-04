/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.skillclasses;

import l2s.commons.util.Rnd;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.instances.ChestInstance;
import l2s.gameserver.model.instances.DoorInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.templates.StatsSet;

public class Unlock
extends Skill {
    private final int _unlockPower;

    public Unlock(StatsSet set) {
        super(set);
        this._unlockPower = set.getInteger("unlockPower", 0) + 100;
    }

    @Override
    public boolean checkCondition(SkillEntry skillEntry, Creature activeChar, Creature target, boolean forceUse, boolean dontMove, boolean first, boolean sendMsg, boolean trigger) {
        if (!super.checkCondition(skillEntry, activeChar, target, forceUse, dontMove, first, sendMsg, trigger)) {
            return false;
        }
        if (target == null || target instanceof ChestInstance && target.isDead()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
            return false;
        }
        if (target instanceof ChestInstance && activeChar.isPlayer()) {
            return true;
        }
        if (!target.isDoor() || this._unlockPower == 0) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
            return false;
        }
        DoorInstance door = (DoorInstance)target;
        if (door.isOpen()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.IT_IS_NOT_LOCKED);
            return false;
        }
        if (!door.isUnlockable()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THIS_DOOR_CANNOT_BE_UNLOCKED);
            return false;
        }
        if (door.getKey() > 0) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THIS_DOOR_CANNOT_BE_UNLOCKED);
            return false;
        }
        if (this._unlockPower - door.getLevel() * 100 < 0) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THIS_DOOR_CANNOT_BE_UNLOCKED);
            return false;
        }
        return true;
    }

    @Override
    protected void useSkill(Creature activeChar, Creature target, boolean reflected) {
        ChestInstance chest;
        if (!activeChar.isPlayer()) {
            return;
        }
        if (target.isDoor()) {
            DoorInstance door = (DoorInstance)target;
            if (!door.isOpen() && (door.getKey() > 0 || Rnd.chance((int)(this._unlockPower - door.getLevel() * 100)))) {
                door.openMe(activeChar.getPlayer(), true);
            } else {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_FAILED_TO_UNLOCK_THE_DOOR);
            }
        } else if (target instanceof ChestInstance && !(chest = (ChestInstance)target).isDead()) {
            chest.tryOpen(activeChar.getPlayer(), this);
        }
    }
}


/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.skillclasses;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.templates.StatsSet;

public class EnergyReplenish
extends Skill {
    private int _addEnergy;

    public EnergyReplenish(StatsSet set) {
        super(set);
        this._addEnergy = set.getInteger("addEnergy");
    }

    @Override
    public boolean checkCondition(SkillEntry skillEntry, Creature activeChar, Creature target, boolean forceUse, boolean dontMove, boolean first, boolean sendMsg, boolean trigger) {
        if (!super.checkCondition(skillEntry, activeChar, target, forceUse, dontMove, first, sendMsg, trigger)) {
            return false;
        }
        if (!activeChar.isPlayer()) {
            return false;
        }
        Player player = (Player)activeChar;
        ItemInstance item = player.getInventory().getPaperdollItem(18);
        if (item == null || item.getTemplate().getAgathionMaxEnergy() - item.getAgathionEnergy() < this._addEnergy) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOUR_ENERGY_CANNOT_BE_REPLENISHED_BECAUSE_CONDITIONS_ARE_NOT_MET);
            return false;
        }
        return true;
    }

    @Override
    protected void useSkill(Creature activeChar, Creature target, boolean reflected) {
        target.setAgathionEnergy(target.getAgathionEnergy() + this._addEnergy);
        target.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.ENERGY_S1_REPLENISHED).addInteger(this._addEnergy));
    }
}


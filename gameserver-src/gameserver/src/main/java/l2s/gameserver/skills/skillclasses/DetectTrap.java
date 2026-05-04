package l2s.gameserver.skills.skillclasses;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.World;
import l2s.gameserver.model.instances.TrapInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.NpcInfoPacket;
import l2s.gameserver.skills.AbnormalType;
import l2s.gameserver.templates.StatsSet;

public class DetectTrap
extends Skill {
    public DetectTrap(StatsSet set) {
        super(set);
    }

    @Override
    protected void useSkill(Creature activeChar, Creature target, boolean reflected) {
        if (target.isTrap()) {
            TrapInstance trap = (TrapInstance)target;
            if ((double)trap.getLevel() <= this.getPower()) {
                trap.setDetected(true);
                for (Player player : World.getAroundObservers(trap)) {
                    player.sendPacket((IBroadcastPacket)new NpcInfoPacket(trap, (Creature)player).init());
                }
            }
        } else if (this.isDetectPC()) {
            target.getAbnormalList().stop(AbnormalType.HIDE);
        }
    }
}


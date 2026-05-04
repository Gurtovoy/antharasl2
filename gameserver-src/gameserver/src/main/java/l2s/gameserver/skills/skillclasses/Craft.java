/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.skillclasses;

import java.util.Set;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.RecipeBookItemListPacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.templates.StatsSet;

public class Craft
extends Skill {
    private final boolean _dwarven;

    public Craft(StatsSet set) {
        super(set);
        this._dwarven = set.getBool("isDwarven");
    }

    @Override
    public boolean checkCondition(SkillEntry skillEntry, Creature activeChar, Creature target, boolean forceUse, boolean dontMove, boolean first, boolean sendMsg, boolean trigger) {
        if (!super.checkCondition(skillEntry, activeChar, target, forceUse, dontMove, first, sendMsg, trigger)) {
            return false;
        }
        Player p = (Player)activeChar;
        return !p.isInStoreMode() && !p.isProcessingRequest();
    }

    @Override
    public void onEndCast(Creature activeChar, Set<Creature> targets) {
        super.onEndCast(activeChar, targets);
        activeChar.sendPacket((IBroadcastPacket)new RecipeBookItemListPacket((Player)activeChar, this._dwarven));
    }
}


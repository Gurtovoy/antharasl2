package l2s.gameserver.skills.skillclasses;

import java.util.List;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.World;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.CIPacket;
import l2s.gameserver.network.l2.s2c.RelationChangedPacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.templates.StatsSet;

/**
 * Viewer-side toggle: when activated, the caster stops seeing OTHER players' costumes (chest visual
 * override from formal wear stored in {@link l2s.gameserver.model.items.Inventory#PAPERDOLL_BROOCH}).
 * The caster's own costume keeps being drawn for everyone (including themselves), because the local
 * avatar is fed by {@code ItemList} / {@code InventoryUpdate}, not by {@link CIPacket}.
 *
 * <p>Mechanically, the flag is consulted inside {@link CIPacket}'s constructor where, if
 * {@code receiver.hideCostume()} is true and the described character has a costume equipped, the
 * chest visual id is rewritten back to the underlying chest item's real value (its own shape-shifting
 * id or 0).
 */
public class HideCostume
extends Skill {
    public HideCostume(StatsSet set) {
        super(set);
    }

    @Override
    public boolean checkCondition(SkillEntry skillEntry, Creature activeChar, Creature target, boolean forceUse, boolean dontMove, boolean first, boolean sendMsg, boolean trigger) {
        if (!super.checkCondition(skillEntry, activeChar, target, forceUse, dontMove, first, sendMsg, trigger)) {
            return false;
        }
        return activeChar.isPlayer();
    }

    @Override
    protected void useSkill(Creature activeChar, Creature target, boolean reflected) {
        Player player = target.getPlayer();
        if (player == null) {
            return;
        }
        player.setHideCostume(!player.hideCostume());
        // Re-broadcast char info of every nearby player TO this viewer so they get re-rendered with the
        // new visibility preference. Other players' caches don't need to change.
        List<Player> nearby = World.getAroundPlayers(player);
        for (Player other : nearby) {
            if (other == player) {
                continue;
            }
            if (other.isInvisible(player)) {
                continue;
            }
            player.sendPacket((IBroadcastPacket)new CIPacket(other, player));
            player.sendPacket((IBroadcastPacket)new RelationChangedPacket(other, player));
        }
    }
}

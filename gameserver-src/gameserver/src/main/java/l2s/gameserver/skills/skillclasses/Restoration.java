/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.skillclasses;

import java.util.List;
import java.util.Set;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.skill.restoration.RestorationInfo;
import l2s.gameserver.templates.skill.restoration.RestorationItem;
import l2s.gameserver.utils.ItemFunctions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Restoration
extends Skill {
    private static final Logger _log = LoggerFactory.getLogger(Restoration.class);
    private final RestorationInfo _restoration;

    public Restoration(StatsSet set) {
        super(set);
        this._restoration = (RestorationInfo)set.get("restoration");
    }

    @Override
    public boolean checkCondition(SkillEntry skillEntry, Creature activeChar, Creature target, boolean forceUse, boolean dontMove, boolean first, boolean sendMsg, boolean trigger) {
        Player player;
        if (!super.checkCondition(skillEntry, activeChar, target, forceUse, dontMove, first, sendMsg, trigger)) {
            return false;
        }
        if (this._restoration == null) {
            _log.warn(this.getClass().getSimpleName() + ": Cannot find restoration info for skill[" + this.getId() + "-" + this.getLevel() + "]");
            return false;
        }
        if (!activeChar.isPlayable()) {
            return false;
        }
        if (activeChar.isPlayer() && ((player = (Player)activeChar).getWeightPenalty() >= 3 || player.getInventory().getSize() > player.getInventoryLimit() - 10)) {
            player.sendPacket((IBroadcastPacket)SystemMsg.THE_CORRESPONDING_WORK_CANNOT_BE_PROCEEDED_BECAUSE_THE_INVENTORY_WEIGHTQUANTITY_LIMIT_HAS_BEEN_EXCEEDED);
            return false;
        }
        return true;
    }

    @Override
    public void onEndCast(Creature activeChar, Set<Creature> targets) {
        List<RestorationItem> restorationItems;
        super.onEndCast(activeChar, targets);
        if (!activeChar.isPlayable()) {
            return;
        }
        Playable playable = (Playable)activeChar;
        int itemConsumeId = this._restoration.getItemConsumeId();
        int itemConsumeCount = this._restoration.getItemConsumeCount();
        if (itemConsumeId > 0 && itemConsumeCount > 0) {
            if (ItemFunctions.getItemCount(playable, itemConsumeId) < (long)itemConsumeCount) {
                playable.sendPacket((IBroadcastPacket)SystemMsg.THERE_ARE_NOT_ENOUGH_NECESSARY_ITEMS_TO_USE_THE_SKILL);
                return;
            }
            ItemFunctions.deleteItem(playable, itemConsumeId, (long)itemConsumeCount, true);
        }
        if ((restorationItems = this._restoration.getRandomGroupItems()) == null || restorationItems.size() == 0) {
            SystemMsg msg = this._restoration.getOnFailMessage();
            if (msg != null) {
                playable.sendPacket((IBroadcastPacket)msg);
            }
            return;
        }
        for (Creature target : targets) {
            if (target == null) continue;
            for (RestorationItem item : restorationItems) {
                ItemFunctions.addItem(playable, item.getId(), item.getRandomCount(), item.getEnchantLevel(), true);
            }
        }
    }
}


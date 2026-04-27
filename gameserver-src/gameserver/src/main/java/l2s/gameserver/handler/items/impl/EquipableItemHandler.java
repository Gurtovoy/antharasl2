/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.handler.items.impl;

import l2s.gameserver.ai.PlayableAI;
import l2s.gameserver.handler.items.impl.DefaultItemHandler;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.SoulShotType;
import l2s.gameserver.model.instances.PetInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessage;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.utils.ItemFunctions;

public class EquipableItemHandler
extends DefaultItemHandler {
    @Override
    public boolean useItem(Playable playable, ItemInstance item, boolean ctrl) {
        SystemMessage sm;
        if (playable.isPet()) {
            PetInstance pet = (PetInstance)playable;
            IBroadcastPacket sm2 = ItemFunctions.checkIfCanEquip(pet, item);
            if (sm2 == null) {
                if (item.isEquipped()) {
                    pet.getInventory().unEquipItem(item);
                } else {
                    pet.getInventory().equipItem(item);
                }
                pet.broadcastCharInfo();
                return true;
            }
            if (pet.getPlayer() != null) {
                pet.getPlayer().sendPacket(sm2);
            }
            return false;
        }
        if (!playable.isPlayer()) {
            return false;
        }
        Player player = playable.getPlayer();
        if (player.isStunned() || player.isSleeping() || player.isDecontrolled() || player.isAlikeDead() || player.isWeaponEquipBlocked()) {
            player.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addItemName(item.getItemId()));
            return false;
        }
        long bodyPart = item.getBodyPart();
        if (!(bodyPart != 16384L && bodyPart != 256L && bodyPart != 128L || !player.isMounted() && player.getActiveWeaponFlagAttachment() == null)) {
            player.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addItemName(item.getItemId()));
            return false;
        }
        if (player.isAttackingNow() || player.isCastingNow()) {
            player.getAI().setNextAction(PlayableAI.AINextAction.EQUIP, item, null, ctrl, true);
            player.sendActionFailed();
            return false;
        }
        if (item.isEquipped()) {
            ItemInstance weapon = player.getActiveWeaponInstance();
            if (item == weapon) {
                player.abortAttack(true, true);
                player.abortCast(true, true);
                player.removeAutoShot(SoulShotType.SOULSHOT);
                player.removeAutoShot(SoulShotType.SPIRITSHOT);
            }
            player.sendDisarmMessage(item);
            player.getInventory().unEquipItem(item);
            return false;
        }
        IBroadcastPacket p = ItemFunctions.checkIfCanEquip(player, item);
        if (p != null) {
            player.sendPacket(p);
            return false;
        }
        player.getInventory().equipItem(item);
        if (!item.isEquipped()) {
            player.sendActionFailed();
            return false;
        }
        if (item.getFixedEnchantLevel(player) > 0) {
            sm = new SystemMessage(368);
            sm.addNumber(item.getFixedEnchantLevel(player));
            sm.addItemName(item.getItemId());
        } else {
            sm = new SystemMessage(49).addItemName(item.getItemId());
        }
        player.sendPacket((IBroadcastPacket)sm);
        return true;
    }
}


/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExGMViewQuestItemListPacket;
import l2s.gameserver.network.l2.s2c.GMHennaInfoPacket;
import l2s.gameserver.network.l2.s2c.GMViewCharacterInfoPacket;
import l2s.gameserver.network.l2.s2c.GMViewItemListPacket;
import l2s.gameserver.network.l2.s2c.GMViewPledgeInfoPacket;
import l2s.gameserver.network.l2.s2c.GMViewQuestInfoPacket;
import l2s.gameserver.network.l2.s2c.GMViewSkillInfoPacket;
import l2s.gameserver.network.l2.s2c.GMViewWarehouseWithdrawListPacket;

public class RequestGMCommand
extends L2GameClientPacket {
    private String _targetName;
    private int _command;

    @Override
    protected boolean readImpl() {
        this._targetName = this.readS();
        this._command = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        Player target = World.getPlayer(this._targetName);
        if (player == null || target == null) {
            return;
        }
        if (!player.getPlayerAccess().CanViewChar) {
            return;
        }
        switch (this._command) {
            case 1: {
                player.sendPacket((IBroadcastPacket)new GMViewCharacterInfoPacket(target));
                player.sendPacket((IBroadcastPacket)new GMHennaInfoPacket(target));
                break;
            }
            case 2: {
                if (target.getClan() == null) break;
                player.sendPacket((IBroadcastPacket)new GMViewPledgeInfoPacket(target));
                break;
            }
            case 3: {
                player.sendPacket((IBroadcastPacket)new GMViewSkillInfoPacket(target));
                break;
            }
            case 4: {
                player.sendPacket((IBroadcastPacket)new GMViewQuestInfoPacket(target));
                break;
            }
            case 5: {
                ItemInstance[] items = target.getInventory().getItems();
                int questSize = 0;
                for (ItemInstance item : items) {
                    if (!item.getTemplate().isQuest()) continue;
                    ++questSize;
                }
                player.sendPacket((IBroadcastPacket)new GMViewItemListPacket(1, target, items, items.length - questSize));
                player.sendPacket((IBroadcastPacket)new GMViewItemListPacket(2, target, items, items.length - questSize));
                player.sendPacket((IBroadcastPacket)new ExGMViewQuestItemListPacket(1, target, items, questSize));
                player.sendPacket((IBroadcastPacket)new ExGMViewQuestItemListPacket(2, target, items, questSize));
                player.sendPacket((IBroadcastPacket)new GMHennaInfoPacket(target));
                break;
            }
            case 6: {
                player.sendPacket((IBroadcastPacket)new GMViewWarehouseWithdrawListPacket(1, target));
                player.sendPacket((IBroadcastPacket)new GMViewWarehouseWithdrawListPacket(2, target));
            }
        }
    }
}


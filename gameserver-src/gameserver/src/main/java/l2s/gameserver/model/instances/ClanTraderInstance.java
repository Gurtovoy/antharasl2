/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.instances;

import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.network.l2.components.HtmlMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.PledgeShowInfoUpdatePacket;
import l2s.gameserver.network.l2.s2c.SystemMessage;
import l2s.gameserver.templates.npc.NpcTemplate;

public final class ClanTraderInstance
extends NpcInstance {
    public ClanTraderInstance(int objectId, NpcTemplate template, MultiValueSet<String> set) {
        super(objectId, template, set);
    }

    @Override
    public void onBypassFeedback(Player player, String command) {
        HtmlMessage html = new HtmlMessage(this);
        if (command.equalsIgnoreCase("crp")) {
            if (player.getClan() != null && player.getClan().getLevel() > 4) {
                html.setFile("default/" + this.getNpcId() + "-2.htm");
            } else {
                html.setFile("default/" + this.getNpcId() + "-1.htm");
            }
            html.replace("%objectId%", String.valueOf(this.getObjectId()));
            player.sendPacket((IBroadcastPacket)html);
        } else if (command.startsWith("exchange")) {
            if (!player.isClanLeader()) {
                html.setFile("default/" + this.getNpcId() + "-no.htm");
                html.replace("%objectId%", String.valueOf(this.getObjectId()));
                player.sendPacket((IBroadcastPacket)html);
                return;
            }
            int itemId = Integer.parseInt(command.substring(9).trim());
            int reputation = 0;
            long itemCount = 0L;
            switch (itemId) {
                case 9911: {
                    reputation = 500;
                    itemCount = 1L;
                    break;
                }
                case 9910: {
                    reputation = 200;
                    itemCount = 10L;
                    break;
                }
                case 9912: {
                    reputation = 20;
                    itemCount = 100L;
                }
            }
            if (player.getInventory().destroyItemByItemId(itemId, itemCount)) {
                player.getClan().incReputation(reputation, false, "ClanTrader " + itemId + " from " + player.getName());
                player.getClan().broadcastToOnlineMembers(new PledgeShowInfoUpdatePacket(player.getClan()));
                player.sendPacket((IBroadcastPacket)new SystemMessage(1781).addNumber(reputation));
                html.setFile("default/" + this.getNpcId() + "-ExchangeSuccess.htm");
            } else {
                html.setFile("default/" + this.getNpcId() + "-ExchangeFailed.htm");
            }
            html.replace("%objectId%", String.valueOf(this.getObjectId()));
            player.sendPacket((IBroadcastPacket)html);
        } else {
            super.onBypassFeedback(player, command);
        }
    }
}


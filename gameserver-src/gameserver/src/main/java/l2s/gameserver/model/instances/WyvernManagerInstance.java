/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.collections.MultiValueSet
 */
package l2s.gameserver.model.instances;

import java.util.StringTokenizer;
import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.MountType;
import l2s.gameserver.model.entity.residence.Residence;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.templates.npc.NpcTemplate;

public final class WyvernManagerInstance
extends NpcInstance {
    public WyvernManagerInstance(int objectId, NpcTemplate template, MultiValueSet<String> set) {
        super(objectId, template, set);
    }

    @Override
    public void onBypassFeedback(Player player, String command) {
        StringTokenizer st = new StringTokenizer(command, " ");
        String actualCommand = st.nextToken();
        boolean condition = this.validateCondition(player);
        if (actualCommand.equalsIgnoreCase("RideWyvern")) {
            if (condition && player.isClanLeader()) {
                if (player.getMountType() != MountType.STRIDER) {
                    this.showChatWindow(player, "wyvern/not_ready.htm", false, new Object[0]);
                } else if (player.getInventory().getItemByItemId(1460) == null || player.getInventory().getItemByItemId(1460).getCount() < 25L) {
                    this.showChatWindow(player, "wyvern/havenot_cry.htm", false, new Object[0]);
                } else if (player.getInventory().destroyItemByItemId(1460, 25L)) {
                    player.setMount(player.getMountControlItemObjId(), 12621, player.getMountLevel(), player.getMountCurrentFeed());
                    this.showChatWindow(player, "wyvern/after_ride.htm", false, new Object[0]);
                }
            }
        } else {
            super.onBypassFeedback(player, command);
        }
    }

    @Override
    public void showChatWindow(Player player, int val, boolean firstTalk, Object ... arg) {
        if (val == 0) {
            if (!this.validateCondition(player)) {
                this.showChatWindow(player, "wyvern/lord_only.htm", false, new Object[0]);
            } else {
                this.showChatWindow(player, "wyvern/lord_here.htm", false, "%Char_name%", String.valueOf(player.getName()));
            }
        } else {
            super.showChatWindow(player, val, firstTalk, arg);
        }
    }

    private boolean validateCondition(Player player) {
        Residence residence = this.getCastle();
        if (residence != null && residence.getId() > 0 && player.getClan() != null && residence.getOwnerId() == player.getClanId() && player.isClanLeader()) {
            return true;
        }
        residence = this.getClanHall();
        return residence != null && residence.getId() > 0 && player.getClan() != null && residence.getOwnerId() == player.getClanId() && player.isClanLeader();
    }
}


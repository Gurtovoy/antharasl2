package l2s.gameserver.model.instances;

import java.util.StringTokenizer;
import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.MerchantInstance;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.templates.npc.NpcTemplate;
import l2s.gameserver.utils.WarehouseFunctions;

public final class NpcFriendInstance
extends MerchantInstance {
    public NpcFriendInstance(int objectId, NpcTemplate template, MultiValueSet<String> set) {
        super(objectId, template, set);
    }

    @Override
    public void showChatWindow(Player player, int val, boolean firstTalk, Object ... replace) {
        if (val == 0) {
            if (this.getNpcId() >= 31370 && this.getNpcId() <= 31376 && player.getVarka() > 0 || this.getNpcId() >= 31377 && this.getNpcId() < 31384 && player.getKetra() > 0) {
                this.showChatWindow(player, "npc_friend/" + this.getNpcId() + "-nofriend.htm", firstTalk, new Object[0]);
                return;
            }
            String filename = null;
            switch (this.getNpcId()) {
                case 31370: 
                case 31371: 
                case 31373: 
                case 31377: 
                case 31378: 
                case 31380: 
                case 31553: 
                case 31554: {
                    filename = "npc_friend/" + this.getNpcId() + ".htm";
                    break;
                }
                case 31372: {
                    if (player.getKetra() > 2) {
                        filename = "npc_friend/" + this.getNpcId() + "-bufflist.htm";
                        break;
                    }
                    filename = "npc_friend/" + this.getNpcId() + ".htm";
                    break;
                }
                case 31379: {
                    if (player.getVarka() > 2) {
                        filename = "npc_friend/" + this.getNpcId() + "-bufflist.htm";
                        break;
                    }
                    filename = "npc_friend/" + this.getNpcId() + ".htm";
                    break;
                }
                case 31374: {
                    if (player.getKetra() > 1) {
                        filename = "npc_friend/" + this.getNpcId() + "-warehouse.htm";
                        break;
                    }
                    filename = "npc_friend/" + this.getNpcId() + ".htm";
                    break;
                }
                case 31381: {
                    if (player.getVarka() > 1) {
                        filename = "npc_friend/" + this.getNpcId() + "-warehouse.htm";
                        break;
                    }
                    filename = "npc_friend/" + this.getNpcId() + ".htm";
                    break;
                }
                case 31375: {
                    if (player.getKetra() == 3 || player.getKetra() == 4) {
                        filename = "npc_friend/" + this.getNpcId() + "-special1.htm";
                        break;
                    }
                    if (player.getKetra() == 5) {
                        filename = "npc_friend/" + this.getNpcId() + "-special2.htm";
                        break;
                    }
                    filename = "npc_friend/" + this.getNpcId() + ".htm";
                    break;
                }
                case 31382: {
                    if (player.getVarka() == 3 || player.getVarka() == 4) {
                        filename = "npc_friend/" + this.getNpcId() + "-special1.htm";
                        break;
                    }
                    if (player.getVarka() == 5) {
                        filename = "npc_friend/" + this.getNpcId() + "-special2.htm";
                        break;
                    }
                    filename = "npc_friend/" + this.getNpcId() + ".htm";
                    break;
                }
                case 31376: {
                    if (player.getKetra() == 4) {
                        filename = "npc_friend/" + this.getNpcId() + "-normal.htm";
                        break;
                    }
                    if (player.getKetra() == 5) {
                        filename = "npc_friend/" + this.getNpcId() + "-special.htm";
                        break;
                    }
                    filename = "npc_friend/" + this.getNpcId() + ".htm";
                    break;
                }
                case 31383: {
                    if (player.getVarka() == 4) {
                        filename = "npc_friend/" + this.getNpcId() + "-normal.htm";
                        break;
                    }
                    if (player.getVarka() == 5) {
                        filename = "npc_friend/" + this.getNpcId() + "-special.htm";
                        break;
                    }
                    filename = "npc_friend/" + this.getNpcId() + ".htm";
                    break;
                }
                case 31555: {
                    if (player.getRam() == 1) {
                        filename = "npc_friend/" + this.getNpcId() + "-special1.htm";
                        break;
                    }
                    if (player.getRam() == 2) {
                        filename = "npc_friend/" + this.getNpcId() + "-special2.htm";
                        break;
                    }
                    filename = "npc_friend/" + this.getNpcId() + ".htm";
                    break;
                }
                case 31556: {
                    filename = player.getRam() == 2 ? "npc_friend/" + this.getNpcId() + "-bufflist.htm" : "npc_friend/" + this.getNpcId() + ".htm";
                }
            }
            if (filename != null) {
                this.showChatWindow(player, filename, firstTalk, new Object[0]);
                return;
            }
        }
        super.showChatWindow(player, val, firstTalk, replace);
    }

    @Override
    public void onBypassFeedback(Player player, String command) {
        StringTokenizer st = new StringTokenizer(command, " ");
        String actualCommand = st.nextToken();
        if (actualCommand.equalsIgnoreCase("Buff")) {
            if (st.countTokens() < 1) {
                return;
            }
            int val = Integer.parseInt(st.nextToken());
            int item = 0;
            switch (this.getNpcId()) {
                case 31372: {
                    item = 7186;
                    break;
                }
                case 31379: {
                    item = 7187;
                    break;
                }
                case 31556: {
                    item = 7251;
                }
            }
            int skill = 0;
            int level = 0;
            long count = 0L;
            switch (val) {
                case 1: {
                    skill = 4359;
                    level = 2;
                    count = 2L;
                    break;
                }
                case 2: {
                    skill = 4360;
                    level = 2;
                    count = 2L;
                    break;
                }
                case 3: {
                    skill = 4345;
                    level = 3;
                    count = 3L;
                    break;
                }
                case 4: {
                    skill = 4355;
                    level = 2;
                    count = 3L;
                    break;
                }
                case 5: {
                    skill = 4352;
                    level = 1;
                    count = 3L;
                    break;
                }
                case 6: {
                    skill = 4354;
                    level = 3;
                    count = 3L;
                    break;
                }
                case 7: {
                    skill = 4356;
                    level = 1;
                    count = 6L;
                    break;
                }
                case 8: {
                    skill = 4357;
                    level = 2;
                    count = 6L;
                }
            }
            if (skill != 0 && player.getInventory().destroyItemByItemId(item, count)) {
                player.doCast(SkillEntry.makeSkillEntry(SkillEntryType.NONE, skill, level), player, true);
            } else {
                this.showChatWindow(player, "npc_friend/" + this.getNpcId() + "-havenotitems.htm", false, new Object[0]);
            }
        } else if (command.startsWith("Chat")) {
            int val = Integer.parseInt(command.substring(5));
            String fname = "";
            fname = "npc_friend/" + this.getNpcId() + "-" + val + ".htm";
            if (!fname.equals("")) {
                this.showChatWindow(player, fname, false, new Object[0]);
            }
        } else if (command.startsWith("Buy")) {
            int val = Integer.parseInt(command.substring(4));
            this.showShopWindow(player, val, false);
        } else if (actualCommand.equalsIgnoreCase("Sell")) {
            this.showShopWindow(player);
        } else if (command.startsWith("WithdrawP")) {
            WarehouseFunctions.showRetrieveWindow(player);
        } else if (command.equals("DepositP")) {
            WarehouseFunctions.showDepositWindow(player);
        } else {
            super.onBypassFeedback(player, command);
        }
    }
}


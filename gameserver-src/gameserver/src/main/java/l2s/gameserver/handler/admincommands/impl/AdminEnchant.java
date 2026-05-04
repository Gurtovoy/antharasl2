package l2s.gameserver.handler.admincommands.impl;

import l2s.gameserver.handler.admincommands.IAdminCommandHandler;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.components.HtmlMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.InventoryUpdatePacket;

public class AdminEnchant
implements IAdminCommandHandler {
    @Override
    public boolean useAdminCommand(Enum<?> comm, String[] wordList, String fullString, Player activeChar) {
        Commands command = (Commands)comm;
        if (!activeChar.getPlayerAccess().CanEditChar) {
            return false;
        }
        int armorType = -1;
        switch (command) {
            case admin_enchant: {
                this.showMainPage(activeChar);
                return true;
            }
            case admin_seteh: {
                armorType = 6;
                break;
            }
            case admin_setec: {
                armorType = 10;
                break;
            }
            case admin_seteg: {
                armorType = 9;
                break;
            }
            case admin_seteb: {
                armorType = 12;
                break;
            }
            case admin_setel: {
                armorType = 11;
                break;
            }
            case admin_setew: {
                armorType = 7;
                break;
            }
            case admin_setes: {
                armorType = 8;
                break;
            }
            case admin_setle: {
                armorType = 2;
                break;
            }
            case admin_setre: {
                armorType = 1;
                break;
            }
            case admin_setlf: {
                armorType = 5;
                break;
            }
            case admin_setrf: {
                armorType = 4;
                break;
            }
            case admin_seten: {
                armorType = 3;
                break;
            }
            case admin_setun: {
                armorType = 0;
                break;
            }
            case admin_setba: {
                armorType = 13;
                break;
            }
            case admin_setha: {
                armorType = 15;
                break;
            }
            case admin_setdha: {
                armorType = 16;
                break;
            }
            case admin_setlbr: {
                armorType = 18;
                break;
            }
            case admin_setrbr: {
                armorType = 17;
                break;
            }
            case admin_setbelt: {
                armorType = 30;
            }
        }
        if (armorType == -1 || wordList.length < 2) {
            this.showMainPage(activeChar);
            return true;
        }
        try {
            int ench = Integer.parseInt(wordList[1]);
            if (ench < 0 || ench > 65535) {
                activeChar.sendMessage("You must set the enchant level to be between 0-65535.");
            } else {
                this.setEnchant(activeChar, ench, armorType);
            }
        }
        catch (StringIndexOutOfBoundsException e) {
            activeChar.sendMessage("Please specify a new enchant value.");
        }
        catch (NumberFormatException e) {
            activeChar.sendMessage("Please specify a valid new enchant value.");
        }
        this.showMainPage(activeChar);
        return true;
    }

    private void setEnchant(Player activeChar, int ench, int armorType) {
        GameObject target = activeChar.getTarget();
        if (target == null) {
            target = activeChar;
        }
        if (!target.isPlayer()) {
            activeChar.sendMessage("Wrong target type.");
            return;
        }
        Player player = (Player)target;
        int curEnchant = 0;
        ItemInstance itemInstance = player.getInventory().getPaperdollItem(armorType);
        if (itemInstance != null) {
            curEnchant = itemInstance.getEnchantLevel();
            itemInstance.setEnchantLevel(ench);
            player.getInventory().refreshEquip(itemInstance);
            player.sendPacket((IBroadcastPacket)new InventoryUpdatePacket().addModifiedItem(player, itemInstance));
            player.broadcastCharInfo();
            activeChar.sendMessage("Changed enchantment of " + player.getName() + "'s " + itemInstance.getName() + " from " + curEnchant + " to " + ench + ".");
            player.sendMessage("Admin has changed the enchantment of your " + itemInstance.getName() + " from " + curEnchant + " to " + ench + ".");
        }
    }

    public void showMainPage(Player activeChar) {
        GameObject target = activeChar.getTarget();
        if (target == null) {
            target = activeChar;
        }
        Player player = activeChar;
        if (target.isPlayer()) {
            player = (Player)target;
        }
        HtmlMessage adminReply = new HtmlMessage(5);
        StringBuilder replyMSG = new StringBuilder("<html><body>");
        replyMSG.append("<center><table width=720><tr><td width=40>");
        replyMSG.append("<button value=\"Main\" action=\"bypass -h admin_admin\" width=50 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\">");
        replyMSG.append("</td><td width=50>&nbsp;</td><td width=50>&nbsp;</td><td width=50>&nbsp;</td><td width=50>&nbsp;</td></tr></table></center><br>");
        replyMSG.append("<center>Enchant equip for player: " + player.getName() + "</center><br>");
        replyMSG.append("<center><table width=270><tr>");
        replyMSG.append("<td width=50><button value=\"Helmet\" action=\"bypass -h admin_seteh $menu_command\" width=50 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("<td width=50><button value=\"Mask\" action=\"bypass -h admin_setha $menu_command\" width=50 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("<td width=50><button value=\"Hair\" action=\"bypass -h admin_setdha $menu_command\" width=50 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("<td width=50><button value=\"Cloak\" action=\"bypass -h admin_setba $menu_command\" width=50 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("<td width=50><button value=\"Necklace\" action=\"bypass -h admin_seten $menu_command\" width=50 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("</tr>");
        replyMSG.append("<tr>");
        replyMSG.append("<td width=50><button value=\"Weapon\" action=\"bypass -h admin_setew $menu_command\" width=50 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("<td width=50><button value=\"Chest\" action=\"bypass -h admin_setec $menu_command\" width=50 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("<td width=50><button value=\"Shield\" action=\"bypass -h admin_setes $menu_command\" width=50 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("<td width=50><button value=\"Earring\" action=\"bypass -h admin_setre $menu_command\" width=50 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("<td width=50><button value=\"Earring\" action=\"bypass -h admin_setle $menu_command\" width=50 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("</tr>");
        replyMSG.append("<tr>");
        replyMSG.append("<td width=50><button value=\"Gloves\" action=\"bypass -h admin_seteg $menu_command\" width=50 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("<td width=50><button value=\"Leggings\" action=\"bypass -h admin_setel $menu_command\" width=50 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("<td width=50><button value=\"Boots\" action=\"bypass -h admin_seteb $menu_command\" width=50 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("<td width=50><button value=\"Ring\" action=\"bypass -h admin_setrf $menu_command\" width=50 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("<td width=50><button value=\"Ring\" action=\"bypass -h admin_setlf $menu_command\" width=50 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("</tr>");
        replyMSG.append("<tr>");
        replyMSG.append("<td width=50>&nbsp;</td>");
        replyMSG.append("<td width=50><button value=\"R-Bracelet\" action=\"bypass -h admin_setrbr $menu_command\" width=50 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>>");
        replyMSG.append("<td width=50><button value=\"L-Bracelet\" action=\"bypass -h admin_setlbr $menu_command\" width=50 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("<td width=50><button value=\"Pendant\" action=\"bypass -h admin_setun $menu_command\" width=50 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("<td width=50><button value=\"Belt\" action=\"bypass -h admin_setbelt $menu_command\" width=50 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("</tr></table></center><br>");
        replyMSG.append("<center>[Enchant 0-127]</center>");
        replyMSG.append("<center><edit var=\"menu_command\" width=100 height=15></center><br>");
        replyMSG.append("</body></html>");
        adminReply.setHtml(replyMSG.toString());
        activeChar.sendPacket((IBroadcastPacket)adminReply);
    }

    @Override
    public Enum<?>[] getAdminCommandEnum() {
        return Commands.values();
    }

    private static enum Commands {
        admin_seteh,
        admin_setec,
        admin_seteg,
        admin_setel,
        admin_seteb,
        admin_setew,
        admin_setes,
        admin_setle,
        admin_setre,
        admin_setlf,
        admin_setrf,
        admin_seten,
        admin_setun,
        admin_setba,
        admin_setha,
        admin_setdha,
        admin_setlbr,
        admin_setrbr,
        admin_setbelt,
        admin_enchant;

    }
}


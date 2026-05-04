/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.instances;

import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.model.instances.MerchantInstance;
import l2s.gameserver.templates.npc.NpcTemplate;
import l2s.gameserver.utils.HtmlUtils;

public final class MercManagerInstance
extends MerchantInstance {
    private static int COND_ALL_FALSE = 0;
    private static int COND_BUSY_BECAUSE_OF_SIEGE = 1;
    private static int COND_OWNER = 2;

    public MercManagerInstance(int objectId, NpcTemplate template, MultiValueSet<String> set) {
        super(objectId, template, set);
    }

    @Override
    public void onMenuSelect(Player player, int ask, long reply, int state) {
        if (ask == 0) {
            this.showMainChatWindow(player, false, new Object[0]);
        } else if (ask == -201) {
            int condition = this.validateCondition(player);
            if (condition == COND_OWNER && reply >= 1L && reply <= 6L) {
                this.showShopWindow(player, (int)reply, false);
            }
        } else if (ask == -202) {
            int castleId = this.getCastle().getId();
            String prefix = "";
            if (castleId == 5) {
                prefix = "aden_";
            } else if (castleId == 8) {
                prefix = "rune_";
            }
            this.showChatWindow(player, "residence2/castle/" + prefix + "msellerlimit.htm", false, "<?feud_name?>", HtmlUtils.htmlNpcString(1001000 + castleId, new Object[0]));
        }
    }

    @Override
    public void showMainChatWindow(Player player, boolean firstTalk, Object ... replace) {
        String filename = "residence2/castle/mseller002.htm";
        int condition = this.validateCondition(player);
        if (condition == COND_BUSY_BECAUSE_OF_SIEGE) {
            filename = "residence2/castle/mseller003.htm";
        } else if (condition == COND_OWNER) {
            filename = "residence2/castle/mseller001.htm";
        }
        this.showChatWindow(player, filename, firstTalk, new Object[0]);
    }

    @Override
    public String getHtmlDir(String filename, Player player) {
        return "residence2/castle/";
    }

    private int validateCondition(Player player) {
        if (player.isGM()) {
            return COND_OWNER;
        }
        if (this.getCastle() != null && this.getCastle().getId() != 0 && player.getClan() != null) {
            if (((SiegeEvent)((Object)this.getCastle().getSiegeEvent())).isInProgress()) {
                return COND_BUSY_BECAUSE_OF_SIEGE;
            }
            if (this.getCastle().getOwnerId() == player.getClanId() && (player.getClanPrivileges() & 0x400000) == 0x400000) {
                return COND_OWNER;
            }
        }
        return COND_ALL_FALSE;
    }
}


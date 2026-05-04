/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.util.List;
import java.util.regex.Matcher;
import l2s.gameserver.Config;
import l2s.gameserver.cache.ImagesCache;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.PledgeCrestPacket;
import l2s.gameserver.tables.FakePlayersTable;
import l2s.gameserver.utils.BypassStorage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ShowBoardPacket
extends L2GameServerPacket {
    private static final Logger _log = LoggerFactory.getLogger(ShowBoardPacket.class);
    public static L2GameServerPacket CLOSE = new ShowBoardPacket();
    private static final String[] DIRECT_BYPASS = new String[]{"bypass _bbshome", "bypass _bbsgetfav", "bypass _bbsloc", "bypass _bbsclan", "bypass _bbsmemo", "bypass _maillist_0_1_0_", "bypass _friendlist_0_"};
    private boolean _show;
    private String _html;
    private String _fav;

    public static void separateAndSend(String html, Player player) {
        if (html == null || html.isEmpty()) {
            return;
        }
        String fav = "";
        if (player.getSessionVar("add_fav") != null) {
            fav = "bypass _bbsaddfav_List";
        }
        html = player.getBypassStorage().parseHtml(html, BypassStorage.BypassType.BBS, true);
        html = html.replace("<?copyright?>", Config.BBS_COPYRIGHT);
        html = html.replace("<?total_online?>", String.valueOf(GameObjectsStorage.getPlayers(true, true).size() + FakePlayersTable.getActiveFakePlayersCount()));
        Matcher m = ImagesCache.HTML_PATTERN.matcher(html);
        while (m.find()) {
            String imageName = m.group(1);
            int imageId = ImagesCache.getInstance().getImageId(imageName);
            html = html.replaceAll("%image:" + imageName + "%", "Crest.pledge_crest_" + Config.REQUEST_ID + "_" + imageId);
            byte[] image = ImagesCache.getInstance().getImage(imageId);
            if (image == null) continue;
            player.sendPacket((IBroadcastPacket)new PledgeCrestPacket(imageId, image));
        }
        if (html.length() < 8180) {
            player.sendPacket((IBroadcastPacket)new ShowBoardPacket("101", html, fav));
            player.sendPacket((IBroadcastPacket)new ShowBoardPacket("102", "", fav));
            player.sendPacket((IBroadcastPacket)new ShowBoardPacket("103", "", fav));
        } else if (html.length() < 16360) {
            player.sendPacket((IBroadcastPacket)new ShowBoardPacket("101", html.substring(0, 8180), fav));
            player.sendPacket((IBroadcastPacket)new ShowBoardPacket("102", html.substring(8180, html.length()), fav));
            player.sendPacket((IBroadcastPacket)new ShowBoardPacket("103", "", fav));
        } else if (html.length() < 24540) {
            player.sendPacket((IBroadcastPacket)new ShowBoardPacket("101", html.substring(0, 8180), fav));
            player.sendPacket((IBroadcastPacket)new ShowBoardPacket("102", html.substring(8180, 16360), fav));
            player.sendPacket((IBroadcastPacket)new ShowBoardPacket("103", html.substring(16360, html.length()), fav));
        } else {
            throw new IllegalArgumentException("Html is too long!");
        }
    }

    public static void separateAndSend(String html, List<String> arg, Player player) {
        String fav = "";
        if (player.getSessionVar("add_fav") != null) {
            fav = "bypass _bbsaddfav_List";
        }
        html = player.getBypassStorage().parseHtml(html, BypassStorage.BypassType.BBS, true);
        html = html.replace("<?copyright?>", Config.BBS_COPYRIGHT);
        html = html.replace("<?total_online?>", String.valueOf(GameObjectsStorage.getPlayers(true, true).size() + FakePlayersTable.getActiveFakePlayersCount()));
        Matcher m = ImagesCache.HTML_PATTERN.matcher(html);
        while (m.find()) {
            String imageName = m.group(1);
            int imageId = ImagesCache.getInstance().getImageId(imageName);
            html = html.replaceAll("%image:" + imageName + "%", "Crest.pledge_crest_" + Config.REQUEST_ID + "_" + imageId);
            byte[] image = ImagesCache.getInstance().getImage(imageId);
            if (image == null) continue;
            player.sendPacket((IBroadcastPacket)new PledgeCrestPacket(imageId, image));
        }
        if (html.length() >= 8180) {
            throw new IllegalArgumentException("Html is too long!");
        }
        player.sendPacket((IBroadcastPacket)new ShowBoardPacket("1001", html, fav));
        player.sendPacket((IBroadcastPacket)new ShowBoardPacket("1002", arg, fav));
    }

    private ShowBoardPacket(String id, String html, String fav) {
        this._show = true;
        this._html = id + "\b";
        if (html != null) {
            this._html = this._html + html;
        }
        this._fav = fav;
    }

    private ShowBoardPacket(String id, List<String> arg, String fav) {
        this._show = true;
        this._html = id + "\b";
        for (String a : arg) {
            this._html = this._html + a + " \b";
        }
    }

    private ShowBoardPacket() {
        this._show = false;
    }

    @Override
    protected final void writeImpl() {
        this.writeC(this._show);
        if (this._show) {
            for (String bbsBypass : DIRECT_BYPASS) {
                this.writeS(bbsBypass);
            }
            this.writeS(this._fav);
            this.writeS(this._html);
        }
    }
}


/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.authcomm.as2gs;

import java.util.List;
import l2s.gameserver.Config;
import l2s.gameserver.dao.HardwareLimitsDAO;
import l2s.gameserver.dao.PremiumAccountDAO;
import l2s.gameserver.data.htm.HtmCache;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.authcomm.AuthServerCommunication;
import l2s.gameserver.network.authcomm.ReceivablePacket;
import l2s.gameserver.network.authcomm.SessionKey;
import l2s.gameserver.network.authcomm.gs2as.PlayerInGame;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.CharacterSelectionInfoPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.LoginResultPacket;
import l2s.gameserver.network.l2.s2c.ServerCloseSocketPacket;
import l2s.gameserver.network.l2.s2c.TutorialCloseHtmlPacket;
import l2s.gameserver.network.l2.s2c.TutorialShowHtmlPacket;
import org.apache.commons.lang3.StringUtils;

public class PlayerAuthResponse
extends ReceivablePacket {
    private String account;
    private boolean authed;
    private int playOkId1;
    private int playOkId2;
    private int loginOkId1;
    private int loginOkId2;
    private int bonus;
    private int bonusExpire;
    private int points;
    private String hwid;
    private long phoneNumber;

    @Override
    public boolean readImpl() {
        this.account = this.readS();
        boolean bl = this.authed = this.readC() == 1;
        if (this.authed) {
            this.playOkId1 = this.readD();
            this.playOkId2 = this.readD();
            this.loginOkId1 = this.readD();
            this.loginOkId2 = this.readD();
            this.bonus = this.readD();
            this.bonusExpire = this.readD();
            this.points = this.readD();
            this.hwid = this.readS();
            if (this.getByteBuffer().hasRemaining()) {
                this.phoneNumber = this.readQ();
            }
        }
        return true;
    }

    @Override
    protected void runImpl() {
        String clientHwid;
        SessionKey skey = new SessionKey(this.loginOkId1, this.loginOkId2, this.playOkId1, this.playOkId2);
        GameClient client = AuthServerCommunication.getInstance().removeWaitingClient(this.account);
        if (client == null) {
            return;
        }
        if (!(StringUtils.isEmpty((CharSequence)this.hwid) || StringUtils.isEmpty((CharSequence)(clientHwid = client.getHWID())) || this.hwid.equalsIgnoreCase(clientHwid))) {
            client.close(LoginResultPacket.ACCESS_FAILED_TRY_LATER);
            return;
        }
        if (this.authed && client.getSessionKey().equals(skey)) {
            if (Config.MAX_ACTIVE_ACCOUNTS_ON_ONE_IP > 0 && AuthServerCommunication.getInstance().getAuthedClient(this.account) == null) {
                boolean ignored = false;
                for (String ignoredIP : Config.MAX_ACTIVE_ACCOUNTS_IGNORED_IP) {
                    if (!ignoredIP.equalsIgnoreCase(client.getIpAddr())) continue;
                    ignored = true;
                    break;
                }
                if (!ignored) {
                    int limit = Config.MAX_ACTIVE_ACCOUNTS_ON_ONE_IP;
                    int[] limits = HardwareLimitsDAO.getInstance().select(client.getIpAddr());
                    if (limits[1] == -1 || (long)limits[1] > System.currentTimeMillis() / 1000L) {
                        limit += limits[0];
                    }
                    List<GameClient> clients = AuthServerCommunication.getInstance().getAuthedClientsByHWID(client.getIpAddr());
                    clients.add(client);
                    for (GameClient c : clients) {
                        int[] limitsByAccount = HardwareLimitsDAO.getInstance().select(c.getLogin());
                        if (limitsByAccount[1] != -1 && (long)limitsByAccount[1] <= System.currentTimeMillis() / 1000L) continue;
                        limit += limitsByAccount[0];
                    }
                    int activeWindows = AuthServerCommunication.getInstance().getAuthedClientsByIP(client.getIpAddr()).size();
                    if (activeWindows >= limit) {
                        String html = HtmCache.getInstance().getCache("windows_limit_ip.htm", client.getLanguage());
                        if (html != null) {
                            html = html.replace("<?active_windows?>", String.valueOf(activeWindows));
                            html = html.replace("<?windows_limit?>", String.valueOf(limit));
                            client.close(new TutorialShowHtmlPacket(TutorialShowHtmlPacket.NORMAL_WINDOW, html));
                        } else {
                            client.close(LoginResultPacket.ACCESS_FAILED_TRY_LATER);
                        }
                        return;
                    }
                }
            }
            if (Config.MAX_ACTIVE_ACCOUNTS_ON_ONE_HWID > 0 && AuthServerCommunication.getInstance().getAuthedClient(this.account) == null) {
                int limit = Config.MAX_ACTIVE_ACCOUNTS_ON_ONE_HWID;
                int[] limits = HardwareLimitsDAO.getInstance().select(client.getHWID());
                if (limits[1] == -1 || (long)limits[1] > System.currentTimeMillis() / 1000L) {
                    limit += limits[0];
                }
                List<GameClient> clients = AuthServerCommunication.getInstance().getAuthedClientsByHWID(client.getHWID());
                clients.add(client);
                for (GameClient c : clients) {
                    int[] limitsByAccount = HardwareLimitsDAO.getInstance().select(c.getLogin());
                    if (limitsByAccount[1] != -1 && (long)limitsByAccount[1] <= System.currentTimeMillis() / 1000L) continue;
                    limit += limitsByAccount[0];
                }
                int activeWindows = clients.size() - 1;
                if (activeWindows >= limit) {
                    String html = HtmCache.getInstance().getCache("windows_limit_hwid.htm", client.getLanguage());
                    if (html != null) {
                        html = html.replace("<?active_windows?>", String.valueOf(activeWindows));
                        html = html.replace("<?windows_limit?>", String.valueOf(limit));
                        client.close(new TutorialShowHtmlPacket(TutorialShowHtmlPacket.NORMAL_WINDOW, html));
                    } else {
                        client.close(LoginResultPacket.ACCESS_FAILED_TRY_LATER);
                    }
                    return;
                }
            }
            if (Config.MAX_ACTIVE_ACCOUNTS_ON_ONE_IP > 0 || Config.MAX_ACTIVE_ACCOUNTS_ON_ONE_HWID > 0) {
                client.sendPacket(TutorialCloseHtmlPacket.STATIC);
            }
            client.setAuthed(true);
            client.setState(GameClient.GameClientState.AUTHED);
            client.sendPacket(LoginResultPacket.SUCCESS);
            if (Config.PREMIUM_ACCOUNT_BASED_ON_GAMESERVER) {
                int[] bonuses = PremiumAccountDAO.getInstance().select(this.account);
                this.bonus = bonuses[0];
                this.bonusExpire = bonuses[1];
            }
            client.setPremiumAccountType(this.bonus);
            client.setPremiumAccountExpire(this.bonusExpire);
            client.setPoints(this.points);
            GameClient oldClient = AuthServerCommunication.getInstance().addAuthedClient(client);
            if (oldClient != null) {
                oldClient.setAuthed(false);
                Player activeChar = oldClient.getActiveChar();
                if (activeChar != null) {
                    activeChar.sendPacket((IBroadcastPacket)SystemMsg.ANOTHER_PERSON_HAS_LOGGED_IN_WITH_THE_SAME_ACCOUNT);
                    activeChar.logout();
                } else {
                    oldClient.close(ServerCloseSocketPacket.STATIC);
                }
            }
            this.sendPacket(new PlayerInGame(client.getLogin()));
            CharacterSelectionInfoPacket csi = new CharacterSelectionInfoPacket(client);
            client.sendPacket((L2GameServerPacket)csi);
            client.setCharSelection(csi.getCharInfo());
            client.setPhoneNumber(this.phoneNumber);
        } else {
            client.close(LoginResultPacket.ACCESS_FAILED_TRY_LATER);
        }
    }
}


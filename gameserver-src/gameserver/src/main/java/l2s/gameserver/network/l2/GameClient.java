package l2s.gameserver.network.l2;

import java.nio.ByteBuffer;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import l2s.commons.dbutils.DbUtils;
import l2s.commons.net.nio.impl.MMOClient;
import l2s.commons.net.nio.impl.MMOConnection;
import l2s.commons.net.nio.impl.SendablePacket;
import l2s.gameserver.Config;
import l2s.gameserver.config.FloodProtectorConfig;
import l2s.gameserver.config.FloodProtectorConfigs;
import l2s.gameserver.dao.CharacterDAO;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.CharSelectInfoPackage;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.authcomm.AuthServerCommunication;
import l2s.gameserver.network.authcomm.SessionKey;
import l2s.gameserver.network.authcomm.gs2as.PlayerLogout;
import l2s.gameserver.network.l2.BlowFishKeygen;
import l2s.gameserver.network.l2.FloodProtector;
import l2s.gameserver.network.l2.GameCrypt;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.security.SecondaryPasswordAuth;
import l2s.gameserver.utils.Language;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class GameClient
extends MMOClient<MMOConnection<GameClient>> {
    private static final Logger _log = LoggerFactory.getLogger(GameClient.class);
    private static final String NO_IP = "?.?.?.?";
    public GameCrypt _crypt = null;
    public GameClientState _state;
    private final Map<String, FloodProtector> _floodProtectors = new HashMap<String, FloodProtector>();
    private String _login;
    private int _premiumAccountType = 0;
    private int _premiumAccountExpire;
    private int _points = 0;
    private Language _language = Config.DEFAULT_LANG;
    private long _phoneNumber = 0L;
    private Player _activeChar;
    private SessionKey _sessionKey;
    private String _ip = "?.?.?.?";
    private int revision = 0;
    private SecondaryPasswordAuth _secondaryAuth = null;
    private List<Integer> _charSlotMapping = new ArrayList<Integer>();
    private String _hwid = null;
    private int _failedPackets = 0;
    private int _unknownPackets = 0;

    public GameClient(MMOConnection<GameClient> con) {
        super(con);
        this._state = GameClientState.CONNECTED;
        this._ip = con.getSocket().getInetAddress().getHostAddress();
        this._crypt = new GameCrypt();
        for (FloodProtectorConfig config : FloodProtectorConfigs.FLOOD_PROTECTORS) {
            this._floodProtectors.put(config.FLOOD_PROTECTOR_TYPE, new FloodProtector(this, config));
        }
    }

    protected void onDisconnection() {
        this.setState(GameClientState.DISCONNECTED);
        Player player = this.getActiveChar();
        this.setActiveChar(null);
        if (player != null) {
            player.setNetConnection(null);
            player.scheduleDelete();
        }
        if (this.getSessionKey() != null) {
            if (this.isAuthed()) {
                AuthServerCommunication.getInstance().removeAuthedClient(this.getLogin());
                AuthServerCommunication.getInstance().sendPacket(new PlayerLogout(this.getLogin()));
            } else {
                AuthServerCommunication.getInstance().removeWaitingClient(this.getLogin());
            }
        }
    }

    protected void onForcedDisconnection() {
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void markRestoredChar(int charslot) throws Exception {
        int objid = this.getObjectIdForSlot(charslot);
        if (objid < 0) {
            return;
        }
        if (this._activeChar != null && this._activeChar.getObjectId() == objid) {
            this._activeChar.setDeleteTimer(0);
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE characters SET deletetime=0 WHERE obj_id=?");
            statement.setInt(1, objid);
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void markToDeleteChar(int charslot) throws Exception {
        int objid = this.getObjectIdForSlot(charslot);
        if (objid < 0) {
            return;
        }
        if (this._activeChar != null && this._activeChar.getObjectId() == objid) {
            this._activeChar.setDeleteTimer((int)(System.currentTimeMillis() / 1000L));
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE characters SET deletetime=? WHERE obj_id=?");
            statement.setLong(1, (int)(System.currentTimeMillis() / 1000L));
            statement.setInt(2, objid);
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("data error on update deletime char:", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    public void deleteChar(int charslot) throws Exception {
        if (this._activeChar != null) {
            return;
        }
        int objid = this.getObjectIdForSlot(charslot);
        if (objid == -1) {
            return;
        }
        CharacterDAO.getInstance().deleteCharByObjId(objid);
    }

    public Player loadCharFromDisk(int charslot) {
        int objectId = this.getObjectIdForSlot(charslot);
        if (objectId == -1) {
            return null;
        }
        Player character = null;
        Player oldPlayer = GameObjectsStorage.getPlayer(objectId);
        if (oldPlayer != null) {
            if (oldPlayer.isInOfflineMode() || oldPlayer.isLogoutStarted()) {
                oldPlayer.kick();
            } else {
                oldPlayer.sendPacket((IBroadcastPacket)SystemMsg.ANOTHER_PERSON_HAS_LOGGED_IN_WITH_THE_SAME_ACCOUNT);
                GameClient oldClient = oldPlayer.getNetConnection();
                if (oldClient != null) {
                    oldClient.setActiveChar(null);
                    oldClient.closeNow(false);
                }
                oldPlayer.setNetConnection(this);
                character = oldPlayer;
            }
        }
        if (character == null) {
            character = Player.restore(objectId, false);
        }
        if (character != null) {
            this.setActiveChar(character);
        } else {
            _log.warn("could not restore obj_id: " + objectId + " in slot:" + charslot);
        }
        return character;
    }

    public int getObjectIdForSlot(int charslot) {
        if (charslot < 0 || charslot >= this._charSlotMapping.size()) {
            _log.warn(this.getLogin() + " tried to modify Character in slot " + charslot + " but no characters exits at that slot.");
            return -1;
        }
        return this._charSlotMapping.get(charslot);
    }

    public Player getActiveChar() {
        return this._activeChar;
    }

    public SessionKey getSessionKey() {
        return this._sessionKey;
    }

    public String getLogin() {
        return this._login;
    }

    public void setLoginName(String loginName) {
        this._login = loginName;
        if (Config.EX_SECOND_AUTH_ENABLED) {
            this._secondaryAuth = new SecondaryPasswordAuth(this);
        }
    }

    public void setActiveChar(Player player) {
        this._activeChar = player;
        if (player != null) {
            player.setNetConnection(this);
        }
    }

    public void setSessionId(SessionKey sessionKey) {
        this._sessionKey = sessionKey;
    }

    public void setCharSelection(CharSelectInfoPackage[] chars) {
        this._charSlotMapping.clear();
        for (CharSelectInfoPackage element : chars) {
            int objectId = element.getObjectId();
            this._charSlotMapping.add(objectId);
        }
    }

    public void setCharSelection(int c) {
        this._charSlotMapping.clear();
        this._charSlotMapping.add(c);
    }

    public int getRevision() {
        return this.revision;
    }

    public void setRevision(int revision) {
        this.revision = revision;
    }

    public boolean checkFloodProtection(String type, String command) {
        FloodProtector floodProtector = this._floodProtectors.get(type.toUpperCase());
        return floodProtector == null || floodProtector.tryPerformAction(command);
    }

    public boolean encrypt(ByteBuffer buf, int size) {
        this._crypt.encrypt(buf.array(), buf.position(), size);
        buf.position(buf.position() + size);
        return true;
    }

    public boolean decrypt(ByteBuffer buf, int size) {
        boolean ret = this._crypt.decrypt(buf.array(), buf.position(), size);
        return ret;
    }

    public void sendPacket(L2GameServerPacket gsp) {
        if (this.isConnected()) {
            this.getConnection().sendPacket((SendablePacket)gsp);
        }
    }

    public void sendPacket(L2GameServerPacket ... gsp) {
        if (this.isConnected()) {
            this.getConnection().sendPacket((SendablePacket[])gsp);
        }
    }

    public void sendPackets(List<L2GameServerPacket> gsp) {
        if (this.isConnected()) {
            this.getConnection().sendPackets(gsp);
        }
    }

    public void close(L2GameServerPacket gsp) {
        if (this.isConnected()) {
            this.getConnection().close((SendablePacket)gsp);
        }
    }

    public String getIpAddr() {
        return this._ip;
    }

    public byte[] enableCrypt() {
        byte[] key = BlowFishKeygen.getRandomKey();
        this._crypt.setKey(key);
        return key;
    }

    public boolean hasPremiumAccount() {
        return this._premiumAccountType != 0 && (long)this._premiumAccountExpire > System.currentTimeMillis() / 1000L;
    }

    public void setPremiumAccountType(int type) {
        this._premiumAccountType = type;
    }

    public int getPremiumAccountType() {
        return this._premiumAccountType;
    }

    public void setPremiumAccountExpire(int expire) {
        this._premiumAccountExpire = expire;
    }

    public int getPremiumAccountExpire() {
        return this._premiumAccountExpire;
    }

    public int getPoints() {
        return this._points;
    }

    public void setPoints(int points) {
        this._points = points;
    }

    public Language getLanguage() {
        return this._language;
    }

    public void setLanguage(Language language) {
        this._language = language;
    }

    public long getPhoneNumber() {
        return this._phoneNumber;
    }

    public void setPhoneNumber(long value) {
        this._phoneNumber = value;
    }

    public GameClientState getState() {
        return this._state;
    }

    public void setState(GameClientState state) {
        this._state = state;
    }

    public SecondaryPasswordAuth getSecondaryAuth() {
        return this._secondaryAuth;
    }

    public void onPacketReadFail() {
        if (this._failedPackets++ >= 10) {
            _log.warn("Too many client packet fails, connection closed : " + (Object)((Object)this));
            this.closeNow(true);
        }
    }

    public void onUnknownPacket() {
        if (this._unknownPackets++ >= 10) {
            _log.warn("Too many client unknown packets, connection closed : " + (Object)((Object)this));
            this.closeNow(true);
        }
    }

    public String toString() {
        return (Object)((Object)this._state) + " IP: " + this.getIpAddr() + (this._login == null ? "" : " Account: " + this._login) + (this._activeChar == null ? "" : " Player : " + this._activeChar);
    }

    public boolean secondaryAuthed() {
        if (!Config.EX_SECOND_AUTH_ENABLED) {
            return true;
        }
        return this.getSecondaryAuth().isAuthed();
    }

    public String getHWID() {
        return this._hwid;
    }

    public void setHWID(String hwid) {
        this._hwid = hwid;
    }

    public static enum GameClientState {
        CONNECTED,
        AUTHED,
        IN_GAME,
        DISCONNECTED;

    }
}


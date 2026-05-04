package l2s.gameserver.model.actor.instances.player;

import java.util.Calendar;
import l2s.commons.lang.reference.HardReference;
import l2s.commons.lang.reference.HardReferences;
import l2s.gameserver.model.Player;

public class Friend {
    private final int _objectId;
    private String _name;
    private int _classId;
    private int _level;
    private String _memo;
    private int _clanId;
    private String _clanName;
    private int _allyId;
    private String _allyName;
    private int _creationDay;
    private int _creationMonth;
    private long _lastAccess;
    private HardReference<Player> _playerRef = HardReferences.emptyRef();

    public Friend(int objectId, String name, int classId, int level, String memo, int clanId, String clanName, int allyId, String allyName, int createTime, int lastAccess) {
        this._objectId = objectId;
        this._name = name;
        this._classId = classId;
        this._level = level;
        this._memo = memo;
        this._clanId = clanId;
        this._clanName = clanName;
        this._allyId = allyId;
        this._allyName = allyName;
        this.setCreateTime((long)createTime * 1000L);
        this._lastAccess = (long)lastAccess * 1000L;
    }

    public Friend(Player player) {
        this._objectId = player.getObjectId();
        this._memo = "";
        this.update(player, true);
    }

    public void update(Player player, boolean set) {
        this._level = player.getLevel();
        this._name = player.getName();
        this._classId = player.getActiveClassId();
        this._playerRef = set ? player.getRef() : HardReferences.emptyRef();
        this._clanId = player.getClanId();
        this._allyId = player.getAllyId();
        if (player.getClan() != null) {
            this._clanName = player.getClan().getName();
            this._allyName = player.getClan().getAlliance() != null ? player.getClan().getAlliance().getAllyName() : "";
        } else {
            this._clanName = "";
            this._allyName = "";
        }
        this.setCreateTime(player.getCreateTime());
        this._lastAccess = System.currentTimeMillis();
    }

    public String getName() {
        Player player = this.getPlayer();
        return player == null ? this._name : player.getName();
    }

    public int getObjectId() {
        return this._objectId;
    }

    public int getClassId() {
        Player player = this.getPlayer();
        return player == null ? this._classId : player.getActiveClassId();
    }

    public int getLevel() {
        Player player = this.getPlayer();
        return player == null ? this._level : player.getLevel();
    }

    public boolean isOnline() {
        Player player = (Player)this._playerRef.get();
        return player != null && !player.isInOfflineMode();
    }

    public Player getPlayer() {
        Player player = (Player)this._playerRef.get();
        return player != null && !player.isInOfflineMode() ? player : null;
    }

    public int getClanId() {
        Player player = this.getPlayer();
        return player == null ? this._clanId : player.getClanId();
    }

    public String getClanName() {
        Player player = this.getPlayer();
        if (player == null) {
            return this._clanName;
        }
        if (player.getClan() == null) {
            return "";
        }
        return player.getClan().getName();
    }

    public int getAllyId() {
        Player player = this.getPlayer();
        return player == null ? this._allyId : player.getAllyId();
    }

    public String getAllyName() {
        Player player = this.getPlayer();
        if (player == null) {
            return this._allyName;
        }
        if (player.getClan() == null || player.getClan().getAlliance() == null) {
            return "";
        }
        return player.getClan().getAlliance().getAllyName();
    }

    public String getMemo() {
        return this._memo;
    }

    public void setMemo(String val) {
        this._memo = val;
    }

    public int getCreationDay() {
        return this._creationDay;
    }

    public int getCreationMonth() {
        return this._creationMonth;
    }

    public void setCreateTime(long time) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(time);
        this._creationDay = calendar.get(5);
        this._creationMonth = calendar.get(2);
    }

    public int getLastAccessDelay() {
        return this.isOnline() ? -1 : (int)((System.currentTimeMillis() - this._lastAccess) / 1000L);
    }
}


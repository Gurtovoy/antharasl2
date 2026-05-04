package l2s.gameserver.model.entity;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.idfactory.IdFactory;
import l2s.gameserver.instancemanager.CoupleManager;
import l2s.gameserver.model.Player;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Couple {
    private static final Logger _log = LoggerFactory.getLogger(Couple.class);
    private int _id = 0;
    private int _player1Id = 0;
    private int _player2Id = 0;
    private boolean _maried = false;
    private long _affiancedDate;
    private long _weddingDate;
    private boolean isChanged;

    public Couple(int coupleId) {
        this._id = coupleId;
    }

    public Couple(Player player1, Player player2) {
        long time;
        this._id = IdFactory.getInstance().getNextId();
        this._player1Id = player1.getObjectId();
        this._player2Id = player2.getObjectId();
        this._affiancedDate = time = System.currentTimeMillis();
        this._weddingDate = time;
        player1.setCoupleId(this._id);
        player1.setPartnerId(this._player2Id);
        player2.setCoupleId(this._id);
        player2.setPartnerId(this._player1Id);
    }

    public void marry() {
        this._weddingDate = System.currentTimeMillis();
        this._maried = true;
        this.setChanged(true);
    }

    public void divorce() {
        CoupleManager.getInstance().getCouples().remove(this);
        CoupleManager.getInstance().getDeletedCouples().add(this);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void store(Connection con) {
        PreparedStatement statement = null;
        try {
            statement = con.prepareStatement("REPLACE INTO couples (id, player1Id, player2Id, maried, affiancedDate, weddingDate) VALUES (?, ?, ?, ?, ?, ?)");
            statement.setInt(1, this._id);
            statement.setInt(2, this._player1Id);
            statement.setInt(3, this._player2Id);
            statement.setBoolean(4, this._maried);
            statement.setLong(5, this._affiancedDate);
            statement.setLong(6, this._weddingDate);
            statement.execute();
        }
        catch (Exception e) {
            _log.error("", (Throwable)e);
        }
        finally {
            DbUtils.closeQuietly((Statement)statement);
        }
    }

    public final int getId() {
        return this._id;
    }

    public final int getPlayer1Id() {
        return this._player1Id;
    }

    public final int getPlayer2Id() {
        return this._player2Id;
    }

    public final boolean getMaried() {
        return this._maried;
    }

    public final long getAffiancedDate() {
        return this._affiancedDate;
    }

    public final long getWeddingDate() {
        return this._weddingDate;
    }

    public void setPlayer1Id(int _player1Id) {
        this._player1Id = _player1Id;
    }

    public void setPlayer2Id(int _player2Id) {
        this._player2Id = _player2Id;
    }

    public void setMaried(boolean _maried) {
        this._maried = _maried;
    }

    public void setAffiancedDate(long _affiancedDate) {
        this._affiancedDate = _affiancedDate;
    }

    public void setWeddingDate(long _weddingDate) {
        this._weddingDate = _weddingDate;
    }

    public boolean isChanged() {
        return this.isChanged;
    }

    public void setChanged(boolean val) {
        this.isChanged = val;
    }
}


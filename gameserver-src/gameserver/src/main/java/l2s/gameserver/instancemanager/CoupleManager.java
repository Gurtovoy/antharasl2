/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.dbutils.DbUtils
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.instancemanager;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.Couple;
import l2s.gameserver.network.l2.components.CustomMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CoupleManager {
    private static final Logger _log = LoggerFactory.getLogger(CoupleManager.class);
    private static CoupleManager _instance;
    private List<Couple> _couples;
    private List<Couple> _deletedCouples;

    public static CoupleManager getInstance() {
        if (_instance == null) {
            new CoupleManager();
        }
        return _instance;
    }

    public CoupleManager() {
        _instance = this;
        _log.info("Initializing CoupleManager");
        _instance.load();
        ThreadPoolManager.getInstance().scheduleAtFixedRate(new StoreTask(), 600000L, 600000L);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private void load() {
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rs = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT * FROM couples ORDER BY id");
            rs = statement.executeQuery();
            while (rs.next()) {
                Couple c = new Couple(rs.getInt("id"));
                c.setPlayer1Id(rs.getInt("player1Id"));
                c.setPlayer2Id(rs.getInt("player2Id"));
                c.setMaried(rs.getBoolean("maried"));
                c.setAffiancedDate(rs.getLong("affiancedDate"));
                c.setWeddingDate(rs.getLong("weddingDate"));
                this.getCouples().add(c);
            }
            _log.info("Loaded: " + this.getCouples().size() + " couples(s)");
        }
        catch (Exception e) {
            try {
                _log.error("", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rs);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rs);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rs);
    }

    public final Couple getCouple(int coupleId) {
        for (Couple c : this.getCouples()) {
            if (c == null || c.getId() != coupleId) continue;
            return c;
        }
        return null;
    }

    public void engage(Player cha) {
        int chaId = cha.getObjectId();
        for (Couple cl : this.getCouples()) {
            if (cl == null || cl.getPlayer1Id() != chaId && cl.getPlayer2Id() != chaId) continue;
            if (cl.getMaried()) {
                cha.setMaried(true);
            }
            cha.setCoupleId(cl.getId());
            if (cl.getPlayer1Id() == chaId) {
                cha.setPartnerId(cl.getPlayer2Id());
                continue;
            }
            cha.setPartnerId(cl.getPlayer1Id());
        }
    }

    public void notifyPartner(Player cha) {
        Player partner;
        if (cha.getPartnerId() != 0 && (partner = GameObjectsStorage.getPlayer(cha.getPartnerId())) != null) {
            partner.sendMessage(new CustomMessage("l2s.gameserver.instancemanager.CoupleManager.PartnerEntered"));
        }
    }

    public void createCouple(Player player1, Player player2) {
        if (player1 != null && player2 != null && player1.getPartnerId() == 0 && player2.getPartnerId() == 0) {
            this.getCouples().add(new Couple(player1, player2));
        }
    }

    public final List<Couple> getCouples() {
        if (this._couples == null) {
            this._couples = new CopyOnWriteArrayList<Couple>();
        }
        return this._couples;
    }

    public List<Couple> getDeletedCouples() {
        if (this._deletedCouples == null) {
            this._deletedCouples = new CopyOnWriteArrayList<Couple>();
        }
        return this._deletedCouples;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void store() {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            if (this._deletedCouples != null && !this._deletedCouples.isEmpty()) {
                statement = con.prepareStatement("DELETE FROM couples WHERE id = ?");
                for (Couple c : this._deletedCouples) {
                    statement.setInt(1, c.getId());
                    statement.execute();
                }
                this._deletedCouples.clear();
            }
            if (this._couples != null && !this._couples.isEmpty()) {
                for (Couple c : this._couples) {
                    if (c == null || !c.isChanged()) continue;
                    c.store(con);
                    c.setChanged(false);
                }
            }
        }
        catch (Exception e) {
            _log.error("", (Throwable)e);
        }
        finally {
            DbUtils.closeQuietly((Connection)con, statement);
        }
    }

    private class StoreTask
    implements Runnable {
        private StoreTask() {
        }

        @Override
        public void run() {
            CoupleManager.this.store();
        }
    }
}


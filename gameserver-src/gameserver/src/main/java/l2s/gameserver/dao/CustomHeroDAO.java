/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.dbutils.DbUtils
 *  org.napile.primitive.maps.IntIntMap
 *  org.napile.primitive.maps.impl.HashIntIntMap
 *  org.napile.primitive.pair.IntIntPair
 *  org.napile.primitive.sets.impl.HashIntSet
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.entity.Hero;
import org.napile.primitive.maps.IntIntMap;
import org.napile.primitive.maps.impl.HashIntIntMap;
import org.napile.primitive.pair.IntIntPair;
import org.napile.primitive.sets.impl.HashIntSet;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CustomHeroDAO {
    private static final Logger _log = LoggerFactory.getLogger(CustomHeroDAO.class);
    private static final CustomHeroDAO _instance = new CustomHeroDAO();
    private IntIntMap _heroes = new HashIntIntMap();

    public CustomHeroDAO() {
        this.deleteExpiredHeroes();
        this.loadCustomHeroes();
    }

    public static CustomHeroDAO getInstance() {
        return _instance;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private void deleteExpiredHeroes() {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("DELETE FROM custom_heroes WHERE time > 0 AND time < ?");
            statement.setInt(1, (int)(System.currentTimeMillis() / 1000L));
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("CustomHeroDAO:deleteExpiredHeroes()", (Throwable)e);
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
    public void loadCustomHeroes() {
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT * FROM custom_heroes");
            rset = statement.executeQuery();
            while (rset.next()) {
                this._heroes.put(rset.getInt("hero_id"), rset.getInt("time"));
            }
        }
        catch (Exception e) {
            try {
                _log.error("CharacterVariablesDAO:loadCustomHeroes()", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                _log.info("CustomHeroDAO: loaded " + this._heroes.size() + " custom heroes.");
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
            _log.info("CustomHeroDAO: loaded " + this._heroes.size() + " custom heroes.");
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        _log.info("CustomHeroDAO: loaded " + this._heroes.size() + " custom heroes.");
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void addCustomHero(int objectId, int time) {
        if (time != -1 && this._heroes.get(objectId) > time) {
            return;
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("REPLACE INTO custom_heroes (hero_id, time) VALUES(?,?)");
            statement.setInt(1, objectId);
            statement.setInt(2, time);
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("CharacterVariablesDAO:addCustomHero(int,int)", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                this._heroes.put(objectId, time);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
            this._heroes.put(objectId, time);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
        this._heroes.put(objectId, time);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     * Loose catch block
     */
    public void removeCustomHero(int objectId) {
        if (this._heroes.containsKey(objectId) || Hero.getInstance().isHero(objectId)) {
            return;
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("DELETE FROM custom_heroes WHERE hero_id =?");
            statement.setInt(1, objectId);
            statement.execute();
        }
        catch (Exception e) {
            // exception handling
        }
        finally {
            DbUtils.closeQuietly((Connection)con, statement);
            this._heroes.remove(objectId);
        }
    }

    public boolean isCustomHero(int objectId) {
        int time = this._heroes.get(objectId);
        return time == -1 || (long)time > System.currentTimeMillis() / 1000L;
    }

    public int getExpiryTime(int objectId) {
        return this._heroes.get(objectId);
    }

    public int[] getActiveHeroes() {
        HashIntSet result = new HashIntSet();
        for (IntIntPair entry : this._heroes.entrySet()) {
            int time = entry.getValue();
            if (time != -1 && (long)time <= System.currentTimeMillis() / 1000L) continue;
            result.add(entry.getKey());
        }
        return result.toArray();
    }
}


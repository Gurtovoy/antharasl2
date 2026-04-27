/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.dbutils.DbUtils
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Map;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.actor.instances.player.TrainingCamp;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CharacterTrainingCampDAO {
    private static final Logger _log = LoggerFactory.getLogger(CharacterTrainingCampDAO.class);
    private static final CharacterTrainingCampDAO _instance = new CharacterTrainingCampDAO();

    public static CharacterTrainingCampDAO getInstance() {
        return _instance;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void restore(Map<String, TrainingCamp> map) {
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT * FROM character_training_camp");
            rset = statement.executeQuery();
            while (rset.next()) {
                String accountName = rset.getString("account_name");
                map.put(accountName, new TrainingCamp(accountName, rset.getInt("char_id"), rset.getInt("class_index"), rset.getInt("level"), rset.getLong("start_time") * 1000L, rset.getLong("end_time") * 1000L));
            }
        }
        catch (Exception e) {
            try {
                _log.error("CharacterTrainingCampDAO.restore(): " + e, (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean replace(String account, TrainingCamp trainingCamp) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("REPLACE INTO character_training_camp (account_name,char_id,class_index,level,start_time,end_time) VALUES(?,?,?,?,?,?)");
            statement.setString(1, account);
            statement.setInt(2, trainingCamp.getObjectId());
            statement.setInt(3, trainingCamp.getClassIndex());
            statement.setInt(4, trainingCamp.getLevel());
            statement.setInt(5, (int)(trainingCamp.getStartTime() / 1000L));
            statement.setInt(6, (int)(trainingCamp.getEndTime() / 1000L));
            statement.execute();
        }
        catch (Exception e) {
            boolean bl;
            try {
                _log.warn("CharacterTrainingCampDAO.replace(String,TrainingCamp): " + e, (Throwable)e);
                bl = false;
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
            return bl;
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void delete(String account) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("DELETE FROM character_training_camp WHERE account_name=?");
            statement.setString(1, account);
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.warn("CharacterTrainingCampDAO.delete(String): " + e, (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }
}


/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.dbutils.DbUtils
 *  org.napile.primitive.maps.impl.HashIntIntMap
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.model.entity.olympiad;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.Announcements;
import l2s.gameserver.Config;
import l2s.gameserver.dao.OlympiadParticipantsDAO;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.instancemanager.ServerVariables;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.model.base.ClassLevel;
import l2s.gameserver.model.base.SubClassType;
import l2s.gameserver.model.entity.Hero;
import l2s.gameserver.model.entity.olympiad.Olympiad;
import l2s.gameserver.model.entity.olympiad.OlympiadParticipiantData;
import l2s.gameserver.network.l2.s2c.SystemMessage;
import l2s.gameserver.templates.StatsSet;
import org.napile.primitive.maps.impl.HashIntIntMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class OlympiadDatabase {
    private static final Logger _log = LoggerFactory.getLogger(OlympiadDatabase.class);

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public static synchronized void loadParticipantsRank() {
        Olympiad._participantRank.clear();
        HashIntIntMap tmpPlace = new HashIntIntMap();
        for (int heroId : Hero.getInstance().getHeroes().keySet().toArray()) {
            Olympiad._participantRank.put(heroId, 1);
        }
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT `char_id` FROM `olympiad_participants` ORDER BY olympiad_points_past_static DESC");
            rset = statement.executeQuery();
            int place = 1;
            while (rset.next()) {
                int charId = rset.getInt("char_id");
                if (Olympiad._participantRank.containsKey(charId)) continue;
                tmpPlace.put(charId, place++);
            }
        }
        catch (Exception e) {
            try {
                _log.error("Olympiad System: Error!", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        int rank1 = (int)Math.round((double)tmpPlace.size() * 0.01);
        int rank2 = (int)Math.round((double)tmpPlace.size() * 0.1);
        int rank3 = (int)Math.round((double)tmpPlace.size() * 0.25);
        int rank4 = (int)Math.round((double)tmpPlace.size() * 0.5);
        if (rank1 == 0) {
            rank1 = 1;
            ++rank2;
            ++rank3;
            ++rank4;
        }
        for (int charId : tmpPlace.keySet().toArray()) {
            if (tmpPlace.get(charId) <= rank1) {
                Olympiad._participantRank.put(charId, 2);
                continue;
            }
            if (tmpPlace.get(charId) <= rank2) {
                Olympiad._participantRank.put(charId, 3);
                continue;
            }
            if (tmpPlace.get(charId) <= rank3) {
                Olympiad._participantRank.put(charId, 4);
                continue;
            }
            if (tmpPlace.get(charId) <= rank4) {
                Olympiad._participantRank.put(charId, 5);
                continue;
            }
            Olympiad._participantRank.put(charId, 6);
        }
    }

    public static synchronized void cleanupParticipants() {
        _log.info("Olympiad: Calculating last period...");
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE `olympiad_participants` SET `olympiad_points_past` = `olympiad_points`, `olympiad_points_past_static` = `olympiad_points` WHERE `competitions_done` >= ?");
            statement.setInt(1, Config.OLYMPIAD_BATTLES_FOR_REWARD);
            statement.execute();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("UPDATE `olympiad_participants` SET `olympiad_points` = ?, `competitions_done` = 0, `competitions_win` = 0, `competitions_loose` = 0, game_classes_count=0, game_noclasses_count=0");
            statement.setInt(1, Config.OLYMPIAD_POINTS_DEFAULT);
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("Olympiad System: Couldn't calculate last period!", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
        for (OlympiadParticipiantData participantsInfo : Olympiad.getParticipantsMap().valueCollection()) {
            int points = participantsInfo.getPoints();
            int compDone = participantsInfo.getCompDone();
            int compWin = participantsInfo.getCompWin();
            participantsInfo.setPoints(Config.OLYMPIAD_POINTS_DEFAULT);
            if (compDone >= Config.OLYMPIAD_BATTLES_FOR_REWARD) {
                points = compWin > 0 ? (points += Config.OLYMPIAD_1_OR_MORE_WIN_POINTS_BONUS) : (points += Config.OLYMPIAD_ALL_LOOSE_POINTS_BONUS);
                participantsInfo.setPointsPast(points);
                participantsInfo.setPointsPastStatic(points);
            } else {
                participantsInfo.setPointsPast(0);
                participantsInfo.setPointsPastStatic(0);
            }
            participantsInfo.setCompDone(0);
            participantsInfo.setCompWin(0);
            participantsInfo.setCompLoose(0);
            participantsInfo.setClassedGamesCount(0);
            participantsInfo.setNonClassedGamesCount(0);
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public static synchronized List<StatsSet> computeHeroesToBe() {
        if (Olympiad._period != 1) {
            return Collections.emptyList();
        }
        ArrayList<StatsSet> heroesToBe = new ArrayList<StatsSet>();
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            for (ClassId id3 : ClassId.VALUES) {
                ClassId id2;
                if (!id3.isOfLevel(ClassLevel.THIRD) || !(id2 = id3.getParent(0)).isOfLevel(ClassLevel.SECOND)) continue;
                statement = con.prepareStatement("SELECT `char_id`, characters.char_name AS char_name, character_subclasses.class_id AS class_id FROM `olympiad_participants` LEFT JOIN characters ON char_id=characters.obj_Id LEFT JOIN character_subclasses ON char_id=character_subclasses.char_obj_id AND character_subclasses.type=? WHERE characters.obj_Id > 0 AND (character_subclasses.class_id = ? OR character_subclasses.class_id = ?) AND `competitions_done` >= ? AND `competitions_win` > 0 ORDER BY `olympiad_points` DESC, `competitions_win` DESC, `competitions_done` DESC");
                statement.setInt(1, SubClassType.BASE_CLASS.ordinal());
                statement.setInt(2, id2.getId());
                statement.setInt(3, id3.getId());
                statement.setInt(4, Config.OLYMPIAD_BATTLES_FOR_REWARD);
                rset = statement.executeQuery();
                if (rset.next()) {
                    StatsSet hero = new StatsSet();
                    hero.set("class_id", rset.getInt("class_id"));
                    hero.set("char_id", rset.getInt("char_id"));
                    hero.set("char_name", rset.getString("char_name"));
                    heroesToBe.add(hero);
                }
                DbUtils.close((Statement)statement, (ResultSet)rset);
            }
        }
        catch (Exception e) {
            _log.error("Olympiad System: Couldnt heros from db!", (Throwable)e);
        }
        finally {
            DbUtils.closeQuietly((Connection)con, statement, rset);
        }
        return heroesToBe;
    }

    public static synchronized void saveParticipantData(int participantId) {
        OlympiadParticipantsDAO.getInstance().replace(participantId);
    }

    public static synchronized void saveParticipantsData() {
        for (int participantId : Olympiad.getParticipantsMap().keySet().toArray()) {
            OlympiadDatabase.saveParticipantData(participantId);
        }
    }

    public static synchronized void deleteParticipantData(int participantId) {
        OlympiadParticipantsDAO.getInstance().delete(participantId);
    }

    public static synchronized void setNewOlympiadStartTime() {
        Announcements.announceToAll(new SystemMessage(1639).addNumber(Olympiad._currentCycle));
        Olympiad.setOlympiadPeriodStartTime(System.currentTimeMillis());
        Olympiad.setWeekStartTime(System.currentTimeMillis());
        Olympiad._isOlympiadEnd = false;
    }

    public static void save() {
        OlympiadDatabase.saveParticipantsData();
        ServerVariables.set("Olympiad_CurrentCycle", Olympiad._currentCycle);
        ServerVariables.set("Olympiad_Period", Olympiad._period);
        ServerVariables.set("olympiad_period_start_time", Olympiad.getOlympiadPeriodStartTime());
        ServerVariables.set("olympiad_validation_start_time", Olympiad.getValidationStartTime());
        ServerVariables.set("olympiad_week_start_time", Olympiad.getWeekStartTime());
    }
}


package l2s.gameserver.model.entity;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.Config;
import l2s.gameserver.dao.CustomHeroDAO;
import l2s.gameserver.data.string.StringsHolder;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.database.mysql;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.SubClassType;
import l2s.gameserver.model.entity.HeroDiary;
import l2s.gameserver.model.entity.olympiad.Olympiad;
import l2s.gameserver.model.pledge.Alliance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.components.HtmlMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.SocialActionPacket;
import l2s.gameserver.network.l2.s2c.SystemMessage;
import l2s.gameserver.tables.ClanTable;
import l2s.gameserver.templates.StatsSet;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.CHashIntObjectMap;
import org.napile.primitive.pair.IntObjectPair;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Hero {
    private static final Logger _log = LoggerFactory.getLogger(Hero.class);
    private static Hero _instance;
    private static final String GET_HEROES = "SELECT h.char_id AS char_id, h.count AS count, h.active AS active, c.char_name AS char_name, cs.class_id AS class_id FROM heroes AS h LEFT JOIN characters AS c ON c.obj_Id = h.char_id LEFT JOIN character_subclasses AS cs ON cs.char_obj_id = h.char_id AND cs.type=? WHERE char_name IS NOT NULL AND class_id IS NOT NULL AND played = 1";
    private static final String GET_ALL_HEROES = "SELECT h.char_id AS char_id, h.count AS count, h.active AS active, h.played AS played, c.char_name AS char_name, cs.class_id AS class_id FROM heroes AS h LEFT JOIN characters AS c ON c.obj_Id = h.char_id LEFT JOIN character_subclasses AS cs ON cs.char_obj_id = h.char_id AND cs.type=? WHERE char_name IS NOT NULL AND class_id IS NOT NULL";
    private static IntObjectMap<StatsSet> _heroes;
    private static IntObjectMap<StatsSet> _completeHeroes;
    private static IntObjectMap<List<HeroDiary>> _herodiary;
    private static IntObjectMap<String> _heroMessage;
    public static final String CHAR_ID = "char_id";
    public static final String CLASS_ID = "class_id";
    public static final String CHAR_NAME = "char_name";
    public static final String COUNT = "count";
    public static final String PLAYED = "played";
    public static final String CLAN_NAME = "clan_name";
    public static final String CLAN_CREST = "clan_crest";
    public static final String ALLY_NAME = "ally_name";
    public static final String ALLY_CREST = "ally_crest";
    public static final String ACTIVE = "active";
    public static final String MESSAGE = "message";

    public static Hero getInstance() {
        if (_instance == null) {
            _instance = new Hero();
        }
        return _instance;
    }

    public Hero() {
        this.init();
    }

    private static void HeroSetClanAndAlly(int charId, StatsSet hero) {
        Map.Entry<Clan, Alliance> e = ClanTable.getInstance().getClanAndAllianceByCharId(charId);
        hero.set(CLAN_CREST, e.getKey() == null ? 0 : e.getKey().getCrestId());
        hero.set(CLAN_NAME, e.getKey() == null ? "" : e.getKey().getName());
        hero.set(ALLY_CREST, e.getValue() == null ? 0 : e.getValue().getAllyCrestId());
        hero.set(ALLY_NAME, e.getValue() == null ? "" : e.getValue().getAllyName());
        e = null;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private void init() {
        _heroes = new CHashIntObjectMap();
        _completeHeroes = new CHashIntObjectMap();
        _herodiary = new CHashIntObjectMap();
        _heroMessage = new CHashIntObjectMap();
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            int charId;
            StatsSet hero;
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(GET_HEROES);
            statement.setInt(1, SubClassType.BASE_CLASS.ordinal());
            rset = statement.executeQuery();
            while (rset.next()) {
                hero = new StatsSet();
                charId = rset.getInt(CHAR_ID);
                hero.set(CHAR_NAME, rset.getString(CHAR_NAME));
                hero.set(CLASS_ID, Olympiad.convertParticipantClassId(rset.getInt(CLASS_ID)));
                hero.set(COUNT, rset.getInt(COUNT));
                hero.set(PLAYED, 1);
                hero.set(ACTIVE, rset.getInt(ACTIVE));
                Hero.HeroSetClanAndAlly(charId, hero);
                this.loadDiary(charId);
                this.loadMessage(charId);
                _heroes.put(charId, hero);
            }
            DbUtils.close((Statement)statement, (ResultSet)rset);
            statement = con.prepareStatement(GET_ALL_HEROES);
            statement.setInt(1, SubClassType.BASE_CLASS.ordinal());
            rset = statement.executeQuery();
            while (rset.next()) {
                hero = new StatsSet();
                charId = rset.getInt(CHAR_ID);
                hero.set(CHAR_NAME, rset.getString(CHAR_NAME));
                hero.set(CLASS_ID, Olympiad.convertParticipantClassId(rset.getInt(CLASS_ID)));
                hero.set(COUNT, rset.getInt(COUNT));
                hero.set(PLAYED, rset.getInt(PLAYED));
                hero.set(ACTIVE, rset.getInt(ACTIVE));
                Hero.HeroSetClanAndAlly(charId, hero);
                _completeHeroes.put(charId, hero);
            }
        }
        catch (SQLException e) {
            try {
                _log.warn("Hero System: Couldnt load Heroes", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        _log.info("Hero System: Loaded " + _heroes.size() + " Heroes.");
        _log.info("Hero System: Loaded " + _completeHeroes.size() + " all time Heroes.");
    }

    public IntObjectMap<StatsSet> getHeroes() {
        return _heroes;
    }

    public synchronized void clearHeroes() {
        mysql.set("UPDATE heroes SET played = 0, active = 0");
        for (IntObjectPair entry : _heroes.entrySet()) {
            Player player;
            if (((StatsSet)(entry.getValue())).getInteger(ACTIVE) == 0 || (player = GameObjectsStorage.getPlayer(entry.getKey())) == null) continue;
            player.setHero(CustomHeroDAO.getInstance().isCustomHero(player.getObjectId()));
            player.checkAndDeleteOlympiadItems();
            player.updatePledgeRank();
            player.broadcastUserInfo(true);
        }
        _heroes.clear();
        _herodiary.clear();
    }

    public synchronized boolean computeNewHeroes(List<StatsSet> newHeroes) {
        if (newHeroes.size() == 0) {
            return true;
        }
        CHashIntObjectMap heroes = new CHashIntObjectMap();
        for (StatsSet hero : newHeroes) {
            int charId = hero.getInteger(CHAR_ID);
            if (_completeHeroes != null && _completeHeroes.containsKey(charId)) {
                StatsSet oldHero = (StatsSet)((Object)_completeHeroes.get(charId));
                int count = oldHero.getInteger(COUNT);
                oldHero.set(COUNT, count + 1);
                oldHero.set(PLAYED, 1);
                oldHero.set(ACTIVE, 0);
                heroes.put(charId, oldHero);
            } else {
                StatsSet newHero = new StatsSet();
                newHero.set(CHAR_NAME, hero.getString(CHAR_NAME));
                newHero.set(CLASS_ID, hero.getInteger(CLASS_ID));
                newHero.set(COUNT, 1);
                newHero.set(PLAYED, 1);
                newHero.set(ACTIVE, 0);
                heroes.put(charId, newHero);
            }
            this.addHeroDiary(charId, 2, 0);
            this.loadDiary(charId);
        }
        _heroes.putAll((IntObjectMap)heroes);
        heroes.clear();
        this.updateHeroes(0);
        return false;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void updateHeroes(int id) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("REPLACE INTO heroes (char_id, count, played, active) VALUES (?,?,?,?)");
            for (int heroId : _heroes.keySet().toArray()) {
                if (id > 0 && heroId != id) continue;
                StatsSet hero = (StatsSet)((Object)_heroes.get(heroId));
                statement.setInt(1, heroId);
                statement.setInt(2, hero.getInteger(COUNT));
                statement.setInt(3, hero.getInteger(PLAYED));
                statement.setInt(4, hero.getInteger(ACTIVE));
                statement.execute();
                if (_completeHeroes == null || _completeHeroes.containsKey(heroId)) continue;
                Hero.HeroSetClanAndAlly(heroId, hero);
                _completeHeroes.put(heroId, hero);
            }
        }
        catch (SQLException e) {
            try {
                _log.warn("Hero System: Couldnt update Heroes");
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

    public boolean isHero(int id) {
        if (_heroes == null || _heroes.isEmpty()) {
            return false;
        }
        return _heroes.containsKey(id) && ((StatsSet)((Object)_heroes.get(id))).getInteger(ACTIVE) == 1;
    }

    public boolean isInactiveHero(int id) {
        if (_heroes == null || _heroes.isEmpty()) {
            return false;
        }
        return _heroes.containsKey(id) && ((StatsSet)((Object)_heroes.get(id))).getInteger(ACTIVE) == 0;
    }

    public void activateHero(Player player) {
        int points;
        StatsSet hero = (StatsSet)((Object)_heroes.get(player.getObjectId()));
        if (hero == null) {
            return;
        }
        hero.set(ACTIVE, 1);
        player.setHero(true);
        player.checkHeroSkills();
        player.updatePledgeRank();
        player.broadcastPacket(new SocialActionPacket(player.getObjectId(), 20016));
        Clan clan = player.getClan();
        if (clan != null && (points = clan.incReputation(Config.OLYMPIAD_HERO_REWARD_CLAN_POINTS, true, "Hero:activateHero:" + player)) > 0) {
            clan.broadcastToOtherOnlineMembers(new SystemMessage(1776).addString(player.getName()).addNumber(points), player);
        }
        player.broadcastUserInfo(true);
        this.updateHeroes(player.getObjectId());
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void loadDiary(int charId) {
        ResultSet rset;
        PreparedStatement statement;
        Connection con;
        block5: {
            ArrayList<HeroDiary> diary = new ArrayList<HeroDiary>();
            con = null;
            statement = null;
            rset = null;
            try {
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.prepareStatement("SELECT * FROM  heroes_diary WHERE charId=? ORDER BY time ASC");
                statement.setInt(1, charId);
                rset = statement.executeQuery();
                while (rset.next()) {
                    long time = rset.getLong("time");
                    int action = rset.getInt("action");
                    int param = rset.getInt("param");
                    HeroDiary d = new HeroDiary(action, time, param);
                    diary.add(d);
                }
                _herodiary.put(charId, diary);
                if (!Config.DEBUG) break block5;
                _log.info("Hero System: Loaded " + diary.size() + " diary entries for Hero(object id: #" + charId + ")");
            }
            catch (SQLException e) {
                try {
                    _log.warn("Hero System: Couldnt load Hero Diary for CharId: " + charId, (Throwable)e);
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly((Connection)con, statement, rset);
                    throw throwable;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
            }
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
    }

    public void showHeroDiary(Player activeChar, int heroclass, int charid, int page) {
        StatsSet hero = (StatsSet)((Object)_heroes.get(charid));
        if (hero == null) {
            return;
        }
        int perpage = 10;
        List mainlist = (List)_herodiary.get(charid);
        if (mainlist != null) {
            HtmlMessage html = new HtmlMessage(5);
            html.setFile("olympiad/monument_hero_info.htm");
            html.replace("%title%", StringsHolder.getInstance().getString(activeChar, "hero.diary"));
            html.replace("%heroname%", hero.getString(CHAR_NAME));
            String message = (String)_heroMessage.get(charid);
            html.replace("%message%", message == null ? "" : message);
            ArrayList list = new ArrayList(mainlist);
            Collections.reverse(list);
            boolean color = true;
            StringBuilder fList = new StringBuilder(500);
            int counter = 0;
            int breakat = 0;
            for (int i = (page - 1) * 10; i < list.size(); ++i) {
                breakat = i;
                HeroDiary diary = (HeroDiary)list.get(i);
                Map.Entry<String, String> entry = diary.toString(activeChar);
                fList.append("<tr><td>");
                if (color) {
                    fList.append("<table width=270 bgcolor=\"131210\">");
                } else {
                    fList.append("<table width=270>");
                }
                fList.append("<tr><td width=270><font color=\"LEVEL\">" + entry.getKey() + "</font></td></tr>");
                fList.append("<tr><td width=270>" + entry.getValue() + "</td></tr>");
                fList.append("<tr><td>&nbsp;</td></tr></table>");
                fList.append("</td></tr>");
                boolean bl = color = !color;
                if (++counter >= 10) break;
            }
            if (breakat < list.size() - 1) {
                html.replace("%buttprev%", "<button value=\"&$1037;\" action=\"bypass %prev_bypass%\" width=\"60\" height=\"25\" back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\">");
                html.replace("%prev_bypass%", "_diary?class=" + heroclass + "&page=" + (page + 1));
            } else {
                html.replace("%buttprev%", "");
            }
            if (page > 1) {
                html.replace("%buttnext%", "<button value=\"&$1038;\" action=\"bypass %next_bypass%\" width=\"60\" height=\"25\" back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\">");
                html.replace("%next_bypass%", "_diary?class=" + heroclass + "&page=" + (page - 1));
            } else {
                html.replace("%buttnext%", "");
            }
            html.replace("%list%", fList.toString());
            activeChar.sendPacket((IBroadcastPacket)html);
        }
    }

    public void addHeroDiary(int playerId, int id, int param) {
        this.insertHeroDiary(playerId, id, param);
        List list = (List)_herodiary.get(playerId);
        if (list != null) {
            list.add(new HeroDiary(id, System.currentTimeMillis(), param));
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private void insertHeroDiary(int charId, int action, int param) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("INSERT INTO heroes_diary (charId, time, action, param) values(?,?,?,?)");
            statement.setInt(1, charId);
            statement.setLong(2, System.currentTimeMillis());
            statement.setInt(3, action);
            statement.setInt(4, param);
            statement.execute();
            statement.close();
        }
        catch (SQLException e) {
            try {
                _log.error("SQL exception while saving DiaryData.", (Throwable)e);
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
    public void loadMessage(int charId) {
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            String message = null;
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT message FROM heroes WHERE char_id=?");
            statement.setInt(1, charId);
            rset = statement.executeQuery();
            rset.next();
            message = rset.getString(MESSAGE);
            _heroMessage.put(charId, message);
        }
        catch (SQLException e) {
            try {
                _log.error("Hero System: Couldnt load Hero Message for CharId: " + charId, (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
    }

    public void setHeroMessage(int charId, String message) {
        _heroMessage.put(charId, message);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void saveHeroMessage(int charId) {
        if (_heroMessage.get(charId) == null) {
            return;
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE heroes SET message=? WHERE char_id=?;");
            statement.setString(1, (String)_heroMessage.get(charId));
            statement.setInt(2, charId);
            statement.execute();
            statement.close();
        }
        catch (SQLException e) {
            try {
                _log.error("SQL exception while saving HeroMessage.", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    public void shutdown() {
        for (int charId : _heroMessage.keySet().toArray()) {
            this.saveHeroMessage(charId);
        }
    }

    public int getHeroByClass(int classid) {
        if (!_heroes.isEmpty()) {
            for (int heroId : _heroes.keySet().toArray()) {
                StatsSet hero = (StatsSet)((Object)_heroes.get(heroId));
                if (hero.getInteger(CLASS_ID) != classid) continue;
                return heroId;
            }
        }
        return 0;
    }

    public IntObjectPair<StatsSet> getHeroStats(int classId) {
        for (IntObjectPair entry : _heroes.entrySet()) {
            if (((StatsSet)(entry.getValue())).getInteger(CLASS_ID) != classId) continue;
            return entry;
        }
        return null;
    }
}


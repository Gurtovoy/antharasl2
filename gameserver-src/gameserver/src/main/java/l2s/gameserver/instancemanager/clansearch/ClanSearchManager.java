/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.instancemanager.clansearch;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.instancemanager.clansearch.ClanSearchTask;
import l2s.gameserver.listener.actor.player.OnPlayerEnterListener;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.listener.CharListenerList;
import l2s.gameserver.model.clansearch.ClanSearchClan;
import l2s.gameserver.model.clansearch.ClanSearchParams;
import l2s.gameserver.model.clansearch.ClanSearchPlayer;
import l2s.gameserver.model.clansearch.ClanSearchWaiterParams;
import l2s.gameserver.model.clansearch.base.ClanSearchClanSortType;
import l2s.gameserver.model.clansearch.base.ClanSearchListType;
import l2s.gameserver.model.clansearch.base.ClanSearchPlayerSortType;
import l2s.gameserver.model.clansearch.base.ClanSearchSortOrder;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExPledgeWaitingListAlarm;
import l2s.gameserver.tables.ClanTable;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ClanSearchManager {
    private static final Logger _log = LoggerFactory.getLogger(ClanSearchManager.class);
    public static final long CLAN_LOCK_TIME = 300000L;
    public static final long WAITER_LOCK_TIME = 300000L;
    public static final long APPLICANT_LOCK_TIME = 300000L;
    private static final long CLAN_SEARCH_SAVE_DELAY = 3600000L;
    private static final OnPlayerEnterListener PLAYER_ENTER_LISTENER = new PlayerEnterListener();
    private static final ClanSearchManager _instance = new ClanSearchManager();
    private final TIntObjectMap<ClanSearchClan> _registeredClans = new TIntObjectHashMap();
    private final List<ClanSearchClan> _registeredClansList = new ArrayList<ClanSearchClan>();
    private final TIntObjectMap<ClanSearchPlayer> _waitingPlayers = new TIntObjectHashMap();
    private final TIntObjectMap<TIntObjectMap<ClanSearchPlayer>> _applicantPlayers = new TIntObjectHashMap();
    private final ClanSearchTask _scheduledTaskExecutor = new ClanSearchTask();

    public static ClanSearchManager getInstance() {
        return _instance;
    }

    
    public void load() {
        _log.info(this.getClass().getSimpleName() + ": Loading clan search data...");
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet result = null;
        try {
            int charClassId;
            String charName;
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT `clan_id`, `search_type`, `desc`, `application`, `sub_unit` FROM `clan_search_registered_clans`");
            result = statement.executeQuery();
            while (result.next()) {
                try {
                    int clanId = result.getInt("clan_id");
                    ClanSearchListType searchType = ClanSearchListType.valueOf(result.getString("search_type"));
                    String desc = result.getString("desc");
                    int application = result.getInt("application");
                    int subUnit = result.getInt("sub_unit");
                    ClanSearchClan clan = new ClanSearchClan(clanId, searchType, desc, application, subUnit);
                    if (ClanTable.getInstance().getClan(clanId) == null) {
                        this._scheduledTaskExecutor.scheduleClanForRemoval(clanId);
                        continue;
                    }
                    this.addClan(clan);
                }
                catch (Exception e) {
                    _log.error(this.getClass().getSimpleName() + ": Failed to load Clan Search Engine clan row.", (Throwable)e);
                }
            }
            DbUtils.closeQuietly((Statement)statement, (ResultSet)result);
            statement = con.prepareStatement("SELECT `char_id`, `char_name`, `char_level`, `char_class_id`, `preffered_clan_id`, `search_type`, `desc` FROM `clan_search_clan_applicants`");
            result = statement.executeQuery();
            while (result.next()) {
                try {
                    int charId = result.getInt("char_id");
                    charName = result.getString("char_name");
                    int charLevel = result.getInt("char_level");
                    charClassId = result.getInt("char_class_id");
                    int prefferedClanId = result.getInt("preffered_clan_id");
                    ClanSearchListType searchType = ClanSearchListType.valueOf(result.getString("search_type"));
                    String desc = result.getString("desc");
                    ClanSearchPlayer player = new ClanSearchPlayer(charId, charName, charLevel, charClassId, prefferedClanId, searchType, desc);
                    this.addPlayer(player);
                }
                catch (Exception e) {
                    _log.error(this.getClass().getSimpleName() + ": Failed to load Clan Search Engine applicant.", (Throwable)e);
                }
            }
            statement = con.prepareStatement("SELECT `char_id`, `char_name`, `char_level`, `char_class_id`, `search_type` FROM `clan_search_waiting_players`");
            result = statement.executeQuery();
            while (result.next()) {
                try {
                    int charId = result.getInt("char_id");
                    charName = result.getString("char_name");
                    int charLevel = result.getInt("char_level");
                    charClassId = result.getInt("char_class_id");
                    ClanSearchListType searchType = ClanSearchListType.valueOf(result.getString("search_type"));
                    this.addPlayer(new ClanSearchPlayer(charId, charName, charLevel, charClassId, searchType));
                }
                catch (Exception e) {
                    _log.error(this.getClass().getSimpleName() + ": Failed to load Clan Search Engine waiter.", (Throwable)e);
                }
            }
        }
        catch (SQLException e) {
            try {
                _log.error(this.getClass().getSimpleName() + ": Failed to load Clan Search Engine clan list.", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, result);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)result);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)result);
        _log.info(this.getClass().getSimpleName() + ": Loaded " + this._registeredClans.size() + " registered clans.");
        _log.info(this.getClass().getSimpleName() + ": Loaded " + this._applicantPlayers.size() + " registered players.");
        ThreadPoolManager.getInstance().scheduleAtFixedRate(this._scheduledTaskExecutor, 3600000L, 3600000L);
        CharListenerList.addGlobal(PLAYER_ENTER_LISTENER);
    }

    public int getPageCount(int paginationLimit) {
        return this._registeredClans.size() / paginationLimit + (this._registeredClans.size() % paginationLimit == 0 ? 0 : 1);
    }

    public ClanSearchClan getClan(int clanId) {
        return (ClanSearchClan)this._registeredClans.get(clanId);
    }

    
    public List<ClanSearchClan> listClans(int paginationLimit, ClanSearchParams params) {
        int currentIndex;
        ArrayList<ClanSearchClan> clanList = new ArrayList<ClanSearchClan>();
        int page = Math.min(params.getCurrentPage(), this.getPageCount(paginationLimit));
        block4: for (int i = 0; i < paginationLimit && (currentIndex = i + page * paginationLimit) < this._registeredClansList.size(); ++i) {
            ClanSearchClan csClan = this._registeredClansList.get(currentIndex);
            Clan clan = ClanTable.getInstance().getClan(csClan.getClanId());
            if (clan == null || params.getClanLevel() >= 0 && clan.getLevel() != params.getClanLevel() || params.getSearchType() != ClanSearchListType.SLT_ANY && csClan.getSearchType() != params.getSearchType()) continue;
            if (!params.getName().isEmpty()) {
                switch (params.getTargetType()) {
                    case TARGET_TYPE_LEADER_NAME: {
                        if (!clan.getLeaderName().contains(params.getName())) break;
                        continue block4;
                    }
                    case TARGET_TYPE_CLAN_NAME: {
                        if (!clan.getName().contains(params.getName())) continue block4;
                    }
                }
            }
            clanList.add(csClan);
        }
        ClanSearchSortOrder sortOrder = params.getSortOrder();
        if (sortOrder != ClanSearchSortOrder.NONE) {
            ClanSearchClanSortType sortType = params.getSortType();
            Collections.sort(clanList, (csClanLeft, csClanRight) -> {
                if (csClanLeft == csClanRight) {
                    return 0;
                }
                Clan clanLeft = ClanTable.getInstance().getClan(csClanLeft.getClanId());
                Clan clanRight = ClanTable.getInstance().getClan(csClanRight.getClanId());
                int result = 0;
                switch (sortType) {
                    case SORT_TYPE_CLAN_NAME: {
                        result = Integer.compare(clanLeft.getLevel(), clanRight.getLevel());
                        break;
                    }
                    case SORT_TYPE_LEADER_NAME: {
                        result = clanLeft.getName().compareTo(clanRight.getName());
                        break;
                    }
                    case SORT_TYPE_MEMBER_COUNT: {
                        result = clanLeft.getLeaderName().compareTo(clanRight.getName());
                        break;
                    }
                    case SORT_TYPE_CLAN_LEVEL: {
                        result = Integer.compare(clanLeft.getAllSize(), clanRight.getAllSize());
                        break;
                    }
                    case SORT_TYPE_SEARCH_LIST_TYPE: {
                        result = Integer.compare(csClanLeft.getSearchType().ordinal(), csClanRight.getSearchType().ordinal());
                    }
                }
                if (sortOrder != ClanSearchSortOrder.DESC) {
                    return -result;
                }
                return result;
            });
        }
        return clanList;
    }

    public boolean isClanRegistered(int clanId) {
        return this._registeredClans.containsKey(clanId);
    }

    public boolean addClan(ClanSearchClan clan) {
        if (this._scheduledTaskExecutor.isClanLocked(clan.getClanId())) {
            return false;
        }
        ClanSearchClan existedClan = this.getClan(clan.getClanId());
        if (existedClan != null) {
            existedClan.setSearchType(clan.getSearchType());
            existedClan.setDesc(clan.getDesc());
            existedClan.setApplication(clan.getApplication());
            existedClan.setSubUnit(clan.getSubUnit());
            this._scheduledTaskExecutor.scheduleClanForAddition(existedClan);
            return true;
        }
        this._registeredClansList.add(clan);
        this._registeredClans.put(clan.getClanId(), clan);
        this._scheduledTaskExecutor.scheduleClanForAddition(clan);
        return true;
    }

    public void removeClan(ClanSearchClan clan) {
        if (this._registeredClans.containsKey(clan.getClanId())) {
            this._registeredClansList.remove(clan);
            this._registeredClans.remove(clan.getClanId());
            this._scheduledTaskExecutor.lockClan(clan.getClanId(), 300000L);
        }
    }

    public ClanSearchPlayer getWaiter(int charId) {
        return (ClanSearchPlayer)this._waitingPlayers.get(charId);
    }

    public ClanSearchPlayer findAnyApplicant(int charId) {
        for (TIntObjectMap players : this._applicantPlayers.valueCollection()) {
            if (!players.containsKey(charId)) continue;
            return (ClanSearchPlayer)players.get(charId);
        }
        return null;
    }

    public ClanSearchPlayer getApplicant(int clanId, int charId) {
        TIntObjectMap players = (TIntObjectMap)this._applicantPlayers.get(clanId);
        if (players == null) {
            return null;
        }
        return (ClanSearchPlayer)players.get(charId);
    }

    public boolean isApplicantRegistered(int clanId, int playerId) {
        TIntObjectMap players = (TIntObjectMap)this._applicantPlayers.get(clanId);
        if (players == null) {
            return false;
        }
        return players.containsKey(playerId);
    }

    public boolean isWaiterRegistered(int playerId) {
        return this._waitingPlayers.containsKey(playerId);
    }

    public boolean addPlayer(ClanSearchPlayer player) {
        if (player.isApplicant()) {
            if (this._scheduledTaskExecutor.isApplicantLocked(player.getCharId())) {
                return false;
            }
            if (!this.isApplicantRegistered(player.getPrefferedClanId(), player.getCharId())) {
                TIntObjectMap players = (TIntObjectMap)this._applicantPlayers.get(player.getPrefferedClanId());
                if (players == null) {
                    players = new TIntObjectHashMap(1);
                    this._applicantPlayers.put(player.getPrefferedClanId(), players);
                }
                players.put(player.getCharId(), player);
                this._scheduledTaskExecutor.scheduleApplicantForAddition(player);
                return true;
            }
        } else {
            if (this._scheduledTaskExecutor.isWaiterLocked(player.getCharId())) {
                return false;
            }
            if (!this.isWaiterRegistered(player.getCharId())) {
                this._waitingPlayers.put(player.getCharId(), player);
                this._scheduledTaskExecutor.scheduleWaiterForAddition(player);
            }
        }
        return false;
    }

    public void removeApplicant(int clanId, int charId) {
        TIntObjectMap players = (TIntObjectMap)this._applicantPlayers.get(clanId);
        if (players == null) {
            return;
        }
        if (!players.containsKey(charId)) {
            return;
        }
        this._scheduledTaskExecutor.scheduleApplicantForRemoval(charId);
        players.remove(charId);
        this._scheduledTaskExecutor.lockApplicant(charId, 300000L);
    }

    public List<ClanSearchPlayer> listWaiters(ClanSearchWaiterParams params) {
        ArrayList<ClanSearchPlayer> list = new ArrayList<ClanSearchPlayer>();
        for (ClanSearchPlayer csPlayer : this._waitingPlayers.valueCollection()) {
            if (csPlayer.getLevel() < params.getMinLevel() || csPlayer.getLevel() > params.getMaxLevel() || !params.getRole().isClassRole(csPlayer.getClassId()) || params.getCharName() != null && !params.getCharName().isEmpty() && !csPlayer.getName().toLowerCase().contains(params.getCharName())) continue;
            list.add(csPlayer);
        }
        ClanSearchSortOrder sortOrder = params.getSortOrder();
        if (sortOrder != ClanSearchSortOrder.NONE) {
            ClanSearchPlayerSortType sortType = params.getSortType();
            Collections.sort(list, (playerLeft, playerRight) -> {
                if (playerLeft == playerRight) {
                    return 0;
                }
                int result = 0;
                switch (sortType) {
                    case SORT_TYPE_NAME: {
                        result = Integer.compare(playerLeft.getLevel(), playerRight.getLevel());
                        break;
                    }
                    case SORT_TYPE_SEARCH_TYPE: {
                        result = playerLeft.getName().compareTo(playerRight.getName());
                        break;
                    }
                    case SORT_TYPE_ROLE: {
                        result = Integer.compare(playerLeft.getClassId(), playerRight.getClassId());
                        break;
                    }
                    case SORT_TYPE_LEVEL: {
                        result = Integer.compare(playerLeft.getSearchType().ordinal(), playerRight.getSearchType().ordinal());
                    }
                }
                if (sortOrder != ClanSearchSortOrder.DESC) {
                    return -result;
                }
                return result;
            });
        }
        return list;
    }

    public Collection<ClanSearchPlayer> applicantsCollection(int clanId) {
        TIntObjectMap players = (TIntObjectMap)this._applicantPlayers.get(clanId);
        if (players == null) {
            return Collections.emptyList();
        }
        return players.valueCollection();
    }

    public boolean removeWaiter(int charId) {
        if (!this._waitingPlayers.containsKey(charId)) {
            return false;
        }
        this._waitingPlayers.remove(charId);
        this._scheduledTaskExecutor.lockWaiter(charId, 300000L);
        return true;
    }

    public int getClanLockTime(int clanId) {
        return (int)(this._scheduledTaskExecutor.getClanLockTime(clanId) / 1000L / 60L);
    }

    public int getWaiterLockTime(int charId) {
        return (int)(this._scheduledTaskExecutor.getWaiterLockTime(charId) / 1000L / 60L);
    }

    public int getApplicantLockTime(int charId) {
        return (int)(this._scheduledTaskExecutor.getApplicantLockTime(charId) / 1000L / 60L);
    }

    public void save() {
        try {
            this._scheduledTaskExecutor.run();
        }
        catch (Exception e) {
            _log.error(this.getClass().getSimpleName() + ": Failed run save task.", (Throwable)e);
        }
    }

    private static class PlayerEnterListener
    implements OnPlayerEnterListener {
        private PlayerEnterListener() {
        }

        @Override
        public void onPlayerEnter(Player player) {
            Clan clan = player.getClan();
            if (clan == null || player.isClanLeader() && clan.getClanMembersLimit() > clan.getAllSize()) {
                player.sendPacket((IBroadcastPacket)new ExPledgeWaitingListAlarm());
            }
        }
    }
}


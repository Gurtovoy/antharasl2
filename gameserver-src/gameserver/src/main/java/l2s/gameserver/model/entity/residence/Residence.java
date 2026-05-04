package l2s.gameserver.model.entity.residence;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import gnu.trove.set.TIntSet;
import gnu.trove.set.hash.TIntHashSet;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import l2s.commons.dao.JdbcEntity;
import l2s.commons.dao.JdbcEntityState;
import l2s.commons.dbutils.DbUtils;
import l2s.commons.util.Rnd;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.data.xml.holder.EventHolder;
import l2s.gameserver.data.xml.holder.ResidenceFunctionsHolder;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.base.ResidenceFunctionType;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.events.EventType;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.model.entity.residence.ResidenceFunction;
import l2s.gameserver.model.entity.residence.ResidenceSide;
import l2s.gameserver.model.entity.residence.ResidenceType;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillInfo;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.residence.ResidenceFunctionTemplate;
import l2s.gameserver.utils.ReflectionUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class Residence
implements JdbcEntity {
    private static final Logger _log = LoggerFactory.getLogger(Residence.class);
    public static final long CYCLE_TIME = 3600000L;
    private final int _id;
    private final String _name;
    protected Clan _owner;
    protected Zone _zone;
    private TIntObjectMap<SkillEntry> _skills = new TIntObjectHashMap();
    protected SiegeEvent<?, ?> _siegeEvent;
    protected Calendar _siegeDate = Calendar.getInstance();
    protected Calendar _lastSiegeDate = Calendar.getInstance();
    protected Calendar _ownDate = Calendar.getInstance();
    protected ScheduledFuture<?> _cycleTask;
    private int _cycle;
    private int _paidCycle;
    protected JdbcEntityState _jdbcEntityState = JdbcEntityState.CREATED;
    protected List<Location> _banishPoints = new ArrayList<Location>();
    protected List<Location> _ownerRestartPoints = new ArrayList<Location>();
    protected List<Location> _otherRestartPoints = new ArrayList<Location>();
    protected List<Location> _chaosRestartPoints = new ArrayList<Location>();
    private final Map<ResidenceFunctionType, ResidenceFunction> _activeFunctions = new HashMap<ResidenceFunctionType, ResidenceFunction>();
    private final TIntSet _availableFunctions = new TIntHashSet();

    public Residence(StatsSet set) {
        this._id = set.getInteger("id");
        this._name = set.getString("name");
        this._siegeDate.setTimeInMillis(0L);
        this._lastSiegeDate.setTimeInMillis(0L);
        this._ownDate.setTimeInMillis(0L);
        this.initZone();
    }

    public abstract ResidenceType getType();

    public void init() {
        this.initEvent();
        this.loadData();
        this.loadFunctions();
        this.rewardSkills();
        this.startCycleTask();
    }

    protected void initZone() {
        this._zone = ReflectionUtils.getZone("residence_" + this.getId());
        this._zone.setParam("residence", this);
    }

    protected void initEvent() {
        this._siegeEvent = (SiegeEvent)((Object)EventHolder.getInstance().getEvent(EventType.SIEGE_EVENT, this.getId()));
    }

    public <E extends SiegeEvent<?, ?>> E getSiegeEvent() {
        return (E)((Object)this._siegeEvent);
    }

    public int getId() {
        return this._id;
    }

    public String getName() {
        return this._name;
    }

    public int getOwnerId() {
        return this._owner == null ? 0 : this._owner.getClanId();
    }

    public void setOwner(Clan owner) {
        this._owner = owner;
    }

    public Clan getOwner() {
        return this._owner;
    }

    public boolean isOwner(int clanId) {
        return this._owner == null ? false : this._owner.getClanId() == clanId;
    }

    public Zone getZone() {
        return this._zone;
    }

    public boolean isInstant() {
        return false;
    }

    protected abstract void loadData();

    public abstract void changeOwner(Clan var1);

    public Calendar getOwnDate() {
        return this._ownDate;
    }

    public Calendar getSiegeDate() {
        return this._siegeDate;
    }

    public Calendar getLastSiegeDate() {
        return this._lastSiegeDate;
    }

    public void addAvailableFunction(int id) {
        this._availableFunctions.add(id);
    }

    public void addSkill(SkillEntry skillEntry) {
        this._skills.put(skillEntry.getId(), skillEntry);
    }

    public void removeSkill(SkillInfo skillInfo) {
        this._skills.remove(skillInfo.getId());
    }

    public boolean checkIfInZone(Location loc, Reflection ref) {
        return this.checkIfInZone(loc.x, loc.y, loc.z, ref);
    }

    public boolean checkIfInZone(int x, int y, int z, Reflection ref) {
        return this.getZone() != null && this.getZone().checkIfInZone(x, y, z, ref);
    }

    public void banishForeigner(int clanId) {
        for (Player player : this._zone.getInsidePlayers()) {
            if (player.getClanId() == this.getOwnerId()) continue;
            player.teleToLocation(this.getBanishPoint());
        }
    }

    public void rewardSkills() {
        Clan owner = this.getOwner();
        if (owner != null) {
            for (SkillEntry skillEntry : this.getSkills()) {
                if (owner.addSkill(skillEntry, false) != null) continue;
                owner.broadcastToOnlineMembers(new IBroadcastPacket[]{new SystemMessagePacket(SystemMsg.THE_CLAN_SKILL_S1_HAS_BEEN_ADDED).addSkillName(skillEntry)});
            }
        }
    }

    public void removeSkills() {
        Clan owner = this.getOwner();
        if (owner != null) {
            for (SkillEntry skillEntry : this.getSkills()) {
                owner.removeSkill(skillEntry.getId(), false);
            }
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    protected void loadFunctions() {
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rs = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT * FROM residence_functions WHERE residence_id=?");
            statement.setInt(1, this.getId());
            rs = statement.executeQuery();
            while (rs.next()) {
                ResidenceFunctionType type = ResidenceFunctionType.VALUES[rs.getInt("type")];
                ResidenceFunctionTemplate functionTemplate = ResidenceFunctionsHolder.getInstance().getTemplate(type, rs.getInt("level"));
                if (functionTemplate == null || !this.isFunctionAvailable(functionTemplate)) {
                    this.removeFunction(type);
                    continue;
                }
                ResidenceFunction function = new ResidenceFunction(functionTemplate, this.getId());
                function.setEndTimeInMillis((long)rs.getInt("end_time") * 1000L);
                function.setInDebt(rs.getBoolean("in_debt"));
                this.addActiveFunction(function);
                this.startAutoTaskForFunction(function);
            }
        }
        catch (Exception e) {
            try {
                _log.warn("Residence: loadFunctions(): " + e, (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rs);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rs);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rs);
    }

    public void addActiveFunction(ResidenceFunction function) {
        this._activeFunctions.put(function.getType(), function);
    }

    public boolean isFunctionActive(ResidenceFunctionType type) {
        return this._activeFunctions.containsKey((Object)type);
    }

    public ResidenceFunction getActiveFunction(ResidenceFunctionType type) {
        return this._activeFunctions.get(type);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     * Enabled force condition propagation
     * Lifted jumps to return sites
     */
    public boolean updateFunctions(ResidenceFunctionType type, int level) {
        Clan clan = this.getOwner();
        if (clan == null) {
            return false;
        }
        ResidenceFunction activeFunction = this.getActiveFunction(type);
        if (activeFunction != null && activeFunction.getLevel() == level) {
            return true;
        }
        if (level == 0) {
            if (activeFunction == null) return false;
            this.removeFunction(type);
            return true;
        }
        ResidenceFunctionTemplate functionTemplate = ResidenceFunctionsHolder.getInstance().getTemplate(type, level);
        if (!this.isFunctionAvailable(functionTemplate)) {
            return false;
        }
        long clanAdenaCount = clan.getAdenaCount();
        long lease = functionTemplate.getCost();
        if (activeFunction == null) {
            if (clanAdenaCount < lease) return false;
            clan.getWarehouse().destroyItemByItemId(57, lease);
        } else {
            long activeFunctionLease = activeFunction.getTemplate().getCost() / (long)activeFunction.getTemplate().getPeriod() * (long)functionTemplate.getPeriod();
            if (clanAdenaCount < lease - activeFunctionLease) return false;
            if (lease > activeFunctionLease) {
                clan.getWarehouse().destroyItemByItemId(57, lease - activeFunctionLease);
            }
        }
        long time = Calendar.getInstance().getTimeInMillis() + (long)(functionTemplate.getPeriod() * 24 * 60 * 60) * 1000L;
        ResidenceFunction function = new ResidenceFunction(functionTemplate, this.getId());
        function.setEndTimeInMillis(time);
        this._activeFunctions.put(function.getType(), function);
        this.startAutoTaskForFunction(function);
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("REPLACE residence_functions SET residence_id=?, type=?, level=?, end_time=?");
            statement.setInt(1, this.getId());
            statement.setInt(2, type.ordinal());
            statement.setInt(3, level);
            statement.setInt(4, (int)(time / 1000L));
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.warn("Exception: updateFunctions(ResidenceFunctionType,int): " + e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
            return true;
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void removeFunction(ResidenceFunctionType type) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("DELETE FROM residence_functions WHERE residence_id=? AND type=?");
            statement.setInt(1, this.getId());
            statement.setInt(2, type.ordinal());
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.warn("Exception: removeFunction(int type): " + e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
        this._activeFunctions.remove(type);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void removeFunctions() {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("DELETE FROM residence_functions WHERE residence_id=?");
            statement.setInt(1, this.getId());
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.warn("Exception: removeFunctions(): " + e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
        this._activeFunctions.clear();
    }

    private void startAutoTaskForFunction(ResidenceFunction function) {
        Clan clan = this.getOwner();
        if (clan == null) {
            return;
        }
        if (function.getEndTimeInMillis() > System.currentTimeMillis()) {
            ThreadPoolManager.getInstance().schedule(new AutoTaskForFunctions(function), function.getEndTimeInMillis() - System.currentTimeMillis());
        } else if (function.isInDebt() && clan.getAdenaCount() >= function.getTemplate().getCost()) {
            clan.getWarehouse().destroyItemByItemId(57, function.getTemplate().getCost());
            function.updateRentTime(false);
            ThreadPoolManager.getInstance().schedule(new AutoTaskForFunctions(function), function.getEndTimeInMillis() - System.currentTimeMillis());
        } else if (!function.isInDebt()) {
            function.setInDebt(true);
            function.updateRentTime(true);
            ThreadPoolManager.getInstance().schedule(new AutoTaskForFunctions(function), function.getEndTimeInMillis() - System.currentTimeMillis());
        } else {
            this.removeFunction(function.getType());
        }
    }

    public void setJdbcState(JdbcEntityState state) {
        this._jdbcEntityState = state;
    }

    public JdbcEntityState getJdbcState() {
        return this._jdbcEntityState;
    }

    public void save() {
        throw new UnsupportedOperationException();
    }

    public void delete() {
        throw new UnsupportedOperationException();
    }

    public void cancelCycleTask() {
        this._cycle = 0;
        this._paidCycle = 0;
        if (this._cycleTask != null) {
            this._cycleTask.cancel(false);
            this._cycleTask = null;
        }
        this.setJdbcState(JdbcEntityState.UPDATED);
    }

    public void startCycleTask() {
        long diff;
        if (this._owner == null) {
            return;
        }
        long ownedTime = this.getOwnDate().getTimeInMillis();
        if (ownedTime == 0L) {
            return;
        }
        for (diff = System.currentTimeMillis() - ownedTime; diff >= 3600000L; diff -= 3600000L) {
        }
        this._cycleTask = ThreadPoolManager.getInstance().scheduleAtFixedRate(new ResidenceCycleTask(), diff, 3600000L);
    }

    public void chanceCycle() {
        this.setCycle(this.getCycle() + 1);
        this.setJdbcState(JdbcEntityState.UPDATED);
    }

    public List<SkillEntry> getSkills() {
        return new ArrayList<SkillEntry>(this._skills.valueCollection());
    }

    public void addBanishPoint(Location loc) {
        this._banishPoints.add(loc);
    }

    public void addOwnerRestartPoint(Location loc) {
        this._ownerRestartPoints.add(loc);
    }

    public void addOtherRestartPoint(Location loc) {
        this._otherRestartPoints.add(loc);
    }

    public void addChaosRestartPoint(Location loc) {
        this._chaosRestartPoints.add(loc);
    }

    public Location getBanishPoint() {
        if (this._banishPoints.isEmpty()) {
            return null;
        }
        return this._banishPoints.get(Rnd.get((int)this._banishPoints.size()));
    }

    public Location getOwnerRestartPoint() {
        if (this._ownerRestartPoints.isEmpty()) {
            return null;
        }
        return this._ownerRestartPoints.get(Rnd.get((int)this._ownerRestartPoints.size()));
    }

    public Location getOtherRestartPoint() {
        if (this._otherRestartPoints.isEmpty()) {
            return null;
        }
        return this._otherRestartPoints.get(Rnd.get((int)this._otherRestartPoints.size()));
    }

    public Location getChaosRestartPoint() {
        if (this._chaosRestartPoints.isEmpty()) {
            return null;
        }
        return this._chaosRestartPoints.get(Rnd.get((int)this._chaosRestartPoints.size()));
    }

    public Location getNotOwnerRestartPoint(Player player) {
        return player.isPK() ? this.getChaosRestartPoint() : this.getOtherRestartPoint();
    }

    public int getCycle() {
        return this._cycle;
    }

    public long getCycleDelay() {
        if (this._cycleTask == null) {
            return 0L;
        }
        return this._cycleTask.getDelay(TimeUnit.SECONDS);
    }

    public void setCycle(int cycle) {
        this._cycle = cycle;
    }

    public int getPaidCycle() {
        return this._paidCycle;
    }

    public void setPaidCycle(int paidCycle) {
        this._paidCycle = paidCycle;
    }

    public void setResidenceSide(ResidenceSide side, boolean onRestore) {
    }

    public ResidenceSide getResidenceSide() {
        return ResidenceSide.NEUTRAL;
    }

    public void broadcastResidenceState() {
    }

    public int getVisibleFunctionLevel(int level) {
        return level - 10;
    }

    public boolean isFunctionAvailable(ResidenceFunctionTemplate template) {
        if (this.getVisibleFunctionLevel(template.getLevel()) <= 0) {
            return false;
        }
        return this._availableFunctions.contains(template.getId());
    }

    public List<ResidenceFunctionTemplate> getAvailableFunctions(ResidenceFunctionType type) {
        ArrayList<ResidenceFunctionTemplate> functions = new ArrayList<ResidenceFunctionTemplate>();
        for (ResidenceFunctionTemplate template : ResidenceFunctionsHolder.getInstance().getTemplates(type)) {
            if (!this.isFunctionAvailable(template)) continue;
            functions.add(template);
        }
        return functions;
    }

    public Reflection getReflection(int clanId) {
        return ReflectionManager.MAIN;
    }

    public static int getInstantResidenceId(int instantId) {
        return instantId * 1000;
    }

    private class AutoTaskForFunctions
    implements Runnable {
        ResidenceFunction _function;

        public AutoTaskForFunctions(ResidenceFunction function) {
            this._function = function;
        }

        @Override
        public void run() {
            Residence.this.startAutoTaskForFunction(this._function);
        }
    }

    public class ResidenceCycleTask
    implements Runnable {
        @Override
        public void run() {
            Residence.this.chanceCycle();
            Residence.this.update();
        }
    }
}


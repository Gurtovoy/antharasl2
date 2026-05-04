/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.actor.instances.player;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.actor.instances.player.BookMark;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.utils.ItemFunctions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class BookMarkList {
    private static final int TELEPORT_FLAG_ID = 20033;
    private static final int[] TELEPORT_SCROLLS = new int[]{13016};
    public static final Zone.ZoneType[] FORBIDDEN_ZONES = new Zone.ZoneType[]{Zone.ZoneType.RESIDENCE, Zone.ZoneType.ssq_zone, Zone.ZoneType.battle_zone, Zone.ZoneType.SIEGE, Zone.ZoneType.no_restart, Zone.ZoneType.no_summon};
    private static final Logger _log = LoggerFactory.getLogger(BookMarkList.class);
    private final Player owner;
    private List<BookMark> elementData;
    private int capacity;

    public BookMarkList(Player owner, int acapacity) {
        this.owner = owner;
        this.elementData = new ArrayList<BookMark>(acapacity);
        this.capacity = acapacity;
    }

    public synchronized void setCapacity(int val) {
        this.capacity = val;
    }

    public int getCapacity() {
        return this.capacity;
    }

    public void clear() {
        this.elementData.clear();
    }

    public BookMark[] toArray() {
        return this.elementData.toArray(new BookMark[this.elementData.size()]);
    }

    public int incCapacity(int val) {
        this.capacity += val;
        this.owner.sendPacket((IBroadcastPacket)SystemMsg.THE_NUMBER_OF_MY_TELEPORTS_SLOTS_HAS_BEEN_INCREASED);
        return this.getCapacity();
    }

    public synchronized boolean add(BookMark e) {
        if (this.elementData.size() >= this.getCapacity()) {
            return false;
        }
        return this.elementData.add(e);
    }

    public BookMark get(int slot) {
        if (slot < 1 || slot > this.elementData.size()) {
            return null;
        }
        return this.elementData.get(slot - 1);
    }

    public void remove(int slot) {
        if (slot < 1 || slot > this.elementData.size()) {
            return;
        }
        this.elementData.remove(slot - 1);
    }

    public boolean tryTeleport(int slot) {
        if (!BookMarkList.checkFirstConditions(this.owner) || !BookMarkList.checkTeleportConditions(this.owner)) {
            return false;
        }
        if (slot < 1 || slot > this.elementData.size()) {
            return false;
        }
        BookMark bookmark = this.elementData.get(slot - 1);
        if (!BookMarkList.checkTeleportLocation(this.owner, bookmark.x, bookmark.y, bookmark.z)) {
            this.owner.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_USE_MY_TELEPORTS_IN_THIS_AREA);
            return false;
        }
        this.owner.bookmarkLocation = new Location(bookmark.x, bookmark.y, bookmark.z);
        SkillEntry skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, 2588, 1);
        if (!skillEntry.checkCondition(this.owner, this.owner, false, true, true)) {
            this.owner.bookmarkLocation = null;
            return false;
        }
        for (int item_id : TELEPORT_SCROLLS) {
            if (!ItemFunctions.deleteItem((Playable)this.owner, item_id, 1L)) continue;
            this.owner.getAI().Cast(skillEntry, this.owner, false, true);
            return true;
        }
        this.owner.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_BOOKMARK_THIS_LOCATION_BECAUSE_YOU_DO_NOT_HAVE_A_MY_TELEPORT_FLAG);
        return false;
    }

    public boolean add(String aname, String aacronym, int aiconId) {
        return this.add(aname, aacronym, aiconId, true);
    }

    public boolean add(String aname, String aacronym, int aiconId, boolean takeFlag) {
        return this.owner != null && this.add(this.owner.getLoc(), aname, aacronym, aiconId, takeFlag);
    }

    public boolean add(Location loc, String aname, String aacronym, int aiconId, boolean takeFlag) {
        if (!BookMarkList.checkFirstConditions(this.owner) || !BookMarkList.checkTeleportLocation(this.owner, loc)) {
            return false;
        }
        if (this.elementData.size() >= this.getCapacity()) {
            this.owner.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_NO_SPACE_TO_SAVE_THE_TELEPORT_LOCATION);
            return false;
        }
        if (takeFlag && !ItemFunctions.deleteItem((Playable)this.owner, 20033, 1L)) {
            this.owner.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_BOOKMARK_THIS_LOCATION_BECAUSE_YOU_DO_NOT_HAVE_A_MY_TELEPORT_FLAG);
            return false;
        }
        this.add(new BookMark(loc, aiconId, aname, aacronym));
        return true;
    }

    
    public void store() {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("DELETE FROM `character_bookmarks` WHERE char_Id=?");
            statement.setInt(1, this.owner.getObjectId());
            statement.execute();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("INSERT INTO `character_bookmarks` VALUES(?,?,?,?,?,?,?,?);");
            int slotId = 0;
            for (BookMark bookmark : this.elementData) {
                statement.setInt(1, this.owner.getObjectId());
                statement.setInt(2, ++slotId);
                statement.setString(3, bookmark.getName());
                statement.setString(4, bookmark.getAcronym());
                statement.setInt(5, bookmark.getIcon());
                statement.setInt(6, bookmark.x);
                statement.setInt(7, bookmark.y);
                statement.setInt(8, bookmark.z);
                statement.execute();
            }
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

    
    public synchronized void restore() {
        if (this.getCapacity() == 0) {
            this.elementData.clear();
            return;
        }
        Connection con = null;
        Statement statement = null;
        ResultSet rs = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.createStatement();
            rs = statement.executeQuery("SELECT * FROM `character_bookmarks` WHERE `char_Id`=" + this.owner.getObjectId() + " ORDER BY `idx` LIMIT " + this.getCapacity());
            this.elementData.clear();
            while (rs.next()) {
                this.add(new BookMark(rs.getInt("x"), rs.getInt("y"), rs.getInt("z"), rs.getInt("icon"), rs.getString("name"), rs.getString("acronym")));
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rs);
        }
        catch (Exception e) {
            _log.error("Could not restore " + this.owner + " bookmarks!", (Throwable)e);
        }
        finally {
            DbUtils.closeQuietly((Connection)con, (Statement)statement, rs);
        }
    }

    public static boolean checkFirstConditions(Player player) {
        if (player == null) {
            return false;
        }
        if (player.getActiveWeaponFlagAttachment() != null) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_TELEPORT_WHILE_IN_POSSESSION_OF_A_WARD);
            return false;
        }
        if (player.isInOlympiadMode()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_USE_MY_TELEPORTS_WHILE_PARTICIPATING_IN_AN_OLYMPIAD_MATCH);
            return false;
        }
        if (!player.getReflection().isMain()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_USE_MY_TELEPORTS_IN_AN_INSTANT_ZONE);
            return false;
        }
        if (player.isInDuel()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_USE_MY_TELEPORTS_DURING_A_DUEL);
            return false;
        }
        if (player.isInCombat() || player.getPvpFlag() != 0) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_USE_MY_TELEPORTS_DURING_A_BATTLE);
            return false;
        }
        if (player.isInSiegeZone() || player.isInZoneBattle()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_USE_MY_TELEPORTS_WHILE_PARTICIPATING_A_LARGESCALE_BATTLE_SUCH_AS_A_CASTLE_SIEGE_FORTRESS_SIEGE_OR_HIDEOUT_SIEGE);
            return false;
        }
        if (player.isFlying()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_USE_MY_TELEPORTS_WHILE_FLYING);
            return false;
        }
        if (player.isInWater() || player.isInBoat()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_USE_MY_TELEPORTS_UNDERWATER);
            return false;
        }
        return true;
    }

    public static boolean checkTeleportConditions(Player player) {
        if (player == null) {
            return false;
        }
        if (player.isAlikeDead()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_USE_MY_TELEPORTS_WHILE_YOU_ARE_DEAD);
            return false;
        }
        if (player.isInStoreMode() || player.isInTrade()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_SUMMON_DURING_A_TRADE_OR_WHILE_USING_A_PRIVATE_STORE);
            return false;
        }
        if (player.isInBoat() || player.isDecontrolled() || player.isStunned() || player.isSleeping()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_USE_MY_TELEPORTS_WHILE_YOU_ARE_IN_A_PETRIFIED_OR_PARALYZED_STATE);
            return false;
        }
        return true;
    }

    public static boolean checkTeleportLocation(Player player, Location loc) {
        return BookMarkList.checkTeleportLocation(player, loc.x, loc.y, loc.z);
    }

    public static boolean checkTeleportLocation(Player player, int x, int y, int z) {
        if (player == null) {
            return false;
        }
        for (Zone.ZoneType zoneType : FORBIDDEN_ZONES) {
            Zone zone = player.getZone(zoneType);
            if (zone == null) continue;
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_USE_MY_TELEPORTS_TO_REACH_THIS_AREA);
            return false;
        }
        return true;
    }
}


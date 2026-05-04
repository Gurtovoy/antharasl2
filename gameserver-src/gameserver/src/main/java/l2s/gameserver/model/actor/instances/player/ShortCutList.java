/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.actor.instances.player;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Collection;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.ShortCut;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ShortCutInitPacket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ShortCutList {
    private static final Logger _log = LoggerFactory.getLogger(ShortCutList.class);
    private final Player player;
    private Map<Integer, ShortCut> _shortCuts = new ConcurrentHashMap<Integer, ShortCut>();

    public ShortCutList(Player owner) {
        this.player = owner;
    }

    public Collection<ShortCut> getAllShortCuts() {
        return this._shortCuts.values();
    }

    public void validate() {
        for (ShortCut sc : this._shortCuts.values()) {
            if (sc.getType() != ShortCut.ShortCutType.ITEM || this.player.getInventory().getItemByObjectId(sc.getId()) != null) continue;
            this.deleteShortCut(sc.getSlot(), sc.getPage());
        }
    }

    public ShortCut getShortCut(int slot, int page) {
        ShortCut sc = this._shortCuts.get(slot + page * 12);
        if (sc != null && sc.getType() == ShortCut.ShortCutType.ITEM && this.player.getInventory().getItemByObjectId(sc.getId()) == null) {
            this.player.sendPacket((IBroadcastPacket)SystemMsg.THERE_ARE_NO_MORE_ITEMS_IN_THE_SHORTCUT);
            this.deleteShortCut(sc.getSlot(), sc.getPage());
            sc = null;
        }
        return sc;
    }

    public void registerShortCut(ShortCut shortcut) {
        ShortCut oldShortCut = this._shortCuts.put(shortcut.getSlot() + 12 * shortcut.getPage(), shortcut);
        this.registerShortCutInDb(shortcut, oldShortCut);
    }

    
    private synchronized void registerShortCutInDb(ShortCut shortcut, ShortCut oldShortCut) {
        if (oldShortCut != null) {
            this.deleteShortCutFromDb(oldShortCut);
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("REPLACE INTO character_shortcuts SET object_id=?,slot=?,page=?,type=?,shortcut_id=?,level=?,character_type=?,class_index=?");
            statement.setInt(1, this.player.getObjectId());
            statement.setInt(2, shortcut.getSlot());
            statement.setInt(3, shortcut.getPage());
            statement.setInt(4, shortcut.getType().ordinal());
            statement.setInt(5, shortcut.getId());
            statement.setInt(6, shortcut.getLevel());
            statement.setInt(7, shortcut.getCharacterType());
            statement.setInt(8, this.player.getActiveClassId());
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("could not store shortcuts:", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    
    private void deleteShortCutFromDb(ShortCut shortcut) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("DELETE FROM character_shortcuts WHERE object_id=? AND slot=? AND page=? AND class_index=?");
            statement.setInt(1, this.player.getObjectId());
            statement.setInt(2, shortcut.getSlot());
            statement.setInt(3, shortcut.getPage());
            statement.setInt(4, this.player.getActiveClassId());
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("could not delete shortcuts:", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    public void deleteShortCut(int slot, int page) {
        ShortCut old = this._shortCuts.remove(slot + page * 12);
        if (old == null) {
            return;
        }
        this.deleteShortCutFromDb(old);
        if (old.getType() == ShortCut.ShortCutType.SKILL) {
            this.player.sendPacket((IBroadcastPacket)new ShortCutInitPacket(this.player));
            this.player.sendActiveAutoShots();
        }
    }

    public void deleteShortCutByObjectId(int objectId) {
        for (ShortCut shortcut : this._shortCuts.values()) {
            if (shortcut == null || shortcut.getType() != ShortCut.ShortCutType.ITEM || shortcut.getId() != objectId) continue;
            this.deleteShortCut(shortcut.getSlot(), shortcut.getPage());
        }
    }

    public void deleteShortCutBySkillId(int skillId) {
        for (ShortCut shortcut : this._shortCuts.values()) {
            if (shortcut == null || shortcut.getType() != ShortCut.ShortCutType.SKILL || shortcut.getId() != skillId) continue;
            this.deleteShortCut(shortcut.getSlot(), shortcut.getPage());
        }
    }

    
    public void restore() {
        this._shortCuts.clear();
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT character_type, slot, page, type, shortcut_id, level FROM character_shortcuts WHERE object_id=? AND class_index=?");
            statement.setInt(1, this.player.getObjectId());
            statement.setInt(2, this.player.getActiveClassId());
            rset = statement.executeQuery();
            while (rset.next()) {
                ShortCut.ShortCutType type;
                try {
                    type = ShortCut.ShortCutType.VALUES[rset.getInt("type")];
                }
                catch (Exception e) {
                    continue;
                }
                int slot = rset.getInt("slot");
                int page = rset.getInt("page");
                int id = rset.getInt("shortcut_id");
                int level = rset.getInt("level");
                int character_type = rset.getInt("character_type");
                this._shortCuts.put(slot + page * 12, new ShortCut(slot, page, type, id, level, character_type));
            }
        }
        catch (Exception e) {
            try {
                _log.error("could not store shortcuts:", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
    }
}


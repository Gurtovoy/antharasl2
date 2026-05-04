package l2s.gameserver.model.actor.instances.player;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.StringTokenizer;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.Macro;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.MacroListPacket;
import l2s.gameserver.utils.Strings;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class MacroList {
    private static final Logger _log = LoggerFactory.getLogger(MacroList.class);
    private final Player _owner;
    private final Map<Integer, Macro> _macroses = new HashMap<Integer, Macro>();
    private int _macroId;

    public MacroList(Player player) {
        this._owner = player;
        this._macroId = 1000;
    }

    public Macro[] getAllMacroses() {
        return this._macroses.values().toArray(new Macro[this._macroses.size()]);
    }

    public int size() {
        return this._macroses.size();
    }

    public Macro getMacro(int id) {
        return this._macroses.get(id - 1);
    }

    public void registerMacro(Macro macro) {
        if (macro.getId() == 0) {
            macro.incrementId();
            while (this._macroses.get(macro.getId()) != null) {
                macro.incrementId();
            }
            this._macroses.put(macro.getId(), macro);
            this.registerMacroInDb(macro);
            this._owner.sendPacket((IBroadcastPacket)new MacroListPacket(macro.getId(), MacroListPacket.Action.ADD, 1, macro));
        } else {
            Macro old = this._macroses.put(macro.getId(), macro);
            if (old != null) {
                this.deleteMacroFromDb(old);
            }
            this.registerMacroInDb(macro);
            this._owner.sendPacket((IBroadcastPacket)new MacroListPacket(macro.getId(), MacroListPacket.Action.UPDATE, 1, macro));
        }
    }

    public void deleteMacro(int id) {
        Macro toRemove = this._macroses.get(id);
        if (toRemove != null) {
            this.deleteMacroFromDb(toRemove);
        }
        this._macroses.remove(id);
        this._owner.sendPacket((IBroadcastPacket)new MacroListPacket(id, MacroListPacket.Action.DELETE, 0, null));
    }

    public void sendMacroses() {
        int size = this.size();
        if (size == 0) {
            this._owner.sendPacket((IBroadcastPacket)new MacroListPacket(0, MacroListPacket.Action.ADD, 0, null));
        } else {
            for (Macro macro : this._macroses.values()) {
                this._owner.sendPacket((IBroadcastPacket)new MacroListPacket(0, MacroListPacket.Action.ADD, size, macro));
            }
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private void registerMacroInDb(Macro macro) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("REPLACE INTO character_macroses (char_obj_id,id,icon,name,descr,acronym,commands) values(?,?,?,?,?,?,?)");
            statement.setInt(1, this._owner.getObjectId());
            statement.setInt(2, macro.getId());
            statement.setInt(3, macro.getIcon());
            statement.setString(4, macro.getName());
            statement.setString(5, macro.getDescr());
            statement.setString(6, macro.getAcronym());
            StringBuilder sb = new StringBuilder();
            for (Macro.L2MacroCmd cmd : macro.getCommands()) {
                sb.append(cmd.getType()).append(',');
                sb.append(cmd.getParam1()).append(',');
                sb.append(cmd.getParam2());
                if (!StringUtils.isEmpty((CharSequence)cmd.getCmd())) {
                    sb.append(',').append(cmd.getCmd());
                }
                sb.append(';');
            }
            statement.setString(7, sb.toString());
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("could not store macro: " + macro.toString(), (Throwable)e);
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
    private void deleteMacroFromDb(Macro macro) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("DELETE FROM character_macroses WHERE char_obj_id=? AND id=?");
            statement.setInt(1, this._owner.getObjectId());
            statement.setInt(2, macro.getId());
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("could not delete macro:", (Throwable)e);
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
    public void restore() {
        this._macroses.clear();
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT char_obj_id, id, icon, name, descr, acronym, commands FROM character_macroses WHERE char_obj_id=?");
            statement.setInt(1, this._owner.getObjectId());
            rset = statement.executeQuery();
            while (rset.next()) {
                int id = rset.getInt("id");
                int icon = rset.getInt("icon");
                String name = Strings.stripSlashes(rset.getString("name"));
                String descr = Strings.stripSlashes(rset.getString("descr"));
                String acronym = Strings.stripSlashes(rset.getString("acronym"));
                ArrayList<Macro.L2MacroCmd> commands = new ArrayList<Macro.L2MacroCmd>();
                StringTokenizer st1 = new StringTokenizer(rset.getString("commands"), ";");
                while (st1.hasMoreTokens()) {
                    StringTokenizer st = new StringTokenizer(st1.nextToken(), ",");
                    int type = Integer.parseInt(st.nextToken());
                    int d1 = Integer.parseInt(st.nextToken());
                    int d2 = Integer.parseInt(st.nextToken());
                    String cmd = "";
                    if (st.hasMoreTokens()) {
                        cmd = st.nextToken();
                    }
                    Macro.L2MacroCmd mcmd = new Macro.L2MacroCmd(commands.size(), type, d1, d2, cmd);
                    commands.add(mcmd);
                }
                Macro m = new Macro(id, icon, name, descr, acronym, commands.toArray(new Macro.L2MacroCmd[commands.size()]));
                this._macroses.put(m.getId(), m);
            }
        }
        catch (Exception e) {
            try {
                _log.error("could not restore shortcuts:", (Throwable)e);
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


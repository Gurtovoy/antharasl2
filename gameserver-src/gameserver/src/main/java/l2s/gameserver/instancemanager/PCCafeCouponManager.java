package l2s.gameserver.instancemanager;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import l2s.commons.dbutils.DbUtils;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.handler.pccoupon.IPCCouponHandler;
import l2s.gameserver.handler.pccoupon.PCCouponHandler;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.utils.Util;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PCCafeCouponManager {
    private static final Logger _log = LoggerFactory.getLogger(PCCafeCouponManager.class);
    public static final String PC_CODE_ATTEMPS_VAR = "@pc_code_attempts";
    private static final String SELECT_PCCAFE_CODE = "SELECT type, value, used_by FROM pccafe_coupons WHERE serial_code=?";
    private static final String UPDATE_PCCAFE_CODE = "UPDATE pccafe_coupons SET used_by=? WHERE serial_code=?";
    private static final String INSERT_PCCAFE_CODE = "INSERT INTO pccafe_coupons (serial_code, type, value, used_by) VALUES (?,?,?,?)";
    private static final String CODE_CHARACTERS_STRING = "abcdefghijklmnopqrstuvwxyz1234567890";
    private static final char[] CODE_CHARACTERS_ARRAY = "abcdefghijklmnopqrstuvwxyz1234567890".toCharArray();
    private static final int CODE_LENGTH = 20;
    private static final String COUPON_TEMPLATE = "[abcdefghijklmnopqrstuvwxyz1234567890]{20,20}";
    private static final PCCafeCouponManager _instance = new PCCafeCouponManager();
    private Lock _lock = new ReentrantLock();

    public static PCCafeCouponManager getInstance() {
        return _instance;
    }

    public List<String> generateCodes(int count, int type, String value) {
        ArrayList<String> codes = new ArrayList<String>();
        for (int i = 0; i < count; ++i) {
            String code = this.generateCode(type, value);
            if (code == null) continue;
            codes.add(code);
        }
        return codes;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public String generateCode(int type, String value) {
        this._lock.lock();
        try {
            for (int i = 0; i < 100; ++i) {
                ResultSet rset;
                PreparedStatement statement;
                Connection con;
                String generatedCode;
                block11: {
                    generatedCode = "";
                    for (int c = 0; c < 20; ++c) {
                        generatedCode = generatedCode + CODE_CHARACTERS_ARRAY[Rnd.get((int)CODE_CHARACTERS_ARRAY.length)];
                    }
                    if (!Util.isMatchingRegexp(generatedCode = generatedCode.toLowerCase(), COUPON_TEMPLATE)) continue;
                    con = null;
                    statement = null;
                    rset = null;
                    try {
                        con = DatabaseFactory.getInstance().getConnection();
                        statement = con.prepareStatement(SELECT_PCCAFE_CODE);
                        statement.setString(1, generatedCode);
                        rset = statement.executeQuery();
                        if (!rset.next()) break block11;
                    } catch (java.sql.SQLException e) {
                        DbUtils.closeQuietly((Connection)con, (Statement)statement);
                        continue;
                    }
                    DbUtils.closeQuietly((Connection)con, (Statement)statement);
                    continue;
                }
                try {
                    DbUtils.closeQuietly((Statement)statement, (ResultSet)rset);
                    statement = con.prepareStatement(INSERT_PCCAFE_CODE);
                    statement.setString(1, generatedCode);
                    statement.setInt(2, type);
                    statement.setString(3, value);
                    statement.setInt(4, 0);
                    statement.execute();
                }
                catch (Exception e) {
                    try {
                        _log.error(this.getClass().getSimpleName() + ": Error while generate coupon code.", (Throwable)e);
                    }
                    catch (Throwable throwable) {
                        DbUtils.closeQuietly((Connection)con, statement);
                        throw throwable;
                    }
                    DbUtils.closeQuietly((Connection)con, (Statement)statement);
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement);
                String string = generatedCode;
                return string;
            }
        }
        finally {
            this._lock.unlock();
        }
        return null;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean requestEnterCode(Player player, String couponCode) {
        block17: {
            this._lock.lock();
            try {
                ResultSet rset;
                PreparedStatement statement;
                Connection con;
                block15: {
                    String value;
                    int type;
                    block16: {
                        couponCode = couponCode.toLowerCase();
                        if (!Util.isMatchingRegexp(couponCode, COUPON_TEMPLATE)) {
                            this.onWrongCode(player);
                            boolean bl = false;
                            return bl;
                        }
                        con = null;
                        statement = null;
                        rset = null;
                        int used_by = 0;
                        try {
                            con = DatabaseFactory.getInstance().getConnection();
                            statement = con.prepareStatement(SELECT_PCCAFE_CODE);
                            statement.setString(1, couponCode);
                            rset = statement.executeQuery();
                            if (!rset.next()) break block15;
                            type = rset.getInt("type");
                            value = rset.getString("value");
                            used_by = rset.getInt("used_by");
                        } catch (java.sql.SQLException e) {
                            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
                            this.onWrongCode(player);
                            boolean bl = false;
                            return bl;
                        }
                        if (used_by <= 0) break block16;
                        if (used_by == player.getObjectId()) {
                            player.sendPacket((IBroadcastPacket)SystemMsg.SINCE_YOU_HAVE_ALREADY_USED_THIS_COUPON_YOU_MAY_NOT_USE_THIS_SERIAL_NUMBER);
                        } else {
                            player.sendPacket((IBroadcastPacket)SystemMsg.THIS_SERIAL_NUMBER_HAS_ALREADY_BEEN_USED);
                        }
                        boolean bl = false;
                        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
                        return bl;
                    }
                    boolean bl = this.useCoupon(player, couponCode, type, value);
                    DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
                    return bl;
                }
                try {
                    this.onWrongCode(player);
                }
                catch (Exception e) {
                    try {
                        _log.error(this.getClass().getSimpleName() + ": Error while reading coupon code.", (Throwable)e);
                    }
                    catch (Throwable throwable) {
                        DbUtils.closeQuietly((Connection)con, statement, rset);
                        throw throwable;
                    }
                    DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
                    break block17;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
            }
            finally {
                this._lock.unlock();
            }
        }
        return false;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private boolean useCoupon(Player player, String couponCode, int type, String value) {
        block11: {
            this._lock.lock();
            try {
                couponCode = couponCode.toLowerCase();
                IPCCouponHandler handler = PCCouponHandler.getInstance().getHandler(type);
                if (handler == null) {
                    _log.warn(this.getClass().getSimpleName() + ": Not found handler for coupon TYPE[" + type + "]!");
                    boolean bl = false;
                    return bl;
                }
                if (!handler.useCoupon(player, value)) {
                    boolean bl = false;
                    return bl;
                }
                Connection con = null;
                PreparedStatement statement = null;
                ResultSet rset = null;
                try {
                    con = DatabaseFactory.getInstance().getConnection();
                    statement = con.prepareStatement(UPDATE_PCCAFE_CODE);
                    statement.setInt(1, player.getObjectId());
                    statement.setString(2, couponCode);
                    statement.execute();
                    player.unsetVar(PC_CODE_ATTEMPS_VAR);
                }
                catch (Exception e) {
                    try {
                        _log.error(this.getClass().getSimpleName() + ": Error while use coupon code.", (Throwable)e);
                    }
                    catch (Throwable throwable) {
                        DbUtils.closeQuietly((Connection)con, statement, rset);
                        throw throwable;
                    }
                    DbUtils.closeQuietly((Connection)con, (Statement)statement, rset);
                    break block11;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement, rset);
            }
            finally {
                this._lock.unlock();
            }
        }
        return true;
    }

    private void onWrongCode(Player player) {
        int pcCodeAttempts = player.getVarInt(PC_CODE_ATTEMPS_VAR, 0) + 1;
        if (pcCodeAttempts > Config.ALT_PCBANG_POINTS_MAX_CODE_ENTER_ATTEMPTS) {
            long leftTime = player.getVarExpireTime(PC_CODE_ATTEMPS_VAR) - System.currentTimeMillis();
            if (leftTime > 0L) {
                player.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THIS_SERIAL_NUMBER_CANNOT_BE_ENTERED_PLEASE_TRY_AGAIN_IN_S1_MINUTES).addInteger(TimeUnit.MILLISECONDS.toMinutes(leftTime)));
                return;
            }
            pcCodeAttempts = 0;
        }
        if (pcCodeAttempts == Config.ALT_PCBANG_POINTS_MAX_CODE_ENTER_ATTEMPTS) {
            player.setVar(PC_CODE_ATTEMPS_VAR, pcCodeAttempts, System.currentTimeMillis() + TimeUnit.MINUTES.toMillis(Config.ALT_PCBANG_POINTS_BAN_TIME));
            player.sendPacket((IBroadcastPacket)SystemMsg.INVALID_SERIAL_NUMBER_YOUR_ATTEMPT_TO_ENTER_THE_NUMBER_HAS_FAILED_5_TIMES_PLEASE_TRY_AGAIN_IN_4_HOURS);
        } else {
            player.setVar(PC_CODE_ATTEMPS_VAR, pcCodeAttempts);
            player.sendPacket((IBroadcastPacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.INVALID_SERIAL_NUMBER__YOUR_ATTEMPT_TO_ENTER_THE_NUMBER_HAS_FAILED_S1_TIMES_YOU_WILL_BE_ALLOWED_TO_MAKE_S2_MORE_ATTEMPTS).addInteger(pcCodeAttempts)).addInteger(Config.ALT_PCBANG_POINTS_MAX_CODE_ENTER_ATTEMPTS - pcCodeAttempts));
        }
    }
}


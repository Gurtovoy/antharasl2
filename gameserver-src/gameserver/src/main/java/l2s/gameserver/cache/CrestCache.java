/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  gnu.trove.iterator.TIntIntIterator
 *  gnu.trove.iterator.TIntObjectIterator
 *  gnu.trove.map.TIntIntMap
 *  gnu.trove.map.TIntObjectMap
 *  gnu.trove.map.hash.TIntIntHashMap
 *  gnu.trove.map.hash.TIntObjectHashMap
 *  l2s.commons.dbutils.DbUtils
 *  org.apache.commons.lang3.builder.HashCodeBuilder
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.cache;

import gnu.trove.iterator.TIntIntIterator;
import gnu.trove.iterator.TIntObjectIterator;
import gnu.trove.map.TIntIntMap;
import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntIntHashMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.database.DatabaseFactory;
import org.apache.commons.lang3.builder.HashCodeBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CrestCache {
    public static final int ALLY_CREST_SIZE = 192;
    public static final int CREST_SIZE = 256;
    public static final int LARGE_CREST_PART_SIZE = 14336;
    private static final Logger _log = LoggerFactory.getLogger(CrestCache.class);
    private static final CrestCache _instance = new CrestCache();
    private final TIntIntMap _pledgeCrestId = new TIntIntHashMap();
    private final TIntIntMap _pledgeCrestLargeId = new TIntIntHashMap();
    private final TIntIntMap _allyCrestId = new TIntIntHashMap();
    private final TIntObjectMap<byte[]> _pledgeCrest = new TIntObjectHashMap();
    private final TIntObjectMap<TIntObjectMap<byte[]>> _pledgeCrestLarge = new TIntObjectHashMap();
    private final TIntObjectMap<TIntObjectMap<byte[]>> _pledgeCrestLargeTemp = new TIntObjectHashMap();
    private final TIntObjectMap<byte[]> _allyCrest = new TIntObjectHashMap();
    private final ReentrantReadWriteLock lock = new ReentrantReadWriteLock();
    private final Lock readLock = this.lock.readLock();
    private final Lock writeLock = this.lock.writeLock();

    public static final CrestCache getInstance() {
        return _instance;
    }

    private CrestCache() {
        this.load();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void load() {
        int count = 0;
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            int crestId;
            byte[] crest;
            int pledgeId;
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT clan_id, crest FROM clan_data WHERE crest IS NOT NULL");
            rset = statement.executeQuery();
            while (rset.next()) {
                ++count;
                pledgeId = rset.getInt("clan_id");
                crest = rset.getBytes("crest");
                crestId = CrestCache.getCrestId(pledgeId, crest);
                this._pledgeCrestId.put(pledgeId, crestId);
                this._pledgeCrest.put(crestId, crest);
            }
            DbUtils.close((Statement)statement, (ResultSet)rset);
            statement = con.prepareStatement("SELECT clan_id, data FROM clan_largecrests WHERE crest_part=0 AND data IS NOT NULL");
            rset = statement.executeQuery();
            while (rset.next()) {
                ++count;
                pledgeId = rset.getInt("clan_id");
                crest = rset.getBytes("data");
                crestId = CrestCache.getCrestId(pledgeId, crest);
                this._pledgeCrestLargeId.put(pledgeId, crestId);
            }
            DbUtils.close((Statement)statement, (ResultSet)rset);
            statement = con.prepareStatement("SELECT clan_id, crest_part, data FROM clan_largecrests WHERE data IS NOT NULL ORDER BY clan_id asc, crest_part asc");
            rset = statement.executeQuery();
            while (rset.next()) {
                pledgeId = rset.getInt("clan_id");
                int crestPartId = rset.getInt("crest_part");
                crest = rset.getBytes("data");
                if (!this._pledgeCrestLargeId.containsKey(pledgeId)) {
                    _log.warn("Clan large crest has crashed. Clan ID: " + pledgeId);
                    continue;
                }
                crestId = this._pledgeCrestLargeId.get(pledgeId);
                TIntObjectMap crestMap = (TIntObjectMap)this._pledgeCrestLarge.get(crestId);
                if (crestMap == null) {
                    crestMap = new TIntObjectHashMap();
                }
                crestMap.put(crestPartId, crest);
                this._pledgeCrestLarge.put(crestId, crestMap);
            }
            DbUtils.close((Statement)statement, (ResultSet)rset);
            statement = con.prepareStatement("SELECT ally_id, crest FROM ally_data WHERE crest IS NOT NULL");
            rset = statement.executeQuery();
            while (rset.next()) {
                ++count;
                pledgeId = rset.getInt("ally_id");
                crest = rset.getBytes("crest");
                crestId = CrestCache.getCrestId(pledgeId, crest);
                this._allyCrestId.put(pledgeId, crestId);
                this._allyCrest.put(crestId, crest);
            }
        }
        catch (Exception e) {
            try {
                _log.error("", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        _log.info("CrestCache: Loaded " + count + " crests");
    }

    private static int getCrestId(int pledgeId, byte[] crest) {
        return Math.abs(new HashCodeBuilder(15, 87).append(pledgeId).append(crest).toHashCode());
    }

    public byte[] getPledgeCrest(int crestId) {
        byte[] crest = null;
        this.readLock.lock();
        try {
            crest = (byte[])this._pledgeCrest.get(crestId);
        }
        finally {
            this.readLock.unlock();
        }
        return crest;
    }

    public TIntObjectMap<byte[]> getPledgeCrestLarge(int crestId) {
        TIntObjectMap crest = null;
        this.readLock.lock();
        try {
            crest = (TIntObjectMap)this._pledgeCrestLarge.get(crestId);
        }
        finally {
            this.readLock.unlock();
        }
        return crest;
    }

    public byte[] getAllyCrest(int crestId) {
        byte[] crest = null;
        this.readLock.lock();
        try {
            crest = (byte[])this._allyCrest.get(crestId);
        }
        finally {
            this.readLock.unlock();
        }
        return crest;
    }

    public int getPledgeCrestId(int pledgeId) {
        int crestId = 0;
        this.readLock.lock();
        try {
            crestId = this._pledgeCrestId.get(pledgeId);
        }
        finally {
            this.readLock.unlock();
        }
        return crestId;
    }

    public int getPledgeCrestLargeId(int pledgeId) {
        int crestId = 0;
        this.readLock.lock();
        try {
            crestId = this._pledgeCrestLargeId.get(pledgeId);
        }
        finally {
            this.readLock.unlock();
        }
        return crestId;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public int getPledgeIdByCrestLargeId(int crestId) {
        int pledgeId;
        block4: {
            pledgeId = 0;
            this.readLock.lock();
            try {
                if (!this._pledgeCrestLargeId.containsValue(crestId)) break block4;
                TIntIntIterator iterator = this._pledgeCrestLargeId.iterator();
                while (iterator.hasNext()) {
                    iterator.advance();
                    if (iterator.value() != crestId) continue;
                    pledgeId = iterator.key();
                    break;
                }
            }
            finally {
                this.readLock.unlock();
            }
        }
        return pledgeId;
    }

    public int getAllyCrestId(int pledgeId) {
        int crestId = 0;
        this.readLock.lock();
        try {
            crestId = this._allyCrestId.get(pledgeId);
        }
        finally {
            this.readLock.unlock();
        }
        return crestId;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void removePledgeCrest(int pledgeId) {
        this.writeLock.lock();
        try {
            this._pledgeCrest.remove(this._pledgeCrestId.remove(pledgeId));
        }
        finally {
            this.writeLock.unlock();
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE clan_data SET crest=? WHERE clan_id=?");
            statement.setNull(1, -3);
            statement.setInt(2, pledgeId);
            statement.execute();
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

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void removePledgeCrestLarge(int pledgeId) {
        this.writeLock.lock();
        try {
            this._pledgeCrestLarge.remove(this._pledgeCrestLargeId.remove(pledgeId));
        }
        finally {
            this.writeLock.unlock();
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("DELETE FROM clan_largecrests WHERE clan_id=?");
            statement.setInt(1, pledgeId);
            statement.execute();
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

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void removeAllyCrest(int pledgeId) {
        this.writeLock.lock();
        try {
            this._allyCrest.remove(this._allyCrestId.remove(pledgeId));
        }
        finally {
            this.writeLock.unlock();
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE ally_data SET crest=? WHERE ally_id=?");
            statement.setNull(1, -3);
            statement.setInt(2, pledgeId);
            statement.execute();
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

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public int savePledgeCrest(int pledgeId, byte[] crest) {
        int crestId = CrestCache.getCrestId(pledgeId, crest);
        this.writeLock.lock();
        try {
            this._pledgeCrestId.put(pledgeId, crestId);
            this._pledgeCrest.put(crestId, crest);
        }
        finally {
            this.writeLock.unlock();
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE clan_data SET crest=? WHERE clan_id=?");
            statement.setBytes(1, crest);
            statement.setInt(2, pledgeId);
            statement.execute();
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
        return crestId;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public int savePledgeCrestLarge(int pledgeId, int crestPart, int crestTotalSize, byte[] data) {
        int crestId;
        block11: {
            crestId = 0;
            this.writeLock.lock();
            try {
                block12: {
                    TIntObjectMap crest = (TIntObjectMap)this._pledgeCrestLargeTemp.get(pledgeId);
                    if (crestPart == 0) {
                        this._pledgeCrestLargeTemp.remove(pledgeId);
                        crest = new TIntObjectHashMap();
                    }
                    if (crest == null) break block12;
                    crest.put(crestPart, data);
                    int tempSize = CrestCache.getByteMapSize((TIntObjectMap<byte[]>)crest);
                    if (crestTotalSize > tempSize) {
                        this._pledgeCrestLargeTemp.put(pledgeId, crest);
                        break block11;
                    }
                    if (crestTotalSize < tempSize) {
                        this._pledgeCrestLargeTemp.remove(pledgeId);
                        _log.warn("Error while save pledge large crest, clan_id: " + pledgeId + ", crest_part: " + crestPart + ", crest_total_size: " + crestTotalSize + ", temp_size: " + tempSize);
                        break block11;
                    }
                    crestId = CrestCache.getCrestId(pledgeId, (byte[])crest.get(0));
                    this._pledgeCrestLargeId.put(pledgeId, crestId);
                    this._pledgeCrestLarge.put(crestId, crest);
                    Connection con = null;
                    PreparedStatement statement = null;
                    try {
                        con = DatabaseFactory.getInstance().getConnection();
                        statement = con.prepareStatement("DELETE FROM clan_largecrests WHERE clan_id=?");
                        statement.setInt(1, pledgeId);
                        statement.execute();
                        DbUtils.closeQuietly((Statement)statement);
                        TIntObjectIterator iterator = crest.iterator();
                        while (iterator.hasNext()) {
                            iterator.advance();
                            statement = con.prepareStatement("REPLACE INTO clan_largecrests(clan_id, crest_part, data) VALUES (?,?,?)");
                            statement.setInt(1, pledgeId);
                            statement.setInt(2, iterator.key());
                            statement.setBytes(3, (byte[])iterator.value());
                            statement.execute();
                            DbUtils.closeQuietly((Statement)statement);
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
                    this._pledgeCrestLargeTemp.remove(pledgeId);
                    break block11;
                }
                _log.warn("Error while save pledge large crest, clan_id: " + pledgeId + ", crest_part: " + crestPart + ", crest_total_size: " + crestTotalSize);
            }
            finally {
                this.writeLock.unlock();
            }
        }
        return crestId;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public int saveAllyCrest(int pledgeId, byte[] crest) {
        int crestId = CrestCache.getCrestId(pledgeId, crest);
        this.writeLock.lock();
        try {
            this._allyCrestId.put(pledgeId, crestId);
            this._allyCrest.put(crestId, crest);
        }
        finally {
            this.writeLock.unlock();
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE ally_data SET crest=? WHERE ally_id=?");
            statement.setBytes(1, crest);
            statement.setInt(2, pledgeId);
            statement.execute();
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
        return crestId;
    }

    public static int getByteMapSize(TIntObjectMap<byte[]> map) {
        int size = 0;
        if (map != null && !map.isEmpty()) {
            for (byte[] tempCrest : map.valueCollection()) {
                size += tempCrest.length;
            }
        }
        return size;
    }
}


/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.dao.JdbcDAO
 *  l2s.commons.dao.JdbcEntityState
 *  l2s.commons.dao.JdbcEntityStats
 *  l2s.commons.dbutils.DbUtils
 *  net.sf.ehcache.Cache
 *  net.sf.ehcache.CacheManager
 *  net.sf.ehcache.Element
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.dao;

import java.io.Serializable;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.atomic.AtomicLong;
import l2s.commons.dao.JdbcDAO;
import l2s.commons.dao.JdbcEntityState;
import l2s.commons.dao.JdbcEntityStats;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.dao.ItemsDAO;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.mail.Mail;
import net.sf.ehcache.Cache;
import net.sf.ehcache.CacheManager;
import net.sf.ehcache.Element;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class MailDAO
implements JdbcDAO<Integer, Mail> {
    private static final Logger _log = LoggerFactory.getLogger(MailDAO.class);
    private static final String RESTORE_MAIL = "SELECT sender_id, sender_name, receiver_id, receiver_name, expire_time, topic, body, price, type, unread, returned, system_topic, system_body, system_params  FROM mail WHERE message_id = ?";
    private static final String STORE_MAIL = "INSERT INTO mail(sender_id, sender_name, receiver_id, receiver_name, expire_time, topic, body, price, type, unread, returned, system_topic, system_body, system_params) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    private static final String UPDATE_MAIL = "UPDATE mail SET sender_id = ?, sender_name = ?, receiver_id = ?, receiver_name = ?, expire_time = ?, topic = ?, body = ?, price = ?, type = ?, unread = ?, returned = ?, system_topic = ?, system_body = ?, system_params = ? WHERE message_id = ?";
    private static final String REMOVE_MAIL = "DELETE FROM mail WHERE message_id = ?";
    private static final String RESTORE_EXPIRED_MAIL = "SELECT message_id FROM mail WHERE expire_time <= ?";
    private static final String RESTORE_OWN_MAIL = "SELECT message_id FROM character_mail WHERE char_id = ? AND is_sender = ?";
    private static final String STORE_OWN_MAIL = "INSERT INTO character_mail(char_id, message_id, is_sender) VALUES (?,?,?)";
    private static final String REMOVE_OWN_MAIL = "DELETE FROM character_mail WHERE char_id = ? AND message_id = ? AND is_sender = ?";
    private static final String REMOVE_OWN_MAIL2 = "DELETE FROM character_mail WHERE message_id = ?";
    private static final String RESTORE_MAIL_ATTACHMENTS = "SELECT item_id FROM mail_attachments WHERE message_id = ?";
    private static final String STORE_MAIL_ATTACHMENT = "INSERT INTO mail_attachments(message_id, item_id) VALUES (?,?)";
    private static final String REMOVE_MAIL_ATTACHMENTS = "DELETE FROM mail_attachments WHERE message_id = ?";
    private static final MailDAO instance = new MailDAO();
    private AtomicLong load = new AtomicLong();
    private AtomicLong insert = new AtomicLong();
    private AtomicLong update = new AtomicLong();
    private AtomicLong delete = new AtomicLong();
    private final Cache cache;
    private final JdbcEntityStats stats = new JdbcEntityStats(){

        public long getLoadCount() {
            return MailDAO.this.load.get();
        }

        public long getInsertCount() {
            return MailDAO.this.insert.get();
        }

        public long getUpdateCount() {
            return MailDAO.this.update.get();
        }

        public long getDeleteCount() {
            return MailDAO.this.delete.get();
        }
    };

    public static MailDAO getInstance() {
        return instance;
    }

    private MailDAO() {
        this.cache = CacheManager.getInstance().getCache(Mail.class.getName());
    }

    public Cache getCache() {
        return this.cache;
    }

    public JdbcEntityStats getStats() {
        return this.stats;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private void save0(Mail mail) throws SQLException {
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(STORE_MAIL, 1);
            statement.setInt(1, mail.getSenderId());
            statement.setString(2, mail.getSenderName());
            statement.setInt(3, mail.getReceiverId());
            statement.setString(4, mail.getReceiverName());
            statement.setInt(5, mail.getExpireTime());
            statement.setString(6, mail.getTopic());
            statement.setString(7, mail.getBody());
            statement.setLong(8, mail.getPrice());
            statement.setInt(9, mail.getType().ordinal());
            statement.setBoolean(10, mail.isUnread());
            statement.setBoolean(11, mail.isReturned());
            statement.setInt(12, mail.getSystemTopic());
            statement.setInt(13, mail.getSystemBody());
            statement.setString(14, mail.getSystemParamsToString());
            statement.execute();
            rset = statement.getGeneratedKeys();
            rset.next();
            mail.setMessageId(rset.getInt(1));
            if (!mail.getAttachments().isEmpty()) {
                DbUtils.close((Statement)statement);
                statement = con.prepareStatement(STORE_MAIL_ATTACHMENT);
                for (ItemInstance localItemInstance : mail.getAttachments()) {
                    statement.setInt(1, mail.getMessageId());
                    statement.setInt(2, localItemInstance.getObjectId());
                    statement.addBatch();
                }
                statement.executeBatch();
            }
            DbUtils.close((Statement)statement);
            if (mail.getType() == Mail.SenderType.NORMAL) {
                statement = con.prepareStatement(STORE_OWN_MAIL);
                statement.setInt(1, mail.getSenderId());
                statement.setInt(2, mail.getMessageId());
                statement.setBoolean(3, true);
                statement.execute();
            }
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement(STORE_OWN_MAIL);
            statement.setInt(1, mail.getReceiverId());
            statement.setInt(2, mail.getMessageId());
            statement.setBoolean(3, false);
            statement.execute();
        }
        catch (Throwable throwable) {
            DbUtils.closeQuietly((Connection)con, statement, rset);
            throw throwable;
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        this.insert.incrementAndGet();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private Mail load0(int messageId) throws SQLException {
        Mail mail = null;
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(RESTORE_MAIL);
            statement.setInt(1, messageId);
            rset = statement.executeQuery();
            if (rset.next()) {
                mail = new Mail();
                mail.setMessageId(messageId);
                mail.setSenderId(rset.getInt(1));
                mail.setSenderName(rset.getString(2));
                mail.setReceiverId(rset.getInt(3));
                mail.setReceiverName(rset.getString(4));
                mail.setExpireTime(rset.getInt(5));
                mail.setTopic(rset.getString(6));
                mail.setBody(rset.getString(7));
                mail.setPrice(rset.getLong(8));
                mail.setType(Mail.SenderType.VALUES[rset.getInt(9)]);
                mail.setUnread(rset.getBoolean(10));
                mail.setReturned(rset.getBoolean(11));
                mail.setSystemTopic(rset.getInt(12));
                mail.setSystemBody(rset.getInt(13));
                mail.setSystemParams(rset.getString(14));
                DbUtils.close((Statement)statement, (ResultSet)rset);
                statement = con.prepareStatement(RESTORE_MAIL_ATTACHMENTS);
                statement.setInt(1, messageId);
                rset = statement.executeQuery();
                while (rset.next()) {
                    int objectId = rset.getInt(1);
                    ItemInstance item = ItemsDAO.getInstance().load(objectId);
                    if (item == null) continue;
                    mail.addAttachment(item);
                }
            }
        }
        catch (Throwable throwable) {
            DbUtils.closeQuietly((Connection)con, statement, rset);
            throw throwable;
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        this.load.incrementAndGet();
        return mail;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private void update0(Mail mail) throws SQLException {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(UPDATE_MAIL);
            statement.setInt(1, mail.getSenderId());
            statement.setString(2, mail.getSenderName());
            statement.setInt(3, mail.getReceiverId());
            statement.setString(4, mail.getReceiverName());
            statement.setInt(5, mail.getExpireTime());
            statement.setString(6, mail.getTopic());
            statement.setString(7, mail.getBody());
            statement.setLong(8, mail.getPrice());
            statement.setInt(9, mail.getType().ordinal());
            statement.setBoolean(10, mail.isUnread());
            statement.setBoolean(11, mail.isReturned());
            statement.setInt(12, mail.getSystemTopic());
            statement.setInt(13, mail.getSystemBody());
            statement.setString(14, mail.getSystemParamsToString());
            statement.setInt(15, mail.getMessageId());
            statement.execute();
            if (mail.getAttachments().isEmpty()) {
                DbUtils.close((Statement)statement);
                statement = con.prepareStatement(REMOVE_MAIL_ATTACHMENTS);
                statement.setInt(1, mail.getMessageId());
                statement.execute();
            }
        }
        catch (Throwable throwable) {
            DbUtils.closeQuietly((Connection)con, statement);
            throw throwable;
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
        this.update.incrementAndGet();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private void delete0(Mail mail) throws SQLException {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(REMOVE_MAIL);
            statement.setInt(1, mail.getMessageId());
            statement.execute();
            if (mail.getAttachments().isEmpty()) {
                DbUtils.close((Statement)statement);
                statement = con.prepareStatement(REMOVE_MAIL_ATTACHMENTS);
                statement.setInt(1, mail.getMessageId());
                statement.execute();
            }
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement(REMOVE_OWN_MAIL2);
            statement.setInt(1, mail.getMessageId());
            statement.execute();
        }
        catch (Throwable throwable) {
            DbUtils.closeQuietly((Connection)con, statement);
            throw throwable;
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
        this.delete.incrementAndGet();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private List<Mail> getMailByOwnerId(int ownerId, boolean sent) {
        List<Integer> messageIds = Collections.emptyList();
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(RESTORE_OWN_MAIL);
            statement.setInt(1, ownerId);
            statement.setBoolean(2, sent);
            rset = statement.executeQuery();
            messageIds = new ArrayList();
            while (rset.next()) {
                messageIds.add(rset.getInt(1));
            }
        }
        catch (SQLException e) {
            try {
                _log.error("Error while restore mail of owner : " + ownerId, (Throwable)e);
                messageIds.clear();
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        return this.load(messageIds);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private boolean deleteMailByOwnerIdAndMailId(int ownerId, int messageId, boolean sent) {
        boolean bl;
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(REMOVE_OWN_MAIL);
            statement.setInt(1, ownerId);
            statement.setInt(2, messageId);
            statement.setBoolean(3, sent);
            bl = statement.execute();
        }
        catch (SQLException e) {
            boolean bl2;
            try {
                _log.error("Error while deleting mail of owner : " + ownerId, (Throwable)e);
                bl2 = false;
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
            return bl2;
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
        return bl;
    }

    public List<Mail> getReceivedMailByOwnerId(int receiverId) {
        return this.getMailByOwnerId(receiverId, false);
    }

    public List<Mail> getSentMailByOwnerId(int senderId) {
        return this.getMailByOwnerId(senderId, true);
    }

    public Mail getReceivedMailByMailId(int receiverId, int messageId) {
        List<Mail> list = this.getMailByOwnerId(receiverId, false);
        for (Mail mail : list) {
            if (mail.getMessageId() != messageId) continue;
            return mail;
        }
        return null;
    }

    public Mail getSentMailByMailId(int senderId, int messageId) {
        List<Mail> list = this.getMailByOwnerId(senderId, true);
        for (Mail mail : list) {
            if (mail.getMessageId() != messageId) continue;
            return mail;
        }
        return null;
    }

    public boolean deleteReceivedMailByMailId(int receiverId, int messageId) {
        return this.deleteMailByOwnerIdAndMailId(receiverId, messageId, false);
    }

    public boolean deleteSentMailByMailId(int senderId, int messageId) {
        return this.deleteMailByOwnerIdAndMailId(senderId, messageId, true);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public List<Mail> getExpiredMail(int expireTime) {
        List<Integer> messageIds = Collections.emptyList();
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(RESTORE_EXPIRED_MAIL);
            statement.setInt(1, expireTime);
            rset = statement.executeQuery();
            messageIds = new ArrayList<Integer>();
            while (rset.next()) {
                messageIds.add(rset.getInt(1));
            }
        }
        catch (SQLException e) {
            try {
                _log.error("Error while restore expired mail!", (Throwable)e);
                messageIds.clear();
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        return this.load(messageIds);
    }

    public Mail load(Integer id) {
        Mail mail;
        Element ce = this.cache.get((Serializable)id);
        if (ce != null) {
            Mail mail2 = (Mail)ce.getObjectValue();
            return mail2;
        }
        try {
            mail = this.load0(id);
        }
        catch (SQLException e) {
            _log.error("Error while restoring mail : " + id, (Throwable)e);
            return null;
        }
        if (mail == null) {
            return null;
        }
        mail.setJdbcState(JdbcEntityState.STORED);
        this.cache.put(new Element((Serializable)Integer.valueOf(mail.getMessageId()), (Serializable)((Object)mail)));
        return mail;
    }

    public List<Mail> load(Collection<Integer> messageIds) {
        if (messageIds.isEmpty()) {
            return Collections.emptyList();
        }
        ArrayList<Mail> list = new ArrayList<Mail>(messageIds.size());
        for (Integer messageId : messageIds) {
            Mail mail = this.load(messageId);
            if (mail == null) continue;
            list.add(mail);
        }
        return list;
    }

    public void save(Mail mail) {
        if (!mail.getJdbcState().isSavable()) {
            return;
        }
        try {
            this.save0(mail);
            mail.setJdbcState(JdbcEntityState.STORED);
        }
        catch (SQLException e) {
            _log.error("Error while saving mail!", (Throwable)e);
            return;
        }
        this.cache.put(new Element((Serializable)Integer.valueOf(mail.getMessageId()), (Serializable)((Object)mail)));
    }

    public void update(Mail mail) {
        if (!mail.getJdbcState().isUpdatable()) {
            return;
        }
        try {
            this.update0(mail);
            mail.setJdbcState(JdbcEntityState.STORED);
        }
        catch (SQLException e) {
            _log.error("Error while updating mail : " + mail.getMessageId(), (Throwable)e);
            return;
        }
        this.cache.putIfAbsent(new Element((Serializable)Integer.valueOf(mail.getMessageId()), (Serializable)((Object)mail)));
    }

    public void saveOrUpdate(Mail mail) {
        if (mail.getJdbcState().isSavable()) {
            this.save(mail);
        } else if (mail.getJdbcState().isUpdatable()) {
            this.update(mail);
        }
    }

    public void delete(Mail mail) {
        if (!mail.getJdbcState().isDeletable()) {
            return;
        }
        try {
            this.delete0(mail);
            mail.setJdbcState(JdbcEntityState.DELETED);
        }
        catch (SQLException e) {
            _log.error("Error while deleting mail : " + mail.getMessageId(), (Throwable)e);
            return;
        }
        this.cache.remove((Serializable)Integer.valueOf(mail.getExpireTime()));
    }
}


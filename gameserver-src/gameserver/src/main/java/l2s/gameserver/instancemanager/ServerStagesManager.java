package l2s.gameserver.instancemanager;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicLong;

import l2s.commons.configuration.ExProperties;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.listener.actor.OnDeathListener;
import l2s.gameserver.listener.actor.npc.OnSpawnListener;
import l2s.gameserver.listener.actor.player.OnPlayerEnterListener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.listener.CharListenerList;
import l2s.gameserver.model.base.Experience;
import l2s.gameserver.model.instances.MonsterInstance;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.mail.Mail;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExNoticePostArrived;
import l2s.gameserver.network.l2.s2c.ExUnReadMailCount;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.utils.ItemFunctions;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Server progression stages: level cap, mob spawn filter, global goals, mail rewards, advance after restart.
 */
public class ServerStagesManager {
    private static final Logger _log = LoggerFactory.getLogger(ServerStagesManager.class);

    private static final String CONFIG_FILE = "config/server_stages.properties";

    private static final String VAR_STAGE_ID = "server_stages_current_id";
    private static final String VAR_PENDING_ADVANCE = "server_stages_pending_advance";
    private static final String VAR_MAILS_SENT = "server_stages_mails_sent";
    private static final String VAR_BASE_PK = "server_stages_base_pk_sum";
    private static final String VAR_BASE_PVP = "server_stages_base_pvp_sum";
    private static final String VAR_RAID_KILLS = "server_stages_raid_kills";
    private static final String VAR_SNAPSHOT_READY = "server_stages_pk_pvp_snapshot_ok";

    /** FakePlayersTable uses account_name '#fake_account'; legacy installs may use 'fake'. */
    private static final String SQL_REAL_CHARS = " accesslevel >= 0 AND deletetime = 0 AND account_name NOT IN ('#fake_account', 'fake') ";

    private static final ServerStagesManager INSTANCE = new ServerStagesManager();

    public static ServerStagesManager getInstance() {
        return INSTANCE;
    }

    public static final class StageDef {
        public int maxPlayerLevel;
        public int reqPk;
        public int reqPvp;
        public int reqRaid;
        public double reqAvgLevel;
        public String mailTopic = "";
        public String mailBody = "";
        public String mailSender = "Server";
        public int[] rewardIds = new int[0];
        public long[] rewardCounts = new long[0];
    }

    private boolean _enabled;
    private final StageDef[] _stages = new StageDef[4];

    private final AtomicLong _cacheExpire = new AtomicLong(0L);
    private long _cachedPkDelta;
    private long _cachedPvpDelta;
    private double _cachedAvgLevel;

    private ServerStagesManager() {
        for (int i = 0; i < _stages.length; i++) {
            _stages[i] = new StageDef();
        }
    }

    public boolean isEnabled() {
        return _enabled;
    }

    /**
     * Effective max level for current stage; 0 = no extra cap (only subclass/global limits apply).
     */
    public int getEffectiveMaxPlayerLevelForCap() {
        if (!_enabled) {
            return 0;
        }
        int idx = getCurrentStageIndex();
        int cap = _stages[idx].maxPlayerLevel;
        return cap > 0 ? cap : 0;
    }

    public int getCurrentStageIndex() {
        int id = ServerVariables.getInt(VAR_STAGE_ID, 1);
        if (id < 1) {
            id = 1;
        }
        if (id > 4) {
            id = 4;
        }
        return id - 1;
    }

    public int getCurrentStageNumber() {
        return getCurrentStageIndex() + 1;
    }

    public StageDef getCurrentStageDef() {
        return _stages[getCurrentStageIndex()];
    }

    public void init() {
        loadConfig();
        if (!_enabled) {
            _log.info("ServerStagesManager: disabled.");
            return;
        }
        applyPendingAdvanceOnStartup();
        if (ServerVariables.getInt(VAR_SNAPSHOT_READY, 0) != 1) {
            refreshSnapshotFromDb(true);
        }
        ServerVariables.set(VAR_SNAPSHOT_READY, 1);
        CharListenerList.addGlobal(new StageDeathListener());
        CharListenerList.addGlobal(new StageSpawnListener());
        CharListenerList.addGlobal(new StagePlayerEnterListener());
        ThreadPoolManager.getInstance().scheduleAtFixedRate(this::onPeriodicTick, 60000L, 60000L);
        ThreadPoolManager.getInstance().schedule(this::sweepHighLevelMonsters, 15000L);
        _log.info("ServerStagesManager: stage " + getCurrentStageNumber() + ", max level cap " + getEffectiveMaxPlayerLevelForCap());
    }

    private void loadConfig() {
        ExProperties p = Config.load(CONFIG_FILE);
        _enabled = p.getProperty("Enabled", false);
        String sender = p.getProperty("MailSenderName", "Server");
        for (int i = 0; i < 4; i++) {
            String prefix = "Stage" + (i + 1) + "_";
            StageDef s = _stages[i];
            s.mailSender = sender;
            s.maxPlayerLevel = p.getProperty(prefix + "MaxPlayerLevel", 0);
            s.reqPk = p.getProperty(prefix + "RequirePkKills", 0);
            s.reqPvp = p.getProperty(prefix + "RequirePvpKills", 0);
            s.reqRaid = p.getProperty(prefix + "RequireRaidBossKills", 0);
            s.reqAvgLevel = p.getProperty(prefix + "RequireAvgLevel", 0.0);
            s.mailTopic = p.getProperty(prefix + "MailTopic", "");
            String body = p.getProperty(prefix + "MailBody", "");
            s.mailBody = body.replace('|', '\n');
            parseRewards(p.getProperty(prefix + "Rewards", ""), s);
        }
    }

    private static void parseRewards(String raw, StageDef into) {
        if (raw == null || raw.isEmpty()) {
            into.rewardIds = new int[0];
            into.rewardCounts = new long[0];
            return;
        }
        String[] parts = raw.split(";");
        List<Integer> ids = new ArrayList<>();
        List<Long> cnt = new ArrayList<>();
        for (String part : parts) {
            part = part.trim();
            if (part.isEmpty()) {
                continue;
            }
            int colon = part.indexOf(':');
            if (colon <= 0) {
                continue;
            }
            try {
                int id = Integer.parseInt(part.substring(0, colon).trim());
                long c = Long.parseLong(part.substring(colon + 1).trim());
                if (id > 0 && c > 0) {
                    ids.add(id);
                    cnt.add(c);
                }
            } catch (NumberFormatException ignored) {
            }
        }
        into.rewardIds = new int[ids.size()];
        into.rewardCounts = new long[cnt.size()];
        for (int i = 0; i < ids.size(); i++) {
            into.rewardIds[i] = ids.get(i);
            into.rewardCounts[i] = cnt.get(i);
        }
    }

    private void applyPendingAdvanceOnStartup() {
        if (ServerVariables.getInt(VAR_PENDING_ADVANCE, 0) != 1) {
            return;
        }
        int cur = ServerVariables.getInt(VAR_STAGE_ID, 1);
        if (cur < 4) {
            ServerVariables.set(VAR_STAGE_ID, cur + 1);
        }
        ServerVariables.set(VAR_PENDING_ADVANCE, 0);
        ServerVariables.set(VAR_MAILS_SENT, 0);
        ServerVariables.set(VAR_RAID_KILLS, 0);
        refreshSnapshotFromDb(true);
        ServerVariables.set(VAR_SNAPSHOT_READY, 1);
        _log.info("ServerStagesManager: stage after restart: " + ServerVariables.getInt(VAR_STAGE_ID, 1));
    }

    private void refreshSnapshotFromDb(boolean force) {
        long pk = queryLongSum("SELECT COALESCE(SUM(pkkills),0) FROM characters WHERE " + SQL_REAL_CHARS.trim());
        long pvp = queryLongSum("SELECT COALESCE(SUM(pvpkills),0) FROM characters WHERE " + SQL_REAL_CHARS.trim());
        ServerVariables.set(VAR_BASE_PK, pk);
        ServerVariables.set(VAR_BASE_PVP, pvp);
        if (force) {
            invalidateCache();
        }
    }

    private static long queryLongSum(String sql) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getLong(1);
            }
        } catch (Exception e) {
            _log.error("ServerStagesManager: " + sql, e);
        } finally {
            DbUtils.closeQuietly(con, ps, rs);
        }
        return 0L;
    }

    private double queryAvgLevel() {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            ps = con.prepareStatement(
                    "SELECT AVG(cs.level) FROM character_subclasses cs INNER JOIN characters c ON c.obj_Id = cs.char_obj_id WHERE cs.active = 1 AND cs.type = ? AND c.accesslevel >= 0 AND c.deletetime = 0 AND c.account_name NOT IN ('#fake_account', 'fake')");
            ps.setInt(1, 0);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            _log.error("ServerStagesManager: avg level query", e);
        } finally {
            DbUtils.closeQuietly(con, ps, rs);
        }
        return 0.0;
    }

    private void invalidateCache() {
        _cacheExpire.set(0L);
    }

    private void ensureCache() {
        long now = System.currentTimeMillis();
        if (now < _cacheExpire.get()) {
            return;
        }
        long basePk = ServerVariables.getLong(VAR_BASE_PK, 0L);
        long basePvp = ServerVariables.getLong(VAR_BASE_PVP, 0L);
        long sumPk = queryLongSum("SELECT COALESCE(SUM(pkkills),0) FROM characters WHERE " + SQL_REAL_CHARS.trim());
        long sumPvp = queryLongSum("SELECT COALESCE(SUM(pvpkills),0) FROM characters WHERE " + SQL_REAL_CHARS.trim());
        _cachedPkDelta = Math.max(0L, sumPk - basePk);
        _cachedPvpDelta = Math.max(0L, sumPvp - basePvp);
        _cachedAvgLevel = queryAvgLevel();
        _cacheExpire.set(now + 30000L);
    }

    public long getPkDeltaThisStage() {
        ensureCache();
        return _cachedPkDelta;
    }

    public long getPvpDeltaThisStage() {
        ensureCache();
        return _cachedPvpDelta;
    }

    public double getAverageLevel() {
        ensureCache();
        return _cachedAvgLevel;
    }

    public int getRaidKillsThisStage() {
        return ServerVariables.getInt(VAR_RAID_KILLS, 0);
    }

    public boolean isPendingAdvanceAfterRestart() {
        return ServerVariables.getInt(VAR_PENDING_ADVANCE, 0) == 1;
    }

    public boolean isCompletionMailSent() {
        return ServerVariables.getInt(VAR_MAILS_SENT, 0) == 1;
    }

    /**
     * Сброс прогресса текущей стадии: новый снимок PK/PvP, обнуление рейдов и флагов завершения/перезапуска.
     * Номер стадии не меняется.
     */
    public void resetCurrentStageProgress() {
        if (!_enabled) {
            return;
        }
        ServerVariables.set(VAR_MAILS_SENT, 0);
        ServerVariables.set(VAR_PENDING_ADVANCE, 0);
        ServerVariables.set(VAR_RAID_KILLS, 0);
        refreshSnapshotFromDb(true);
        ServerVariables.set(VAR_SNAPSHOT_READY, 1);
        invalidateCache();
        _log.info("ServerStagesManager: resetCurrentStageProgress()");
    }

    /**
     * Установить активную стадию (1–4) и сбросить её прогресс (см. {@link #resetCurrentStageProgress}).
     */
    public void setCurrentStage(int stage1to4) {
        if (!_enabled) {
            return;
        }
        int s = Math.min(4, Math.max(1, stage1to4));
        ServerVariables.set(VAR_STAGE_ID, s);
        resetCurrentStageProgress();
        _log.info("ServerStagesManager: setCurrentStage(" + s + ")");
    }

    /**
     * Overall progress 0..100 from enabled requirements for current stage.
     */
    public boolean hasAnyNumericRequirement() {
        StageDef s = getCurrentStageDef();
        return s.reqPk > 0 || s.reqPvp > 0 || s.reqRaid > 0 || s.reqAvgLevel > 0.0;
    }

    public int getOverallProgressPercent() {
        if (!_enabled) {
            return 0;
        }
        StageDef s = getCurrentStageDef();
        ensureCache();
        if (!hasAnyNumericRequirement()) {
            return 0;
        }
        double sum = 0.0;
        int parts = 0;
        if (s.reqPk > 0) {
            sum += pct(_cachedPkDelta, s.reqPk);
            parts++;
        }
        if (s.reqPvp > 0) {
            sum += pct(_cachedPvpDelta, s.reqPvp);
            parts++;
        }
        if (s.reqRaid > 0) {
            sum += pct(getRaidKillsThisStage(), s.reqRaid);
            parts++;
        }
        if (s.reqAvgLevel > 0.0) {
            sum += pct(_cachedAvgLevel, s.reqAvgLevel);
            parts++;
        }
        if (parts == 0) {
            return 0;
        }
        return (int) Math.min(100.0, Math.round(sum / parts));
    }

    private static double pct(double cur, double req) {
        if (req <= 0.0) {
            return 100.0;
        }
        return Math.min(100.0, cur / req * 100.0);
    }

    private static long pct(long cur, long req) {
        if (req <= 0L) {
            return 100L;
        }
        return Math.min(100L, (long) (cur * 100L / req));
    }

    public boolean isStageComplete() {
        if (!_enabled) {
            return true;
        }
        StageDef s = getCurrentStageDef();
        if (!hasAnyNumericRequirement()) {
            return false;
        }
        ensureCache();
        if (s.reqPk > 0 && _cachedPkDelta < s.reqPk) {
            return false;
        }
        if (s.reqPvp > 0 && _cachedPvpDelta < s.reqPvp) {
            return false;
        }
        if (s.reqRaid > 0 && getRaidKillsThisStage() < s.reqRaid) {
            return false;
        }
        if (s.reqAvgLevel > 0.0 && _cachedAvgLevel + 1.0E-4 < s.reqAvgLevel) {
            return false;
        }
        return true;
    }

    private void onPeriodicTick() {
        if (!_enabled) {
            return;
        }
        invalidateCache();
        tryCompleteStage();
    }

    private void tryCompleteStage() {
        if (!_enabled || ServerVariables.getInt(VAR_MAILS_SENT, 0) == 1) {
            return;
        }
        if (!isStageComplete()) {
            return;
        }
        sendRewardMails();
        ServerVariables.set(VAR_MAILS_SENT, 1);
        ServerVariables.set(VAR_PENDING_ADVANCE, 1);
        _log.info("ServerStagesManager: stage " + getCurrentStageNumber() + " completed; mails sent; advance scheduled for next restart.");
    }

    private void sendRewardMails() {
        StageDef s = getCurrentStageDef();
        Map<Integer, Long> items = new java.util.LinkedHashMap<Integer, Long>();
        int n = Math.min(s.rewardIds.length, s.rewardCounts.length);
        for (int i = 0; i < n && items.size() < 8; i++) {
            items.put(s.rewardIds[i], s.rewardCounts[i]);
        }
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            ps = con.prepareStatement("SELECT obj_Id, char_name FROM characters WHERE " + SQL_REAL_CHARS.trim());
            rs = ps.executeQuery();
            while (rs.next()) {
                int oid = rs.getInt("obj_Id");
                String name = rs.getString("char_name");
                deliverMail(oid, name, s.mailTopic, s.mailBody, s.mailSender, items);
            }
        } catch (Exception e) {
            _log.error("ServerStagesManager: sendRewardMails", e);
        } finally {
            DbUtils.closeQuietly(con, ps, rs);
        }
    }

    private void deliverMail(int receiverId, String receiverName, String topic, String body, String senderName, Map<Integer, Long> items) {
        if (topic == null || topic.isEmpty()) {
            topic = "Stage reward";
        }
        Player online = GameObjectsStorage.getPlayer(receiverId);
        if (online != null) {
            deliverMailOnline(online, topic, body, senderName, items);
            return;
        }
        Mail mail = new Mail();
        mail.setSenderId(1);
        mail.setSenderName(senderName);
        mail.setReceiverId(receiverId);
        mail.setReceiverName(receiverName);
        mail.setTopic(topic);
        mail.setBody(body == null ? "" : body);
        for (Map.Entry<Integer, Long> e : items.entrySet()) {
            ItemInstance it = ItemFunctions.createItem(e.getKey());
            it.setLocation(ItemInstance.ItemLocation.MAIL);
            it.setCount(e.getValue());
            it.save();
            mail.addAttachment(it);
        }
        mail.setType(Mail.SenderType.NEWS_INFORMER);
        mail.setUnread(true);
        mail.setExpireTime(2592000 + (int) (System.currentTimeMillis() / 1000L));
        mail.save();
    }

    private void deliverMailOnline(Player receiver, String topic, String body, String senderName, Map<Integer, Long> items) {
        Mail mail = new Mail();
        mail.setSenderId(1);
        mail.setSenderName(senderName);
        mail.setReceiverId(receiver.getObjectId());
        mail.setReceiverName(receiver.getName());
        mail.setTopic(topic);
        mail.setBody(body == null ? "" : body);
        for (Map.Entry<Integer, Long> e : items.entrySet()) {
            ItemInstance it = ItemFunctions.createItem(e.getKey());
            it.setLocation(ItemInstance.ItemLocation.MAIL);
            it.setCount(e.getValue());
            it.save();
            mail.addAttachment(it);
        }
        mail.setType(Mail.SenderType.NEWS_INFORMER);
        mail.setUnread(true);
        mail.setExpireTime(2592000 + (int) (System.currentTimeMillis() / 1000L));
        mail.save();
        receiver.sendPacket((IBroadcastPacket) ExNoticePostArrived.STATIC_TRUE);
        receiver.sendPacket((IBroadcastPacket) new ExUnReadMailCount(receiver));
        receiver.sendPacket((IBroadcastPacket) SystemMsg.THE_MAIL_HAS_ARRIVED);
    }

    private void incrementRaid() {
        int v = ServerVariables.getInt(VAR_RAID_KILLS, 0) + 1;
        ServerVariables.set(VAR_RAID_KILLS, v);
        invalidateCache();
        tryCompleteStage();
    }

    private void sweepHighLevelMonsters() {
        if (!_enabled) {
            return;
        }
        int maxLv = getEffectiveMaxPlayerLevelForCap();
        if (maxLv <= 0) {
            return;
        }
        for (NpcInstance npc : GameObjectsStorage.getNpcs()) {
            if (!(npc instanceof MonsterInstance) || npc.isDead()) {
                continue;
            }
            if (npc.getLevel() > maxLv) {
                npc.deleteMe();
            }
        }
    }

    private final class StageDeathListener implements OnDeathListener {
        @Override
        public void onDeath(Creature victim, Creature killer) {
            if (!_enabled) {
                return;
            }
            if (victim == null) {
                return;
            }
            if (victim.isRaid() && killer != null && killer.getPlayer() != null) {
                incrementRaid();
            }
            if (victim.isPlayer() && killer != null && killer.getPlayer() != null) {
                invalidateCache();
            }
        }
    }

    private final class StageSpawnListener implements OnSpawnListener {
        @Override
        public void onSpawn(NpcInstance npc) {
            if (!_enabled || npc == null) {
                return;
            }
            int maxLv = getEffectiveMaxPlayerLevelForCap();
            if (maxLv <= 0) {
                return;
            }
            if (!(npc instanceof MonsterInstance)) {
                return;
            }
            if (npc.getLevel() > maxLv) {
                ThreadPoolManager.getInstance().execute(() -> {
                    if (!npc.isDead()) {
                        npc.deleteMe();
                    }
                });
            }
        }
    }

    private final class StagePlayerEnterListener implements OnPlayerEnterListener {
        @Override
        public void onPlayerEnter(Player player) {
            if (!_enabled || player == null || player.getActiveSubClass() == null) {
                return;
            }
            int cap = getEffectiveMaxPlayerLevelForCap();
            if (cap <= 0) {
                return;
            }
            if (player.getLevel() <= cap) {
                return;
            }
            long targetExp = Experience.getExpForLevel(cap + 1) - 1L;
            long diff = targetExp - player.getExp();
            if (diff < 0L) {
                player.addExpAndSp(diff, 0L, true);
            }
        }
    }
}

/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.quest;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import l2s.commons.dbutils.DbUtils;
import l2s.commons.logging.LogUtils;
import l2s.gameserver.Config;
import l2s.gameserver.data.QuestHolder;
import l2s.gameserver.data.htm.HtmCache;
import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.data.xml.holder.NpcHolder;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.geometry.ILocation;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.listener.script.OnInitScriptListener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.model.base.ClassLevel;
import l2s.gameserver.model.base.ClassType;
import l2s.gameserver.model.base.Experience;
import l2s.gameserver.model.base.Race;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.olympiad.OlympiadGame;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.quest.QuestEventType;
import l2s.gameserver.model.quest.QuestNpcLogInfo;
import l2s.gameserver.model.quest.QuestPartyType;
import l2s.gameserver.model.quest.QuestRepeatType;
import l2s.gameserver.model.quest.QuestState;
import l2s.gameserver.model.quest.QuestTimer;
import l2s.gameserver.model.quest.startcondition.ICheckStartCondition;
import l2s.gameserver.model.quest.startcondition.impl.ClassIdCondition;
import l2s.gameserver.model.quest.startcondition.impl.ClassLevelCondition;
import l2s.gameserver.model.quest.startcondition.impl.ClassTypeCondition;
import l2s.gameserver.model.quest.startcondition.impl.ItemHaveCondition;
import l2s.gameserver.model.quest.startcondition.impl.PlayerLevelCondition;
import l2s.gameserver.model.quest.startcondition.impl.PlayerRaceCondition;
import l2s.gameserver.model.quest.startcondition.impl.QuestCompletedCondition;
import l2s.gameserver.network.l2.components.HtmlMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExQuestNpcLogList;
import l2s.gameserver.network.l2.s2c.TutorialShowHtmlPacket;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.npc.NpcTemplate;
import l2s.gameserver.templates.spawn.SpawnRange;
import l2s.gameserver.utils.HtmlUtils;
import l2s.gameserver.utils.NpcUtils;
import l2s.gameserver.utils.ReflectionUtils;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.CHashIntObjectMap;
import org.napile.primitive.sets.IntSet;
import org.napile.primitive.sets.impl.HashIntSet;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Quest
implements OnInitScriptListener {
    private static final Logger _log = LoggerFactory.getLogger(Quest.class);
    public static final String SOUND_ITEMGET = "ItemSound.quest_itemget";
    public static final String SOUND_ACCEPT = "ItemSound.quest_accept";
    public static final String SOUND_MIDDLE = "ItemSound.quest_middle";
    public static final String SOUND_FINISH = "ItemSound.quest_finish";
    public static final String SOUND_GIVEUP = "ItemSound.quest_giveup";
    public static final String SOUND_TUTORIAL = "ItemSound.quest_tutorial";
    public static final String SOUND_JACKPOT = "ItemSound.quest_jackpot";
    public static final String SOUND_HORROR2 = "SkillSound5.horror_02";
    public static final String SOUND_BEFORE_BATTLE = "Itemsound.quest_before_battle";
    public static final String SOUND_FANFARE_MIDDLE = "ItemSound.quest_fanfare_middle";
    public static final String SOUND_FANFARE2 = "ItemSound.quest_fanfare_2";
    public static final String SOUND_BROKEN_KEY = "ItemSound2.broken_key";
    public static final String SOUND_ENCHANT_SUCESS = "ItemSound3.sys_enchant_sucess";
    public static final String SOUND_ENCHANT_FAILED = "ItemSound3.sys_enchant_failed";
    public static final String SOUND_ED_CHIMES05 = "AmdSound.ed_chimes_05";
    public static final String SOUND_ARMOR_WOOD_3 = "ItemSound.armor_wood_3";
    public static final String SOUND_ITEM_DROP_EQUIP_ARMOR_CLOTH = "ItemSound.item_drop_equip_armor_cloth";
    public static final String NO_QUEST_DIALOG = "no-quest";
    public static final String COMPLETED_DIALOG = "completed";
    private static final String FONT_QUEST_AVAILABLE = "<font color=\"bbaa88\">";
    private static final String FONT_QUEST_DONE = "<font color=\"787878\">";
    private static final String FONT_QUEST_IN_PROGRESS = "<font color=\"ffdd66\">";
    protected static final String TODO_FIND_HTML = "<font color=\"6699ff\">TODO:<br>Find this dialog";
    public static final String ACCEPT_QUEST_EVENT = "quest_accept";
    public static final int ADENA_ID = 57;
    public static final QuestPartyType PARTY_NONE = QuestPartyType.PARTY_NONE;
    public static final QuestPartyType PARTY_ONE = QuestPartyType.PARTY_ONE;
    public static final QuestPartyType PARTY_ALL = QuestPartyType.PARTY_ALL;
    public static final QuestPartyType COMMAND_CHANNEL = QuestPartyType.COMMAND_CHANNEL;
    public static final QuestRepeatType ONETIME = QuestRepeatType.ONETIME;
    public static final QuestRepeatType REPEATABLE = QuestRepeatType.REPEATABLE;
    public static final QuestRepeatType DAILY = QuestRepeatType.DAILY;
    private IntObjectMap<Map<String, QuestTimer>> _pausedQuestTimers = new CHashIntObjectMap();
    private IntSet _startNpcs = new HashIntSet();
    private IntSet _questItems = new HashIntSet();
    private TIntObjectMap<List<QuestNpcLogInfo>> _npcLogList = new TIntObjectHashMap(5);
    private TIntObjectMap<List<QuestNpcLogInfo>> _itemsLogList = new TIntObjectHashMap(5);
    private TIntObjectMap<List<QuestNpcLogInfo>> _customLogList = new TIntObjectHashMap(5);
    private Map<ICheckStartCondition, ConditionMessage> _startConditions = new HashMap<ICheckStartCondition, ConditionMessage>();
    private final double _rewardRate;
    private final String _name = this.getClass().getSimpleName();
    private final int _id = Integer.parseInt(this._name.split("_")[1]);
    private final QuestPartyType _partyType;
    private final QuestRepeatType _repeatType;
    private final boolean _abortable;

    public void addQuestItem(int ... ids) {
        for (int id : ids) {
            if (id == 0) continue;
            ItemTemplate i = ItemHolder.getInstance().getTemplate(id);
            if (i == null) {
                _log.warn("Item ID[" + id + "] is null in quest drop in " + this.getName());
                continue;
            }
            this._questItems.add(id);
        }
    }

    public void addQuestItemWithLog(int cond, int npcStringId, int max, int ... ids) {
        if (ids.length == 0) {
            throw new IllegalArgumentException("Items list cant be empty!");
        }
        this.addQuestItem(ids);
        ArrayList<QuestNpcLogInfo> vars = (ArrayList<QuestNpcLogInfo>)this._itemsLogList.get(cond);
        if (vars == null) {
            vars = new ArrayList<QuestNpcLogInfo>(5);
            this._itemsLogList.put(cond, vars);
        }
        vars.add(new QuestNpcLogInfo(ids, null, max, npcStringId));
    }

    public void updateItems(ItemInstance item, QuestState st) {
        Player player = st.getPlayer();
        if (player == null) {
            return;
        }
        List<QuestNpcLogInfo> vars = this.getItemsLogList(st.getCond());
        if (vars == null) {
            return;
        }
        for (QuestNpcLogInfo info : vars) {
            if (!ArrayUtils.contains((int[])info.getNpcIds(), (int)item.getItemId())) continue;
            player.sendPacket((IBroadcastPacket)new ExQuestNpcLogList(st));
            break;
        }
    }

    public int[] getItems() {
        return this._questItems.toArray();
    }

    public boolean isQuestItem(int id) {
        return this._questItems.contains(id);
    }

    public void addCustomLog(int cond, String varName, int npcStringId, int max) {
        ArrayList<QuestNpcLogInfo> vars = (ArrayList<QuestNpcLogInfo>)this._customLogList.get(cond);
        if (vars == null) {
            vars = new ArrayList<QuestNpcLogInfo>(5);
            this._customLogList.put(cond, vars);
        }
        vars.add(new QuestNpcLogInfo(null, varName, max, npcStringId));
    }

    
    public static void updateQuestVarInDb(QuestState qs, String var, String value) {
        Player player = qs.getPlayer();
        if (player == null) {
            return;
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("REPLACE INTO character_quests (char_id,id,var,value) VALUES (?,?,?,?)");
            statement.setInt(1, qs.getPlayer().getObjectId());
            statement.setInt(2, qs.getQuest().getId());
            statement.setString(3, var);
            statement.setString(4, value);
            statement.executeUpdate();
        }
        catch (Exception e) {
            try {
                _log.error("could not insert char quest:", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    
    public static void deleteQuestInDb(QuestState qs) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("DELETE FROM character_quests WHERE char_id=? AND id=?");
            statement.setInt(1, qs.getPlayer().getObjectId());
            statement.setInt(2, qs.getQuest().getId());
            statement.executeUpdate();
        }
        catch (Exception e) {
            try {
                _log.error("could not delete char quest:", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    
    public static void deleteQuestVarInDb(QuestState qs, String var) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("DELETE FROM character_quests WHERE char_id=? AND id=? AND var=?");
            statement.setInt(1, qs.getPlayer().getObjectId());
            statement.setInt(2, qs.getQuest().getId());
            statement.setString(3, var);
            statement.executeUpdate();
        }
        catch (Exception e) {
            try {
                _log.error("could not delete char quest:", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    
    public static void restoreQuestStates(Player player) {
        ResultSet rset;
        PreparedStatement statement;
        Connection con;
        block8: {
            HashIntSet questsToDelete = null;
            con = null;
            statement = null;
            rset = null;
            try {
                questsToDelete = new HashIntSet();
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.prepareStatement("SELECT id,var,value FROM character_quests WHERE char_id=?");
                statement.setInt(1, player.getObjectId());
                rset = statement.executeQuery();
                while (rset.next()) {
                    int questId = rset.getInt("id");
                    String var = rset.getString("var");
                    String value = rset.getString("value");
                    QuestState qs = player.getQuestState(questId);
                    if (qs == null) {
                        Quest q = QuestHolder.getInstance().getQuest(questId);
                        if (q == null) {
                            if (Config.DONTLOADQUEST || questsToDelete.contains(questId)) continue;
                            questsToDelete.add(questId);
                            _log.warn("Unknown quest " + questId + " for player " + player.getName());
                            continue;
                        }
                        qs = new QuestState(q, player);
                    }
                    qs.set(var, value, false);
                }
                if (questsToDelete.isEmpty()) break block8;
                DbUtils.close((Statement)statement);
                statement = con.prepareStatement("DELETE FROM character_quests WHERE char_id=? AND id=?");
                for (int questId : questsToDelete.toArray()) {
                    statement.setInt(1, player.getObjectId());
                    statement.setInt(2, questId);
                    statement.addBatch();
                }
                statement.executeBatch();
            }
            catch (Exception e) {
                try {
                    _log.error("could not insert char quest:", (Throwable)e);
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly(con, statement, rset);
                    throw throwable;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement, rset);
            }
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
    }

    public Quest(QuestPartyType partyType, QuestRepeatType repeatType, boolean abortable) {
        this._partyType = partyType;
        this._repeatType = repeatType;
        this._abortable = abortable;
        this._rewardRate = !Config.EX_USE_QUEST_REWARD_PENALTY_PER || !Config.EX_F2P_QUEST_REWARD_PENALTY_QUESTS.contains(this._id) ? 1.0 : (double)Config.EX_F2P_QUEST_REWARD_PENALTY_PER * 0.01;
    }

    public Quest(QuestPartyType partyType, QuestRepeatType repeatType) {
        this(partyType, repeatType, true);
    }

    public QuestRepeatType getRepeatType() {
        return this._repeatType;
    }

    public boolean isAbortable() {
        return this._abortable;
    }

    public List<QuestNpcLogInfo> getNpcLogList(int cond) {
        return (List)this._npcLogList.get(cond);
    }

    public List<QuestNpcLogInfo> getItemsLogList(int cond) {
        return (List)this._itemsLogList.get(cond);
    }

    public List<QuestNpcLogInfo> getCustomLogList(int cond) {
        return (List)this._customLogList.get(cond);
    }

    public void addAttackId(int ... attackIds) {
        for (int attackId : attackIds) {
            this.addEventId(attackId, QuestEventType.ATTACKED_WITH_QUEST);
        }
    }

    public NpcTemplate addEventId(int npcId, QuestEventType eventType) {
        try {
            NpcTemplate t = NpcHolder.getInstance().getTemplate(npcId);
            if (t != null) {
                t.addQuestEvent(eventType, this);
            }
            return t;
        }
        catch (Exception e) {
            _log.error("", (Throwable)e);
            return null;
        }
    }

    public void addKillId(int ... killIds) {
        for (int killid : killIds) {
            this.addEventId(killid, QuestEventType.MOB_KILLED_WITH_QUEST);
        }
    }

    public void addKillNpcWithLog(int cond, int npcStringId, String varName, int max, int ... killIds) {
        if (killIds.length == 0) {
            throw new IllegalArgumentException("Npc list cant be empty!");
        }
        this.addKillId(killIds);
        ArrayList<QuestNpcLogInfo> vars = (ArrayList<QuestNpcLogInfo>)this._npcLogList.get(cond);
        if (vars == null) {
            vars = new ArrayList<QuestNpcLogInfo>(5);
            this._npcLogList.put(cond, vars);
        }
        vars.add(new QuestNpcLogInfo(killIds, varName, max, npcStringId));
    }

    public void addKillNpcWithLog(int cond, String varName, int max, int ... killIds) {
        this.addKillNpcWithLog(cond, 0, varName, max, killIds);
    }

    public boolean updateKill(NpcInstance npc, QuestState st) {
        Player player = st.getPlayer();
        if (player == null) {
            return false;
        }
        List<QuestNpcLogInfo> vars = this.getNpcLogList(st.getCond());
        if (vars == null) {
            return false;
        }
        boolean done = true;
        boolean find = false;
        boolean update = false;
        for (QuestNpcLogInfo info : vars) {
            int count = st.getInt(info.getVarName());
            if (!find && ArrayUtils.contains((int[])info.getNpcIds(), (int)npc.getNpcId())) {
                find = true;
                if (count < info.getMaxCount()) {
                    st.set(info.getVarName(), ++count);
                    update = true;
                }
            }
            if (count == info.getMaxCount()) continue;
            done = false;
        }
        if (update) {
            player.sendPacket((IBroadcastPacket)new ExQuestNpcLogList(st));
        }
        return done;
    }

    public boolean setCustomLog(String var, QuestState st, int value) {
        Player player = st.getPlayer();
        if (player == null) {
            return false;
        }
        List<QuestNpcLogInfo> vars = this.getCustomLogList(st.getCond());
        if (vars == null) {
            return false;
        }
        boolean done = true;
        boolean update = false;
        for (QuestNpcLogInfo info : vars) {
            if (!var.equalsIgnoreCase(info.getVarName())) continue;
            int count = Math.min(value, info.getMaxCount());
            if (st.getInt(var) == count) continue;
            st.set(info.getVarName(), count);
            update = true;
            if (count == info.getMaxCount()) continue;
            done = false;
        }
        if (update) {
            player.sendPacket((IBroadcastPacket)new ExQuestNpcLogList(st));
        }
        return done;
    }

    public boolean updateCustomLog(String var, QuestState st) {
        Player player = st.getPlayer();
        if (player == null) {
            return false;
        }
        List<QuestNpcLogInfo> vars = this.getCustomLogList(st.getCond());
        if (vars == null) {
            return false;
        }
        boolean done = true;
        boolean update = false;
        for (QuestNpcLogInfo info : vars) {
            if (!var.equalsIgnoreCase(info.getVarName())) continue;
            int count = st.getInt(var);
            if (count < info.getMaxCount()) {
                st.set(info.getVarName(), ++count);
                update = true;
            }
            if (count == info.getMaxCount()) continue;
            done = false;
        }
        if (update) {
            player.sendPacket((IBroadcastPacket)new ExQuestNpcLogList(st));
        }
        return done;
    }

    public void addKillId(Collection<Integer> killIds) {
        for (int killid : killIds) {
            this.addKillId(killid);
        }
    }

    public NpcTemplate addSkillUseId(int npcId) {
        return this.addEventId(npcId, QuestEventType.MOB_TARGETED_BY_SKILL);
    }

    public void addStartNpc(int ... npcIds) {
        for (int talkId : npcIds) {
            this.addStartNpc(talkId);
        }
    }

    public NpcTemplate addStartNpc(int npcId) {
        this._startNpcs.add(npcId);
        this.addTalkId(npcId);
        return this.addEventId(npcId, QuestEventType.QUEST_START);
    }

    public void addFirstTalkId(int ... npcIds) {
        for (int npcId : npcIds) {
            this.addEventId(npcId, QuestEventType.NPC_FIRST_TALK);
        }
    }

    public void addTalkId(int ... talkIds) {
        for (int talkId : talkIds) {
            this.addEventId(talkId, QuestEventType.QUEST_TALK);
        }
    }

    public void addTalkId(Collection<Integer> talkIds) {
        for (int talkId : talkIds) {
            this.addTalkId(talkId);
        }
    }

    public void addLevelCheck(int npcId, String message, int min) {
        this.addLevelCheck(message, min, Experience.getMaxLevel());
    }

    public void addLevelCheck(String message, int min) {
        this.addLevelCheck(-1, message, min);
    }

    public void addLevelCheck(int npcId, String message, int min, int max) {
        this._startConditions.put(new PlayerLevelCondition(min, max), new ConditionMessage(npcId, message));
    }

    public void addLevelCheck(String message, int min, int max) {
        this.addLevelCheck(-1, message, min, max);
    }

    public void addRaceCheck(int npcId, String message, boolean classRace, Race ... races) {
        this._startConditions.put(new PlayerRaceCondition(classRace, races), new ConditionMessage(npcId, message));
    }

    public void addRaceCheck(String message, boolean classRace, Race ... races) {
        this.addRaceCheck(-1, message, classRace, races);
    }

    public void addRaceCheck(int npcId, String message, Race ... races) {
        this.addRaceCheck(npcId, message, false, races);
    }

    public void addRaceCheck(String message, Race ... races) {
        this.addRaceCheck(-1, message, false, races);
    }

    public void addQuestCompletedCheck(int npcId, String message, int questId) {
        this._startConditions.put(new QuestCompletedCondition(questId), new ConditionMessage(npcId, message));
    }

    public void addQuestCompletedCheck(String message, int questId) {
        this.addQuestCompletedCheck(-1, message, questId);
    }

    public void addClassLevelCheck(int npcId, String message, ClassLevel ... classLevels) {
        this._startConditions.put(new ClassLevelCondition(classLevels), new ConditionMessage(npcId, message));
    }

    public void addClassLevelCheck(String message, ClassLevel ... classLevels) {
        this.addClassLevelCheck(-1, message, classLevels);
    }

    public void addClassIdCheck(int npcId, String message, int ... classIds) {
        this._startConditions.put(new ClassIdCondition(classIds), new ConditionMessage(npcId, message));
    }

    public void addClassIdCheck(String message, int ... classIds) {
        this.addClassIdCheck(-1, message, classIds);
    }

    public void addClassIdCheck(int npcId, String message, ClassId ... classIds) {
        this._startConditions.put(new ClassIdCondition(classIds), new ConditionMessage(npcId, message));
    }

    public void addClassIdCheck(String message, ClassId ... classIds) {
        this.addClassIdCheck(-1, message, classIds);
    }

    public void addItemHaveCheck(int npcId, String message, int itemId, long count) {
        this._startConditions.put(new ItemHaveCondition(itemId, count), new ConditionMessage(npcId, message));
    }

    public void addItemHaveCheck(String message, int itemId, long count) {
        this.addItemHaveCheck(-1, message, itemId, count);
    }

    public void addClassTypeCheck(int npcId, String message, ClassType type) {
        this._startConditions.put(new ClassTypeCondition(type), new ConditionMessage(npcId, message));
    }

    public void addClassTypeCheck(String message, ClassType type) {
        this.addClassTypeCheck(-1, message, type);
    }

    public String getDescr(NpcInstance npc, Player player, boolean isStartNpc) {
        if (!this.isVisible(player)) {
            return null;
        }
        int state = this.getDescrState(npc, player, isStartNpc);
        String font = FONT_QUEST_AVAILABLE;
        switch (state) {
            case 2: {
                font = FONT_QUEST_IN_PROGRESS;
                break;
            }
            case 3: {
                font = FONT_QUEST_DONE;
            }
        }
        return font.concat(HtmlUtils.htmlNpcString(this.getDescriprionId(state), new Object[0])).concat("</font>");
    }

    public int getDescriprionId(int state) {
        int fStringId = this.getId();
        if (fStringId > 11000) {
            fStringId -= 10000;
        } else if (fStringId >= 10000) {
            fStringId -= 5000;
        }
        fStringId = fStringId * 100 + state;
        return fStringId;
    }

    public final int getDescrState(NpcInstance npc, Player player, boolean isStartNpc) {
        QuestState qs = player.getQuestState(this);
        int state = 1;
        if (qs != null && qs.isStarted()) {
            state = 2;
        } else if (qs != null && qs.isCompleted()) {
            state = 3;
        }
        return state;
    }

    public String getName() {
        return this._name;
    }

    public int getId() {
        return this._id;
    }

    public QuestPartyType getPartyType() {
        return this._partyType;
    }

    public QuestState newQuestState(Player player) {
        return new QuestState(this, player);
    }

    public void notifyAttack(NpcInstance npc, QuestState qs) {
        boolean showQuestInfo = this.canShowQuestInfo(qs.getPlayer());
        String res = null;
        try {
            res = this.onAttack(npc, qs);
        }
        catch (Exception e) {
            this.showError(qs.getPlayer(), e);
            return;
        }
        showQuestInfo = showQuestInfo && this.canShowQuestInfo(qs.getPlayer());
        this.showResult(npc, qs.getPlayer(), res, showQuestInfo);
    }

    public void notifyDeath(Creature killer, Creature victim, QuestState qs) {
        boolean showQuestInfo = this.canShowQuestInfo(qs.getPlayer());
        String res = null;
        try {
            res = this.onDeath(killer, victim, qs);
        }
        catch (Exception e) {
            this.showError(qs.getPlayer(), e);
            return;
        }
        showQuestInfo = showQuestInfo && this.canShowQuestInfo(qs.getPlayer());
        this.showResult(null, qs.getPlayer(), res, showQuestInfo);
    }

    public void notifyEvent(String event, QuestState qs, NpcInstance npc) {
        boolean showQuestInfo = this.canShowQuestInfo(qs.getPlayer());
        String res = null;
        try {
            if (event.equalsIgnoreCase(ACCEPT_QUEST_EVENT)) {
                res = this.onAcceptQuest(qs, npc);
            }
            if (res == null) {
                res = this.onEvent(event, qs, npc);
            }
        }
        catch (Exception e) {
            this.showError(qs.getPlayer(), e);
            return;
        }
        showQuestInfo = showQuestInfo && this.canShowQuestInfo(qs.getPlayer());
        this.showResult(npc, qs.getPlayer(), res, showQuestInfo);
    }

    public boolean notifyMenuSelect(int reply, QuestState qs, NpcInstance npc) {
        boolean showQuestInfo = this.canShowQuestInfo(qs.getPlayer());
        String res = null;
        try {
            res = this.onMenuSelect(reply, qs, npc);
        }
        catch (Exception e) {
            this.showError(qs.getPlayer(), e);
            return true;
        }
        showQuestInfo = showQuestInfo && this.canShowQuestInfo(qs.getPlayer());
        return this.showResult(npc, qs.getPlayer(), res, showQuestInfo);
    }

    public void notifyKill(NpcInstance npc, QuestState qs) {
        boolean showQuestInfo = this.canShowQuestInfo(qs.getPlayer());
        String res = null;
        try {
            res = this.onKill(npc, qs);
        }
        catch (Exception e) {
            this.showError(qs.getPlayer(), e);
            return;
        }
        showQuestInfo = showQuestInfo && this.canShowQuestInfo(qs.getPlayer());
        this.showResult(npc, qs.getPlayer(), res, showQuestInfo);
    }

    public void notifyKill(Player target, QuestState qs) {
        boolean showQuestInfo = this.canShowQuestInfo(qs.getPlayer());
        String res = null;
        try {
            res = this.onKill(target, qs);
        }
        catch (Exception e) {
            this.showError(qs.getPlayer(), e);
            return;
        }
        showQuestInfo = showQuestInfo && this.canShowQuestInfo(qs.getPlayer());
        this.showResult(null, qs.getPlayer(), res, showQuestInfo);
    }

    public final boolean notifyFirstTalk(NpcInstance npc, Player player) {
        String res = null;
        try {
            res = this.onFirstTalk(npc, player);
        }
        catch (Exception e) {
            this.showError(player, e);
            return true;
        }
        return this.showResult(npc, player, res, true, false);
    }

    public boolean notifyTalk(NpcInstance npc, QuestState qs) {
        boolean showQuestInfo = this.canShowQuestInfo(qs.getPlayer());
        String res = null;
        try {
            Set<Quest> quests;
            if (qs.isNotAccepted() && (quests = npc.getTemplate().getEventQuests(QuestEventType.QUEST_START)) != null && quests.contains(this)) {
                res = this.checkStartCondition(npc, qs.getPlayer());
            }
            if (StringUtils.isEmpty(res)) {
                res = this.onTalk(npc, qs);
            }
        }
        catch (Exception e) {
            this.showError(qs.getPlayer(), e);
            return true;
        }
        showQuestInfo = showQuestInfo && this.canShowQuestInfo(qs.getPlayer());
        return this.showResult(npc, qs.getPlayer(), res, showQuestInfo);
    }

    public boolean notifyCompleted(NpcInstance npc, QuestState qs) {
        boolean showQuestInfo = this.canShowQuestInfo(qs.getPlayer());
        String res = null;
        try {
            res = this.onCompleted(npc, qs);
        }
        catch (Exception e) {
            this.showError(qs.getPlayer(), e);
            return true;
        }
        showQuestInfo = showQuestInfo && this.canShowQuestInfo(qs.getPlayer());
        return this.showResult(npc, qs.getPlayer(), res, showQuestInfo);
    }

    public boolean notifySkillUse(NpcInstance npc, Skill skill, QuestState qs) {
        boolean showQuestInfo = this.canShowQuestInfo(qs.getPlayer());
        String res = null;
        try {
            res = this.onSkillUse(npc, skill, qs);
        }
        catch (Exception e) {
            this.showError(qs.getPlayer(), e);
            return true;
        }
        showQuestInfo = showQuestInfo && this.canShowQuestInfo(qs.getPlayer());
        return this.showResult(npc, qs.getPlayer(), res, showQuestInfo);
    }

    public void notifySocialActionUse(QuestState qs, int actionId) {
        try {
            this.onSocialActionUse(qs, actionId);
        }
        catch (Exception e) {
            this.showError(qs.getPlayer(), e);
        }
    }

    public void notifyUpdateItem(ItemInstance item, QuestState qs) {
        try {
            this.updateItems(item, qs);
        }
        catch (Exception e) {
            this.showError(qs.getPlayer(), e);
            return;
        }
    }

    public void notifyTutorialEvent(String event, boolean quest, String value, QuestState qs) {
        String res = null;
        try {
            res = this.onTutorialEvent(event, quest, value, qs);
        }
        catch (Exception e) {
            this.showError(qs.getPlayer(), e);
            return;
        }
        this.showTutorialResult(qs.getPlayer(), res);
    }

    public void onSocialActionUse(QuestState qs, int actionId) {
    }

    public void onRestore(QuestState qs) {
    }

    public void onAccept(QuestState qs) {
    }

    public void onExit(QuestState qs) {
    }

    public void onAbort(QuestState qs) {
    }

    public void onFinish(QuestState qs) {
    }

    public String onAttack(NpcInstance npc, QuestState qs) {
        return null;
    }

    public String onDeath(Creature killer, Creature victim, QuestState qs) {
        return null;
    }

    public String onEvent(String event, QuestState qs, NpcInstance npc) {
        return null;
    }

    public String onAcceptQuest(QuestState qs, NpcInstance npc) {
        return null;
    }

    public String onMenuSelect(long reply, QuestState qs, NpcInstance npc) {
        return "";
    }

    public String onKill(NpcInstance npc, QuestState qs) {
        return null;
    }

    public String onKill(Player killed, QuestState st) {
        return null;
    }

    public String onFirstTalk(NpcInstance npc, Player player) {
        return null;
    }

    public String onTalk(NpcInstance npc, QuestState qs) {
        return null;
    }

    public String onCompleted(NpcInstance npc, QuestState qs) {
        return COMPLETED_DIALOG;
    }

    public String onSkillUse(NpcInstance npc, Skill skill, QuestState qs) {
        return null;
    }

    public void onOlympiadEnd(OlympiadGame og, QuestState qs) {
    }

    public String onTutorialEvent(String event, boolean quest, String value, QuestState qs) {
        return null;
    }

    public boolean canAbortByPacket() {
        return this.isAbortable();
    }

    private void showError(Player player, Throwable t) {
        _log.error("", t);
        if (player != null && player.isGM()) {
            String res = "<html><body><title>Script error</title>" + LogUtils.dumpStack((Throwable)t).replace("\n", "<br>") + "</body></html>";
            this.showResult(null, player, res, false);
        }
    }

    protected void showHtmlFile(Player player, NpcInstance npc, String fileName, boolean showQuestInfo) {
        this.showHtmlFile(player, npc, fileName, showQuestInfo, ArrayUtils.EMPTY_OBJECT_ARRAY);
    }

    protected void showHtmlFile(Player player, NpcInstance npc, String fileName, boolean showQuestInfo, Object ... arg) {
        if (player == null) {
            return;
        }
        HtmlMessage npcReply = new HtmlMessage(npc == null ? 5 : npc.getObjectId());
        if (showQuestInfo) {
            npcReply.setQuestId(this.getId());
        }
        npcReply.setFile("quests/" + this.getClass().getSimpleName() + "/" + fileName);
        npcReply.replace("<?quest_id?>", String.valueOf(this.getId()));
        if (arg.length % 2 == 0) {
            for (int i = 0; i < arg.length; i += 2) {
                npcReply.replace(String.valueOf(arg[i]), String.valueOf(arg[i + 1]));
            }
        }
        player.sendPacket((IBroadcastPacket)npcReply);
    }

    protected void showSimpleHtmFile(Player player, String fileName) {
        if (player == null) {
            return;
        }
        HtmlMessage npcReply = new HtmlMessage(5);
        npcReply.setFile(fileName);
        player.sendPacket((IBroadcastPacket)npcReply);
    }

    protected void showTutorialHtmlFile(Player player, String fileName, Object ... arg) {
        if (player == null) {
            return;
        }
        String text = HtmCache.getInstance().getHtml("quests/" + this.getClass().getSimpleName() + "/tutorial/" + fileName, player);
        if (arg.length % 2 == 0) {
            for (int i = 0; i < arg.length; i += 2) {
                text.replace(String.valueOf(arg[i]), String.valueOf(arg[i + 1]));
            }
        }
        player.sendPacket((IBroadcastPacket)new TutorialShowHtmlPacket(TutorialShowHtmlPacket.NORMAL_WINDOW, text));
    }

    private boolean showResult(NpcInstance npc, Player player, String res, boolean showQuestInfo) {
        return this.showResult(npc, player, res, false, showQuestInfo);
    }

    private boolean showResult(NpcInstance npc, Player player, String res, boolean isFirstTalk, boolean showQuestInfo) {
        if (res == null) {
            return true;
        }
        if (StringUtils.isEmpty((CharSequence)res)) {
            return false;
        }
        if (res.startsWith("no_quest") || res.equalsIgnoreCase("noquest") || res.equalsIgnoreCase(NO_QUEST_DIALOG)) {
            this.showSimpleHtmFile(player, "no-quest.htm");
        } else if (res.equalsIgnoreCase(COMPLETED_DIALOG)) {
            this.showSimpleHtmFile(player, "completed-quest.htm");
        } else if (res.endsWith(".htm")) {
            this.showHtmlFile(player, npc, res, showQuestInfo);
        } else {
            HtmlMessage npcReply = new HtmlMessage(npc == null ? 5 : npc.getObjectId()).setPlayVoice(isFirstTalk);
            npcReply.setHtml(res);
            if (showQuestInfo) {
                npcReply.setQuestId(this.getId());
            }
            npcReply.replace("<?quest_id?>", String.valueOf(this.getId()));
            player.sendPacket((IBroadcastPacket)npcReply);
        }
        return true;
    }

    private void showTutorialResult(Player player, String res) {
        if (StringUtils.isEmpty((CharSequence)res)) {
            return;
        }
        if (res.endsWith(".htm")) {
            this.showTutorialHtmlFile(player, res, new Object[0]);
        } else {
            player.sendPacket((IBroadcastPacket)new TutorialShowHtmlPacket(TutorialShowHtmlPacket.NORMAL_WINDOW, res));
        }
    }

    private boolean canShowQuestInfo(Player player) {
        QuestState qs = player.getQuestState(this);
        return this.isVisible(player) && (qs == null || qs.isNotAccepted());
    }

    void pauseQuestTimers(QuestState qs) {
        if (qs.getTimers().isEmpty()) {
            return;
        }
        for (QuestTimer timer : qs.getTimers().values()) {
            timer.setQuestState(null);
            timer.pause();
        }
        this._pausedQuestTimers.put(qs.getPlayer().getObjectId(), qs.getTimers());
    }

    void resumeQuestTimers(QuestState qs) {
        Map timers = (Map)this._pausedQuestTimers.remove(qs.getPlayer().getObjectId());
        if (timers == null) {
            return;
        }
        qs.getTimers().putAll(timers);
        for (QuestTimer timer : qs.getTimers().values()) {
            timer.setQuestState(qs);
            timer.start();
        }
    }

    protected String str(long i) {
        return String.valueOf(i);
    }

    public NpcInstance addSpawn(int npcId, int x, int y, int z, int heading, int randomOffset, int despawnDelay) {
        return this.addSpawn(npcId, new Location(x, y, z, heading), randomOffset, despawnDelay);
    }

    public NpcInstance addSpawn(int npcId, Location loc, int randomOffset, int despawnDelay) {
        return NpcUtils.spawnSingle(npcId, (SpawnRange)(randomOffset > 50 ? Location.findPointToStay(loc, 50, randomOffset, ReflectionManager.MAIN.getGeoIndex()) : loc), despawnDelay);
    }

    public static NpcInstance addSpawnToInstance(int npcId, int x, int y, int z, int heading, int randomOffset, int refId) {
        return Quest.addSpawnToInstance(npcId, new Location(x, y, z, heading), randomOffset, refId);
    }

    public static NpcInstance addSpawnToInstance(int npcId, Location loc, int randomOffset, int refId) {
        try {
            NpcTemplate template = NpcHolder.getInstance().getTemplate(npcId);
            if (template != null) {
                NpcInstance npc = NpcHolder.getInstance().getTemplate(npcId).getNewInstance();
                npc.setReflection(refId);
                npc.setSpawnedLoc(randomOffset > 50 ? Location.findPointToStay(loc, 50, randomOffset, npc.getGeoIndex()) : loc);
                npc.spawnMe(npc.getSpawnedLoc());
                return npc;
            }
        }
        catch (Exception e1) {
            _log.warn("Could not spawn Npc " + npcId);
        }
        return null;
    }

    public boolean isVisible(Player player) {
        return true;
    }

    public final boolean enterInstance(QuestState st, Reflection reflection, int instancedZoneId, Object ... args) {
        Reflection newReflection;
        Player player = st.getPlayer();
        if (player == null) {
            return false;
        }
        Reflection activeReflection = player.getActiveReflection();
        if (activeReflection != null) {
            if (player.canReenterInstance(instancedZoneId)) {
                player.teleToLocation((ILocation)activeReflection.getTeleportLoc(), activeReflection);
                this.onReenterInstance(st, activeReflection, args);
                return true;
            }
        } else if (player.canEnterInstance(instancedZoneId) && (newReflection = ReflectionUtils.enterReflection(player, reflection, instancedZoneId)) != null) {
            this.onEnterInstance(st, newReflection, args);
            return true;
        }
        return false;
    }

    public final boolean enterInstance(QuestState st, int instancedZoneId, Object ... args) {
        return this.enterInstance(st, new Reflection(), instancedZoneId, args);
    }

    public void onEnterInstance(QuestState st, Reflection reflection, Object[] args) {
    }

    public void onReenterInstance(QuestState st, Reflection reflection, Object[] args) {
    }

    public String checkStartCondition(int npcId, Player player) {
        for (Map.Entry<ICheckStartCondition, ConditionMessage> entry : this._startConditions.entrySet()) {
            ConditionMessage condMsg = entry.getValue();
            if (condMsg.getNpcId() != -1 && condMsg.getNpcId() != npcId || entry.getKey().checkCondition(player)) continue;
            return condMsg.getMessage();
        }
        return null;
    }

    public String checkStartCondition(NpcInstance npc, Player player) {
        if (npc != null) {
            return this.checkStartCondition(npc.getNpcId(), player);
        }
        String msg = this.checkStartCondition(-1, player);
        if (msg == null) {
            for (int npcId : this._startNpcs.toArray()) {
                msg = this.checkStartCondition(npcId, player);
                if (msg != null) continue;
                return null;
            }
            return msg;
        }
        return msg;
    }

    public boolean checkStartNpc(NpcInstance npc, Player player) {
        return true;
    }

    public boolean checkMaxLevelCondition(Player player) {
        for (ICheckStartCondition startCondition : this._startConditions.keySet()) {
            if (!(startCondition instanceof PlayerLevelCondition) || startCondition.checkCondition(player)) continue;
            return false;
        }
        return true;
    }

    public boolean checkTalkNpc(NpcInstance npc, QuestState st) {
        return true;
    }

    public double getRewardRate() {
        return this._rewardRate;
    }

    public void onHaosBattleEnd(Player player, boolean isWinner) {
    }

    @Override
    public void onInit() {
        if (!Config.DONTLOADQUEST) {
            QuestHolder.getInstance().addQuest(this);
        }
    }

    private static class ConditionMessage {
        private final int _npcId;
        private final String _message;

        public ConditionMessage(int npcId, String message) {
            this._npcId = npcId;
            this._message = message;
        }

        public int getNpcId() {
            return this._npcId;
        }

        public String getMessage() {
            return this._message;
        }
    }
}


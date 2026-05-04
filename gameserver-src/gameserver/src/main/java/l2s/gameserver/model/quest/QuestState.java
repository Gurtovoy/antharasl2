/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.quest;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collection;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.listener.actor.OnDeathListener;
import l2s.gameserver.listener.actor.OnKillListener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Party;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.base.Element;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.quest.Quest;
import l2s.gameserver.model.quest.QuestRepeatType;
import l2s.gameserver.model.quest.QuestTimer;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExShowQuestMarkPacket;
import l2s.gameserver.network.l2.s2c.PlaySoundPacket;
import l2s.gameserver.network.l2.s2c.QuestListPacket;
import l2s.gameserver.network.l2.s2c.ShowTutorialMarkPacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.network.l2.s2c.TutorialEnableClientEventPacket;
import l2s.gameserver.network.l2.s2c.TutorialShowHtmlPacket;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.utils.ItemFunctions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class QuestState {
    private static final Logger _log = LoggerFactory.getLogger(QuestState.class);
    public static final int RESTART_HOUR = 6;
    public static final int RESTART_MINUTES = 30;
    public static final String VAR_COND = "cond";
    public static final QuestState[] EMPTY_ARRAY = new QuestState[0];
    private final Player _player;
    private Quest _quest;
    private Integer _cond = null;
    private Integer _condsMask = null;
    private long _restartTime = 0L;
    private Map<String, String> _vars = new ConcurrentHashMap<String, String>();
    private Map<String, QuestTimer> _timers = new ConcurrentHashMap<String, QuestTimer>();
    private OnKillListener _onKillListener = null;

    public QuestState(Quest quest, Player player) {
        this._quest = quest;
        this._player = player;
        player.setQuestState(this);
        quest.onRestore(this);
    }

    public void addExpAndSp(long exp, long sp) {
        Player player = this.getPlayer();
        if (player == null) {
            return;
        }
        if (exp > 0L) {
            player.addExpAndSp((long)((double)exp * this.getRateQuestsReward()), 0L);
        }
        if (sp > 0L) {
            player.addExpAndSp(0L, (long)((double)sp * this.getRateQuestsReward()));
        }
    }

    public void addNotifyOfDeath(Player player, boolean withPet) {
        OnDeathListenerImpl listener = new OnDeathListenerImpl();
        player.addListener(listener);
        if (withPet) {
            for (Servitor servitor : player.getServitors()) {
                servitor.addListener(listener);
            }
        }
    }

    public void addPlayerOnKillListener() {
        if (this._onKillListener != null) {
            throw new IllegalArgumentException("Cant add twice kill listener to player");
        }
        this._onKillListener = new PlayerOnKillListenerImpl();
        this._player.addListener(this._onKillListener);
    }

    public void removePlayerOnKillListener() {
        if (this._onKillListener != null) {
            this._player.removeListener(this._onKillListener);
        }
    }

    public void addRadar(int x, int y, int z) {
        Player player = this.getPlayer();
        if (player != null) {
            player.addRadar(x, y, z);
        }
    }

    public void addRadarWithMap(int x, int y, int z) {
        Player player = this.getPlayer();
        if (player != null) {
            player.addRadarWithMap(x, y, z);
        }
    }

    
    private boolean exitCurrentQuest(QuestRepeatType repeatType) {
        Player player = this.getPlayer();
        if (player == null) {
            return false;
        }
        this.removePlayerOnKillListener();
        player.getInventory().writeLock();
        try {
            for (int itemId : this._quest.getItems()) {
                ItemInstance item = player.getInventory().getItemByItemId(itemId);
                if (item == null || itemId == 57) continue;
                long count = item.getCount();
                player.getInventory().destroyItemByItemId(itemId, count);
                player.getWarehouse().destroyItemByItemId(itemId, count);
            }
        }
        finally {
            player.getInventory().writeUnlock();
        }
        Iterator<String> object = this._vars.keySet().iterator();
        while (object.hasNext()) {
            String var = object.next();
            if (var == null) continue;
            this.unset(var);
        }
        if (repeatType == Quest.REPEATABLE) {
            player.removeQuestState(this._quest);
        } else {
            if (repeatType == Quest.DAILY) {
                this.recalcRestartTime();
            }
            this.setCond(-1, new String[0]);
        }
        this.getQuest().onExit(this);
        player.sendPacket((IBroadcastPacket)new QuestListPacket(player));
        return true;
    }

    public boolean finishQuest(String ... sound) {
        if (this.exitCurrentQuest(this.getQuest().getRepeatType())) {
            if (sound.length > 0) {
                this.playSound(sound[0]);
            } else {
                this.playSound("ItemSound.quest_finish");
            }
            this.getQuest().onFinish(this);
            this.getPlayer().getListeners().onQuestFinish(this.getQuest().getId());
            return true;
        }
        return false;
    }

    public boolean abortQuest() {
        if (this.getQuest().isAbortable() && this.exitCurrentQuest(QuestRepeatType.REPEATABLE)) {
            this.getQuest().onAbort(this);
            return true;
        }
        return false;
    }

    public String get(String var) {
        return this._vars.get(var);
    }

    public Map<String, String> getVars() {
        return this._vars;
    }

    public int getInt(String var) {
        int varint = 0;
        try {
            String val = this.get(var);
            if (val == null) {
                return 0;
            }
            varint = Integer.parseInt(val);
        }
        catch (Exception e) {
            _log.error(this.getPlayer().getName() + ": variable " + var + " isn't an integer: " + varint, (Throwable)e);
        }
        return varint;
    }

    public int getItemEquipped(int loc) {
        return this.getPlayer().getInventory().getPaperdollItemId(loc);
    }

    public Player getPlayer() {
        return this._player;
    }

    public Quest getQuest() {
        return this._quest;
    }

    public boolean checkQuestItemsCount(int ... itemIds) {
        Player player = this.getPlayer();
        if (player == null) {
            return false;
        }
        for (int itemId : itemIds) {
            if (player.getInventory().getCountOf(itemId) > 0L) continue;
            return false;
        }
        return true;
    }

    public long getSumQuestItemsCount(int ... itemIds) {
        Player player = this.getPlayer();
        if (player == null) {
            return 0L;
        }
        long count = 0L;
        for (int itemId : itemIds) {
            count += player.getInventory().getCountOf(itemId);
        }
        return count;
    }

    public long getQuestItemsCount(int itemId) {
        Player player = this.getPlayer();
        return player == null ? 0L : player.getInventory().getCountOf(itemId);
    }

    public long getQuestItemsCount(int ... itemsIds) {
        long result = 0L;
        for (int id : itemsIds) {
            result += this.getQuestItemsCount(id);
        }
        return result;
    }

    public boolean haveQuestItem(int itemId, int count) {
        return this.getQuestItemsCount(itemId) >= (long)count;
    }

    public boolean haveQuestItem(int itemId) {
        return this.haveQuestItem(itemId, 1);
    }

    public void giveItems(int itemId, long count) {
        this.giveItems(itemId, count, -1L, itemId == 57);
    }

    public void giveItems(int itemId, long count, long limit) {
        this.giveItems(itemId, count, limit, itemId == 57);
    }

    public void giveItems(int itemId, long count, boolean rate) {
        this.giveItems(itemId, count, -1L, rate);
    }

    public void giveItems(int itemId, long count, long limit, boolean rate) {
        Player player = this.getPlayer();
        if (player == null) {
            return;
        }
        if (count <= 0L) {
            count = 1L;
        }
        if (rate) {
            if (!Config.RATE_QUEST_REWARD_EXP_SP_ADENA_ONLY || itemId == 57) {
                count = (long)((double)count * this.getRateQuestsReward());
            }
            if (limit > 0L) {
                count = (long)Math.min((double)limit * Config.QUESTS_REWARD_LIMIT_MODIFIER, (double)count);
            }
        }
        ItemFunctions.addItem(player, itemId, count, true);
        player.sendChanges();
    }

    public void giveItems(int itemId, long count, Element element, int power) {
        ItemTemplate template;
        Player player = this.getPlayer();
        if (player == null) {
            return;
        }
        if (count <= 0L) {
            count = 1L;
        }
        if ((template = ItemHolder.getInstance().getTemplate(itemId)) == null) {
            return;
        }
        int i = 0;
        while ((long)i < count) {
            ItemInstance item = ItemFunctions.createItem(itemId);
            if (element != Element.NONE) {
                item.setAttributeElement(element, power);
            }
            player.getInventory().addItem(item);
            ++i;
        }
        player.sendPacket((IBroadcastPacket)SystemMessagePacket.obtainItems(template.getItemId(), count, 0));
        player.sendChanges();
    }

    public void dropItem(NpcInstance npc, int itemId, long count) {
        Player player = this.getPlayer();
        if (player == null) {
            return;
        }
        ItemInstance item = ItemFunctions.createItem(itemId);
        item.setCount(count);
        item.dropToTheGround(player, npc);
    }

    public long rollDrop(long count, double calcChance) {
        if (calcChance <= 0.0 || count <= 0L) {
            return 0L;
        }
        return this.rollDrop(count, count, calcChance);
    }

    public long rollDrop(long min, long max, double calcChance) {
        Player player;
        if (calcChance <= 0.0 || min <= 0L || max <= 0L) {
            return 0L;
        }
        int dropmult = 1;
        calcChance *= this.getPlayer().getRateQuestsDrop();
        if (this.getQuest().getPartyType() != Quest.PARTY_NONE && (player = this.getPlayer()).getParty() != null) {
            calcChance *= Config.ALT_PARTY_BONUS[Math.min(Config.ALT_PARTY_BONUS.length, player.getParty().getMemberCountInRange(player, Config.ALT_PARTY_DISTRIBUTION_RANGE)) - 1];
        }
        if (calcChance > 100.0) {
            if ((double)((int)Math.ceil(calcChance / 100.0)) <= calcChance / 100.0) {
                calcChance = Math.nextUp(calcChance);
            }
            dropmult = (int)Math.ceil(calcChance / 100.0);
            calcChance /= (double)dropmult;
        }
        return Rnd.chance((double)calcChance) ? Rnd.get((long)(min * (long)dropmult), (long)(max * (long)dropmult)) : 0L;
    }

    public double getRateQuestsReward() {
        double rate = this._quest.getRewardRate();
        Player player = this.getPlayer();
        if (player == null) {
            return rate * Config.RATE_QUESTS_REWARD;
        }
        return rate * player.getRateQuestsReward();
    }

    public boolean rollAndGive(int itemId, long min, long max, long limit, double calcChance) {
        if (calcChance <= 0.0 || min <= 0L || max <= 0L || limit <= 0L || itemId <= 0) {
            return false;
        }
        long count = this.rollDrop(min, max, calcChance);
        if (count > 0L) {
            long alreadyCount = this.getQuestItemsCount(itemId);
            if (alreadyCount + count > limit) {
                count = limit - alreadyCount;
            }
            if (count > 0L) {
                this.giveItems(itemId, count, false);
                if (count + alreadyCount < limit) {
                    this.playSound("ItemSound.quest_itemget");
                } else {
                    return true;
                }
            }
        }
        return false;
    }

    public void rollAndGive(int itemId, long min, long max, double calcChance) {
        if (calcChance <= 0.0 || min <= 0L || max <= 0L || itemId <= 0) {
            return;
        }
        long count = this.rollDrop(min, max, calcChance);
        if (count > 0L) {
            this.giveItems(itemId, count, false);
            this.playSound("ItemSound.quest_itemget");
        }
    }

    public boolean rollAndGive(int itemId, long count, double calcChance) {
        if (calcChance <= 0.0 || count <= 0L || itemId <= 0) {
            return false;
        }
        long countToDrop = this.rollDrop(count, calcChance);
        if (countToDrop > 0L) {
            this.giveItems(itemId, countToDrop, false);
            this.playSound("ItemSound.quest_itemget");
            return true;
        }
        return false;
    }

    public boolean isCompleted() {
        return this.getCond() == -1;
    }

    public boolean isStarted() {
        return this.getCond() > 0;
    }

    public boolean isNotAccepted() {
        return this.getCond() == 0;
    }

    public void killNpcByObjectId(int _objId) {
        NpcInstance npc = GameObjectsStorage.getNpc(_objId);
        if (npc != null) {
            npc.doDie(null);
        } else {
            _log.warn("Attemp to kill object that is not npc in quest " + this.getQuest().getId());
        }
    }

    public String set(String var, String val) {
        return this.set(var, val, true);
    }

    public String set(String var, int intval) {
        return this.set(var, String.valueOf(intval), true);
    }

    public String set(String var, String val, boolean store) {
        if (val == null) {
            val = "";
        }
        this._vars.put(var, val);
        if (store) {
            Quest.updateQuestVarInDb(this, var, val);
        }
        return val;
    }

    public String set(String var, int intval, boolean store) {
        return this.set(var, String.valueOf(intval), store);
    }

    public void playSound(String sound) {
        Player player = this.getPlayer();
        if (player != null) {
            player.sendPacket((IBroadcastPacket)new PlaySoundPacket(sound));
        }
    }

    public void playTutorialVoice(String voice) {
        Player player = this.getPlayer();
        if (player != null) {
            player.sendPacket((IBroadcastPacket)new PlaySoundPacket(PlaySoundPacket.Type.VOICE, voice, 0, 0, player.getLoc()));
        }
    }

    public void onTutorialClientEvent(int number) {
        Player player = this.getPlayer();
        if (player != null) {
            player.sendPacket((IBroadcastPacket)new TutorialEnableClientEventPacket(number));
        }
    }

    public void showQuestionMark(boolean quest, int tutorialId) {
        Player player = this.getPlayer();
        if (player != null) {
            player.sendPacket((IBroadcastPacket)new ShowTutorialMarkPacket(quest, tutorialId));
        }
    }

    public void showTutorialHTML(String html) {
        Player player = this.getPlayer();
        if (player == null) {
            return;
        }
        this.getQuest().showTutorialHtmlFile(player, html, new Object[0]);
    }

    public void showTutorialClientHTML(String fileName) {
        Player player = this.getPlayer();
        if (player == null) {
            return;
        }
        player.sendPacket((IBroadcastPacket)new TutorialShowHtmlPacket(TutorialShowHtmlPacket.LARGE_WINDOW, "..\\L2text\\" + fileName + ".htm"));
    }

    public void startQuestTimer(String name, long time) {
        this.startQuestTimer(name, time, null);
    }

    public void startQuestTimer(String name, long time, NpcInstance npc) {
        QuestTimer timer = new QuestTimer(name, time, npc);
        timer.setQuestState(this);
        QuestTimer oldTimer = this.getTimers().put(name, timer);
        if (oldTimer != null) {
            oldTimer.stop();
        }
        timer.start();
    }

    public boolean isRunningQuestTimer(String name) {
        return this.getTimers().get(name) != null;
    }

    public boolean cancelQuestTimer(String name) {
        QuestTimer timer = this.removeQuestTimer(name);
        if (timer != null) {
            timer.stop();
        }
        return timer != null;
    }

    QuestTimer removeQuestTimer(String name) {
        QuestTimer timer = this.getTimers().remove(name);
        if (timer != null) {
            timer.setQuestState(null);
        }
        return timer;
    }

    public void pauseQuestTimers() {
        this.getQuest().pauseQuestTimers(this);
    }

    public void stopQuestTimers() {
        for (QuestTimer timer : this.getTimers().values()) {
            timer.setQuestState(null);
            timer.stop();
        }
        this._timers.clear();
    }

    public void resumeQuestTimers() {
        this.getQuest().resumeQuestTimers(this);
    }

    Map<String, QuestTimer> getTimers() {
        return this._timers;
    }

    
    public long takeItems(int itemId, long count) {
        Player player = this.getPlayer();
        if (player == null) {
            return 0L;
        }
        player.getInventory().writeLock();
        try {
            ItemInstance item = player.getInventory().getItemByItemId(itemId);
            if (item == null) {
                long l = 0L;
                return l;
            }
            if (count < 0L || count > item.getCount()) {
                count = item.getCount();
            }
            player.getInventory().destroyItemByItemId(itemId, count);
        }
        finally {
            player.getInventory().writeUnlock();
        }
        player.sendPacket((IBroadcastPacket)SystemMessagePacket.removeItems(itemId, count));
        return count;
    }

    public long takeAllItems(int itemId) {
        return this.takeItems(itemId, -1L);
    }

    public long takeAllItems(int ... itemsIds) {
        long result = 0L;
        for (int id : itemsIds) {
            result += this.takeAllItems(id);
        }
        return result;
    }

    public long takeAllItems(Collection<Integer> itemsIds) {
        long result = 0L;
        for (int id : itemsIds) {
            result += this.takeAllItems(id);
        }
        return result;
    }

    public String unset(String var) {
        if (var == null) {
            return null;
        }
        String old = this._vars.remove(var);
        if (old != null) {
            Quest.deleteQuestVarInDb(this, var);
        }
        return old;
    }

    private boolean checkPartyMember(Player member, int cond, int maxrange, GameObject rangefrom) {
        if (member == null) {
            return false;
        }
        if (rangefrom != null && maxrange > 0 && !member.isInRange(rangefrom, maxrange)) {
            return false;
        }
        QuestState qs = member.getQuestState(this.getQuest().getId());
        return qs != null && qs.getCond() == cond;
    }

    public List<Player> getPartyMembers(int cond, int maxrange, GameObject rangefrom) {
        ArrayList<Player> result = new ArrayList<Player>();
        Party party = this.getPlayer().getParty();
        if (party == null) {
            if (this.checkPartyMember(this.getPlayer(), cond, maxrange, rangefrom)) {
                result.add(this.getPlayer());
            }
            return result;
        }
        for (Player _member : party.getPartyMembers()) {
            if (!this.checkPartyMember(_member, cond, maxrange, rangefrom)) continue;
            result.add(this.getPlayer());
        }
        return result;
    }

    public Player getRandomPartyMember(int cond, int maxrangefromplayer) {
        return this.getRandomPartyMember(cond, maxrangefromplayer, this.getPlayer());
    }

    public Player getRandomPartyMember(int cond, int maxrange, GameObject rangefrom) {
        List<Player> list = this.getPartyMembers(cond, maxrange, rangefrom);
        if (list.size() == 0) {
            return null;
        }
        return list.get(Rnd.get((int)list.size()));
    }

    public NpcInstance addSpawn(int npcId) {
        return this.addSpawn(npcId, this.getPlayer().getX(), this.getPlayer().getY(), this.getPlayer().getZ(), 0, 0, 0);
    }

    public NpcInstance addSpawn(int npcId, int despawnDelay) {
        return this.addSpawn(npcId, this.getPlayer().getX(), this.getPlayer().getY(), this.getPlayer().getZ(), 0, 0, despawnDelay);
    }

    public NpcInstance addSpawn(int npcId, int x, int y, int z) {
        return this.addSpawn(npcId, x, y, z, 0, 0, 0);
    }

    public NpcInstance addSpawn(int npcId, int x, int y, int z, int despawnDelay) {
        return this.addSpawn(npcId, x, y, z, 0, 0, despawnDelay);
    }

    public NpcInstance addSpawn(int npcId, int x, int y, int z, int heading, int randomOffset, int despawnDelay) {
        return this.getQuest().addSpawn(npcId, x, y, z, heading, randomOffset, despawnDelay);
    }

    public int calculateLevelDiffForDrop(int mobLevel, int player) {
        if (!Config.DEEPBLUE_DROP_RULES) {
            return 0;
        }
        return Math.max(player - mobLevel - Config.DEEPBLUE_DROP_MAXDIFF, 0);
    }

    public int getCond() {
        if (this._cond == null) {
            int condsMask = this.getCondsMask();
            if (condsMask != -1 && (condsMask & Integer.MIN_VALUE) != 0) {
                condsMask &= Integer.MAX_VALUE;
                for (int i = 1; i < 32; ++i) {
                    if ((condsMask >>= 1) != 0) continue;
                    condsMask = i;
                    break;
                }
            }
            this._cond = condsMask;
        }
        return this._cond;
    }

    public int getCondsMask() {
        if (this._condsMask == null) {
            this._condsMask = this.getInt(VAR_COND);
        }
        if (this._condsMask == -1 && this.getRestartTime() > 0L && this.isNowAvailable()) {
            this._condsMask = 0;
        }
        return this._condsMask;
    }

    public void setCond(int cond, String ... sound) {
        this.setCond(cond, true, sound);
    }

    public void setCond(int cond, boolean store, String ... sound) {
        Player player;
        if (cond < -1) {
            _log.warn("Cannot set negate cond in quest ID[" + this.getQuest().getId() + "]!");
            return;
        }
        if (cond == this.getCond()) {
            return;
        }
        boolean accepted = cond > 0 && !this.isStarted();
        this._cond = cond;
        if (cond != -1) {
            int condsMask = this.getCondsMask();
            if ((condsMask & Integer.MIN_VALUE) != 0) {
                condsMask &= 0x80000001 | (1 << cond) - 1;
                cond = condsMask | 1 << cond - 1;
            } else {
                cond = 0x80000001 | 1 << cond - 1 | (1 << condsMask) - 1;
            }
        }
        this._condsMask = cond;
        this.set(VAR_COND, String.valueOf(cond), store);
        if (accepted) {
            this.getQuest().onAccept(this);
        }
        if ((player = this.getPlayer()) != null && this.getQuest().isVisible(player)) {
            if (this.isStarted()) {
                player.sendPacket((IBroadcastPacket)new ExShowQuestMarkPacket(this.getQuest().getId(), this._cond));
                if (sound.length > 0) {
                    this.playSound(sound[0]);
                } else {
                    this.playSound(accepted ? "ItemSound.quest_accept" : "ItemSound.quest_middle");
                }
            }
            player.sendPacket((IBroadcastPacket)new QuestListPacket(player));
        }
    }

    private void recalcRestartTime() {
        Calendar reDo = Calendar.getInstance();
        if (reDo.get(11) >= 6) {
            reDo.add(5, 1);
        }
        reDo.set(11, 6);
        reDo.set(12, 30);
        this._restartTime = reDo.getTimeInMillis();
        this.set("restartTime", String.valueOf(this._restartTime));
    }

    private long getRestartTime() {
        String val;
        if (this._restartTime == 0L && (val = this.get("restartTime")) != null) {
            this._restartTime = Long.parseLong(val);
        }
        return this._restartTime;
    }

    private boolean isNowAvailable() {
        return this.getRestartTime() <= System.currentTimeMillis();
    }

    public class PlayerOnKillListenerImpl
    implements OnKillListener {
        @Override
        public void onKill(Creature actor, Creature victim) {
            if (!victim.isPlayer()) {
                return;
            }
            Player actorPlayer = (Player)actor;
            List<Player> players = null;
            switch (QuestState.this._quest.getPartyType()) {
                case PARTY_NONE: {
                    players = Collections.singletonList(actorPlayer);
                    break;
                }
                case PARTY_ALL: {
                    if (actorPlayer.getParty() == null) {
                        players = Collections.singletonList(actorPlayer);
                        break;
                    }
                    players = new ArrayList(actorPlayer.getParty().getMemberCount());
                    for (Player player : actorPlayer.getParty().getPartyMembers()) {
                        if (!player.checkInteractionDistance(actorPlayer)) continue;
                        players.add(player);
                    }
                    break;
                }
                case COMMAND_CHANNEL: {
                    if (actorPlayer.getParty() == null || actorPlayer.getParty().getCommandChannel() == null) {
                        players = Collections.singletonList(actorPlayer);
                        break;
                    }
                    players = new ArrayList(actorPlayer.getParty().getCommandChannel().getMemberCount());
                    for (Player player : actorPlayer.getPlayer().getParty().getCommandChannel()) {
                        if (!player.checkInteractionDistance(actorPlayer)) continue;
                        players.add(player);
                    }
                    break;
                }
                default: {
                    players = Collections.emptyList();
                }
            }
            for (Player player : players) {
                QuestState questState = player.getQuestState(QuestState.this._quest);
                if (questState == null || questState.isCompleted()) continue;
                QuestState.this._quest.notifyKill((Player)victim, questState);
            }
        }

        @Override
        public boolean ignorePetOrSummon() {
            return true;
        }
    }

    public class OnDeathListenerImpl
    implements OnDeathListener {
        @Override
        public void onDeath(Creature actor, Creature killer) {
            Player player = actor.getPlayer();
            if (player == null) {
                return;
            }
            player.removeListener(this);
            QuestState.this._quest.notifyDeath(killer, actor, QuestState.this);
        }
    }
}


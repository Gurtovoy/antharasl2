/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver;

import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.StringTokenizer;
import java.util.concurrent.Future;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.ChatType;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.NpcString;
import l2s.gameserver.network.l2.s2c.SayPacket2;
import l2s.gameserver.utils.ArabicConv;
import l2s.gameserver.utils.ChatUtils;
import l2s.gameserver.utils.Files;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Announcements {
    private static final Logger _log = LoggerFactory.getLogger(Announcements.class);
    private static final Announcements _instance = new Announcements();
    private List<Announce> _announcements = new ArrayList<Announce>();

    public static final Announcements getInstance() {
        return _instance;
    }

    private Announcements() {
        this.loadAnnouncements();
    }

    public List<Announce> getAnnouncements() {
        return this._announcements;
    }

    public void loadAnnouncements() {
        this._announcements.clear();
        try {
            List<String> lines = Arrays.asList(Files.readFile(new File("config/announcements.txt")).split("\n"));
            for (String line : lines) {
                if (line == null || line.isEmpty()) continue;
                StringTokenizer token = new StringTokenizer(line, "\t");
                if (token.countTokens() > 1) {
                    this.addAnnouncement(Integer.parseInt(token.nextToken()), token.nextToken(), false);
                    continue;
                }
                this.addAnnouncement(0, line, false);
            }
        }
        catch (Exception e) {
            _log.error("Error while loading config/announcements.txt!");
        }
    }

    public void showAnnouncements(Player activeChar) {
        for (Announce announce : this._announcements) {
            announce.showAnnounce(activeChar);
        }
    }

    public void addAnnouncement(int val, String text, boolean save) {
        Announce announce = new Announce(val, text);
        announce.start();
        this._announcements.add(announce);
        if (save) {
            this.saveToDisk();
        }
    }

    public void delAnnouncement(int line) {
        Announce announce = this._announcements.remove(line);
        if (announce != null) {
            announce.stop();
        }
        this.saveToDisk();
    }

    private void saveToDisk() {
        try {
            File f = new File("config/announcements.txt");
            FileWriter writer = new FileWriter(f, false);
            for (Announce announce : this._announcements) {
                writer.write(announce.getTime() + "\t" + announce.getAnnounce() + "\n");
            }
            writer.close();
        }
        catch (Exception e) {
            _log.error("Error while saving config/announcements.txt!", (Throwable)e);
        }
    }

    public static void announceToAll(String text) {
        Announcements.announceToAll(text, ChatType.ANNOUNCEMENT);
    }

    public static void announceToAll(NpcString npcString, String ... params) {
        Announcements.announceToAll(ChatType.ANNOUNCEMENT, npcString, params);
    }

    public static void shout(Player activeChar, String text, ChatType type) {
        SayPacket2 cs = new SayPacket2(activeChar.getObjectId(), type, activeChar.getName(), text);
        ChatUtils.shout(activeChar, cs);
        activeChar.sendPacket((IBroadcastPacket)cs);
    }

    public static void announceToAll(String text, ChatType type) {
        SayPacket2 cs = new SayPacket2(0, type, "", text);
        for (Player player : GameObjectsStorage.getPlayers(false, false)) {
            player.sendPacket((IBroadcastPacket)cs);
        }
    }

    public static void announceToAll(ChatType type, NpcString npcString, String ... params) {
        SayPacket2 cs = new SayPacket2(0, type, "", npcString, params);
        for (Player player : GameObjectsStorage.getPlayers(false, false)) {
            player.sendPacket((IBroadcastPacket)cs);
        }
    }

    public static void announceToAllFromStringHolder(String add, Object ... arg) {
        for (Player player : GameObjectsStorage.getPlayers(false, false)) {
            Announcements.announceToPlayerFromStringHolder(player, add, arg);
        }
    }

    public static void announceToPlayerFromStringHolder(Player player, String add, Object ... arg) {
        CustomMessage message = new CustomMessage(add);
        for (Object a : arg) {
            if (a instanceof CustomMessage) {
                message.addCustomMessage((CustomMessage)a);
                continue;
            }
            message.addString(String.valueOf(a));
        }
        player.sendPacket((IBroadcastPacket)new SayPacket2(0, ChatType.ANNOUNCEMENT, "", message.toString(player)));
    }

    public static void criticalAnnounceToAllFromStringHolder(String add, Object ... arg) {
        for (Player player : GameObjectsStorage.getPlayers(false, false)) {
            Announcements.criticalAnnounceToPlayerFromStringHolder(player, add, arg);
        }
    }

    public static void criticalAnnounceToPlayerFromStringHolder(Player player, String add, Object ... arg) {
        CustomMessage message = new CustomMessage(add);
        for (Object a : arg) {
            if (a instanceof CustomMessage) {
                message.addCustomMessage((CustomMessage)a);
                continue;
            }
            message.addString(String.valueOf(a));
        }
        player.sendPacket((IBroadcastPacket)new SayPacket2(0, ChatType.CRITICAL_ANNOUNCE, "", message.toString(player)));
    }

    public static void announceToAll(IBroadcastPacket sm) {
        for (Player player : GameObjectsStorage.getPlayers(false, false)) {
            player.sendPacket(sm);
        }
    }

    public class Announce
    implements Runnable {
        private Future<?> _task;
        private final int _time;
        private final String _announce;

        public Announce(int t, String announce) {
            this._time = t;
            this._announce = announce;
        }

        @Override
        public void run() {
            Announcements.announceToAll(Config.HTM_SHAPE_ARABIC ? ArabicConv.shapeArabic(this._announce) : this._announce);
        }

        public void showAnnounce(Player player) {
            String text = Config.HTM_SHAPE_ARABIC ? ArabicConv.shapeArabic(this._announce) : this._announce;
            SayPacket2 cs = new SayPacket2(0, ChatType.ANNOUNCEMENT, player.getName(), text);
            player.sendPacket((IBroadcastPacket)cs);
        }

        public void start() {
            if (this._time > 0) {
                this._task = ThreadPoolManager.getInstance().scheduleAtFixedRate(this, (long)this._time * 1000L, (long)this._time * 1000L);
            }
        }

        public void stop() {
            if (this._task != null) {
                this._task.cancel(false);
                this._task = null;
            }
        }

        public int getTime() {
            return this._time;
        }

        public String getAnnounce() {
            return this._announce;
        }
    }
}


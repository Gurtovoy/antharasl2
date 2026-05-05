package l2s.gameserver.utils;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Player;

public final class MovementRecorder {
    private static final Map<Integer, String> ACTIVE_RECORDS = new ConcurrentHashMap<Integer, String>();
    private static final SimpleDateFormat FILE_DATE_FORMAT = new SimpleDateFormat("yyyyMMdd_HHmmss_SSS");

    private MovementRecorder() {
    }

    public static boolean isRecording(Player player) {
        return player != null && ACTIVE_RECORDS.containsKey(player.getObjectId());
    }

    public static String toggle(Player player) {
        if (player == null) {
            return null;
        }
        if (isRecording(player)) {
            return stop(player);
        }
        return start(player);
    }

    public static String start(Player player) {
        if (player == null) {
            return null;
        }
        int objectId = player.getObjectId();
        String activeFile = ACTIVE_RECORDS.get(objectId);
        if (activeFile != null) {
            return activeFile;
        }
        File logDir = new File("log");
        if (!logDir.exists()) {
            logDir.mkdirs();
        }
        String fileName = "log_move_" + FILE_DATE_FORMAT.format(new Date()) + "_" + objectId + ".log";
        File logFile = new File(logDir, fileName);
        try {
            if (!logFile.exists()) {
                logFile.createNewFile();
            }
            FileWriter writer = new FileWriter(logFile, true);
            writer.write("# Movement recording started for " + player.getName() + " (" + objectId + ")\n");
            writer.close();
        }
        catch (IOException e) {
            return null;
        }
        ACTIVE_RECORDS.put(objectId, logFile.getPath());
        return logFile.getPath();
    }

    public static String stop(Player player) {
        if (player == null) {
            return null;
        }
        String filePath = ACTIVE_RECORDS.remove(player.getObjectId());
        if (filePath == null) {
            return null;
        }
        try {
            FileWriter writer = new FileWriter(filePath, true);
            writer.write("# Movement recording stopped\n");
            writer.close();
        }
        catch (IOException e) {
            // ignore write errors on stop
        }
        return filePath;
    }

    public static void recordClickMove(Player player, Location targetLoc, Location originLoc) {
        if (player == null || targetLoc == null || originLoc == null) {
            return;
        }
        String filePath = ACTIVE_RECORDS.get(player.getObjectId());
        if (filePath == null) {
            return;
        }
        String line = targetLoc.x + " " + targetLoc.y + " " + targetLoc.z + " ; from " + originLoc.x + " " + originLoc.y + " " + originLoc.z + "\n";
        try {
            FileWriter writer = new FileWriter(filePath, true);
            writer.write(line);
            writer.close();
        }
        catch (IOException e) {
            // ignore write errors to avoid affecting gameplay packets
        }
    }
}

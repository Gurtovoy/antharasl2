/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.data.xml.AbstractHolder
 */
package l2s.gameserver.data.string;

import java.io.File;
import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.utils.Files;
import l2s.gameserver.utils.Language;

public final class NpcNameHolder
extends AbstractHolder {
    private static final Pattern LINE_PATTERN = Pattern.compile("^([0-9]+)\\t(.*?)$");
    private static final NpcNameHolder INSTANCE = new NpcNameHolder();
    private final Map<Language, Map<Integer, String>> npcNames = new HashMap<Language, Map<Integer, String>>();

    public static NpcNameHolder getInstance() {
        return INSTANCE;
    }

    private NpcNameHolder() {
    }

    public String getNpcName(Language lang, int npcId) {
        Map<Integer, String> names = this.npcNames.get(lang);
        String name = names.get(npcId);
        if (name == null) {
            Language secondLang = lang;
            while (secondLang != secondLang.getSecondLanguage() && (name = (names = this.npcNames.get((secondLang = secondLang.getSecondLanguage()))).get(npcId)) == null) {
            }
            if (name == null) {
                for (Language l : Language.VALUES) {
                    names = this.npcNames.get(secondLang);
                    name = names.get(npcId);
                    if (name != null) break;
                }
            }
        }
        return name;
    }

    public String getNpcName(Player player, int npcId) {
        Language lang = player == null ? Config.DEFAULT_LANG : player.getLanguage();
        return this.getNpcName(lang, npcId);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void load() {
        for (Language lang : Language.VALUES) {
            this.npcNames.put(lang, new HashMap());
            if (!Config.AVAILABLE_LANGUAGES.contains(lang)) continue;
            File file = new File(Config.DATAPACK_ROOT, "data/string/npcname/" + lang.getShortName() + ".txt");
            if (!file.exists()) {
                if (lang.isCustom()) continue;
                this.warn("Not find file: " + file.getAbsolutePath());
                continue;
            }
            Scanner scanner = null;
            try {
                String content = Files.readFile(file);
                scanner = new Scanner(content);
                int i = 0;
                while (scanner.hasNextLine()) {
                    ++i;
                    String line = scanner.nextLine();
                    if (line.startsWith("#")) continue;
                    Matcher m = LINE_PATTERN.matcher(line);
                    if (m.find()) {
                        int id = Integer.parseInt(m.group(1));
                        String value = m.group(2);
                        this.npcNames.get(lang).put(id, value);
                        continue;
                    }
                    this.error("Error on line #: " + i + "; file: " + file.getName());
                }
            }
            catch (Exception e) {
                this.error("Exception: " + e, e);
            }
            finally {
                try {
                    scanner.close();
                }
                catch (Exception e) {}
            }
        }
        this.log();
    }

    public void reload() {
        this.clear();
        this.load();
    }

    public void log() {
        for (Map.Entry<Language, Map<Integer, String>> entry : this.npcNames.entrySet()) {
            if (!Config.AVAILABLE_LANGUAGES.contains(entry.getKey())) continue;
            this.info("load npc names: " + entry.getValue().size() + " for lang: " + (Object)(entry.getKey()));
        }
    }

    public int size() {
        return this.npcNames.size();
    }

    public void clear() {
        this.npcNames.clear();
    }
}


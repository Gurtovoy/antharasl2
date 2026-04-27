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

public final class StringsHolder
extends AbstractHolder {
    private static final Pattern LINE_PATTERN = Pattern.compile("^(((?!=).)+)=(.*?)$");
    private static final StringsHolder _instance = new StringsHolder();
    private final Map<Language, Map<String, String>> _strings = new HashMap<Language, Map<String, String>>();

    public static StringsHolder getInstance() {
        return _instance;
    }

    private StringsHolder() {
    }

    public String getString(String name, Player player) {
        Language lang = player == null ? Config.DEFAULT_LANG : player.getLanguage();
        return this.getString(name, lang);
    }

    public String getString(Player player, String name) {
        Language lang = player == null ? Config.DEFAULT_LANG : player.getLanguage();
        return this.getString(name, lang);
    }

    public String getString(String address, Language lang) {
        Map<String, String> strings = this._strings.get(lang);
        String value = strings.get(address);
        if (value == null) {
            Language secondLang = lang;
            while (secondLang != secondLang.getSecondLanguage() && (value = (strings = this._strings.get((secondLang = secondLang.getSecondLanguage()))).get(address)) == null) {
            }
            if (value == null) {
                for (Language l : Language.VALUES) {
                    strings = this._strings.get(secondLang);
                    value = strings.get(address);
                    if (value != null) break;
                }
            }
        }
        if (value == null) {
            this.warn("String for '" + (Object)((Object)lang) + "' language: '" + address + "' not found.");
            return "";
        }
        return value;
    }

    public void load() {
        for (Language lang : Language.VALUES) {
            this._strings.put(lang, new HashMap());
            if (!Config.AVAILABLE_LANGUAGES.contains(lang)) continue;
            File file = new File(Config.DATAPACK_ROOT, "data/string/strings/" + lang.getShortName() + ".properties");
            if (!file.exists()) {
                this.warn("Not find file: " + file.getAbsolutePath());
            } else {
                this.loadFile(file, lang);
            }
            file = new File(Config.DATAPACK_ROOT, "data/string/strings/" + lang.getShortName() + "/");
            if (!file.exists() || !file.isDirectory()) continue;
            for (File f : file.listFiles()) {
                if (!f.getName().matches("^(.+)\\.properties$")) continue;
                this.loadFile(f, lang);
            }
        }
        this.log();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private void loadFile(File file, Language lang) {
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
                    String name = m.group(1);
                    String value = m.group(3);
                    this._strings.get(lang).put(name, value);
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

    public void reload() {
        this.clear();
        this.load();
    }

    public void log() {
        for (Map.Entry<Language, Map<String, String>> entry : this._strings.entrySet()) {
            if (!Config.AVAILABLE_LANGUAGES.contains(entry.getKey())) continue;
            this.info("load strings: " + entry.getValue().size() + " for lang: " + (Object)(entry.getKey()));
        }
    }

    public int size() {
        return this._strings.size();
    }

    public void clear() {
        this._strings.clear();
    }
}


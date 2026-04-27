/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  gnu.trove.map.TIntObjectMap
 *  gnu.trove.map.hash.TIntObjectHashMap
 *  l2s.commons.data.xml.AbstractHolder
 */
package l2s.gameserver.data.string;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.io.File;
import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.utils.Files;
import l2s.gameserver.utils.Language;

public final class SkillNameHolder
extends AbstractHolder {
    private static final Pattern LINE_PATTERN = Pattern.compile("^([0-9]+)\\t([0-9]+)\\t(.*?)$");
    private static final SkillNameHolder _instance = new SkillNameHolder();
    private final Map<Language, TIntObjectMap<String>> _skillNames = new HashMap<Language, TIntObjectMap<String>>();

    public static SkillNameHolder getInstance() {
        return _instance;
    }

    private SkillNameHolder() {
    }

    public String getSkillName(Language lang, int hashCode) {
        TIntObjectMap<String> skillNames = this._skillNames.get(lang);
        String name = (String)skillNames.get(hashCode);
        if (name == null) {
            Language secondLang = lang;
            while (secondLang != secondLang.getSecondLanguage() && (name = (String)(skillNames = this._skillNames.get((secondLang = secondLang.getSecondLanguage()))).get(hashCode)) == null) {
            }
            if (name == null) {
                for (Language l : Language.VALUES) {
                    skillNames = this._skillNames.get(secondLang);
                    name = (String)skillNames.get(hashCode);
                    if (name != null) break;
                }
            }
        }
        return name;
    }

    public String getSkillName(Player player, int hashCode) {
        Language lang = player == null ? Config.DEFAULT_LANG : player.getLanguage();
        return this.getSkillName(lang, hashCode);
    }

    public String getSkillName(Language lang, Skill skill) {
        return this.getSkillName(lang, skill.hashCode());
    }

    public String getSkillName(Player player, Skill skill) {
        return this.getSkillName(player, skill.hashCode());
    }

    public String getSkillName(Language lang, int id, int level) {
        return this.getSkillName(lang, SkillHolder.getInstance().getHashCode(id, level));
    }

    public String getSkillName(Player player, int id, int level) {
        return this.getSkillName(player, SkillHolder.getInstance().getHashCode(id, level));
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void load() {
        for (Language lang : Language.VALUES) {
            this._skillNames.put(lang, (TIntObjectMap<String>)new TIntObjectHashMap());
            if (!Config.AVAILABLE_LANGUAGES.contains(lang)) continue;
            File file = new File(Config.DATAPACK_ROOT, "data/string/skillname/" + lang.getShortName() + ".txt");
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
                        int level = Integer.parseInt(m.group(2));
                        int hashCode = SkillHolder.getInstance().getHashCode(id, level);
                        String value = m.group(3);
                        this._skillNames.get(lang).put(hashCode, value);
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
        for (Map.Entry<Language, TIntObjectMap<String>> entry : this._skillNames.entrySet()) {
            if (!Config.AVAILABLE_LANGUAGES.contains(entry.getKey())) continue;
            this.info("load skill names: " + entry.getValue().size() + " for lang: " + (Object)(entry.getKey()));
        }
    }

    public int size() {
        return this._skillNames.size();
    }

    public void clear() {
        this._skillNames.clear();
    }
}


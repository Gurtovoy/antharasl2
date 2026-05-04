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
import l2s.gameserver.model.Player;
import l2s.gameserver.utils.Files;
import l2s.gameserver.utils.Language;

public final class ItemNameHolder
extends AbstractHolder {
    private static final Pattern LINE_PATTERN = Pattern.compile("^([0-9]+)\\t(.*?)$");
    private static final ItemNameHolder _instance = new ItemNameHolder();
    private final Map<Language, TIntObjectMap<String>> _itemNames = new HashMap<Language, TIntObjectMap<String>>();

    public static ItemNameHolder getInstance() {
        return _instance;
    }

    private ItemNameHolder() {
    }

    public String getItemName(Language lang, int itemId) {
        TIntObjectMap<String> itemNames = this._itemNames.get(lang);
        String name = (String)itemNames.get(itemId);
        if (name == null) {
            Language secondLang = lang;
            while (secondLang != secondLang.getSecondLanguage() && (name = (String)(itemNames = this._itemNames.get((secondLang = secondLang.getSecondLanguage()))).get(itemId)) == null) {
            }
            if (name == null) {
                for (Language l : Language.VALUES) {
                    itemNames = this._itemNames.get(secondLang);
                    name = (String)itemNames.get(itemId);
                    if (name != null) break;
                }
            }
        }
        return name;
    }

    public String getItemName(Player player, int itemId) {
        Language lang = player == null ? Config.DEFAULT_LANG : player.getLanguage();
        return this.getItemName(lang, itemId);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void load() {
        for (Language lang : Language.VALUES) {
            this._itemNames.put(lang, (TIntObjectMap<String>)new TIntObjectHashMap());
            if (!Config.AVAILABLE_LANGUAGES.contains(lang)) continue;
            File file = new File(Config.DATAPACK_ROOT, "data/string/itemname/" + lang.getShortName() + ".txt");
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
                        this._itemNames.get(lang).put(id, value);
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
        for (Map.Entry<Language, TIntObjectMap<String>> entry : this._itemNames.entrySet()) {
            if (!Config.AVAILABLE_LANGUAGES.contains(entry.getKey())) continue;
            this.info("load item names: " + entry.getValue().size() + " for lang: " + (Object)(entry.getKey()));
        }
    }

    public int size() {
        return this._itemNames.size();
    }

    public void clear() {
        this._itemNames.clear();
    }
}


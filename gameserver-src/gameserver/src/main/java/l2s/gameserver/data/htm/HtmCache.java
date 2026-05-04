/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.htm;

import java.io.File;
import java.io.IOException;
import java.io.Serializable;
import l2s.gameserver.Config;
import l2s.gameserver.data.htm.HtmTemplates;
import l2s.gameserver.model.Player;
import l2s.gameserver.utils.ArabicConv;
import l2s.gameserver.utils.Files;
import l2s.gameserver.utils.HtmlUtils;
import l2s.gameserver.utils.Language;
import l2s.gameserver.utils.Util;
import net.sf.ehcache.Cache;
import net.sf.ehcache.CacheManager;
import net.sf.ehcache.Element;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class HtmCache {
    public static final int DISABLED = 0;
    public static final int LAZY = 1;
    public static final int ENABLED = 2;
    private static final Logger _log = LoggerFactory.getLogger(HtmCache.class);
    private static final HtmCache _instance = new HtmCache();
    private final Cache[] _cache = new Cache[Language.VALUES.length];

    public static HtmCache getInstance() {
        return _instance;
    }

    private HtmCache() {
        for (int i = 0; i < this._cache.length; ++i) {
            this._cache[i] = CacheManager.getInstance().getCache(this.getClass().getName() + "." + Language.VALUES[i].name());
        }
    }

    public void reload() {
        this.clear();
        switch (Config.HTM_CACHE_MODE) {
            case 2: {
                _log.info("HtmCache: Loading HTML's...");
                for (Language lang : Language.VALUES) {
                    if (!Config.AVAILABLE_LANGUAGES.contains(lang)) continue;
                    File root = new File(Config.DATAPACK_ROOT, "data/html/" + lang.getShortName());
                    if (!root.exists()) {
                        _log.info("HtmCache: Not find html dir for lang: " + (Object)((Object)lang));
                        continue;
                    }
                    this.load(lang, root, root.getAbsolutePath() + "/");
                    root = new File(Config.DATAPACK_ROOT, "custom/html/" + lang.getShortName());
                    if (!root.exists()) continue;
                    this.load(lang, root, root.getAbsolutePath() + "/");
                    _log.info(String.format("HtmCache: parsing %d documents; lang: %s.", new Object[]{this._cache[lang.ordinal()].getSize(), lang}));
                }
                break;
            }
            case 1: {
                _log.info("HtmCache: lazy cache mode.");
                break;
            }
            case 0: {
                _log.info("HtmCache: disabled.");
            }
        }
    }

    private void load(Language lang, File f, String rootPath) {
        File[] files;
        if (!f.exists()) {
            _log.info("HtmCache: dir not exists: " + f);
            return;
        }
        for (File file : files = f.listFiles()) {
            if (file.isDirectory()) {
                this.load(lang, file, rootPath);
                continue;
            }
            if (!file.getName().endsWith(".htm")) continue;
            try {
                this.putContent(lang, file, rootPath);
            }
            catch (IOException e) {
                _log.error("HtmCache: file error: " + e, (Throwable)e);
            }
        }
    }

    private String putContent(Language lang, File f, String rootPath) throws IOException {
        String content = HtmCache.readContent(f);
        String path = f.getAbsolutePath().substring(rootPath.length()).replace("\\", "/");
        content = HtmlUtils.bbParse(content);
        this._cache[lang.ordinal()].put(new Element((Serializable)((Object)path.toLowerCase()), (Serializable)((Object)content)));
        return content;
    }

    public String getHtml(String fileName, Player player) {
        Language lang = player == null ? Config.DEFAULT_LANG : player.getLanguage();
        String cache = this.getCache(fileName, lang);
        if (cache == null) {
            _log.warn("Dialog: 'data/html/" + lang.getShortName() + "/" + fileName + "' not found.");
        }
        return cache;
    }

    public String getIfExists(String fileName, Player player) {
        Language lang = player == null ? Config.DEFAULT_LANG : player.getLanguage();
        return this.getCache(fileName, lang);
    }

    public HtmTemplates getTemplates(String fileName, Player player) {
        Language lang = player == null ? Config.DEFAULT_LANG : player.getLanguage();
        HtmTemplates templates = Util.parseTemplates(fileName, lang, this.getHtml(fileName, player));
        if (templates == null) {
            return HtmTemplates.EMPTY_TEMPLATES;
        }
        return templates;
    }

    public String getCache(String file, Language lang) {
        if (file == null) {
            return null;
        }
        String fileLower = file.toLowerCase();
        String cache = this.get(lang, fileLower);
        if (cache == null) {
            Language secondLang = lang;
            switch (Config.HTM_CACHE_MODE) {
                case 2: {
                    Language l;
                    while (secondLang != secondLang.getSecondLanguage() && Config.AVAILABLE_LANGUAGES.contains(secondLang) && (cache = this.get(secondLang = secondLang.getSecondLanguage(), fileLower)) == null) {
                    }
                    if (cache != null) break;
                    Language[] languageArray = Language.VALUES;
                    int n = languageArray.length;
                    for (int i = 0; !(i >= n || Config.AVAILABLE_LANGUAGES.contains((l = languageArray[i])) && (cache = this.get(l, fileLower)) != null); ++i) {
                    }
                    break;
                }
                case 1: {
                    Language l;
                    cache = this.loadLazy(lang, file);
                    if (cache != null) break;
                    while (secondLang != secondLang.getSecondLanguage() && Config.AVAILABLE_LANGUAGES.contains(secondLang) && (cache = this.loadLazy(secondLang = secondLang.getSecondLanguage(), file)) == null) {
                    }
                    if (cache != null) break;
                    Language[] languageArray = Language.VALUES;
                    int n = languageArray.length;
                    for (int i = 0; !(i >= n || Config.AVAILABLE_LANGUAGES.contains((l = languageArray[i])) && (cache = this.loadLazy(l, file)) != null); ++i) {
                    }
                    break;
                }
                case 0: {
                    Language l;
                    cache = this.loadDisabled(lang, file);
                    if (cache != null) break;
                    while (secondLang != secondLang.getSecondLanguage() && Config.AVAILABLE_LANGUAGES.contains(secondLang) && (cache = this.loadDisabled(secondLang = secondLang.getSecondLanguage(), file)) == null) {
                    }
                    if (cache != null) break;
                    Language[] languageArray = Language.VALUES;
                    int n = languageArray.length;
                    for (int i = 0; !(i >= n || Config.AVAILABLE_LANGUAGES.contains((l = languageArray[i])) && (cache = this.loadDisabled(l, file)) != null); ++i) {
                    }
                    break;
                }
            }
        }
        return cache;
    }

    private String loadDisabled(Language lang, String file) {
        String cache = null;
        File f = HtmCache.getFile(new File(Config.DATAPACK_ROOT, "data/html/" + lang.getShortName() + "/" + file));
        if (f.exists()) {
            try {
                cache = HtmCache.readContent(f);
                cache = HtmlUtils.bbParse(cache);
            }
            catch (IOException e) {
                _log.info("HtmCache: File error: " + file + " lang: " + (Object)((Object)lang));
            }
        }
        if ((f = HtmCache.getFile(new File(Config.DATAPACK_ROOT, "custom/html/" + lang.getShortName() + "/" + file))).exists()) {
            try {
                cache = HtmCache.readContent(f);
                cache = HtmlUtils.bbParse(cache);
            }
            catch (IOException e) {
                _log.info("HtmCache: File error: " + file + " lang: " + (Object)((Object)lang));
            }
        }
        return cache;
    }

    private String loadLazy(Language lang, String file) {
        String cache = null;
        File root = new File(Config.DATAPACK_ROOT, "data/html/" + lang.getShortName());
        File f = HtmCache.getFile(new File(root, file));
        if (f.exists()) {
            try {
                cache = this.putContent(lang, f, root.getAbsolutePath() + "/");
            }
            catch (IOException e) {
                _log.info("HtmCache: File error: " + file + " lang: " + (Object)((Object)lang));
            }
        }
        if ((f = HtmCache.getFile(new File(root = new File(Config.DATAPACK_ROOT, "custom/html/" + lang.getShortName()), file))).exists()) {
            try {
                cache = this.putContent(lang, f, root.getAbsolutePath() + "/");
            }
            catch (IOException e) {
                _log.info("HtmCache: File error: " + file + " lang: " + (Object)((Object)lang));
            }
        }
        return cache;
    }

    private String get(Language lang, String f) {
        Element element = this._cache[lang.ordinal()].get((Serializable)((Object)f));
        if (element == null) {
            element = this._cache[Language.ENGLISH.ordinal()].get((Serializable)((Object)f));
        }
        return element == null ? null : (String)element.getObjectValue();
    }

    public void clear() {
        for (int i = 0; i < this._cache.length; ++i) {
            this._cache[i].removeAll();
        }
    }

    private static String readContent(File file) throws IOException {
        String content = Files.readFile(file);
        if (Config.HTM_SHAPE_ARABIC) {
            content = ArabicConv.shapeArabic(content);
        }
        return content;
    }

    private static File getFile(File file) {
        File dir;
        if (!file.exists() && (dir = file.getParentFile()) != null && dir.isDirectory()) {
            for (File f : dir.listFiles()) {
                if (!f.getName().equalsIgnoreCase(file.getName())) continue;
                return f;
            }
        }
        return file;
    }
}


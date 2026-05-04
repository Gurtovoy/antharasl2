/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.utils;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import l2s.commons.util.Rnd;
import l2s.gameserver.data.string.NpcStringHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import org.apache.commons.lang3.StringUtils;

public class BypassStorage {
    private static final Pattern htmlBypass = Pattern.compile("\\s+action=\"bypass\\s+(?:-h +)?([^\"]+?)\"", 2);
    private static final Pattern htmlLink = Pattern.compile("\\s+action=\"link\\s+([^\"]+?\\.html?(#[0-9]+)?)\"", 2);
    private static final Pattern bbsWrite = Pattern.compile("\\s+action=\"write\\s+(\\S+)\\s+\\S+\\s+\\S+\\s+\\S+\\s+\\S+\\s+\\S+\"", 2);
    private static final Pattern directHtmlBypass = Pattern.compile("^(_mrsl|_diary|_match|manor_menu_select|_olympiad|pledgegame|_heroes|pcbang?).*", 32);
    private static final Pattern directBbsBypass = Pattern.compile("^(_bbshome|_bbsgetfav|_bbsaddfav|_bbslink|_bbsloc|_bbsclan|_bbsmemo|_maillist|_friendlist).*", 32);
    private static final Pattern fstringPattern = Pattern.compile("<fstring(\\s+p[0-9]+\\s*=\\s*\"((?!>).*?)\")*\\s*>([0-9]+)<\\s*/\\s*fstring\\s*>", 2);
    private final Player _owner;
    private final Map<BypassType, List<ValidBypass>> _bypassesMap = new HashMap<BypassType, List<ValidBypass>>(BypassType.VALUES.length);

    public BypassStorage(Player owner) {
        this._owner = owner;
        for (BypassType type : BypassType.VALUES) {
            this._bypassesMap.put(type, new CopyOnWriteArrayList());
        }
    }

    public void parseHtml(CharSequence html, BypassType type) {
        this.parseHtml(html.toString(), type, false);
    }

    public String parseHtml(String html, BypassType type, boolean encode) {
        String bypass;
        this.clear(type);
        if (StringUtils.isEmpty((CharSequence)html)) {
            return html;
        }
        Matcher m = htmlBypass.matcher(html);
        while (m.find()) {
            bypass = m.group(1);
            int i = bypass.indexOf(" $");
            if (i > 0) {
                bypass = bypass.substring(0, i);
            }
            if (encode) {
                ValidBypass validBypass = new ValidBypass(BypassStorage.encodeBypass(bypass), bypass, i >= 0, type);
                this.addBypass(validBypass);
                html = html.replaceFirst(Pattern.quote(validBypass.bypass), validBypass.encryptedBypass);
                continue;
            }
            this.addBypass(new ValidBypass(bypass, bypass, i >= 0, type));
        }
        if (type == BypassType.BBS) {
            m = bbsWrite.matcher(html);
            while (m.find()) {
                bypass = m.group(1);
                if (encode) {
                    ValidBypass validBypass = new ValidBypass(BypassStorage.encodeBypass(bypass), bypass, true, type);
                    this.addBypass(validBypass);
                    html = html.replaceFirst(Pattern.quote(validBypass.bypass), validBypass.encryptedBypass);
                    continue;
                }
                this.addBypass(new ValidBypass(bypass, bypass, true, type));
            }
        }
        m = htmlLink.matcher(html);
        while (m.find()) {
            bypass = m.group(1);
            if (encode) {
                ValidBypass validBypass = new ValidBypass(BypassStorage.encodeBypass(bypass), bypass, false, type);
                this.addBypass(validBypass);
                html = html.replaceFirst(Pattern.quote(validBypass.bypass), validBypass.encryptedBypass);
                continue;
            }
            this.addBypass(new ValidBypass(bypass, bypass, false, type));
        }
        m = fstringPattern.matcher(html);
        while (m.find()) {
            String npcString = null;
            int npcStringId = Integer.parseInt(m.group(3));
            GameClient client = this._owner.getNetConnection();
            npcString = client == null ? NpcStringHolder.getInstance().getNpcString(this._owner, npcStringId) : NpcStringHolder.getInstance().getNpcString(client.getLanguage(), npcStringId);
            if (npcString == null) continue;
            Matcher m2 = htmlBypass.matcher(npcString);
            while (m2.find()) {
                String bypass2 = m2.group(1);
                this.addBypass(new ValidBypass(bypass2, bypass2, false, type));
            }
        }
        return html;
    }

    public static String encodeBypass(String bypass) {
        int encoded = Rnd.get((int)Integer.MAX_VALUE);
        return String.valueOf(encoded);
    }

    public ValidBypass validate(String bypass) {
        ValidBypass ret = null;
        if (directHtmlBypass.matcher(bypass).matches()) {
            ret = new ValidBypass(bypass, bypass, false, BypassType.DEFAULT);
        } else if (directBbsBypass.matcher(bypass).matches()) {
            ret = new ValidBypass(bypass, bypass, false, BypassType.BBS);
        } else {
            String[] args = bypass.split("\\s+");
            block0: for (List<ValidBypass> bypasses : this._bypassesMap.values()) {
                for (ValidBypass bp : bypasses) {
                    if (bp.encryptedBypass.equals(bypass)) {
                        ret = bp;
                        break block0;
                    }
                    if (!bp.args || !bp.encryptedBypass.split("\\s+")[0].equals(args[0])) continue;
                    if (args.length > 1) {
                        ret = new ValidBypass(bp.encryptedBypass, bypass.replaceFirst(Pattern.quote(args[0]), bp.bypass), true, bp.type);
                        break block0;
                    }
                    ret = bp;
                    break block0;
                }
            }
        }
        return ret;
    }

    private void addBypass(ValidBypass bypass) {
        this._bypassesMap.get(bypass.type).add(bypass);
    }

    private void clear(BypassType type) {
        this._bypassesMap.get(type).clear();
    }

    public static class ValidBypass {
        public String encryptedBypass;
        public String bypass;
        public boolean args;
        public BypassType type;

        public ValidBypass(String encryptedBypass, String bypass, boolean args, BypassType type) {
            this.encryptedBypass = encryptedBypass;
            this.bypass = bypass;
            this.args = args;
            this.type = type;
        }
    }

    public static enum BypassType {
        DEFAULT,
        BBS,
        ITEM;

        public static final BypassType[] VALUES;

        static {
            VALUES = BypassType.values();
        }
    }
}


/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.apache.commons.lang3.ArrayUtils
 *  org.apache.commons.lang3.StringUtils
 *  org.apache.commons.text.TextStringBuilder
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.network.l2.components;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.regex.Matcher;
import l2s.gameserver.Config;
import l2s.gameserver.cache.ImagesCache;
import l2s.gameserver.data.htm.HtmCache;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.NpcString;
import l2s.gameserver.network.l2.s2c.ActionFailPacket;
import l2s.gameserver.network.l2.s2c.ExNpcQuestHtmlMessage;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.NpcHtmlMessagePacket;
import l2s.gameserver.network.l2.s2c.PledgeCrestPacket;
import l2s.gameserver.utils.BypassStorage;
import l2s.gameserver.utils.ChatUtils;
import l2s.gameserver.utils.HtmlUtils;
import l2s.gameserver.utils.velocity.VelocityUtils;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.text.TextStringBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class HtmlMessage
implements IBroadcastPacket {
    private static final Logger _log = LoggerFactory.getLogger(HtmlMessage.class);
    public static final String OBJECT_ID_VAR = "OBJECT_ID";
    private String _filename;
    private String _html;
    private Map<String, Object> _variables;
    private Map<String, String> _replaces;
    private NpcInstance _npc;
    private int _npcObjId;
    private int _itemId;
    private int _questId;
    private boolean _playVoice;

    public HtmlMessage(NpcInstance npc, String filename) {
        this._npc = npc;
        this._npcObjId = npc.getObjectId();
        this._filename = filename;
    }

    public HtmlMessage(NpcInstance npc) {
        this(npc, null);
    }

    public HtmlMessage(int npcObjId) {
        this._npc = GameObjectsStorage.getNpc(npcObjId);
        this._npcObjId = npcObjId;
    }

    public HtmlMessage setHtml(String text) {
        this._html = text;
        return this;
    }

    public final HtmlMessage setFile(String file) {
        this._filename = file;
        return this;
    }

    public final HtmlMessage setItemId(int itemId) {
        this._itemId = itemId;
        return this;
    }

    public final HtmlMessage setQuestId(int questId) {
        this._questId = questId;
        return this;
    }

    public final HtmlMessage setPlayVoice(boolean playVoice) {
        this._playVoice = playVoice;
        return this;
    }

    public HtmlMessage addVar(String name, Object value) {
        if (name == null) {
            throw new IllegalArgumentException("Name can't be null!");
        }
        if (value == null) {
            throw new IllegalArgumentException("Value can't be null!");
        }
        if (name.startsWith("${")) {
            throw new IllegalArgumentException("Incorrect name: " + name);
        }
        if (this._variables == null) {
            this._variables = new HashMap<String, Object>(2);
        }
        this._variables.put(name, value);
        return this;
    }

    public HtmlMessage replace(String name, String value) {
        if (name == null) {
            throw new IllegalArgumentException("Name can't be null!");
        }
        if (value == null) {
            throw new IllegalArgumentException("Value can't be null!");
        }
        if (!(name.startsWith("%") && name.endsWith("%") || name.startsWith("<?") && name.endsWith("?>"))) {
            throw new IllegalArgumentException("Incorrect name: " + name);
        }
        if (this._replaces == null) {
            this._replaces = new LinkedHashMap<String, String>(2);
        }
        this._replaces.put(name, value);
        return this;
    }

    public HtmlMessage replace(String name, NpcString npcString) {
        return this.replace(name, HtmlUtils.htmlNpcString(npcString, ArrayUtils.EMPTY_OBJECT_ARRAY));
    }

    public HtmlMessage replace(String name, NpcString npcString, Object ... arg) {
        if (npcString == null) {
            throw new IllegalArgumentException("NpcString can't be null!");
        }
        return this.replace(name, HtmlUtils.htmlNpcString(npcString, arg));
    }

    @Override
    public L2GameServerPacket packet(Player player) {
        CharSequence content = null;
        if (!StringUtils.isEmpty((CharSequence)this._html)) {
            content = this.make(player, this._html);
        } else if (!StringUtils.isEmpty((CharSequence)this._filename)) {
            if (player.isGM()) {
                ChatUtils.sys(player, "HTML", this._filename);
            }
            String htmCache = HtmCache.getInstance().getHtml(this._filename, player);
            content = this.make(player, htmCache);
        } else {
            _log.warn("HtmlMessage: empty dialog" + (this._npc == null ? "!" : " npc id : " + this._npc.getNpcId() + "!"), (Throwable)new Exception());
        }
        if (this._itemId == 0) {
            if (this._npc != null) {
                player.setLastNpc(this._npc);
            }
            content = player.getBypassStorage().parseHtml(content.toString(), BypassStorage.BypassType.DEFAULT, true);
        } else {
            content = player.getBypassStorage().parseHtml(content.toString(), BypassStorage.BypassType.ITEM, true);
        }
        if (StringUtils.isEmpty((CharSequence)content)) {
            return ActionFailPacket.STATIC;
        }
        if (this._questId == 0) {
            return new NpcHtmlMessagePacket(this._npcObjId, this._itemId, this._playVoice, content);
        }
        return new ExNpcQuestHtmlMessage(this._npcObjId, content, this._questId);
    }

    public Map<String, Object> getVariables() {
        return this._variables;
    }

    private CharSequence make(Player player, String content) {
        if (content == null) {
            return "";
        }
        TextStringBuilder sb = new TextStringBuilder(content);
        if (this._replaces != null) {
            for (Map.Entry<String, String> e : this._replaces.entrySet()) {
                sb.replaceAll(e.getKey(), e.getValue());
            }
        }
        Matcher m = ImagesCache.HTML_PATTERN.matcher(content);
        while (m.find()) {
            String imageName = m.group(1);
            int imageId = ImagesCache.getInstance().getImageId(imageName);
            sb.replaceAll("%image:" + imageName + "%", "Crest.pledge_crest_" + Config.REQUEST_ID + "_" + imageId);
            byte[] image = ImagesCache.getInstance().getImage(imageId);
            if (image == null) continue;
            player.sendPacket((IBroadcastPacket)new PledgeCrestPacket(imageId, image));
        }
        sb.replaceAll("%playername%", player.getName());
        if (this._npcObjId != 0) {
            sb.replaceAll("%objectId%", String.valueOf(this._npcObjId));
            if (this._npc != null) {
                sb.replaceAll("%npcId%", String.valueOf(this._npc.getNpcId()));
            }
        }
        content = VelocityUtils.evaluate(sb.toString(), this._variables);
        sb.clear();
        if (!content.startsWith("<html>")) {
            sb.append("<html><body>");
            sb.append(content);
            sb.append("</body></html>");
            return sb;
        }
        return content;
    }
}


/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.apache.commons.lang3.StringUtils
 *  org.apache.commons.text.TextStringBuilder
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.network.l2.components;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.data.string.ItemNameHolder;
import l2s.gameserver.data.string.SkillNameHolder;
import l2s.gameserver.data.string.StringsHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.SystemMessage;
import l2s.gameserver.skills.SkillInfo;
import l2s.gameserver.utils.Language;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.text.TextStringBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CustomMessage
implements IBroadcastPacket {
    private static final Logger _log = LoggerFactory.getLogger(CustomMessage.class);
    private static final String[] PARAMS = new String[]{"{0}", "{1}", "{2}", "{3}", "{4}", "{5}", "{6}", "{7}", "{8}", "{9}"};
    private String _address;
    private List<IArgument> _args;

    public CustomMessage(String address) {
        this._address = address;
    }

    public CustomMessage addString(String text) {
        if (this._args == null) {
            this._args = new ArrayList<IArgument>();
        }
        this._args.add(new StringArgument(text));
        return this;
    }

    public CustomMessage addNumber(int i) {
        return this.addString(String.valueOf(i));
    }

    public CustomMessage addNumber(long l) {
        return this.addString(String.valueOf(l));
    }

    public CustomMessage addCustomMessage(CustomMessage msg) {
        if (msg != this) {
            if (this._args == null) {
                this._args = new ArrayList<IArgument>();
            }
            this._args.add(new CustomMessageArgument(msg));
        }
        return this;
    }

    public CustomMessage addItemName(int itemId) {
        if (this._args == null) {
            this._args = new ArrayList<IArgument>();
        }
        this._args.add(new ItemNameArgument(itemId));
        return this;
    }

    public CustomMessage addSkillName(int skillId, int skillLvl) {
        if (this._args == null) {
            this._args = new ArrayList<IArgument>();
        }
        this._args.add(new SkillNameArgument(skillId, skillLvl));
        return this;
    }

    public CustomMessage addSkillName(SkillInfo skillInfo) {
        return this.addSkillName(skillInfo.getDisplayId(), skillInfo.getDisplayLevel());
    }

    public String toString(Player player) {
        return this.toString(player.getLanguage());
    }

    public String toString(Language lang) {
        TextStringBuilder msg = null;
        String text = StringsHolder.getInstance().getString(this._address, lang);
        if (text != null) {
            msg = new TextStringBuilder(text);
            if (this._args != null) {
                for (int i = 0; i < this._args.size(); ++i) {
                    msg.replaceFirst(PARAMS[i], this._args.get(i).toString(lang));
                }
            }
        }
        if (StringUtils.isEmpty(msg)) {
            _log.warn("CustomMessage: string: " + this._address + " not found for lang: " + (Object)((Object)lang) + "!");
            return "";
        }
        return msg.toString();
    }

    @Override
    public L2GameServerPacket packet(Player player) {
        return new SystemMessage(SystemMsg.S1).addString(this.toString(player));
    }

    private static class SkillNameArgument
    implements IArgument {
        private final int _skillId;
        private final int _skillLvl;

        public SkillNameArgument(int skillId, int skillLvl) {
            this._skillId = skillId;
            this._skillLvl = skillLvl;
        }

        @Override
        public String toString(Language lang) {
            String name = SkillNameHolder.getInstance().getSkillName(lang, this._skillId, this._skillLvl);
            if (name == null) {
                return "null";
            }
            return name;
        }
    }

    private static class ItemNameArgument
    implements IArgument {
        private final int _itemId;

        public ItemNameArgument(int itemId) {
            this._itemId = itemId;
        }

        @Override
        public String toString(Language lang) {
            String name = ItemNameHolder.getInstance().getItemName(lang, this._itemId);
            if (name == null) {
                return "null";
            }
            return name;
        }
    }

    private static class CustomMessageArgument
    implements IArgument {
        private final CustomMessage _customMessage;

        public CustomMessageArgument(CustomMessage customMessage) {
            this._customMessage = customMessage;
        }

        @Override
        public String toString(Language lang) {
            return this._customMessage.toString(lang);
        }
    }

    private static class StringArgument
    implements IArgument {
        private final String _text;

        public StringArgument(String text) {
            this._text = text;
        }

        @Override
        public String toString(Language lang) {
            return this._text;
        }
    }

    private static interface IArgument {
        public String toString(Language var1);
    }
}


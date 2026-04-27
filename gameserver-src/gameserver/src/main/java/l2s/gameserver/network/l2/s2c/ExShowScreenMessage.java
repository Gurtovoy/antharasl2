/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.components.NpcString;
import l2s.gameserver.network.l2.s2c.NpcStringContainer;

public class ExShowScreenMessage
extends NpcStringContainer {
    public static final int SYSMSG_TYPE = 0;
    public static final int STRING_TYPE = 1;
    private int _type;
    private int _sysMessageId;
    private boolean _big_font;
    private boolean _effect;
    private ScreenMessageAlign _text_align;
    private int _time;
    private int _unk;

    public ExShowScreenMessage(String text, int time, ScreenMessageAlign text_align, boolean big_font) {
        this(text, time, text_align, big_font, 1, -1, false);
    }

    public ExShowScreenMessage(String text, int time, ScreenMessageAlign text_align, boolean big_font, int type, int messageId, boolean showEffect) {
        super(NpcString.NONE, text);
        this._type = type;
        this._sysMessageId = messageId;
        this._time = time;
        this._text_align = text_align;
        this._big_font = big_font;
        this._effect = showEffect;
    }

    public ExShowScreenMessage(NpcString t, int time, ScreenMessageAlign text_align, String ... params) {
        this(t, time, text_align, true, 1, -1, false, params);
    }

    public ExShowScreenMessage(NpcString npcString, int time, ScreenMessageAlign text_align, boolean big_font, String ... params) {
        this(npcString, time, text_align, big_font, 1, -1, false, params);
    }

    public ExShowScreenMessage(NpcString npcString, int time, ScreenMessageAlign text_align, boolean big_font, boolean showEffect, String ... params) {
        this(npcString, time, text_align, big_font, 1, -1, showEffect, 0, params);
    }

    public ExShowScreenMessage(NpcString npcString, int time, ScreenMessageAlign text_align, boolean big_font, int type, int systemMsg, boolean showEffect, String ... params) {
        this(npcString, time, text_align, big_font, type, systemMsg, showEffect, 0, params);
    }

    public ExShowScreenMessage(NpcString npcString, int time, ScreenMessageAlign text_align, boolean big_font, int type, int systemMsg, boolean showEffect, int unk, String ... params) {
        super(npcString, params);
        this._type = type;
        this._sysMessageId = systemMsg;
        this._time = time;
        this._text_align = text_align;
        this._big_font = big_font;
        this._effect = showEffect;
        this._unk = unk;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._type);
        this.writeD(this._sysMessageId);
        this.writeD(this._text_align.ordinal() + 1);
        this.writeD(0);
        this.writeD(this._big_font ? 0 : 1);
        this.writeD(0);
        this.writeD(this._unk);
        this.writeD(this._effect ? 1 : 0);
        this.writeD(this._time);
        this.writeD(1);
        this.writeElements();
    }

    public static enum ScreenMessageAlign {
        TOP_LEFT,
        TOP_CENTER,
        TOP_RIGHT,
        MIDDLE_LEFT,
        MIDDLE_CENTER,
        MIDDLE_RIGHT,
        BOTTOM_CENTER,
        BOTTOM_RIGHT;

    }
}


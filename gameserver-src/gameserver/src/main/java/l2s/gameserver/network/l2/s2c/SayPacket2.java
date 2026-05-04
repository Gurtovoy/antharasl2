/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.components.ChatType;
import l2s.gameserver.network.l2.components.NpcString;
import l2s.gameserver.network.l2.components.SysString;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.NpcStringContainer;

public class SayPacket2
extends NpcStringContainer {
    private static final int IS_FRIEND = 1;
    private static final int IS_CLAN_MEMBER = 2;
    private static final int IS_MENTEE_OR_MENTOR = 4;
    private static final int IS_ALLIANCE_MEMBER = 8;
    private static final int IS_GM = 16;
    private ChatType _type;
    private SysString _sysString;
    private SystemMsg _systemMsg;
    private int _objectId;
    private String _charName;
    private int _mask;
    private int _charLevel = -1;
    private String _text;

    public SayPacket2(int objectId, ChatType type, SysString st, SystemMsg sm) {
        super(NpcString.NONE, new String[0]);
        this._objectId = objectId;
        this._type = type;
        this._sysString = st;
        this._systemMsg = sm;
    }

    public SayPacket2(int objectId, ChatType type, String charName, String text) {
        this(objectId, type, charName, NpcString.NONE, text);
    }

    public SayPacket2(int objectId, ChatType type, String charName, NpcString npcString, String ... params) {
        super(npcString, params);
        this._objectId = objectId;
        this._type = type;
        this._charName = charName;
        this._text = params.length > 0 ? params[0] : null;
    }

    public void setCharName(String name) {
        this._charName = name;
    }

    public void setSenderInfo(Player sender, Player receiver) {
        this._charLevel = sender.getLevel();
        if (receiver.getFriendList().contains(sender.getObjectId())) {
            this._mask |= 1;
        }
        if (receiver.getClanId() > 0 && receiver.getClanId() == sender.getClanId()) {
            this._mask |= 2;
        }
        if (receiver.getAllyId() > 0 && receiver.getAllyId() == sender.getAllyId()) {
            this._mask |= 8;
        }
        if (sender.isGM()) {
            this._mask |= 0x10;
        }
    }

    @Override
    protected final void writeImpl() {
        Player player;
        this.writeD(this._objectId);
        this.writeD(this._type.ordinal());
        switch (this._type) {
            case SYSTEM_MESSAGE: {
                this.writeD(this._sysString.getId());
                this.writeD(this._systemMsg.getId());
                break;
            }
            case TELL: {
                this.writeS(this._charName);
                this.writeElements();
                this.writeC(this._mask);
                if ((this._mask & 0x10) != 0) break;
                this.writeC(this._charLevel);
                break;
            }
            case CLAN: 
            case ALLIANCE: {
                this.writeS(this._charName);
                this.writeElements();
                this.writeC(0);
                break;
            }
            default: {
                this.writeS(this._charName);
                this.writeElements();
            }
        }
        if (this._text != null && (player = ((GameClient)this.getClient()).getActiveChar()) != null) {
            player.getListeners().onChatMessageReceive(this._type, this._charName, this._text);
        }
    }
}


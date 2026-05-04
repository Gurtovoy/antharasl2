package l2s.gameserver.handler.chat;

import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.handler.chat.IChatHandler;
import l2s.gameserver.network.l2.components.ChatType;

public class ChatHandler
extends AbstractHolder {
    private static final ChatHandler _instance = new ChatHandler();
    private IChatHandler[] _handlers = new IChatHandler[ChatType.VALUES.length];

    public static ChatHandler getInstance() {
        return _instance;
    }

    private ChatHandler() {
    }

    public void register(IChatHandler chatHandler) {
        this._handlers[chatHandler.getType().ordinal()] = chatHandler;
    }

    public IChatHandler getHandler(ChatType type) {
        return this._handlers[type.ordinal()];
    }

    public int size() {
        return this._handlers.length;
    }

    public void clear() {
    }
}


package l2s.gameserver.handler.chat;

import l2s.gameserver.network.l2.components.ChatType;

public interface IChatHandler {
    public void say();

    public ChatType getType();
}


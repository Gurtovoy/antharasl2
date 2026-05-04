package l2s.gameserver.handler.bbs;

import l2s.gameserver.model.Player;

public interface IBbsHandler {
    public String[] getBypassCommands();

    public void onBypassCommand(Player var1, String var2);

    public void onWriteCommand(Player var1, String var2, String var3, String var4, String var5, String var6, String var7);
}


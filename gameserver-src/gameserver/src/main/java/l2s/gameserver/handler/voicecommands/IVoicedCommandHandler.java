/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.handler.voicecommands;

import l2s.gameserver.model.Player;

public interface IVoicedCommandHandler {
    public boolean useVoicedCommand(String var1, Player var2, String var3);

    public String[] getVoicedCommandList();
}


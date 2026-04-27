/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.handler.voicecommands;

import l2s.gameserver.model.Player;

public interface IVoicedCommandHandler {
    public boolean useVoicedCommand(String var1, Player var2, String var3);

    public String[] getVoicedCommandList();
}


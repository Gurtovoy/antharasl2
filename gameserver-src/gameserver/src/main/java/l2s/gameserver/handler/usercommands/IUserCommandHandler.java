/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.handler.usercommands;

import l2s.gameserver.model.Player;

public interface IUserCommandHandler {
    public boolean useUserCommand(int var1, Player var2);

    public int[] getUserCommandList();
}


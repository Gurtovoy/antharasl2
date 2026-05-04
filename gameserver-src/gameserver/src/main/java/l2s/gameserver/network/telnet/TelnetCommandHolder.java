/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.telnet;

import java.util.Set;
import l2s.gameserver.network.telnet.TelnetCommand;

public interface TelnetCommandHolder {
    public Set<TelnetCommand> getCommands();
}


/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.telnet;

import org.apache.commons.lang3.ArrayUtils;

public abstract class TelnetCommand
implements Comparable<TelnetCommand> {
    private final String command;
    private final String[] acronyms;

    public TelnetCommand(String command) {
        this(command, ArrayUtils.EMPTY_STRING_ARRAY);
    }

    public TelnetCommand(String command, String ... acronyms) {
        this.command = command;
        this.acronyms = acronyms;
    }

    public String getCommand() {
        return this.command;
    }

    public String[] getAcronyms() {
        return this.acronyms;
    }

    public abstract String getUsage();

    public abstract String handle(String[] var1);

    public boolean equals(String command) {
        for (String acronym : this.acronyms) {
            if (!command.equals(acronym)) continue;
            return true;
        }
        return this.command.equalsIgnoreCase(command);
    }

    public String toString() {
        return this.command;
    }

    public boolean equals(Object o) {
        if (o == this) {
            return true;
        }
        if (o == null) {
            return true;
        }
        if (o instanceof TelnetCommand) {
            return this.command.equals(((TelnetCommand)o).command);
        }
        return false;
    }

    @Override
    public int compareTo(TelnetCommand o) {
        return this.command.compareTo(o.command);
    }
}


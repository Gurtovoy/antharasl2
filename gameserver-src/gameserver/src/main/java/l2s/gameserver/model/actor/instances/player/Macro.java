package l2s.gameserver.model.actor.instances.player;

import java.util.concurrent.atomic.AtomicInteger;

public class Macro {
    private final AtomicInteger id;
    private final int icon;
    private final String name;
    private final String descr;
    private final String acronym;
    private final L2MacroCmd[] commands;
    private final boolean enabled;

    public Macro(int id, int icon, String name, String descr, String acronym, L2MacroCmd[] commands, boolean enabled) {
        this.id = new AtomicInteger(id);
        this.icon = icon;
        this.name = name;
        this.descr = descr;
        this.acronym = acronym.length() > 4 ? acronym.substring(0, 4) : acronym;
        this.commands = commands;
        this.enabled = enabled;
    }

    public Macro(int id, int icon, String name, String descr, String acronym, L2MacroCmd[] commands) {
        this(id, icon, name, descr, acronym, commands, true);
    }

    public int getId() {
        return this.id.get();
    }

    public void incrementId() {
        this.id.incrementAndGet();
    }

    public int getIcon() {
        return this.icon;
    }

    public String getName() {
        return this.name;
    }

    public String getDescr() {
        return this.descr;
    }

    public String getAcronym() {
        return this.acronym;
    }

    public L2MacroCmd[] getCommands() {
        return this.commands;
    }

    public boolean isEnabled() {
        return this.enabled;
    }

    public String toString() {
        return "macro id=" + this.id + " icon=" + this.icon + "name=" + this.name + " descr=" + this.descr + " acronym=" + this.acronym + " commands=" + this.commands;
    }

    public static class L2MacroCmd {
        private final int entry;
        private final int type;
        private final int param1;
        private final int param2;
        private final String cmd;

        public L2MacroCmd(int entry, int type, int param1, int param2, String cmd) {
            this.entry = entry;
            this.type = type;
            this.param1 = param1;
            this.param2 = param2;
            this.cmd = cmd;
        }

        public int getEntry() {
            return this.entry;
        }

        public int getType() {
            return this.type;
        }

        public int getParam1() {
            return this.param1;
        }

        public int getParam2() {
            return this.param2;
        }

        public String getCmd() {
            return this.cmd;
        }
    }

    public static enum MacroCmdType {
        NONE,
        SKILL,
        ACTION,
        TEXT,
        SHORTCUT,
        ITEM,
        DELAY;

        public static final MacroCmdType[] VALUES;

        static {
            VALUES = MacroCmdType.values();
        }
    }
}


package l2s.gameserver.handler.admincommands.impl;

import java.io.File;
import java.util.Iterator;
import java.util.List;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.handler.admincommands.IAdminCommandHandler;
import l2s.gameserver.model.Player;
import l2s.gameserver.scripts.Scripts;
import org.apache.commons.lang3.ClassUtils;

public class AdminScripts
implements IAdminCommandHandler {
    @Override
    public boolean useAdminCommand(Enum<?> comm, String[] wordList, String fullString, Player activeChar) {
        Commands command = (Commands)comm;
        if (!activeChar.getPlayerAccess().CanReload) {
            return false;
        }
        switch (command) {
            case admin_run_script: 
            case admin_runs: {
                if (wordList.length < 2) {
                    return false;
                }
                String param = wordList[1];
                if (!this.run(param)) {
                    activeChar.sendMessage("Can't run script.");
                    break;
                }
                activeChar.sendMessage("Running script...");
            }
        }
        return true;
    }

    private boolean run(String target) {
        File file = new File(Config.DATAPACK_ROOT, "data/scripts/" + target.replace(".", "/") + ".java");
        if (!file.exists()) {
            return false;
        }
        List<Class<?>> classes = Scripts.getInstance().load(file);
        Iterator<Class<?>> iterator = classes.iterator();
        if (iterator.hasNext()) {
            Runnable r;
            Class<?> clazz = iterator.next();
            if (!ClassUtils.isAssignable(clazz, Runnable.class)) {
                return false;
            }
            try {
                r = (Runnable)clazz.newInstance();
            }
            catch (Exception e) {
                return false;
            }
            ThreadPoolManager.getInstance().execute(r);
            return true;
        }
        return false;
    }

    @Override
    public Enum<?>[] getAdminCommandEnum() {
        return Commands.values();
    }

    private static enum Commands {
        admin_run_script,
        admin_runs;

    }
}


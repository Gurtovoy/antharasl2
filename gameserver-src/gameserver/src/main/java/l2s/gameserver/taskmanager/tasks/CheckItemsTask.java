package l2s.gameserver.taskmanager.tasks;

import java.util.concurrent.TimeUnit;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.PetInstance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.tables.ClanTable;
import l2s.gameserver.taskmanager.tasks.AutomaticTask;

public class CheckItemsTask
extends AutomaticTask {
    private static final long TASK_DELAY = TimeUnit.MINUTES.toMillis(1L);

    @Override
    public void doTask() {
        for (Player player : GameObjectsStorage.getPlayers(true, true)) {
            player.getInventory().checkItems();
            PetInstance pet = player.getPet();
            if (pet != null) {
                pet.getInventory().checkItems();
            }
            player.getWarehouse().checkItems();
        }
        for (Clan clan : ClanTable.getInstance().getClans()) {
            clan.getWarehouse().checkItems();
        }
    }

    @Override
    public long reCalcTime(boolean start) {
        return System.currentTimeMillis() + TASK_DELAY;
    }
}


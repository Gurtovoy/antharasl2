package l2s.gameserver.model.quest.startcondition.impl;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.Race;
import l2s.gameserver.model.quest.startcondition.ICheckStartCondition;

public class PlayerRaceCondition
implements ICheckStartCondition {
    private final boolean _classRace;
    private final List<Race> _races = new ArrayList<Race>(Race.VALUES.length);

    public PlayerRaceCondition(boolean human, boolean elf, boolean delf, boolean orc, boolean dwarf) {
        this._classRace = false;
        if (human) {
            this._races.add(Race.HUMAN);
        }
        if (elf) {
            this._races.add(Race.ELF);
        }
        if (delf) {
            this._races.add(Race.DARKELF);
        }
        if (orc) {
            this._races.add(Race.ORC);
        }
        if (dwarf) {
            this._races.add(Race.DWARF);
        }
    }

    public PlayerRaceCondition(boolean classRace, Race[] races) {
        this._classRace = classRace;
        for (Race race : races) {
            this._races.add(race);
        }
    }

    @Override
    public boolean checkCondition(Player player) {
        if (this._races.isEmpty()) {
            return true;
        }
        Race race = player.getClassId().getRace();
        if (!this._classRace || race == null) {
            race = player.getRace();
        }
        return this._races.contains(race);
    }
}


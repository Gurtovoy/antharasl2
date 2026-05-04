/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity;

import l2s.commons.util.Rnd;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.utils.NpcUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class MonsterRace {
    private static final Logger _log = LoggerFactory.getLogger(MonsterRace.class);
    private NpcInstance[] monsters = new NpcInstance[8];
    private static MonsterRace _instance;
    private int[][] speeds = new int[8][20];
    private int[] first = new int[2];
    private int[] second = new int[2];

    private MonsterRace() {
    }

    public static MonsterRace getInstance() {
        if (_instance == null) {
            _instance = new MonsterRace();
        }
        return _instance;
    }

    public void newRace() {
        int random = 0;
        for (int i = 0; i < 8; ++i) {
            int id = 31003;
            random = Rnd.get((int)24);
            for (int j = i - 1; j >= 0; --j) {
                if (this.monsters[j].getNpcId() != id + random) continue;
                random = Rnd.get((int)24);
            }
            try {
                this.monsters[i] = NpcUtils.newInstance(id + random);
                continue;
            }
            catch (Exception e) {
                _log.error("", (Throwable)e);
            }
        }
        this.newSpeeds();
    }

    public void newSpeeds() {
        this.speeds = new int[8][20];
        int total = 0;
        this.first[1] = 0;
        this.second[1] = 0;
        for (int i = 0; i < 8; ++i) {
            total = 0;
            for (int j = 0; j < 20; ++j) {
                this.speeds[i][j] = j == 19 ? 100 : Rnd.get((int)65, (int)124);
                total += this.speeds[i][j];
            }
            if (total >= this.first[1]) {
                this.second[0] = this.first[0];
                this.second[1] = this.first[1];
                this.first[0] = 8 - i;
                this.first[1] = total;
                continue;
            }
            if (total < this.second[1]) continue;
            this.second[0] = 8 - i;
            this.second[1] = total;
        }
    }

    public NpcInstance[] getMonsters() {
        return this.monsters;
    }

    public int[][] getSpeeds() {
        return this.speeds;
    }

    public int getFirstPlace() {
        return this.first[0];
    }

    public int getSecondPlace() {
        return this.second[0];
    }
}


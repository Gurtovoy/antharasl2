/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.util.AbstractMap;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import l2s.gameserver.instancemanager.games.MiniGameScoreManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.TreeIntObjectMap;
import org.napile.primitive.pair.IntObjectPair;

public class ExBR_MiniGameLoadScores
extends L2GameServerPacket {
    private int _place;
    private int _score;
    private int _lastScore;
    private IntObjectMap<List<Map.Entry<String, Integer>>> _entries = new TreeIntObjectMap();

    public ExBR_MiniGameLoadScores(Player player) {
        int lastBig = 0;
        int i = 1;
        block0: for (IntObjectPair entry : MiniGameScoreManager.getInstance().getScores().entrySet()) {
            for (String name : (Set<String>)entry.getValue()) {
                List<Map.Entry<String, Integer>> set = (List<Map.Entry<String, Integer>>)this._entries.get(i);
                if (set == null) {
                    set = new ArrayList<Map.Entry<String, Integer>>();
                    this._entries.put(i, set);
                }
                if (name.equalsIgnoreCase(player.getName()) && entry.getKey() > lastBig) {
                    this._place = i;
                    this._score = lastBig = entry.getKey();
                }
                set.add(new AbstractMap.SimpleImmutableEntry<String, Integer>(name, entry.getKey()));
                this._lastScore = entry.getKey();
                if (++i <= 100) continue;
                continue block0;
            }
        }
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._place);
        this.writeD(this._score);
        this.writeD(0);
        this.writeD(this._lastScore);
        for (IntObjectPair entry : this._entries.entrySet()) {
            for (Map.Entry<String, Integer> scoreEntry : (List<Map.Entry<String, Integer>>)entry.getValue()) {
                this.writeD(entry.getKey());
                this.writeS((CharSequence)scoreEntry.getKey());
                this.writeD((Integer)scoreEntry.getValue());
            }
        }
    }
}


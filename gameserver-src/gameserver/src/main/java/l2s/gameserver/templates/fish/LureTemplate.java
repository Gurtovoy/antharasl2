package l2s.gameserver.templates.fish;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.templates.fish.FishTemplate;

public final class LureTemplate {
    private final int _id;
    private final List<FishTemplate> _fishes = new ArrayList<FishTemplate>();

    public LureTemplate(int id, double failChance, int failDuration) {
        this._id = id;
        if (failChance > 0.0 && failDuration > 0) {
            this._fishes.add(new FishTemplate(0, failChance, failDuration, 0));
        }
    }

    public int getId() {
        return this._id;
    }

    public void addFish(FishTemplate fish) {
        this._fishes.add(fish);
    }

    public List<FishTemplate> getFishes() {
        return this._fishes;
    }
}


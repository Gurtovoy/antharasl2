/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.taskmanager;

import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.model.Creature;

public final class MovementController {
    private static final MovementController _instance = new MovementController();
    private final Set<Creature> _movingCreatures = ConcurrentHashMap.newKeySet();

    public static MovementController getInstance() {
        return _instance;
    }

    protected MovementController() {
        ThreadPoolManager.getInstance().scheduleAtFixedRate(this::run, 100L, 100L, TimeUnit.MILLISECONDS);
    }

    public void registerMovement(Creature creature) {
        this._movingCreatures.add(creature);
    }

    public void removeMovement(Creature creature) {
        this._movingCreatures.remove(creature);
    }

    public boolean isMoving(Creature creature) {
        return this._movingCreatures.contains(creature);
    }

    public void run() {
        this._movingCreatures.removeIf(creature -> creature.getMovement().updatePosition());
    }
}


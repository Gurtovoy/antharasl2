package l2s.gameserver.model.entity.events.objects;

import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.atomic.AtomicInteger;
import l2s.gameserver.model.Player;

public class PvPEventPlayerObject {
    private final Player player;
    private final int team;
    private AtomicInteger countDie;
    private AtomicInteger points;
    private boolean teleport;
    private ScheduledFuture<?> scheduled = null;

    public PvPEventPlayerObject(Player player, int team) {
        this.player = player;
        this.team = team;
        this.countDie = new AtomicInteger(0);
        this.points = new AtomicInteger(0);
    }

    public Player getPlayer() {
        return this.player;
    }

    public int getTeam() {
        return this.team;
    }

    public void addCountDie() {
        this.countDie.getAndAdd(1);
    }

    public int getCountDie() {
        return this.countDie.get();
    }

    public void addPoint() {
        this.points.getAndAdd(1);
    }

    public int getPoints() {
        return this.points.get();
    }

    public boolean isTeleport() {
        return this.teleport;
    }

    public void setTeleport(boolean teleport) {
        this.teleport = teleport;
    }

    public ScheduledFuture<?> getScheduled() {
        return this.scheduled;
    }

    public void setScheduled(ScheduledFuture<?> scheduled) {
        this.stopScheduled();
        this.scheduled = scheduled;
    }

    public void stopScheduled() {
        if (this.scheduled != null) {
            this.scheduled.cancel(false);
            this.scheduled = null;
        }
    }
}


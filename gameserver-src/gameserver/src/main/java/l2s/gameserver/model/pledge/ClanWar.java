/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.pledge;

import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.tables.ClanTable;
import l2s.gameserver.utils.Log;
import l2s.gameserver.utils.TimeUtils;

public class ClanWar {
    public static final long PREPARATION_PERIOD_DURATION = TimeUnit.MILLISECONDS.convert(Config.CLAN_WAR_PREPARATION_DAYS_PERIOD, TimeUnit.DAYS);
    public static final long INACTIVITY_TIME_DURATION = TimeUnit.MILLISECONDS.convert(Config.CLAN_WAR_INACTIVITY_DAYS_PERIOD, TimeUnit.DAYS);
    public static final long PEACE_DURATION = TimeUnit.MILLISECONDS.convert(Config.CLAN_WAR_PEACE_DAYS_PERIOD, TimeUnit.DAYS);
    private final Clan _attackerClan;
    private final Clan _attackedClan;
    private ClanWarPeriod _period;
    private int _currentPeriodStartTime;
    private int _lastKillTime;
    private Future<?> _currentPeriodTask;
    private AtomicInteger _attackersKillCounter = new AtomicInteger();
    private AtomicInteger _attackedKillCounter = new AtomicInteger();

    public ClanWar(Clan attackerClan, Clan attackedClan, ClanWarPeriod period, int currentPeriodStartTime, int lastKillTime, int attackersKillCounter, int attackedKillCounter) {
        this._attackerClan = attackerClan;
        this._attackedClan = attackedClan;
        this._period = period;
        this._currentPeriodStartTime = currentPeriodStartTime;
        this._lastKillTime = lastKillTime;
        this._attackersKillCounter.set(attackersKillCounter);
        this._attackedKillCounter.set(attackedKillCounter);
        this._attackerClan.addWar(this._attackedClan.getClanId(), this);
        this._attackedClan.addWar(this._attackerClan.getClanId(), this);
    }

    public void onKill(Player killer, Player victim) {
        Clan killerClan = killer.getClan();
        if (killerClan == null) {
            return;
        }
        Clan victimClan = victim.getClan();
        if (victimClan == null) {
            return;
        }
        if (this.getOpposingClan(killerClan) != victimClan) {
            return;
        }
        if (this._period == ClanWarPeriod.MUTUAL) {
            if (victimClan.getReputationScore() > 0) {
                killerClan.incReputation(Config.CLAN_WAR_REPUTATION_SCORE_PER_KILL, false, "ClanWar");
            }
            if (killerClan.getReputationScore() > 0) {
                victimClan.incReputation(-Config.CLAN_WAR_REPUTATION_SCORE_PER_KILL, false, "ClanWar");
            }
            this._lastKillTime = (int)(System.currentTimeMillis() / 1000L);
            if (this.isAttacker(killerClan)) {
                this._attackersKillCounter.incrementAndGet();
            } else if (this.isAttacked(killerClan)) {
                this._attackedKillCounter.incrementAndGet();
            }
            this.save(false);
            victimClan.broadcastToOnlineMembers(new IBroadcastPacket[]{((SystemMessagePacket)new SystemMessagePacket(SystemMsg.BECAUSE_C1_WAS_KILLED_BY_A_CLAN_MEMBER_OF_S2_CLAN_REPUTATION_DECREASED_BY_1).addName(victim)).addString(killerClan.getName())});
            killerClan.broadcastToOnlineMembers(new IBroadcastPacket[]{((SystemMessagePacket)new SystemMessagePacket(SystemMsg.BECAUSE_A_CLAN_MEMBER_OF_S1_WAS_KILLED_BY_C2_CLAN_REPUTATION_INCREASED_BY_1).addString(victimClan.getName())).addName(killer)});
        } else if (this._period == ClanWarPeriod.PREPARATION && this.isAttacker(victimClan) && !victim.isPK()) {
            int killCount = this._attackedKillCounter.incrementAndGet();
            if (killCount < Config.CLAN_WAR_KILLS_COUNT_TO_CONFIRM_MUTUAL_WAR) {
                SystemMessagePacket sm = new SystemMessagePacket(SystemMsg.A_CLAN_MEMBER_OF_S1_WAS_KILLED_BY_YOUR_CLAN_MEMBER_IF_YOUR_CLAN_KILLS_S2_MEMBERS_OF_CLAN_S1_A_CLAN_WAR_WITH_CLAN_S1_WILL_START);
                sm.addString(victimClan.getName());
                sm.addInteger(Config.CLAN_WAR_KILLS_COUNT_TO_CONFIRM_MUTUAL_WAR - killCount);
                killerClan.broadcastToOnlineMembers(sm);
                this.save(false);
            } else {
                this.setPeriod(ClanWarPeriod.MUTUAL);
            }
        }
    }

    public int getPointDiff(Clan clan) {
        return this.isAttacker(clan) ? this.getAttackersKillCounter() - this.getAttackedKillCounter() : (this.isAttacked(clan) ? this.getAttackedKillCounter() - this.getAttackersKillCounter() : 0);
    }

    public WarProgress calculateWarProgress(Clan clan) {
        int pointDiff = this.getPointDiff(clan);
        if (pointDiff <= -50) {
            return WarProgress.VERY_LOW;
        }
        if (pointDiff > -50 && pointDiff <= -20) {
            return WarProgress.LOW;
        }
        if (pointDiff > -20 && pointDiff <= 19) {
            return WarProgress.NORMAL;
        }
        if (pointDiff > 19 && pointDiff <= 49) {
            return WarProgress.HIGH;
        }
        return WarProgress.VERY_HIGH;
    }

    public ClanWarState getClanWarState(Clan clan) {
        if (this._period == ClanWarPeriod.PREPARATION) {
            return ClanWarState.PREPARATION;
        }
        if (this._period == ClanWarPeriod.MUTUAL) {
            return ClanWarState.MUTUAL;
        }
        if (this._period == ClanWarPeriod.PEACE) {
            int points = this.getPointDiff(clan);
            if (points == 0) {
                return ClanWarState.TIE;
            }
            if (points < 0) {
                return ClanWarState.LOSS;
            }
            return ClanWarState.WIN;
        }
        return ClanWarState.REJECTED;
    }

    public boolean isAttacker(Clan clan) {
        return this._attackerClan == clan;
    }

    public boolean isAttacked(Clan clan) {
        return this._attackedClan == clan;
    }

    public Clan getAttackerClan() {
        return this._attackerClan;
    }

    public Clan getAttackedClan() {
        return this._attackedClan;
    }

    public int getAttackerClanId() {
        return this._attackerClan.getClanId();
    }

    public int getAttackedClanId() {
        return this._attackedClan.getClanId();
    }

    public Clan getOpposingClan(Clan clan) {
        return this.isAttacker(clan) ? this._attackedClan : (this.isAttacked(clan) ? this._attackerClan : null);
    }

    public int getAttackersKillCounter() {
        return this._attackersKillCounter.get();
    }

    public int getAttackedKillCounter() {
        return this._attackedKillCounter.get();
    }

    public int getLastKillTime() {
        return this._lastKillTime;
    }

    public int getKillToStart() {
        return this._period == ClanWarPeriod.PREPARATION ? Config.CLAN_WAR_KILLS_COUNT_TO_CONFIRM_MUTUAL_WAR - this.getAttackedKillCounter() : 0;
    }

    public ClanWarPeriod getPeriod() {
        return this._period;
    }

    public int getPeriodDuration() {
        switch (this._period) {
            case PREPARATION: {
                long clientCorrection = TimeUnit.MILLISECONDS.convert(7L, TimeUnit.DAYS) - PREPARATION_PERIOD_DURATION;
                return (int)((System.currentTimeMillis() + clientCorrection) / 1000L - (long)this._currentPeriodStartTime);
            }
            case PEACE: {
                long clientCorrection = TimeUnit.MILLISECONDS.convert(5L, TimeUnit.DAYS) - PEACE_DURATION;
                return (int)((System.currentTimeMillis() + clientCorrection) / 1000L - (long)this._currentPeriodStartTime);
            }
        }
        return 0;
    }

    public int getCurrentPeriodStartTime() {
        return this._currentPeriodStartTime;
    }

    public void restore() {
        this.onChange();
    }

    public boolean start() {
        if (this._period == ClanWarPeriod.NEW) {
            this._period = ClanWarPeriod.PREPARATION;
            this.getAttackerClan().broadcastClanStatus(false, false, true);
            this.getAttackerClan().broadcastToOnlineMembers(new IBroadcastPacket[]{new SystemMessagePacket(SystemMsg.YOU_HAVE_DECLARED_A_CLAN_WAR_WITH_S1).addString(this.getAttackedClan().getName())});
            this.getAttackedClan().broadcastClanStatus(false, false, true);
            this.getAttackedClan().broadcastToOnlineMembers(new IBroadcastPacket[]{new SystemMessagePacket(SystemMsg.S1_HAS_DECLARED_A_CLAN_WAR_THE_WAR_WILL_AUTOMATICALLY_START_IF_YOU_KILL_S1_CLAN_MEMBERS_5_TIMES_WITHIN_A_WEEK).addString(this.getAttackerClan().getName())});
            this.onChange();
            return true;
        }
        return false;
    }

    public void accept(Clan requestor) {
        if (this.isAttacked(requestor)) {
            this.setPeriod(ClanWarPeriod.MUTUAL);
        }
    }

    public void cancel(Clan requester) {
        Clan winnerClan = this.getOpposingClan(requester);
        if (Config.CLAN_WAR_CANCEL_REPUTATION_PENALTY > 0) {
            requester.incReputation(-Config.CLAN_WAR_CANCEL_REPUTATION_PENALTY, true, "ClanWar");
        }
        requester.broadcastToOnlineMembers(new IBroadcastPacket[]{new SystemMessagePacket(SystemMsg.YOU_HAVE_SURRENDERED_TO_THE_S1_CLAN).addString(winnerClan.getName())});
        winnerClan.broadcastToOnlineMembers(new IBroadcastPacket[]{new SystemMessagePacket(SystemMsg.YOU_HAVE_WON_THE_WAR_OVER_THE_S1_CLAN).addString(requester.getName())});
        this.setPeriod(ClanWarPeriod.PEACE);
    }

    public void setPeriod(ClanWarPeriod period) {
        if (this._period == period) {
            return;
        }
        if (this._period == ClanWarPeriod.MUTUAL && period == ClanWarPeriod.PREPARATION) {
            Log.add("Cannot change clan war period from mutual (when both sides fighting) to preparation.", "ClanWar");
        }
        this._period = period;
        this._currentPeriodStartTime = (int)(System.currentTimeMillis() / 1000L);
        if (period == ClanWarPeriod.MUTUAL) {
            this.getAttackerClan().broadcastClanStatus(false, false, true);
            this.getAttackerClan().broadcastToOnlineMembers(new IBroadcastPacket[]{new SystemMessagePacket(SystemMsg.A_CLAN_WAR_WITH_CLAN_S1_HAS_STARTED).addString(this.getAttackedClan().getName())});
            this.getAttackedClan().broadcastClanStatus(false, false, true);
            this.getAttackedClan().broadcastToOnlineMembers(new IBroadcastPacket[]{new SystemMessagePacket(SystemMsg.A_CLAN_WAR_WITH_CLAN_S1_HAS_STARTED).addString(this.getAttackerClan().getName())});
        } else if (period == ClanWarPeriod.PEACE) {
            this.getAttackerClan().broadcastClanStatus(false, false, true);
            this.getAttackerClan().broadcastToOnlineMembers(new IBroadcastPacket[]{new SystemMessagePacket(SystemMsg.WAR_WITH_THE_S1_CLAN_HAS_ENDED).addString(this.getAttackedClan().getName())});
            this.getAttackedClan().broadcastClanStatus(false, false, true);
            this.getAttackedClan().broadcastToOnlineMembers(new IBroadcastPacket[]{new SystemMessagePacket(SystemMsg.WAR_WITH_THE_S1_CLAN_HAS_ENDED).addString(this.getAttackerClan().getName())});
        }
        this.onChange();
    }

    private void onChange() {
        if (this._currentPeriodTask != null) {
            this._currentPeriodTask.cancel(true);
            this._currentPeriodTask = null;
        }
        if (this._period == ClanWarPeriod.PREPARATION) {
            long mutualPeriodStartTime = Math.max(0L, PREPARATION_PERIOD_DURATION - (System.currentTimeMillis() - (long)this._currentPeriodStartTime * 1000L));
            this._currentPeriodTask = ThreadPoolManager.getInstance().schedule(() -> this.setPeriod(ClanWarPeriod.MUTUAL), mutualPeriodStartTime);
            if (mutualPeriodStartTime > 0L) {
                Log.add("Clan war between clans with ID " + this.getAttackerClan().getClanId() + " and " + this.getAttackedClan().getClanId() + " in preparation mode. Scheduled for mutual period at " + TimeUtils.toSimpleFormat(System.currentTimeMillis() + mutualPeriodStartTime), "ClanWar");
            }
        } else if (this._period == ClanWarPeriod.MUTUAL) {
            long taskDelay = TimeUnit.MILLISECONDS.convert(1L, TimeUnit.HOURS);
            this._currentPeriodTask = ThreadPoolManager.getInstance().scheduleAtFixedRate(() -> {
                long lastKillTimeDuration = System.currentTimeMillis() - (long)this._lastKillTime * 1000L;
                if (lastKillTimeDuration > INACTIVITY_TIME_DURATION) {
                    this.setPeriod(ClanWarPeriod.PEACE);
                }
            }, taskDelay, taskDelay);
            if (this._lastKillTime > 0) {
                Log.add("Last kill in clan war between clans with ID " + this.getAttackerClan().getClanId() + " and " + this.getAttackedClan().getClanId() + " wat at " + TimeUtils.toSimpleFormat((long)this._lastKillTime * 1000L) + ". Scheduled inactivity check per each hour.", "ClanWar");
            } else {
                Log.add("Last kill in clan war between clans with ID " + this.getAttackerClan().getClanId() + " and " + this.getAttackedClan().getClanId() + " has never happened. Scheduled inactivity check per each hour.", "ClanWar");
            }
        } else if (this._period == ClanWarPeriod.PEACE) {
            long peaceDurationRemain = Math.max(0L, PEACE_DURATION - (System.currentTimeMillis() - (long)this._currentPeriodStartTime * 1000L));
            this._currentPeriodTask = ThreadPoolManager.getInstance().schedule(() -> {
                this.getAttackerClan().deleteWar(this.getAttackedClanId());
                this.getAttackedClan().deleteWar(this.getAttackerClanId());
                ClanTable.getInstance().deleteClanWar(this);
            }, peaceDurationRemain);
            if (peaceDurationRemain > 0L) {
                Log.add("Clan war between clans " + this.getAttackerClan().getName() + " and " + this.getAttackedClan().getName() + " has end. CW scheduled for deletion at " + TimeUtils.toSimpleFormat(System.currentTimeMillis() + peaceDurationRemain) + ".", "ClanWar");
            }
        }
        this.save(true);
    }

    private void save(boolean force) {
        ClanTable.getInstance().storeClanWar(this, force);
    }

    public static enum ClanWarPeriod {
        NEW,
        PREPARATION,
        MUTUAL,
        PEACE;

    }

    public static enum WarProgress {
        VERY_LOW,
        LOW,
        NORMAL,
        HIGH,
        VERY_HIGH;

    }

    public static enum ClanWarState {
        PREPARATION,
        REJECTED,
        MUTUAL,
        WIN,
        LOSS,
        TIE;

    }
}


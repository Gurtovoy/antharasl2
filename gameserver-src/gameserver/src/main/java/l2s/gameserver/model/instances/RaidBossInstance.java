package l2s.gameserver.model.instances;

import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import l2s.commons.collections.MultiValueSet;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.ai.CtrlEvent;
import l2s.gameserver.data.QuestHolder;
import l2s.gameserver.data.xml.holder.NpcHolder;
import l2s.gameserver.idfactory.IdFactory;
import l2s.gameserver.instancemanager.RaidBossSpawnManager;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.entity.Hero;
import l2s.gameserver.model.instances.MonsterInstance;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.quest.Quest;
import l2s.gameserver.model.quest.QuestState;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.NpcString;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExShowScreenMessage;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.npc.NpcTemplate;
import l2s.gameserver.utils.ItemFunctions;
import l2s.gameserver.utils.NpcUtils;

public class RaidBossInstance
extends MonsterInstance {
    private static final int RAID_BERSERK_SKILL_ID = 15458;
    private ScheduledFuture<?> _raidBerserkTask = null;
    private final boolean _canRaidBerserk = this.getParameter("can_raid_berserk", !this.isBoss() && !this.isReflectionBoss());
    private final boolean _spawnDeathKnight = this.getParameter("spawn_death_knight", true);

    public RaidBossInstance(int objectId, NpcTemplate template, MultiValueSet<String> set) {
        super(objectId, template, set);
    }

    @Override
    public boolean isRaid() {
        return true;
    }

    @Override
    public double getRewardRate(Player player) {
        return Config.RATE_DROP_ITEMS_RAIDBOSS;
    }

    @Override
    public double getDropChanceMod(Player player) {
        return Config.DROP_CHANCE_MODIFIER_RAIDBOSS;
    }

    @Override
    public double getDropCountMod(Player player) {
        return Config.DROP_COUNT_MODIFIER_RAIDBOSS;
    }

    @Override
    protected void onDeath(Creature killer) {
        Object boxTemplate;
        this.stopRaidBerserkTask();
        if (this.isReflectionBoss()) {
            super.onDeath(killer);
            return;
        }
        if (killer != null && killer.isPlayable()) {
            QuestState st;
            Player player = killer.getPlayer();
            if (player.isInParty()) {
                for (Player member : player.getParty().getPartyMembers()) {
                    if (!member.isHero()) continue;
                    Hero.getInstance().addHeroDiary(member.getObjectId(), 1, this.getNpcId());
                }
                player.getParty().broadCast(SystemMsg.CONGRATULATIONS_YOUR_RAID_WAS_SUCCESSFUL);
            } else {
                if (player.isHero()) {
                    Hero.getInstance().addHeroDiary(player.getObjectId(), 1, this.getNpcId());
                }
                player.sendPacket((IBroadcastPacket)SystemMsg.CONGRATULATIONS_YOUR_RAID_WAS_SUCCESSFUL);
            }
            Quest q = QuestHolder.getInstance().getQuest(508);
            if (q != null && player.getClan() != null && player.getClan().getLeader().isOnline() && (st = player.getClan().getLeader().getPlayer().getQuestState(q)) != null) {
                st.getQuest().onKill(this, st);
            }
        }
        int boxId = 0;
        switch (this.getNpcId()) {
            case 25035: {
                boxId = 31027;
                break;
            }
            case 25054: {
                boxId = 31028;
                break;
            }
            case 25126: {
                boxId = 31029;
                break;
            }
            case 25220: {
                boxId = 31030;
            }
        }
        if (boxId != 0 && (boxTemplate = NpcHolder.getInstance().getTemplate(boxId)) != null) {
            NpcInstance box = new NpcInstance(IdFactory.getInstance().getNextId(), (NpcTemplate)boxTemplate, StatsSet.EMPTY);
            box.spawnMe(this.getLoc());
            box.setSpawnedLoc(this.getLoc());
            box.startDeleteTask(60000L);
        }
        if (killer != null && killer.getPlayer() != null && Config.RAID_DROP_GLOBAL_ITEMS && this.getLevel() >= Config.MIN_RAID_LEVEL_TO_DROP) {
            for (Config.RaidGlobalDrop drop_inf : Config.RAID_GLOBAL_DROP) {
                int id = drop_inf.getId();
                long count = drop_inf.getCount();
                double chance = drop_inf.getChance();
                if (!Rnd.chance((double)chance)) continue;
                ItemFunctions.addItem(killer.getPlayer(), id, count, true);
            }
        }
        if (this._spawnDeathKnight && !this.isBoss() && this.getReflection().isMain() && Rnd.chance((int)10)) {
            int knightId = 0;
            if (this.getLevel() >= 20 && this.getLevel() < 30) {
                knightId = 25787;
            } else if (this.getLevel() >= 30 && this.getLevel() < 40) {
                knightId = 25788;
            } else if (this.getLevel() >= 40 && this.getLevel() < 50) {
                knightId = 25789;
            } else if (this.getLevel() >= 50 && this.getLevel() < 60) {
                knightId = 25790;
            } else if (this.getLevel() >= 60 && this.getLevel() < 70) {
                knightId = 25791;
            } else if (this.getLevel() >= 70 && this.getLevel() < 80) {
                knightId = 25792;
            }
            if (knightId > 0) {
                NpcInstance npc = NpcUtils.spawnSingle(knightId, this.getLoc(), this.getReflection(), 900000L);
                npc.getAI().notifyEvent(CtrlEvent.EVT_AGGRESSION, killer, 1000);
            }
        }
        super.onDeath(killer);
        RaidBossSpawnManager.getInstance().onBossDeath(this);
    }

    @Override
    protected void onSpawn() {
        super.onSpawn();
        this.addSkill(SkillEntry.makeSkillEntry(SkillEntryType.NONE, 4045, 1));
        RaidBossSpawnManager.getInstance().onBossSpawned(this);
    }

    @Override
    public boolean isFearImmune() {
        return true;
    }

    @Override
    public boolean isParalyzeImmune() {
        return true;
    }

    @Override
    public boolean isLethalImmune() {
        return true;
    }

    @Override
    public boolean isThrowAndKnockImmune() {
        return true;
    }

    @Override
    public boolean isTransformImmune() {
        return true;
    }

    @Override
    public boolean hasRandomWalk() {
        return false;
    }

    @Override
    public boolean canChampion() {
        return false;
    }

    @Override
    public void onZoneEnter(Zone zone) {
        if (!(zone.checkIfInZone(this.getSpawnedLoc().getX(), this.getSpawnedLoc().getY(), this.getSpawnedLoc().getZ()) || zone.getType() != Zone.ZoneType.peace_zone && zone.getType() != Zone.ZoneType.battle_zone && zone.getType() != Zone.ZoneType.SIEGE)) {
            this.getAI().returnHomeAndRestore(this.isRunning());
        }
    }

    @Override
    protected void onDespawn() {
        super.onDespawn();
        this.stopRaidBerserkTask();
    }

    public void startRaidBerserkTask() {
        if (!this._canRaidBerserk) {
            return;
        }
        if (this._raidBerserkTask != null) {
            return;
        }
        if (this.getAbnormalList().contains(15458)) {
            return;
        }
        this._raidBerserkTask = ThreadPoolManager.getInstance().schedule(new BerserkTask(true), TimeUnit.MINUTES.toMillis(10L));
    }

    public void stopRaidBerserkTask() {
        if (this._raidBerserkTask != null) {
            this._raidBerserkTask.cancel(false);
            this._raidBerserkTask = null;
        }
    }

    private class BerserkTask
    implements Runnable {
        private final boolean _prepare;

        public BerserkTask(boolean prepare) {
            this._prepare = prepare;
        }

        @Override
        public void run() {
            if (this._prepare) {
                RaidBossInstance.this._raidBerserkTask = ThreadPoolManager.getInstance().schedule(new BerserkTask(false), TimeUnit.MINUTES.toMillis(5L));
                RaidBossInstance.this.broadcastPacket(new ExShowScreenMessage(NpcString._5_MINUTES_UNTIL_RAID_BOSS_GOES_BERSERK, 10000, ExShowScreenMessage.ScreenMessageAlign.TOP_CENTER, true, true, new String[0]));
            } else {
                RaidBossInstance.this._raidBerserkTask = null;
                RaidBossInstance.this.altUseSkill(SkillEntry.makeSkillEntry(SkillEntryType.NONE, 15458, 1), RaidBossInstance.this);
            }
        }
    }
}


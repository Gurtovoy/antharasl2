package l2s.gameserver.model.instances;

import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.Config;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.Hero;
import l2s.gameserver.model.instances.RaidBossInstance;
import l2s.gameserver.templates.npc.NpcTemplate;

public class BossInstance
extends RaidBossInstance {
    private boolean _teleportedToNest;

    public BossInstance(int objectId, NpcTemplate template, MultiValueSet<String> set) {
        super(objectId, template, set);
    }

    @Override
    public double getRewardRate(Player player) {
        return Config.RATE_DROP_ITEMS_BOSS;
    }

    @Override
    public double getDropChanceMod(Player player) {
        return Config.DROP_CHANCE_MODIFIER_BOSS;
    }

    @Override
    public double getDropCountMod(Player player) {
        return Config.DROP_COUNT_MODIFIER_BOSS;
    }

    @Override
    public boolean isBoss() {
        return true;
    }

    @Override
    public final boolean isMovementDisabled() {
        return this.getNpcId() == 29006 || super.isMovementDisabled();
    }

    @Override
    protected void onDeath(Creature killer) {
        if (killer != null && killer.isPlayable()) {
            Player player = killer.getPlayer();
            if (player.isInParty()) {
                for (Player member : player.getParty().getPartyMembers()) {
                    if (!member.isHero()) continue;
                    Hero.getInstance().addHeroDiary(member.getObjectId(), 1, this.getNpcId());
                }
            } else if (player.isHero()) {
                Hero.getInstance().addHeroDiary(player.getObjectId(), 1, this.getNpcId());
            }
        }
        super.onDeath(killer);
    }

    public void setTeleported(boolean flag) {
        this._teleportedToNest = flag;
    }

    public boolean isTeleported() {
        return this._teleportedToNest;
    }

    @Override
    public boolean hasRandomAnimation() {
        return false;
    }
}


package l2s.gameserver.network.l2.s2c;

import java.util.Collection;
import java.util.Collections;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.skills.SkillCastingType;

public class MagicSkillLaunchedPacket
extends L2GameServerPacket {
    private final int _casterId;
    private final int _skillId;
    private final int _skillLevel;
    private final Collection<Creature> _targets;
    private final SkillCastingType _castingType;

    public MagicSkillLaunchedPacket(int casterId, int skillId, int skillLevel, Creature target, SkillCastingType castingType) {
        this._casterId = casterId;
        this._skillId = skillId;
        this._skillLevel = skillLevel;
        this._targets = Collections.singletonList(target);
        this._castingType = castingType;
    }

    public MagicSkillLaunchedPacket(int casterId, int skillId, int skillLevel, Collection<Creature> targets, SkillCastingType castingType) {
        this._casterId = casterId;
        this._skillId = skillId;
        this._skillLevel = skillLevel;
        this._targets = targets;
        this._castingType = castingType;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._castingType.getClientBarId());
        this.writeD(this._casterId);
        this.writeD(this._skillId);
        this.writeD(this._skillLevel);
        this.writeD(this._targets.size());
        for (Creature target : this._targets) {
            if (target == null) continue;
            this.writeD(target.getObjectId());
        }
    }

    @Override
    public L2GameServerPacket packet(Player player) {
        if (player != null && player.isNotShowBuffAnim()) {
            return this._casterId == player.getObjectId() ? super.packet(player) : null;
        }
        return super.packet(player);
    }
}


/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import java.util.Collection;
import java.util.List;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.SkillAcquireHolder;
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.SkillLearn;
import l2s.gameserver.model.base.AcquireType;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.item.data.ItemData;

public class AcquireSkillListPacket
extends L2GameServerPacket {
    private Player _player;
    private Collection<SkillLearn> _skills;

    public AcquireSkillListPacket(Player player) {
        this._player = player;
        this._skills = SkillAcquireHolder.getInstance().getAcquirableSkillListByClass(player);
    }

    @Override
    protected final void writeImpl() {
        this.writeH(this._skills.size());
        for (SkillLearn sk : this._skills) {
            Skill skill = SkillHolder.getInstance().getSkill(sk.getId(), sk.getLevel());
            if (skill == null) continue;
            this.writeD(sk.getId());
            this.writeH(sk.getLevel());
            this.writeQ(sk.getCost());
            this.writeC(sk.getMinLevel());
            this.writeC(0);
            if (Config.USE_NEW_140_PROTOCOL) {
                this.writeC(true);
            }
            List<ItemData> requiredItems = sk.getRequiredItemsForLearn(AcquireType.NORMAL);
            this.writeC(requiredItems.size());
            for (ItemData item : requiredItems) {
                this.writeD(item.getId());
                this.writeQ(item.getCount());
            }
            this.writeC(0);
        }
    }
}


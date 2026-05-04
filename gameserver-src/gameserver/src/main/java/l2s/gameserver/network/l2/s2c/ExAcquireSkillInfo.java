package l2s.gameserver.network.l2.s2c;

import java.util.List;
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.SkillLearn;
import l2s.gameserver.model.base.AcquireType;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.item.data.ItemData;

public class ExAcquireSkillInfo
extends L2GameServerPacket {
    private Skill _skill;
    private List<ItemData> _requiredItems;
    private SkillLearn _learn;

    public ExAcquireSkillInfo(Player player, AcquireType type, SkillLearn learn) {
        this._learn = learn;
        this._requiredItems = this._learn.getRequiredItemsForLearn(type);
        this._skill = SkillHolder.getInstance().getSkill(this._learn.getId(), this._learn.getLevel());
    }

    @Override
    public void writeImpl() {
        this.writeD(this._learn.getId());
        this.writeD(this._learn.getLevel());
        this.writeQ(this._learn.getCost());
        this.writeH(this._learn.getMinLevel());
        this.writeH(0);
        this.writeD(this._requiredItems.size());
        for (ItemData item : this._requiredItems) {
            this.writeD(item.getId());
            this.writeQ(item.getCount());
        }
        this.writeD(0);
    }
}


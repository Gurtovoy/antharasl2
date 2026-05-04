package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import l2s.gameserver.model.SkillLearn;
import l2s.gameserver.model.base.AcquireType;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.item.data.ItemData;

public class AcquireSkillInfoPacket
extends L2GameServerPacket {
    private SkillLearn _learn;
    private AcquireType _type;
    private List<Require> _reqs = Collections.emptyList();

    public AcquireSkillInfoPacket(AcquireType type, SkillLearn learn) {
        this._type = type;
        this._learn = learn;
        this._reqs = new ArrayList<Require>();
        for (ItemData item : this._learn.getRequiredItemsForLearn(type)) {
            this._reqs.add(new Require(99, item.getId(), item.getCount(), 50));
        }
    }

    @Override
    public void writeImpl() {
        this.writeD(this._learn.getId());
        this.writeD(this._learn.getLevel());
        this.writeQ(this._learn.getCost());
        this.writeD(this._type.getId());
        this.writeD(this._reqs.size());
        for (Require temp : this._reqs) {
            this.writeD(temp.type);
            this.writeD(temp.itemId);
            this.writeQ(temp.count);
            this.writeD(temp.unk);
        }
    }

    private static class Require {
        public int itemId;
        public long count;
        public int type;
        public int unk;

        public Require(int pType, int pItemId, long pCount, int pUnk) {
            this.itemId = pItemId;
            this.type = pType;
            this.count = pCount;
            this.unk = pUnk;
        }
    }
}


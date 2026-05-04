package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInfo;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class TradeStartPacket
extends L2GameServerPacket {
    private static final int IS_FRIEND = 1;
    private static final int CLAN_MEMBER = 2;
    private static final int ALLY_MEMBER = 8;
    private final int _type;
    private final List<ItemInfo> _tradelist = new ArrayList<ItemInfo>();
    private final int _targetId;
    private final int _targetLevel;
    private int _flags = 0;

    public TradeStartPacket(int type, Player player, Player target) {
        ItemInstance[] items;
        this._type = type;
        this._targetId = target.getObjectId();
        this._targetLevel = target.getLevel();
        if (player.getFriendList().contains(target.getObjectId())) {
            this._flags |= 1;
        }
        if (player.getClan() != null && player.getClan() == target.getClan()) {
            this._flags |= 2;
        }
        if (player.getAlliance() != null && player.getAlliance() == target.getAlliance()) {
            this._flags |= 8;
        }
        for (ItemInstance item : items = player.getInventory().getItems()) {
            if (!item.canBeTraded(player)) continue;
            this._tradelist.add(new ItemInfo(item, item.getTemplate().isBlocked(player, item)));
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeC(this._type);
        if (this._type == 1) {
            this.writeD(this._targetId);
            this.writeC(this._flags);
            this.writeC(this._targetLevel);
            this.writeC(0);
            this.writeH(0);
            this.writeC(0);
        } else if (this._type == 2) {
            this.writeD(this._tradelist.size());
            this.writeH(this._tradelist.size());
            this.writeC(0);
            this.writeC(0);
            for (ItemInfo item : this._tradelist) {
                this.writeItemInfo(item);
            }
        }
    }
}


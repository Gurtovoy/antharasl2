package l2s.gameserver.model.actor.instances.player;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.util.Collection;
import l2s.gameserver.Config;
import l2s.gameserver.dao.CharacterBlockListDAO;
import l2s.gameserver.dao.CharacterDAO;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.model.actor.instances.player.Block;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.BlockListPacket;
import l2s.gameserver.network.l2.s2c.ExBlockAddResult;
import l2s.gameserver.network.l2.s2c.ExBlockDefailInfo;
import l2s.gameserver.network.l2.s2c.ExBlockRemoveResult;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import org.apache.commons.lang3.StringUtils;

public class BlockList {
    public static final int MAX_BLOCK_LIST_SIZE = 128;
    private TIntObjectMap<Block> _blockList = new TIntObjectHashMap(0);
    private final Player _owner;

    public BlockList(Player owner) {
        this._owner = owner;
    }

    public void restore() {
        this._blockList = CharacterBlockListDAO.getInstance().select(this._owner);
    }

    public Block get(int objectId) {
        return (Block)this._blockList.get(objectId);
    }

    public Block get(String name) {
        if (StringUtils.isEmpty((CharSequence)name)) {
            return null;
        }
        for (Block b : this.values()) {
            if (!name.equalsIgnoreCase(b.getName())) continue;
            return b;
        }
        return null;
    }

    public boolean contains(int objectId) {
        return this._blockList.containsKey(objectId);
    }

    public boolean contains(Player player) {
        if (player == null) {
            return false;
        }
        return this.contains(player.getObjectId());
    }

    public boolean contains(String name) {
        return this.get(name) != null;
    }

    public int size() {
        return this._blockList.size();
    }

    public Block[] values() {
        return (Block[])this._blockList.values(new Block[this._blockList.size()]);
    }

    public Collection<Block> valueCollection() {
        return this._blockList.valueCollection();
    }

    public boolean isEmpty() {
        return this._blockList.isEmpty();
    }

    public void add(String name) {
        int blockedObjId;
        if (StringUtils.isEmpty((CharSequence)name) || name.equalsIgnoreCase(this._owner.getName()) || this.contains(name)) {
            this._owner.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_FAILED_TO_REGISTER_THE_USER_TO_YOUR_IGNORE_LIST);
            return;
        }
        Player blockedPlayer = World.getPlayer(name);
        if (blockedPlayer != null) {
            if (blockedPlayer.isGM()) {
                this._owner.sendPacket((IBroadcastPacket)SystemMsg.YOU_MAY_NOT_IMPOSE_A_BLOCK_ON_A_GM);
                return;
            }
            blockedObjId = blockedPlayer.getObjectId();
        } else {
            blockedObjId = CharacterDAO.getInstance().getObjectIdByName(name);
            if (blockedObjId == 0) {
                this._owner.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_FAILED_TO_REGISTER_THE_USER_TO_YOUR_IGNORE_LIST);
                return;
            }
            if (Config.gmlist.containsKey(blockedObjId) && Config.gmlist.get(Integer.valueOf((int)blockedObjId)).IsGM) {
                this._owner.sendPacket((IBroadcastPacket)SystemMsg.YOU_MAY_NOT_IMPOSE_A_BLOCK_ON_A_GM);
                return;
            }
        }
        this._owner.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_HAS_BEEN_ADDED_TO_YOUR_IGNORE_LIST).addString(name));
        this._owner.sendPacket((IBroadcastPacket)new ExBlockAddResult(name));
        this._blockList.put(blockedObjId, new Block(blockedObjId, name));
        CharacterBlockListDAO.getInstance().insert(this._owner, blockedObjId);
    }

    public void remove(String name) {
        if (StringUtils.isEmpty((CharSequence)name)) {
            return;
        }
        int blockedObjId = 0;
        for (Block b : this.values()) {
            if (!name.equalsIgnoreCase(b.getName())) continue;
            blockedObjId = b.getObjectId();
            break;
        }
        if (blockedObjId == 0) {
            this._owner.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_FAILED_TO_DELETE_THE_CHARACTER_);
            return;
        }
        this._owner.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_HAS_BEEN_REMOVED_FROM_YOUR_IGNORE_LIST).addString(name));
        this._owner.sendPacket((IBroadcastPacket)new ExBlockRemoveResult(name));
        this._blockList.remove(blockedObjId);
        CharacterBlockListDAO.getInstance().delete(this._owner, blockedObjId);
    }

    public void notifyChangeName(int blockedObjectId) {
        if (this._blockList.containsKey(blockedObjectId)) {
            this._owner.sendPacket((IBroadcastPacket)new BlockListPacket(this._owner));
        }
    }

    public boolean updateMemo(String name, String memo) {
        if (memo.length() > 50) {
            return false;
        }
        Block block = this.get(name);
        if (block == null) {
            return false;
        }
        block.setMemo(memo);
        this._owner.sendPacket((IBroadcastPacket)new ExBlockDefailInfo(name, memo));
        return CharacterBlockListDAO.getInstance().updateMemo(this._owner, block.getObjectId(), memo);
    }

    public String toString() {
        return "BlockList[owner=" + this._owner.getName() + "]";
    }
}


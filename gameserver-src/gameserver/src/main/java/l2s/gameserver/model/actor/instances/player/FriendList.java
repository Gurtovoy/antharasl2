package l2s.gameserver.model.actor.instances.player;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.util.Collection;
import l2s.gameserver.dao.CharacterFriendDAO;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Request;
import l2s.gameserver.model.World;
import l2s.gameserver.model.actor.instances.player.Friend;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExFriendDetailInfo;
import l2s.gameserver.network.l2.s2c.FriendAddRequest;
import l2s.gameserver.network.l2.s2c.FriendRemove;
import l2s.gameserver.network.l2.s2c.FriendStatus;
import l2s.gameserver.network.l2.s2c.L2FriendListPacket;
import l2s.gameserver.network.l2.s2c.SystemMessage;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import org.apache.commons.lang3.StringUtils;

public class FriendList {
    public static final int MAX_FRIEND_SIZE = 128;
    private TIntObjectMap<Friend> _friendList = new TIntObjectHashMap(0);
    private final Player _owner;

    public FriendList(Player owner) {
        this._owner = owner;
    }

    public void restore() {
        this._friendList = CharacterFriendDAO.getInstance().select(this._owner);
    }

    public void add(Player friendPlayer) {
        this._friendList.put(friendPlayer.getObjectId(), new Friend(friendPlayer));
        CharacterFriendDAO.getInstance().insert(this._owner, friendPlayer);
    }

    public Friend get(int objectId) {
        return (Friend)this._friendList.get(objectId);
    }

    public Friend get(String name) {
        if (StringUtils.isEmpty((CharSequence)name)) {
            return null;
        }
        for (Friend friend : this.values()) {
            if (!name.equalsIgnoreCase(friend.getName())) continue;
            return friend;
        }
        return null;
    }

    public boolean contains(int objectId) {
        return this._friendList.containsKey(objectId);
    }

    public int size() {
        return this._friendList.size();
    }

    public Friend[] values() {
        return (Friend[])this._friendList.values(new Friend[this._friendList.size()]);
    }

    public Collection<Friend> valueCollection() {
        return this._friendList.valueCollection();
    }

    public boolean isEmpty() {
        return this._friendList.isEmpty();
    }

    public void remove(int objectId) {
        this._friendList.remove(objectId);
        CharacterFriendDAO.getInstance().delete(this._owner.getObjectId(), objectId);
    }

    public void remove(String name) {
        if (StringUtils.isEmpty((CharSequence)name)) {
            return;
        }
        int objectId = this.remove0(name);
        if (objectId > 0) {
            Player friendChar = World.getPlayer(objectId);
            this._owner.sendPacket(new SystemMessage(133).addString(name), new FriendRemove(name));
            if (friendChar != null) {
                friendChar.sendPacket(new SystemMessage(481).addString(this._owner.getName()), new L2FriendListPacket(friendChar));
            }
        } else {
            this._owner.sendPacket((IBroadcastPacket)new SystemMessage(171).addString(name));
        }
    }

    private int remove0(String name) {
        if (StringUtils.isEmpty((CharSequence)name)) {
            return 0;
        }
        int objectId = 0;
        for (Friend friend : this.values()) {
            if (!name.equalsIgnoreCase(friend.getName())) continue;
            objectId = friend.getObjectId();
            break;
        }
        if (objectId > 0) {
            this.remove(objectId);
            Player friendPlayer = GameObjectsStorage.getPlayer(objectId);
            if (friendPlayer != null) {
                friendPlayer.getFriendList().remove(this._owner.getObjectId());
            } else {
                CharacterFriendDAO.getInstance().delete(objectId, this._owner.getObjectId());
            }
            return objectId;
        }
        return 0;
    }

    public void notifyChangeName(int friendObjectId) {
        if (this._friendList.containsKey(friendObjectId)) {
            this._owner.sendPacket((IBroadcastPacket)new L2FriendListPacket(this._owner));
            this._owner.sendPacket((IBroadcastPacket)new l2s.gameserver.network.l2.s2c.FriendList(this._owner));
        }
    }

    public void notifyFriends(boolean login) {
        for (Friend friend : this.values()) {
            Friend thisFriend;
            Player friendPlayer = GameObjectsStorage.getPlayer(friend.getObjectId());
            if (friendPlayer == null || (thisFriend = friendPlayer.getFriendList().get(this._owner.getObjectId())) == null) continue;
            thisFriend.update(this._owner, login);
            if (login) {
                friendPlayer.sendPacket((IBroadcastPacket)new SystemMessage(503).addString(this._owner.getName()));
            }
            friendPlayer.sendPacket((IBroadcastPacket)new FriendStatus(thisFriend, login));
            friend.update(friendPlayer, login);
        }
    }

    public boolean updateMemo(String name, String memo) {
        if (memo.length() > 50) {
            return false;
        }
        Friend friend = this.get(name);
        if (friend == null) {
            return false;
        }
        friend.setMemo(memo);
        this._owner.sendPacket((IBroadcastPacket)new ExFriendDetailInfo(this._owner, friend));
        return CharacterFriendDAO.getInstance().updateMemo(this._owner, friend.getObjectId(), memo);
    }

    public IBroadcastPacket requestFriendInvite(GameObject target) {
        if (this._owner.isProcessingRequest()) {
            return SystemMsg.WAITING_FOR_ANOTHER_REPLY;
        }
        if (this.size() >= 128) {
            return SystemMsg.YOU_CAN_ONLY_ENTER_UP_128_NAMES_IN_YOUR_FRIENDS_LIST;
        }
        if (target == null) {
            return SystemMsg.THE_USER_WHO_REQUESTED_TO_BECOME_FRIENDS_IS_NOT_FOUND_IN_THE_GAME;
        }
        if (!target.isPlayer()) {
            return null;
        }
        Player player = target.getPlayer();
        if (player == this._owner) {
            return SystemMsg.YOU_CANNOT_ADD_YOURSELF_TO_YOUR_OWN_FRIEND_LIST;
        }
        if (player.isBlockAll() || player.getBlockList().contains(this._owner) || player.getMessageRefusal()) {
            return SystemMsg.THAT_PERSON_IS_IN_MESSAGE_REFUSAL_MODE;
        }
        if (this.contains(player.getObjectId())) {
            return new SystemMessagePacket(SystemMsg.C1_IS_ALREADY_ON_YOUR_FRIEND_LIST).addName(player);
        }
        if (player.getFriendList().size() >= 128) {
            return SystemMsg.THE_FRIENDS_LIST_OF_THE_PERSON_YOU_ARE_TRYING_TO_ADD_IS_FULL_SO_REGISTRATION_IS_NOT_POSSIBLE;
        }
        if (player.isInOlympiadMode()) {
            return SystemMsg.A_USER_CURRENTLY_PARTICIPATING_IN_THE_OLYMPIAD_CANNOT_SEND_PARTY_AND_FRIEND_INVITATIONS;
        }
        new Request(Request.L2RequestType.FRIEND, this._owner, player).setTimeout(10000L);
        player.sendPacket((IBroadcastPacket)new FriendAddRequest(this._owner.getName()));
        return null;
    }

    public String toString() {
        return "FriendList[owner=" + this._owner.getName() + "]";
    }
}


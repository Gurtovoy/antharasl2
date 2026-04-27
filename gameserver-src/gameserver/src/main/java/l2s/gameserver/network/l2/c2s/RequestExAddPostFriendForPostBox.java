/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.napile.primitive.maps.IntObjectMap
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.dao.CharacterDAO;
import l2s.gameserver.dao.CharacterPostFriendDAO;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExConfirmAddingPostFriend;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import org.napile.primitive.maps.IntObjectMap;

public class RequestExAddPostFriendForPostBox
extends L2GameClientPacket {
    private String _name;

    @Override
    protected boolean readImpl() throws Exception {
        this._name = this.readS(Config.CNAME_MAXLEN);
        return true;
    }

    @Override
    protected void runImpl() throws Exception {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        int targetObjectId = CharacterDAO.getInstance().getObjectIdByName(this._name);
        if (targetObjectId == 0) {
            player.sendPacket((IBroadcastPacket)new ExConfirmAddingPostFriend(this._name, ExConfirmAddingPostFriend.NAME_IS_NOT_EXISTS));
            return;
        }
        if (this._name.equalsIgnoreCase(player.getName())) {
            player.sendPacket((IBroadcastPacket)new ExConfirmAddingPostFriend(this._name, ExConfirmAddingPostFriend.NAME_IS_NOT_REGISTERED));
            return;
        }
        IntObjectMap<String> postFriend = player.getPostFriends();
        if (postFriend.size() >= 100) {
            player.sendPacket((IBroadcastPacket)new ExConfirmAddingPostFriend(this._name, ExConfirmAddingPostFriend.LIST_IS_FULL));
            return;
        }
        if (postFriend.containsKey(targetObjectId)) {
            player.sendPacket((IBroadcastPacket)new ExConfirmAddingPostFriend(this._name, ExConfirmAddingPostFriend.ALREADY_ADDED));
            return;
        }
        CharacterPostFriendDAO.getInstance().insert(player, targetObjectId);
        postFriend.put(targetObjectId, CharacterDAO.getInstance().getNameByObjectId(targetObjectId));
        player.sendPacket(new IBroadcastPacket[]{new SystemMessagePacket(SystemMsg.S1_WAS_SUCCESSFULLY_ADDED_TO_YOUR_CONTACT_LIST).addString(this._name), new ExConfirmAddingPostFriend(this._name, ExConfirmAddingPostFriend.SUCCESS)});
    }
}


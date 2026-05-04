package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.dao.CharacterPostFriendDAO;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import org.apache.commons.lang3.StringUtils;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.pair.IntObjectPair;

public class RequestExDeletePostFriendForPostBox
extends L2GameClientPacket {
    private String _name;

    @Override
    protected boolean readImpl() throws Exception {
        this._name = this.readS();
        return true;
    }

    @Override
    protected void runImpl() throws Exception {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        if (StringUtils.isEmpty((CharSequence)this._name)) {
            return;
        }
        int key = 0;
        IntObjectMap<String> postFriends = player.getPostFriends();
        for (IntObjectPair entry : postFriends.entrySet()) {
            if (!((String)entry.getValue()).equalsIgnoreCase(this._name)) continue;
            key = entry.getKey();
        }
        if (key == 0) {
            player.sendPacket((IBroadcastPacket)SystemMsg.THE_NAME_IS_NOT_CURRENTLY_REGISTERED);
            return;
        }
        player.getPostFriends().remove(key);
        CharacterPostFriendDAO.getInstance().delete(player, key);
        player.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_WAS_SUCCESSFULLY_DELETED_FROM_YOUR_CONTACT_LIST).addString(this._name));
    }
}


package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.LuckyGameHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExStartLuckyGame;
import l2s.gameserver.templates.luckygame.LuckyGameData;
import l2s.gameserver.templates.luckygame.LuckyGameType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class RequestLuckyGameStartInfo
extends L2GameClientPacket {
    private static final Logger _log = LoggerFactory.getLogger(RequestLuckyGameStartInfo.class);
    private int _typeId;

    @Override
    protected boolean readImpl() {
        this._typeId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        if (!Config.ALLOW_LUCKY_GAME_EVENT) {
            return;
        }
        if (this._typeId < 0 || this._typeId >= LuckyGameType.VALUES.length) {
            return;
        }
        LuckyGameType type = LuckyGameType.VALUES[this._typeId];
        LuckyGameData gameData = LuckyGameHolder.getInstance().getData(type);
        if (gameData == null) {
            _log.warn("Cannot find data for lucky game TYPE[" + (Object)((Object)type) + "]!");
            return;
        }
        player.sendPacket((IBroadcastPacket)new ExStartLuckyGame(player, gameData));
    }
}


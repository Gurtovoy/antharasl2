package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.Hero;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestWriteHeroWords
extends L2GameClientPacket {
    private String _heroWords;

    @Override
    protected boolean readImpl() {
        this._heroWords = this.readS();
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null || !player.isHero()) {
            return;
        }
        if (this._heroWords == null || this._heroWords.length() > 300) {
            return;
        }
        Hero.getInstance().setHeroMessage(player.getObjectId(), this._heroWords);
    }
}


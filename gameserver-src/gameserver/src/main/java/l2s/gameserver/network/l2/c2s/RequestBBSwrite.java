package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.handler.bbs.BbsHandlerHolder;
import l2s.gameserver.handler.bbs.IBbsHandler;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.utils.BypassStorage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RequestBBSwrite
extends L2GameClientPacket {
    private static final Logger _log = LoggerFactory.getLogger(RequestBBSwrite.class);
    private String _url;
    private String _arg1;
    private String _arg2;
    private String _arg3;
    private String _arg4;
    private String _arg5;

    @Override
    public boolean readImpl() {
        this._url = this.readS();
        this._arg1 = this.readS();
        this._arg2 = this.readS();
        this._arg3 = this.readS();
        this._arg4 = this.readS();
        this._arg5 = this.readS();
        return true;
    }

    @Override
    public void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        BypassStorage.ValidBypass bp = activeChar.getBypassStorage().validate(this._url);
        if (bp == null) {
            _log.warn("RequestBBSwrite: Unexpected bypass : " + this._url + " client : " + this.getClient() + "!");
            return;
        }
        if (!Config.BBS_ENABLED) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THE_COMMUNITY_SERVER_IS_CURRENTLY_OFFLINE);
            return;
        }
        IBbsHandler handler = BbsHandlerHolder.getInstance().getCommunityHandler(bp.bypass);
        if (handler != null) {
            handler.onWriteCommand(activeChar, bp.bypass, this._arg1, this._arg2, this._arg3, this._arg4, this._arg5);
        }
    }
}


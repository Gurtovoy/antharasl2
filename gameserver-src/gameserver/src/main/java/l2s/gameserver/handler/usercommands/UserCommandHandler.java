/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.handler.usercommands;

import gnu.trove.map.hash.TIntObjectHashMap;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.handler.usercommands.IUserCommandHandler;
import l2s.gameserver.handler.usercommands.impl.ClanPenalty;
import l2s.gameserver.handler.usercommands.impl.ClanWarsList;
import l2s.gameserver.handler.usercommands.impl.CommandChannel;
import l2s.gameserver.handler.usercommands.impl.Escape;
import l2s.gameserver.handler.usercommands.impl.InstanceZone;
import l2s.gameserver.handler.usercommands.impl.Loc;
import l2s.gameserver.handler.usercommands.impl.MyBirthday;
import l2s.gameserver.handler.usercommands.impl.OlympiadStat;
import l2s.gameserver.handler.usercommands.impl.PartyInfo;
import l2s.gameserver.handler.usercommands.impl.Time;

public class UserCommandHandler
extends AbstractHolder {
    private static final UserCommandHandler _instance = new UserCommandHandler();
    private TIntObjectHashMap<IUserCommandHandler> _datatable = new TIntObjectHashMap();

    public static UserCommandHandler getInstance() {
        return _instance;
    }

    private UserCommandHandler() {
        this.registerUserCommandHandler(new ClanWarsList());
        this.registerUserCommandHandler(new ClanPenalty());
        this.registerUserCommandHandler(new CommandChannel());
        this.registerUserCommandHandler(new Escape());
        this.registerUserCommandHandler(new Loc());
        this.registerUserCommandHandler(new MyBirthday());
        this.registerUserCommandHandler(new OlympiadStat());
        this.registerUserCommandHandler(new PartyInfo());
        this.registerUserCommandHandler(new InstanceZone());
        this.registerUserCommandHandler(new Time());
    }

    public void registerUserCommandHandler(IUserCommandHandler handler) {
        int[] ids;
        for (int element : ids = handler.getUserCommandList()) {
            this._datatable.put(element, handler);
        }
    }

    public IUserCommandHandler getUserCommandHandler(int userCommand) {
        return (IUserCommandHandler)this._datatable.get(userCommand);
    }

    public int size() {
        return this._datatable.size();
    }

    public void clear() {
        this._datatable.clear();
    }
}


package l2s.gameserver.handler.bbs;

import java.util.HashMap;
import java.util.Map;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.Config;
import l2s.gameserver.handler.bbs.IBbsHandler;
import l2s.gameserver.templates.StatsSet;

public class BbsHandlerHolder
extends AbstractHolder {
    private static final BbsHandlerHolder _instance = new BbsHandlerHolder();
    private final Map<String, IBbsHandler> _handlers = new HashMap<String, IBbsHandler>();
    private final StatsSet _properties = new StatsSet();

    public static BbsHandlerHolder getInstance() {
        return _instance;
    }

    private BbsHandlerHolder() {
    }

    public void registerHandler(IBbsHandler commHandler) {
        for (String bypass : commHandler.getBypassCommands()) {
            if (this._handlers.containsKey(bypass)) {
                this.warn("BbsHandlerHolder: dublicate bypass registered! First handler: " + this._handlers.get(bypass).getClass().getSimpleName() + " second: " + commHandler.getClass().getSimpleName());
            }
            this._handlers.put(bypass, commHandler);
        }
    }

    public void removeHandler(IBbsHandler handler) {
        for (String bypass : handler.getBypassCommands()) {
            this._handlers.remove(bypass);
        }
        this._log.info("BbsHandlerHolder: " + handler.getClass().getSimpleName() + " unloaded.");
    }

    public IBbsHandler getCommunityHandler(String bypass) {
        if (!Config.BBS_ENABLED || this._handlers.isEmpty()) {
            return null;
        }
        for (Map.Entry<String, IBbsHandler> entry : this._handlers.entrySet()) {
            if (!bypass.toLowerCase().startsWith(entry.getKey().toLowerCase())) continue;
            return entry.getValue();
        }
        return null;
    }

    public void setProperty(String name, String val) {
        this._properties.set(name, val);
    }

    public void setProperty(String name, int val) {
        this._properties.set(name, val);
    }

    public int getIntProperty(String name) {
        return this._properties.getInteger(name, 0);
    }

    public int size() {
        return this._handlers.size();
    }

    public void clear() {
        this._handlers.clear();
    }
}


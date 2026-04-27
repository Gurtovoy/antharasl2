/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.data.xml.AbstractHolder
 */
package l2s.gameserver.handler.voicecommands;

import java.util.HashMap;
import java.util.Map;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.handler.voicecommands.IVoicedCommandHandler;

public class VoicedCommandHandler
extends AbstractHolder {
    private static final VoicedCommandHandler _instance = new VoicedCommandHandler();
    private Map<String, IVoicedCommandHandler> _datatable = new HashMap<String, IVoicedCommandHandler>();

    public static VoicedCommandHandler getInstance() {
        return _instance;
    }

    private VoicedCommandHandler() {
    }

    public void registerVoicedCommandHandler(IVoicedCommandHandler handler) {
        String[] ids;
        for (String element : ids = handler.getVoicedCommandList()) {
            this._datatable.put(element, handler);
        }
    }

    public IVoicedCommandHandler getVoicedCommandHandler(String voicedCommand) {
        String command = voicedCommand;
        if (voicedCommand.indexOf(" ") != -1) {
            command = voicedCommand.substring(0, voicedCommand.indexOf(" "));
        }
        return this._datatable.get(command);
    }

    public int size() {
        return this._datatable.size();
    }

    public void clear() {
        this._datatable.clear();
    }
}


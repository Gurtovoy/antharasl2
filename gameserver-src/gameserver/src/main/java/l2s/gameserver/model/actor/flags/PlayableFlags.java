/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.actor.flags;

import l2s.gameserver.model.Playable;
import l2s.gameserver.model.actor.flags.CreatureFlags;
import l2s.gameserver.model.actor.flags.flag.DefaultFlag;

public class PlayableFlags
extends CreatureFlags {
    private final DefaultFlag _silentMoving = new DefaultFlag();

    public PlayableFlags(Playable owner) {
        super(owner);
    }

    public DefaultFlag getSilentMoving() {
        return this._silentMoving;
    }
}


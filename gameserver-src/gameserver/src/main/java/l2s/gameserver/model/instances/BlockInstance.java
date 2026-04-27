/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.collections.MultiValueSet
 */
package l2s.gameserver.model.instances;

import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.templates.npc.NpcTemplate;

public class BlockInstance
extends NpcInstance {
    private boolean _isRed;

    public BlockInstance(int objectId, NpcTemplate template, MultiValueSet<String> set) {
        super(objectId, template, set);
    }

    public boolean isRed() {
        return this._isRed;
    }

    public void setRed(boolean red) {
        this._isRed = red;
        this.broadcastCharInfo();
    }

    public void changeColor() {
        this.setRed(!this._isRed);
    }

    @Override
    public void showChatWindow(Player player, int val, boolean firstTalk, Object ... arg) {
    }

    @Override
    public boolean isNameAbove() {
        return false;
    }

    @Override
    public int getFormId() {
        return this._isRed ? 83 : 0;
    }
}


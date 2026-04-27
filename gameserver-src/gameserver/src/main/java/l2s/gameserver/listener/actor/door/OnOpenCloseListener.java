/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.listener.actor.door;

import l2s.gameserver.listener.CharListener;
import l2s.gameserver.model.instances.DoorInstance;

public interface OnOpenCloseListener
extends CharListener {
    public void onOpen(DoorInstance var1);

    public void onClose(DoorInstance var1);
}


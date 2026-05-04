package l2s.gameserver.listener.actor.door.impl;

import l2s.gameserver.listener.actor.door.OnOpenCloseListener;
import l2s.gameserver.model.instances.DoorInstance;

public class MasterOnOpenCloseListenerImpl
implements OnOpenCloseListener {
    private DoorInstance _door;

    public MasterOnOpenCloseListenerImpl(DoorInstance door) {
        this._door = door;
    }

    @Override
    public void onOpen(DoorInstance doorInstance) {
        this._door.openMe();
    }

    @Override
    public void onClose(DoorInstance doorInstance) {
        this._door.closeMe();
    }
}


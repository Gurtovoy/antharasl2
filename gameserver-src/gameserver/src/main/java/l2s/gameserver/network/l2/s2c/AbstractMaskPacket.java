package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.updatetype.IUpdateTypeComponent;

public abstract class AbstractMaskPacket<T extends IUpdateTypeComponent>
extends L2GameServerPacket {
    protected static final byte[] DEFAULT_FLAG_ARRAY = new byte[]{-128, 64, 32, 16, 8, 4, 2, 1};

    protected abstract byte[] getMasks();

    protected abstract void onNewMaskAdded(T var1);

    public AbstractMaskPacket<T> addComponentType(T ... updateComponents) {
        for (T component : updateComponents) {
            if (this.containsMask(component)) continue;
            byte[] byArray = this.getMasks();
            int n = component.getMask() >> 3;
            byArray[n] = (byte)(byArray[n] | DEFAULT_FLAG_ARRAY[component.getMask() & 7]);
            this.onNewMaskAdded(component);
        }
        return this;
    }

    public boolean containsMask(T component) {
        return this.containsMask(component.getMask());
    }

    public boolean containsMask(int mask) {
        return (this.getMasks()[mask >> 3] & DEFAULT_FLAG_ARRAY[mask & 7]) != 0;
    }
}


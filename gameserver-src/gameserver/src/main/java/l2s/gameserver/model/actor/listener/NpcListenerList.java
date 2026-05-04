package l2s.gameserver.model.actor.listener;

import l2s.commons.listener.Listener;
import l2s.gameserver.listener.actor.npc.OnDecayListener;
import l2s.gameserver.listener.actor.npc.OnSpawnListener;
import l2s.gameserver.model.actor.listener.CharListenerList;
import l2s.gameserver.model.instances.NpcInstance;

public class NpcListenerList
extends CharListenerList {
    public NpcListenerList(NpcInstance actor) {
        super(actor);
    }

    @Override
    public NpcInstance getActor() {
        return (NpcInstance)this.actor;
    }

    public void onSpawn() {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnSpawnListener.class.isInstance(listener)) continue;
                ((OnSpawnListener)listener).onSpawn(this.getActor());
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnSpawnListener.class.isInstance(listener)) continue;
                ((OnSpawnListener)listener).onSpawn(this.getActor());
            }
        }
    }

    public void onDecay() {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnDecayListener.class.isInstance(listener)) continue;
                ((OnDecayListener)listener).onDecay(this.getActor());
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnDecayListener.class.isInstance(listener)) continue;
                ((OnDecayListener)listener).onDecay(this.getActor());
            }
        }
    }
}


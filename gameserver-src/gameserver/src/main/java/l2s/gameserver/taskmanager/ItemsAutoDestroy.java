/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.taskmanager;

import java.util.concurrent.ConcurrentLinkedQueue;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.model.items.ItemInstance;

public class ItemsAutoDestroy {
    private static ItemsAutoDestroy _instance;
    private ConcurrentLinkedQueue<ItemInstance> _items = null;
    private ConcurrentLinkedQueue<ItemInstance> _playersItems = null;
    private ConcurrentLinkedQueue<ItemInstance> _herbs = null;

    private ItemsAutoDestroy() {
        if (Config.AUTODESTROY_ITEM_AFTER > 0) {
            this._items = new ConcurrentLinkedQueue();
            ThreadPoolManager.getInstance().scheduleAtFixedRate(new CheckItemsForDestroy(), 60000L, 60000L);
        }
        if (Config.AUTODESTROY_PLAYER_ITEM_AFTER > 0) {
            this._playersItems = new ConcurrentLinkedQueue();
            ThreadPoolManager.getInstance().scheduleAtFixedRate(new CheckPlayersItemsForDestroy(), 60000L, 60000L);
        }
        this._herbs = new ConcurrentLinkedQueue();
        ThreadPoolManager.getInstance().scheduleAtFixedRate(new CheckHerbsForDestroy(), 1000L, 1000L);
    }

    public static ItemsAutoDestroy getInstance() {
        if (_instance == null) {
            _instance = new ItemsAutoDestroy();
        }
        return _instance;
    }

    public void addItem(ItemInstance item) {
        item.setDropTime(System.currentTimeMillis());
        this._items.add(item);
    }

    public void addPlayerItem(ItemInstance item) {
        item.setDropTime(System.currentTimeMillis());
        this._playersItems.add(item);
    }

    public void addHerb(ItemInstance herb) {
        herb.setDropTime(System.currentTimeMillis());
        this._herbs.add(herb);
    }

    public class CheckHerbsForDestroy
    implements Runnable {
        static final long _sleep = 60000L;

        @Override
        public void run() {
            long curtime = System.currentTimeMillis();
            for (ItemInstance item : ItemsAutoDestroy.this._herbs) {
                if (item == null || item.getLastDropTime() == 0L || item.getLocation() != ItemInstance.ItemLocation.VOID) {
                    ItemsAutoDestroy.this._herbs.remove(item);
                    continue;
                }
                if (item.getLastDropTime() + 60000L >= curtime) continue;
                item.deleteMe();
                ItemsAutoDestroy.this._herbs.remove(item);
            }
        }
    }

    public class CheckPlayersItemsForDestroy
    implements Runnable {
        @Override
        public void run() {
            long _sleep = (long)Config.AUTODESTROY_PLAYER_ITEM_AFTER * 1000L;
            long curtime = System.currentTimeMillis();
            for (ItemInstance item : ItemsAutoDestroy.this._playersItems) {
                if (item == null || item.getLastDropTime() == 0L || item.getLocation() != ItemInstance.ItemLocation.VOID) {
                    ItemsAutoDestroy.this._playersItems.remove(item);
                    continue;
                }
                if (item.getLastDropTime() + _sleep >= curtime) continue;
                item.deleteMe();
                ItemsAutoDestroy.this._playersItems.remove(item);
            }
        }
    }

    public class CheckItemsForDestroy
    implements Runnable {
        @Override
        public void run() {
            long _sleep = (long)Config.AUTODESTROY_ITEM_AFTER * 1000L;
            long curtime = System.currentTimeMillis();
            for (ItemInstance item : ItemsAutoDestroy.this._items) {
                if (item == null || item.getLastDropTime() == 0L || item.getLocation() != ItemInstance.ItemLocation.VOID) {
                    ItemsAutoDestroy.this._items.remove(item);
                    continue;
                }
                if (item.getLastDropTime() + _sleep >= curtime) continue;
                item.deleteMe();
                ItemsAutoDestroy.this._items.remove(item);
            }
        }
    }
}


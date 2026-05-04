/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.actor.instances.player;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import l2s.gameserver.dao.CharacterPremiumItemsDAO;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.PremiumItem;

public class PremiumItemList {
    public static final int MAX_ITEMS_SIZE = Integer.MAX_VALUE;
    private List<PremiumItem> _premiumItemList = new ArrayList<PremiumItem>(0);
    private final Player _owner;
    private final ReadWriteLock lock = new ReentrantReadWriteLock();
    private final Lock readLock = this.lock.readLock();
    private final Lock writeLock = this.lock.writeLock();

    public PremiumItemList(Player owner) {
        this._owner = owner;
    }

    public void restore() {
        this._premiumItemList = CharacterPremiumItemsDAO.getInstance().select(this._owner);
    }

    
    public boolean add(PremiumItem item) {
        this.writeLock();
        try {
            PremiumItem same = this.getSame(item);
            if (same != null) {
                long newCount = same.getItemCount() + item.getItemCount();
                if (!CharacterPremiumItemsDAO.getInstance().update(this._owner, item, newCount)) {
                    boolean bl = false;
                    return bl;
                }
                same.setItemCount(newCount);
            } else {
                if (!CharacterPremiumItemsDAO.getInstance().insert(this._owner, item)) {
                    boolean bl = false;
                    return bl;
                }
                this._premiumItemList.add(item);
                Collections.sort(this._premiumItemList, PremiumItemComparator.getInstance());
            }
        }
        finally {
            this.writeUnlock();
        }
        return true;
    }

    public PremiumItem get(int index) {
        this.readLock();
        try {
            index = Math.min(this._premiumItemList.size() - 1, index);
            PremiumItem premiumItem = this._premiumItemList.get(index);
            return premiumItem;
        }
        finally {
            this.readUnlock();
        }
    }

    
    public PremiumItem getSame(PremiumItem item) {
        this.readLock();
        try {
            for (PremiumItem same : this._premiumItemList) {
                if (same.getReceiveTime() != item.getReceiveTime() || same.getItemId() != item.getItemId() || !same.getSender().equals(item.getSender())) continue;
                PremiumItem premiumItem = same;
                return premiumItem;
            }
        }
        finally {
            this.readUnlock();
        }
        return null;
    }

    
    public boolean remove(PremiumItem item, long count) {
        if (count == 0L) {
            return false;
        }
        this.writeLock();
        try {
            if (count != -1L && item.getItemCount() < count) {
                boolean bl = false;
                return bl;
            }
            long newCount = item.getItemCount() - count;
            if (count != -1L && newCount > 0L) {
                if (!CharacterPremiumItemsDAO.getInstance().update(this._owner, item, newCount)) {
                    boolean bl = false;
                    return bl;
                }
                item.setItemCount(newCount);
            } else {
                if (!CharacterPremiumItemsDAO.getInstance().delete(this._owner, item)) {
                    boolean bl = false;
                    return bl;
                }
                this._premiumItemList.remove(item);
            }
        }
        finally {
            this.writeUnlock();
        }
        return true;
    }

    public boolean contains(PremiumItem item) {
        this.readLock();
        try {
            boolean bl = this._premiumItemList.contains(item);
            return bl;
        }
        finally {
            this.readUnlock();
        }
    }

    public int size() {
        this.readLock();
        try {
            int n = this._premiumItemList.size();
            return n;
        }
        finally {
            this.readUnlock();
        }
    }

    public PremiumItem[] values() {
        this.readLock();
        try {
            PremiumItem[] premiumItemArray = this._premiumItemList.toArray(new PremiumItem[this._premiumItemList.size()]);
            return premiumItemArray;
        }
        finally {
            this.readUnlock();
        }
    }

    public boolean isEmpty() {
        this.readLock();
        try {
            boolean bl = this._premiumItemList.isEmpty();
            return bl;
        }
        finally {
            this.readUnlock();
        }
    }

    public String toString() {
        return "PremiumItemList[owner=" + this._owner.getName() + "]";
    }

    public final void writeLock() {
        this.writeLock.lock();
    }

    public final void writeUnlock() {
        this.writeLock.unlock();
    }

    public final void readLock() {
        this.readLock.lock();
    }

    public final void readUnlock() {
        this.readLock.unlock();
    }

    private static class PremiumItemComparator
    implements Comparator<PremiumItem> {
        private static final PremiumItemComparator _instance = new PremiumItemComparator();

        private PremiumItemComparator() {
        }

        private static PremiumItemComparator getInstance() {
            return _instance;
        }

        @Override
        public int compare(PremiumItem o1, PremiumItem o2) {
            if (o2.getReceiveTime() == o1.getReceiveTime()) {
                return o1.getItemId() - o2.getItemId();
            }
            return o2.getReceiveTime() - o1.getReceiveTime();
        }
    }
}


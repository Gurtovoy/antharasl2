/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.cache;

import java.io.Serializable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.model.items.ItemInfo;
import l2s.gameserver.model.items.ItemInstance;
import net.sf.ehcache.Cache;
import net.sf.ehcache.CacheManager;
import net.sf.ehcache.Element;

public class ItemInfoCache {
    private static final ItemInfoCache _instance = new ItemInfoCache();
    private Cache cache = CacheManager.getInstance().getCache(this.getClass().getName());

    public static final ItemInfoCache getInstance() {
        return _instance;
    }

    private ItemInfoCache() {
    }

    public void put(ItemInstance item) {
        this.cache.put(new Element((Object)item.getObjectId(), new ItemInfo(item)));
    }

    public ItemInfo get(int objectId) {
        Element element = this.cache.get((Serializable)Integer.valueOf(objectId));
        ItemInfo info = null;
        if (element != null) {
            info = (ItemInfo)element.getObjectValue();
        }
        Player player = null;
        if (info != null) {
            player = World.getPlayer(info.getOwnerId());
            ItemInstance item = null;
            if (player != null) {
                item = player.getInventory().getItemByObjectId(objectId);
            }
            if (item != null && item.getItemId() == info.getItemId()) {
                info = new ItemInfo(item);
                this.cache.put(new Element((Object)item.getObjectId(), info));
            }
        }
        return info;
    }
}


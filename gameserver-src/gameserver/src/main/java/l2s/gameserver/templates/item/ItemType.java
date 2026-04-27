/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.templates.item;

import l2s.gameserver.handler.items.IItemHandler;
import l2s.gameserver.templates.item.ExItemType;

public interface ItemType {
    public long mask();

    public IItemHandler getHandler();

    public ExItemType getExType();
}


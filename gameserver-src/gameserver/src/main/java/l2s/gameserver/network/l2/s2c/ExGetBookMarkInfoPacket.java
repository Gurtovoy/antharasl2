/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.BookMark;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExGetBookMarkInfoPacket
extends L2GameServerPacket {
    private final int bookmarksCapacity;
    private final BookMark[] bookmarks;

    public ExGetBookMarkInfoPacket(Player player) {
        this.bookmarksCapacity = player.getBookMarkList().getCapacity();
        this.bookmarks = player.getBookMarkList().toArray();
    }

    @Override
    protected void writeImpl() {
        this.writeD(0);
        this.writeD(this.bookmarksCapacity);
        this.writeD(this.bookmarks.length);
        int slotId = 0;
        for (BookMark bookmark : this.bookmarks) {
            this.writeD(++slotId);
            this.writeD(bookmark.x);
            this.writeD(bookmark.y);
            this.writeD(bookmark.z);
            this.writeS(bookmark.getName());
            this.writeD(bookmark.getIcon());
            this.writeS(bookmark.getAcronym());
        }
    }
}


/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.ShortCut;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.skills.TimeStamp;

public abstract class ShortCutPacket
extends L2GameServerPacket {
    public static ShortcutInfo convert(Player player, ShortCut shortCut) {
        ShortcutInfo shortcutInfo = null;
        int page = shortCut.getSlot() + shortCut.getPage() * 12;
        switch (shortCut.getType()) {
            case ITEM: {
                int reuseGroup = -1;
                int currentReuse = 0;
                int reuse = 0;
                int variation1Id = 0;
                int variation2Id = 0;
                ItemInstance item = player.getInventory().getItemByObjectId(shortCut.getId());
                if (item != null) {
                    TimeStamp timeStamp;
                    variation1Id = item.getVariation1Id();
                    variation2Id = item.getVariation2Id();
                    reuseGroup = item.getTemplate().getDisplayReuseGroup();
                    if (item.getTemplate().getReuseDelay() > 0 && (timeStamp = player.getSharedGroupReuse(item.getTemplate().getReuseGroup())) != null) {
                        currentReuse = (int)(timeStamp.getReuseCurrent() / 1000L);
                        reuse = (int)(timeStamp.getReuseBasic() / 1000L);
                    }
                }
                shortcutInfo = new ItemShortcutInfo(shortCut.getType(), page, shortCut.getId(), reuseGroup, currentReuse, reuse, variation1Id, variation2Id, shortCut.getCharacterType());
                break;
            }
            case SKILL: {
                shortcutInfo = new SkillShortcutInfo(shortCut.getType(), page, shortCut.getId(), shortCut.getLevel(), shortCut.getCharacterType());
                break;
            }
            default: {
                shortcutInfo = new ShortcutInfo(shortCut.getType(), page, shortCut.getId(), shortCut.getCharacterType());
            }
        }
        return shortcutInfo;
    }

    protected static class ShortcutInfo {
        protected final ShortCut.ShortCutType _type;
        protected final int _page;
        protected final int _id;
        protected final int _characterType;

        public ShortcutInfo(ShortCut.ShortCutType type, int page, int id, int characterType) {
            this._type = type;
            this._page = page;
            this._id = id;
            this._characterType = characterType;
        }

        protected void write(ShortCutPacket p) {
            p.writeD(this._type.ordinal());
            p.writeD(this._page);
            this.write0(p);
        }

        protected void write0(ShortCutPacket p) {
            p.writeD(this._id);
            p.writeD(this._characterType);
        }
    }

    protected static class SkillShortcutInfo
    extends ShortcutInfo {
        private final int _level;

        public SkillShortcutInfo(ShortCut.ShortCutType type, int page, int id, int level, int characterType) {
            super(type, page, id, characterType);
            this._level = level;
        }

        public int getLevel() {
            return this._level;
        }

        @Override
        protected void write0(ShortCutPacket p) {
            p.writeD(this._id);
            p.writeD(this._level);
            p.writeD(this._id);
            p.writeC(0);
            p.writeD(this._characterType);
        }
    }

    protected static class ItemShortcutInfo
    extends ShortcutInfo {
        private int _reuseGroup;
        private int _currentReuse;
        private int _basicReuse;
        private int _variation1Id;
        private int _variation2Id;

        public ItemShortcutInfo(ShortCut.ShortCutType type, int page, int id, int reuseGroup, int currentReuse, int basicReuse, int variation1Id, int variation2Id, int characterType) {
            super(type, page, id, characterType);
            this._reuseGroup = reuseGroup;
            this._currentReuse = currentReuse;
            this._basicReuse = basicReuse;
            this._variation1Id = variation1Id;
            this._variation2Id = variation2Id;
        }

        @Override
        protected void write0(ShortCutPacket p) {
            p.writeD(this._id);
            p.writeD(this._characterType);
            p.writeD(this._reuseGroup);
            p.writeD(this._currentReuse);
            p.writeD(this._basicReuse);
            p.writeD(this._variation1Id);
            p.writeD(this._variation2Id);
            p.writeD(0);
        }
    }
}


/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.util.Collection;
import l2s.gameserver.model.entity.Hero;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.StatsSet;

public class ExHeroListPacket
extends L2GameServerPacket {
    private Collection<StatsSet> _heroList = Hero.getInstance().getHeroes().valueCollection();

    @Override
    protected final void writeImpl() {
        this.writeD(this._heroList.size());
        for (StatsSet hero : this._heroList) {
            this.writeS(hero.getString("char_name"));
            this.writeD(hero.getInteger("class_id"));
            this.writeS(hero.getString("clan_name", ""));
            this.writeD(0);
            this.writeS(hero.getString("ally_name", ""));
            this.writeD(0);
            this.writeD(hero.getInteger("count"));
            this.writeD(0);
        }
    }
}


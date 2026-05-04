/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExPledgeClassicRaidInfo
extends L2GameServerPacket {
    private final int _lastRaidPhase;
    private final List<Skill> _skills;

    public ExPledgeClassicRaidInfo(Player player) {
        Clan clan = player.getClan();
        this._lastRaidPhase = clan == null ? 0 : clan.getArenaStage();
        this._skills = new ArrayList<Skill>(4);
        this._skills.add(SkillHolder.getInstance().getSkill(55887, 1));
        this._skills.add(SkillHolder.getInstance().getSkill(55887, 2));
        this._skills.add(SkillHolder.getInstance().getSkill(55887, 3));
        this._skills.add(SkillHolder.getInstance().getSkill(55887, 4));
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._lastRaidPhase);
        this.writeD(this._skills.size());
        for (Skill skill : this._skills) {
            this.writeD(skill.getId());
            this.writeD(skill.getLevel());
        }
    }
}


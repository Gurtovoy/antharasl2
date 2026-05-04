package l2s.gameserver.network.l2.s2c;

import java.util.Collection;
import l2s.gameserver.data.xml.holder.PetitionGroupHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.petition.PetitionMainGroup;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.utils.Language;

public class ExResponseShowStepOne
extends L2GameServerPacket {
    private Language _language;

    public ExResponseShowStepOne(Player player) {
        this._language = player.getLanguage();
    }

    @Override
    protected void writeImpl() {
        Collection<PetitionMainGroup> petitionGroups = PetitionGroupHolder.getInstance().getPetitionGroups();
        this.writeD(petitionGroups.size());
        for (PetitionMainGroup group : petitionGroups) {
            this.writeC(group.getId());
            this.writeS(group.getName(this._language));
        }
    }
}


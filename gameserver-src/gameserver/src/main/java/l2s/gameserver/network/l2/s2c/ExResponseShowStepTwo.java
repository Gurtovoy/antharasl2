package l2s.gameserver.network.l2.s2c;

import java.util.Collection;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.petition.PetitionMainGroup;
import l2s.gameserver.model.petition.PetitionSubGroup;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.utils.Language;

public class ExResponseShowStepTwo
extends L2GameServerPacket {
    private Language _language;
    private PetitionMainGroup _petitionMainGroup;

    public ExResponseShowStepTwo(Player player, PetitionMainGroup gr) {
        this._language = player.getLanguage();
        this._petitionMainGroup = gr;
    }

    @Override
    protected void writeImpl() {
        Collection<PetitionSubGroup> subGroups = this._petitionMainGroup.getSubGroups();
        this.writeD(subGroups.size());
        this.writeS(this._petitionMainGroup.getDescription(this._language));
        for (PetitionSubGroup g : subGroups) {
            this.writeC(g.getId());
            this.writeS(g.getName(this._language));
        }
    }
}


/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.data.xml.holder.PlayerTemplateHolder;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.model.base.ClassLevel;
import l2s.gameserver.model.base.Sex;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.player.PlayerTemplate;

public class NewCharacterSuccessPacket
extends L2GameServerPacket {
    private List<ClassId> _chars = new ArrayList<ClassId>();

    public NewCharacterSuccessPacket() {
        for (ClassId classId : ClassId.VALUES) {
            if (!classId.isOfLevel(ClassLevel.NONE)) continue;
            this._chars.add(classId);
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._chars.size());
        for (ClassId temp : this._chars) {
            PlayerTemplate template = PlayerTemplateHolder.getInstance().getPlayerTemplate(temp.getRace(), temp, Sex.MALE);
            this.writeD(temp.getRace().ordinal());
            this.writeD(temp.getId());
            this.writeD(70);
            this.writeD(template.getBaseSTR());
            this.writeD(10);
            this.writeD(70);
            this.writeD(template.getBaseDEX());
            this.writeD(10);
            this.writeD(70);
            this.writeD(template.getBaseCON());
            this.writeD(10);
            this.writeD(70);
            this.writeD(template.getBaseINT());
            this.writeD(10);
            this.writeD(70);
            this.writeD(template.getBaseWIT());
            this.writeD(10);
            this.writeD(70);
            this.writeD(template.getBaseMEN());
            this.writeD(10);
        }
    }
}


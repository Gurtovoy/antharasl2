/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.data.xml.holder.SkillAcquireHolder;
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.SkillLearn;
import l2s.gameserver.model.base.AcquireType;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.s2c.AcquireSkillInfoPacket;
import l2s.gameserver.network.l2.s2c.ExAcquireSkillInfo;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class RequestAquireSkillInfo
extends L2GameClientPacket {
    private int _id;
    private int _level;
    private AcquireType _type;

    @Override
    protected boolean readImpl() {
        this._id = this.readD();
        this._level = this.readD();
        this._type = AcquireType.getById(this.readD());
        return true;
    }

    @Override
    protected void runImpl() {
        SkillLearn skillLearn;
        NpcInstance trainer;
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null || player.isTransformed() || SkillHolder.getInstance().getSkill(this._id, this._level) == null || this._type == null) {
            return;
        }
        if (!(this._type == AcquireType.NORMAL || this._type == AcquireType.MULTICLASS || this._type == AcquireType.CUSTOM || (trainer = player.getLastNpc()) != null && player.checkInteractionDistance(trainer) || player.isGM())) {
            return;
        }
        ClassId selectedMultiClassId = player.getSelectedMultiClassId();
        if (this._type == AcquireType.MULTICLASS) {
            if (selectedMultiClassId == null) {
                return;
            }
        } else {
            selectedMultiClassId = null;
        }
        if ((skillLearn = SkillAcquireHolder.getInstance().getSkillLearn(player, selectedMultiClassId, this._id, this._level, this._type)) == null) {
            return;
        }
        if (this._type == AcquireType.NORMAL) {
            this.sendPacket((L2GameServerPacket)new ExAcquireSkillInfo(player, this._type, skillLearn));
        } else {
            this.sendPacket((L2GameServerPacket)new AcquireSkillInfoPacket(this._type, skillLearn));
        }
    }
}


package l2s.gameserver.network.l2.components;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.StatusUpdatePacket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class StatusUpdate
implements IBroadcastPacket {
    private static final Logger _log = LoggerFactory.getLogger(StatusUpdate.class);
    private final Creature _creature;
    private final Creature _caster;
    private final StatusUpdatePacket.UpdateType _updateType;
    private final int[] _fields;

    public StatusUpdate(Creature creature, Creature caster, StatusUpdatePacket.UpdateType updateType, int ... fields) {
        this._creature = creature;
        this._caster = caster;
        this._updateType = updateType;
        this._fields = fields;
    }

    public StatusUpdate(Creature creature, StatusUpdatePacket.UpdateType updateType, int ... fields) {
        this(creature, null, updateType, fields);
    }

    @Override
    public L2GameServerPacket packet(Player player) {
        StatusUpdatePacket su = new StatusUpdatePacket(this._updateType, this._creature, this._caster);
        block16: for (int field : this._fields) {
            if (!player.canReceiveStatusUpdate(this._creature, this._updateType, field)) continue;
            switch (field) {
                case 9: {
                    su.addAttribute(field, (int)this._creature.getCurrentHp());
                    break;
                }
                case 10: {
                    su.addAttribute(field, this._creature.getMaxHp());
                    break;
                }
                case 11: {
                    su.addAttribute(field, (int)this._creature.getCurrentMp());
                    break;
                }
                case 12: {
                    su.addAttribute(field, this._creature.getMaxMp());
                }
            }
            if (!this._creature.isPlayable()) continue;
            Playable playable = (Playable)this._creature;
            switch (field) {
                case 27: {
                    su.addAttribute(field, playable.getKarma());
                    break;
                }
                case 26: {
                    su.addAttribute(field, playable.getPvpFlag());
                }
            }
            if (!this._creature.isPlayer()) continue;
            switch (field) {
                case 33: {
                    su.addAttribute(field, (int)playable.getCurrentCp());
                    continue block16;
                }
                case 34: {
                    su.addAttribute(field, playable.getMaxCp());
                    continue block16;
                }
                case 14: {
                    su.addAttribute(field, playable.getCurrentLoad());
                    continue block16;
                }
                case 15: {
                    su.addAttribute(field, playable.getMaxLoad());
                }
            }
        }
        if (!su.hasAttributes()) {
            return null;
        }
        return su;
    }
}


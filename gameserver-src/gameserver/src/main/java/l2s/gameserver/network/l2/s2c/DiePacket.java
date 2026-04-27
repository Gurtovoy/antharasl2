/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import java.util.HashMap;
import java.util.Map;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.model.base.RestartType;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.instances.MonsterInstance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class DiePacket
extends L2GameServerPacket {
    private final int _objectId;
    private final boolean _hideDieAnimation;
    private boolean _sweepable = false;
    private int _blessingFeatherDelay = 0;
    private final Map<RestartType, Boolean> _types = new HashMap<RestartType, Boolean>(RestartType.VALUES.length);

    public DiePacket(Creature cha, boolean hideDieAnimation) {
        this._hideDieAnimation = hideDieAnimation;
        this._objectId = cha.getObjectId();
        if (cha.isMonster()) {
            this._sweepable = ((MonsterInstance)cha).isSweepActive();
        } else if (cha.isPlayer()) {
            Player player = (Player)cha;
            this.put(RestartType.FIXED, player.canFixedRessurect());
            this.put(RestartType.AGATHION, player.isAgathionResAvailable());
            this.put(RestartType.TO_VILLAGE, true);
            this.put(RestartType.ADVENTURES_SONG, player.getAbnormalList().contains(22410) || player.getAbnormalList().contains(22411));
            for (Abnormal effect : player.getAbnormalList()) {
                if (effect.getSkill().getId() != 7008) continue;
                this._blessingFeatherDelay = effect.getTimeLeft();
                break;
            }
            Clan clan = null;
            if (this.get(RestartType.TO_VILLAGE)) {
                clan = player.getClan();
            }
            if (clan != null) {
                this.put(RestartType.TO_CLANHALL, clan.getHasHideout() != 0);
                this.put(RestartType.TO_CASTLE, clan.getCastle() != 0);
            }
            for (Event e : cha.getEvents()) {
                e.checkRestartLocs(player, this._types);
            }
        }
    }

    public DiePacket(Creature cha) {
        this(cha, false);
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._objectId);
        this.writeD(this.get(RestartType.TO_VILLAGE));
        this.writeD(this.get(RestartType.TO_CLANHALL));
        this.writeD(this.get(RestartType.TO_CASTLE));
        this.writeD(this.get(RestartType.TO_FLAG));
        this.writeD(this._sweepable ? 1 : 0);
        this.writeD(this.get(RestartType.FIXED));
        this.writeD(0);
        this.writeD(this._blessingFeatherDelay);
        this.writeD(this.get(RestartType.ADVENTURES_SONG));
        this.writeC(this._hideDieAnimation ? 1 : 0);
        this.writeD(this.get(RestartType.AGATHION));
        int itemsCount = 0;
        this.writeD(itemsCount);
        for (int i = 0; i < itemsCount; ++i) {
            this.writeD(0);
        }
    }

    private void put(RestartType t, boolean b) {
        this._types.put(t, b);
    }

    private boolean get(RestartType t) {
        Boolean b = this._types.get(t);
        return b != null && b != false;
    }
}


/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.lang.reference.HardReference
 */
package l2s.gameserver.model.instances;

import java.util.Collections;
import java.util.List;
import l2s.commons.lang.reference.HardReference;
import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.handler.onshiftaction.OnShiftActionHolder;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.model.reference.L2Reference;
import l2s.gameserver.network.l2.components.HtmlMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.ShowTownMapPacket;
import l2s.gameserver.network.l2.s2c.StaticObjectPacket;
import l2s.gameserver.templates.StaticObjectTemplate;

public class StaticObjectInstance
extends GameObject {
    private final HardReference<StaticObjectInstance> reference;
    private final StaticObjectTemplate _template;
    private int _meshIndex;

    public StaticObjectInstance(int objectId, StaticObjectTemplate template) {
        super(objectId);
        this._template = template;
        this.reference = new L2Reference<StaticObjectInstance>(this);
        GameObjectsStorage.put(this);
    }

    public HardReference<StaticObjectInstance> getRef() {
        return this.reference;
    }

    public int getUId() {
        return this._template.getUId();
    }

    public int getType() {
        return this._template.getType();
    }

    @Override
    public void onAction(Player player, boolean shift) {
        if (shift && OnShiftActionHolder.getInstance().callShiftAction(player, StaticObjectInstance.class, this, true)) {
            return;
        }
        if (player.getTarget() != this) {
            player.setTarget(this);
            return;
        }
        if (!player.checkInteractionDistance(this)) {
            if (player.getAI().getIntention() != CtrlIntention.AI_INTENTION_INTERACT) {
                player.getAI().setIntention(CtrlIntention.AI_INTENTION_INTERACT, this, null);
            }
            return;
        }
        if (this._template.getType() == 0) {
            player.sendPacket((IBroadcastPacket)new HtmlMessage(this.getUId()).setFile("newspaper/arena.htm"));
        } else if (this._template.getType() == 2) {
            player.sendPacket((IBroadcastPacket)new ShowTownMapPacket(this._template.getFilePath(), this._template.getMapX(), this._template.getMapY()));
            player.sendActionFailed();
        } else if (this._template.getType() == 4) {
            // empty if block
        }
    }

    @Override
    public List<L2GameServerPacket> addPacketList(Player forPlayer, Creature dropper) {
        return Collections.singletonList(new StaticObjectPacket(this));
    }

    @Override
    public boolean isAttackable(Creature attacker) {
        return false;
    }

    public void broadcastInfo(boolean force) {
        StaticObjectPacket p = new StaticObjectPacket(this);
        for (Player player : World.getAroundObservers(this)) {
            player.sendPacket((IBroadcastPacket)p);
        }
    }

    @Override
    public int getGeoZ(int x, int y, int z) {
        return z;
    }

    public int getMeshIndex() {
        return this._meshIndex;
    }

    public void setMeshIndex(int meshIndex) {
        this._meshIndex = meshIndex;
    }

    @Override
    public boolean isStaticObject() {
        return true;
    }
}


/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.instances;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import l2s.commons.geometry.Rectangle;
import l2s.commons.geometry.Shape;
import l2s.commons.lang.reference.HardReference;
import l2s.gameserver.dao.FencesDAO;
import l2s.gameserver.idfactory.IdFactory;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.model.base.FenceState;
import l2s.gameserver.model.reference.L2Reference;
import l2s.gameserver.network.l2.s2c.DeleteObjectPacket;
import l2s.gameserver.network.l2.s2c.ExColosseumFenceInfoPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class FenceInstance
extends GameObject {
    private static final int FENCE_HEIGHT = 100;
    private final HardReference<FenceInstance> reference = new L2Reference<FenceInstance>(this);
    private final String _name;
    private final int _width;
    private final int _length;
    private final int[] _heightFences;
    private FenceState _state;

    public FenceInstance(int objectId, String name, int width, int length, int height, FenceState state) {
        super(objectId);
        this._name = name;
        this._width = width;
        this._length = length;
        this._state = state;
        if (height > 1) {
            this._heightFences = new int[height - 1];
            for (int i = 0; i < this._heightFences.length; ++i) {
                this._heightFences[i] = IdFactory.getInstance().getNextId();
            }
        } else {
            this._heightFences = new int[0];
        }
        GameObjectsStorage.put(this);
    }

    public HardReference<FenceInstance> getRef() {
        return this.reference;
    }

    @Override
    protected void onDelete() {
        GameObjectsStorage.remove(this);
        super.onDelete();
    }

    @Override
    public String getName() {
        return this._name;
    }

    @Override
    public List<L2GameServerPacket> addPacketList(Player forPlayer, Creature dropper) {
        ArrayList<L2GameServerPacket> packets = new ArrayList<L2GameServerPacket>();
        packets.add(new ExColosseumFenceInfoPacket(this));
        for (int objId : this._heightFences) {
            packets.add(new ExColosseumFenceInfoPacket(objId, this.getX(), this.getY(), this.getZ(), this.getWidth(), this.getLength(), this.getState().getClientId()));
        }
        return packets;
    }

    @Override
    public List<L2GameServerPacket> deletePacketList(Player forPlayer) {
        ArrayList<L2GameServerPacket> packets = new ArrayList<L2GameServerPacket>();
        packets.add(new DeleteObjectPacket(this));
        for (int objId : this._heightFences) {
            packets.add(new DeleteObjectPacket(objId));
        }
        return packets;
    }

    @Override
    public boolean isAttackable(Creature attacker) {
        return false;
    }

    @Override
    public int getGeoZ(int x, int y, int z) {
        return z;
    }

    @Override
    public boolean isFence() {
        return true;
    }

    public void broadcastInfo() {
        ArrayList<ExColosseumFenceInfoPacket> packets = new ArrayList<ExColosseumFenceInfoPacket>();
        packets.add(new ExColosseumFenceInfoPacket(this));
        for (int objId : this._heightFences) {
            packets.add(new ExColosseumFenceInfoPacket(objId, this.getX(), this.getY(), this.getZ(), this.getWidth(), this.getLength(), this.getState().getClientId()));
        }
        Iterator<Player> object = World.getAroundObservers(this).iterator();
        while (object.hasNext()) {
            Player player = object.next();
            player.sendPacket(packets);
        }
    }

    public FenceState getState() {
        return this._state;
    }

    public void setState(FenceState state) {
        if (this._state == state) {
            return;
        }
        boolean geoControlEnabled = this.isGeoControlEnabled();
        this._state = state;
        this.broadcastInfo();
        FencesDAO.getInstance().update(this);
        if (!geoControlEnabled && this.isGeoControlEnabled()) {
            this.activateGeoControl();
        } else if (geoControlEnabled && !this.isGeoControlEnabled()) {
            this.deactivateGeoControl();
        }
    }

    public int getWidth() {
        return this._width;
    }

    public int getLength() {
        return this._length;
    }

    public int getHeight() {
        return this._heightFences.length + 1;
    }

    @Override
    protected Shape makeGeoShape() {
        int x = this.getX();
        int y = this.getY();
        int z = this.getZ();
        int xMin = x - this._width / 2;
        int xMax = x + this._width / 2;
        int yMin = y - this._length / 2;
        int yMax = y + this._length / 2;
        int zMin = z - 100;
        int zMax = z + 100;
        Rectangle rectangle = new Rectangle(xMin, yMin, xMax, yMax);
        rectangle.setZmin(zMin);
        rectangle.setZmax(zMax);
        return rectangle;
    }

    @Override
    protected boolean isGeoControlEnabled() {
        return this._state.isGeodataEnabled();
    }
}


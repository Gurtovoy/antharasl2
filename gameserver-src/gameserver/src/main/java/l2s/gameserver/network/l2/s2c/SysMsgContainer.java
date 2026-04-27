/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.model.base.Element;
import l2s.gameserver.model.entity.residence.Residence;
import l2s.gameserver.model.instances.DoorInstance;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.instances.StaticObjectInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.components.NpcString;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ConfirmDlgPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.skills.SkillInfo;

public abstract class SysMsgContainer<T extends SysMsgContainer<T>>
extends L2GameServerPacket {
    protected SystemMsg _message;
    protected List<IArgument> _arguments;

    protected SysMsgContainer(int messageId) {
        this(SystemMsg.valueOf(messageId));
    }

    protected SysMsgContainer(SystemMsg message) {
        if (message == null) {
            throw new IllegalArgumentException("SystemMsg is null");
        }
        this._message = message;
        this._arguments = new ArrayList<IArgument>(this._message.size());
    }

    protected void writeElements() {
        if (this._message.size() > this._arguments.size()) {
            throw new IllegalArgumentException("Wrong count of arguments: " + this._message);
        }
        if (this instanceof ConfirmDlgPacket) {
            this.writeD(this._message.getId());
            this.writeD(this._arguments.size());
        } else {
            this.writeH(this._message.getId());
            this.writeC(this._arguments.size());
        }
        for (IArgument argument : this._arguments) {
            argument.write(this);
        }
    }

    public T addName(GameObject object) {
        if (object == null) {
            return this.add(new StringArgument(null));
        }
        if (object.isNpc()) {
            NpcInstance npc = (NpcInstance)object;
            if (npc.getTemplate().displayId != 0 || !npc.getName().equals(npc.getTemplate().name)) {
                return this.add(new StringArgument(npc.getName()));
            }
            return this.add(new NpcNameArgument(npc.getNpcId() + 1000000));
        }
        if (object.isServitor()) {
            Servitor servitor = (Servitor)object;
            if (!servitor.getName().equals(servitor.getTemplate().name)) {
                return this.add(new StringArgument(servitor.getName()));
            }
            return this.add(new NpcNameArgument(servitor.getNpcId() + 1000000));
        }
        if (object.isItem()) {
            return this.add(new ItemNameArgument(((ItemInstance)object).getItemId()));
        }
        if (object.isPlayer()) {
            return this.add(new PlayerNameArgument((Player)object));
        }
        if (object.isDoor()) {
            return this.add(new StaticObjectNameArgument(((DoorInstance)object).getDoorId()));
        }
        if (object instanceof StaticObjectInstance) {
            return this.add(new StaticObjectNameArgument(((StaticObjectInstance)object).getUId()));
        }
        return this.add(new StringArgument(object.getName()));
    }

    public T addInstanceName(int id) {
        return this.add(new InstanceNameArgument(id));
    }

    public T addSysString(int id) {
        return this.add(new SysStringArgument(id));
    }

    public T addSkillName(SkillInfo skillInfo) {
        return this.addSkillName(skillInfo.getDisplayId(), skillInfo.getDisplayLevel());
    }

    public T addSkillName(int id, int level) {
        return this.add(new SkillArgument(id, level));
    }

    public T addItemName(int item_id) {
        return this.add(new ItemNameArgument(item_id));
    }

    public T addItemNameWithAugmentation(ItemInstance item) {
        return this.add(new ItemNameWithAugmentationArgument(item.getItemId(), item.isAugmented()));
    }

    public T addZoneName(Creature c) {
        return this.addZoneName(c.getX(), c.getY(), c.getZ());
    }

    public T addZoneName(Location loc) {
        return this.add(new ZoneArgument(loc.x, loc.y, loc.z));
    }

    public T addZoneName(int x, int y, int z) {
        return this.add(new ZoneArgument(x, y, z));
    }

    public T addResidenceName(Residence r) {
        return this.add(new ResidenceArgument(r.getId()));
    }

    public T addResidenceName(int i) {
        return this.add(new ResidenceArgument(i));
    }

    public T addElementName(int i) {
        return this.add(new ElementNameArgument(i));
    }

    public T addElementName(Element i) {
        return this.add(new ElementNameArgument(i.getId()));
    }

    public T addFactionName(int i) {
        return this.add(new FactionNameArgument(i));
    }

    public T addClassName(int i) {
        return this.add(new ClassNameArgument(i));
    }

    public T addClassName(ClassId i) {
        return this.add(new ClassNameArgument(i.getId()));
    }

    public T addInteger(double i) {
        return this.add(new IntegerArgument((int)i));
    }

    public T addLong(long i) {
        return this.add(new LongArgument(i));
    }

    public T addByte(byte i) {
        return this.add(new ByteArgument(i));
    }

    public T addString(String t) {
        return this.add(new StringArgument(t));
    }

    public T addHpChange(int targetId, int attackerId, int damage) {
        return this.add(new HpChangeArgument(targetId, attackerId, damage));
    }

    public T addNpcString(NpcString npcString, String ... arg) {
        return this.add(new NpcStringArgument(npcString, arg));
    }

    protected T add(IArgument arg) {
        this._arguments.add(arg);
        return (T)this;
    }

    public static class NpcStringArgument
    extends IArgument {
        private final NpcString _npcString;
        private final String[] _parameters;

        public NpcStringArgument(NpcString npcString, String ... arg) {
            this._npcString = npcString;
            this._parameters = arg;
        }

        @Override
        void writeData(SysMsgContainer<?> message) {
            ((SysMsgContainer)message).writeD(this._npcString.getId());
            for (String st : this._parameters) {
                ((SysMsgContainer)message).writeS(st);
            }
        }

        @Override
        Types getType() {
            return Types.NPCSTRING;
        }
    }

    public static class HpChangeArgument
    extends IArgument {
        private int _targetId;
        private int _attackerId;
        private int _hp;

        public HpChangeArgument(int targetId, int attackerId, int hp) {
            this._targetId = targetId;
            this._attackerId = attackerId;
            this._hp = hp;
        }

        @Override
        void writeData(SysMsgContainer<?> message) {
            ((SysMsgContainer)message).writeD(this._targetId);
            ((SysMsgContainer)message).writeD(this._attackerId);
            ((SysMsgContainer)message).writeD(this._hp);
        }

        @Override
        Types getType() {
            return Types.HP_CHANGE;
        }
    }

    public static class ClassNameArgument
    extends IntegerArgument {
        public ClassNameArgument(int classId) {
            super(classId);
        }

        @Override
        Types getType() {
            return Types.CLASS_NAME;
        }
    }

    public static class PlayerNameArgument
    extends IArgument {
        private final Player _player;

        public PlayerNameArgument(Player player) {
            this._player = player;
        }

        @Override
        void writeData(SysMsgContainer<?> message) {
            ((SysMsgContainer)message).writeS(this._player.getVisibleName(((GameClient)message.getClient()).getActiveChar()));
        }

        @Override
        Types getType() {
            return Types.PLAYER_NAME;
        }
    }

    public static class FactionNameArgument
    extends ByteArgument {
        public FactionNameArgument(int type) {
            super((byte)type);
        }

        @Override
        public Types getType() {
            return Types.FACTION_NAME;
        }
    }

    public static class ElementNameArgument
    extends ByteArgument {
        public ElementNameArgument(int type) {
            super((byte)type);
        }

        @Override
        Types getType() {
            return Types.ELEMENT_NAME;
        }
    }

    public static class ZoneArgument
    extends IArgument {
        private final int _x;
        private final int _y;
        private final int _z;

        public ZoneArgument(int t1, int t2, int t3) {
            this._x = t1;
            this._y = t2;
            this._z = t3;
        }

        @Override
        void writeData(SysMsgContainer<?> message) {
            ((SysMsgContainer)message).writeD(this._x);
            ((SysMsgContainer)message).writeD(this._y);
            ((SysMsgContainer)message).writeD(this._z);
        }

        @Override
        Types getType() {
            return Types.ZONE_NAME;
        }
    }

    public static class SkillArgument
    extends IArgument {
        private final int _skillId;
        private final int _skillLevel;

        public SkillArgument(int t1, int t2) {
            this._skillId = t1;
            this._skillLevel = t2;
        }

        @Override
        void writeData(SysMsgContainer<?> message) {
            ((SysMsgContainer)message).writeD(this._skillId);
            ((SysMsgContainer)message).writeH(this._skillLevel);
        }

        @Override
        Types getType() {
            return Types.SKILL_NAME;
        }
    }

    public static class StringArgument
    extends IArgument {
        private final String _data;

        public StringArgument(String da) {
            this._data = da == null ? "null" : da;
        }

        @Override
        void writeData(SysMsgContainer<?> message) {
            ((SysMsgContainer)message).writeS(this._data);
        }

        @Override
        Types getType() {
            return Types.TEXT;
        }
    }

    public static class ShortArgument
    extends IArgument {
        private final short _data;

        public ShortArgument(short da) {
            this._data = da;
        }

        @Override
        void writeData(SysMsgContainer<?> message) {
            ((SysMsgContainer)message).writeH(this._data);
        }

        @Override
        Types getType() {
            return Types.SHORT;
        }
    }

    public static class ByteArgument
    extends IArgument {
        private final byte _data;

        public ByteArgument(byte da) {
            this._data = da;
        }

        @Override
        void writeData(SysMsgContainer<?> message) {
            ((SysMsgContainer)message).writeC(this._data);
        }

        @Override
        Types getType() {
            return Types.BYTE;
        }
    }

    public static class LongArgument
    extends IArgument {
        private final long _data;

        public LongArgument(long da) {
            this._data = da;
        }

        @Override
        void writeData(SysMsgContainer<?> message) {
            ((SysMsgContainer)message).writeQ(this._data);
        }

        @Override
        Types getType() {
            return Types.LONG;
        }
    }

    public static class StaticObjectNameArgument
    extends IntegerArgument {
        public StaticObjectNameArgument(int da) {
            super(da);
        }

        @Override
        Types getType() {
            return Types.STATIC_OBJECT_NAME;
        }
    }

    public static class ResidenceArgument
    extends IntegerArgument {
        public ResidenceArgument(int da) {
            super(da);
        }

        @Override
        Types getType() {
            return Types.RESIDENCE_NAME;
        }
    }

    public static class SysStringArgument
    extends ShortArgument {
        public SysStringArgument(int da) {
            super((short)da);
        }

        @Override
        Types getType() {
            return Types.SYSTEM_STRING;
        }
    }

    public static class InstanceNameArgument
    extends IntegerArgument {
        public InstanceNameArgument(int da) {
            super(da);
        }

        @Override
        Types getType() {
            return Types.INSTANCE_NAME;
        }
    }

    public static class ItemNameWithAugmentationArgument
    extends IArgument {
        private final int _itemId;
        private final boolean _augmented;

        public ItemNameWithAugmentationArgument(int itemId, boolean augmented) {
            this._itemId = itemId;
            this._augmented = augmented;
        }

        @Override
        Types getType() {
            return Types.ITEM_NAME_WITH_AUGMENTATION;
        }

        @Override
        void writeData(SysMsgContainer<?> message) {
            ((SysMsgContainer)message).writeD(this._itemId);
            message.writeC(this._augmented);
        }
    }

    public static class ItemNameArgument
    extends IntegerArgument {
        public ItemNameArgument(int da) {
            super(da);
        }

        @Override
        Types getType() {
            return Types.ITEM_NAME;
        }
    }

    public static class NpcNameArgument
    extends IntegerArgument {
        public NpcNameArgument(int da) {
            super(da);
        }

        @Override
        Types getType() {
            return Types.NPC_NAME;
        }
    }

    public static class IntegerArgument
    extends IArgument {
        private final int _data;

        public IntegerArgument(int da) {
            this._data = da;
        }

        @Override
        public void writeData(SysMsgContainer<?> message) {
            ((SysMsgContainer)message).writeD(this._data);
        }

        @Override
        Types getType() {
            return Types.NUMBER;
        }
    }

    public static abstract class IArgument {
        void write(SysMsgContainer<?> m) {
            if (m instanceof ConfirmDlgPacket) {
                ((SysMsgContainer)m).writeD(this.getType().ordinal());
            } else {
                ((SysMsgContainer)m).writeC(this.getType().ordinal());
            }
            this.writeData(m);
        }

        abstract Types getType();

        abstract void writeData(SysMsgContainer<?> var1);
    }

    public static enum Types {
        TEXT,
        NUMBER,
        NPC_NAME,
        ITEM_NAME,
        SKILL_NAME,
        RESIDENCE_NAME,
        LONG,
        ZONE_NAME,
        ITEM_NAME_WITH_AUGMENTATION,
        ELEMENT_NAME,
        INSTANCE_NAME,
        STATIC_OBJECT_NAME,
        PLAYER_NAME,
        SYSTEM_STRING,
        NPCSTRING,
        CLASS_NAME,
        HP_CHANGE,
        NUMBER_UNK,
        UNK_18,
        BYTE_UNK,
        BYTE,
        SHORT,
        UNK_22,
        UNK_23,
        FACTION_NAME;

    }
}


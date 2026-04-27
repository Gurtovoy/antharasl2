/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.net.nio.impl.SendablePacket
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.network.l2.s2c;

import l2s.commons.net.nio.impl.SendablePacket;
import l2s.gameserver.GameServer;
import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.Element;
import l2s.gameserver.model.base.MultiSellIngredient;
import l2s.gameserver.model.items.ItemInfo;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.ServerPacketOpcodes;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.updatetype.IUpdateTypeComponent;
import l2s.gameserver.skills.TimeStamp;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.item.support.Ensoul;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class L2GameServerPacket
extends SendablePacket<GameClient>
implements IBroadcastPacket {
    private static final int IS_AUGMENTED = 1;
    private static final int IS_ELEMENTED = 2;
    private static final int HAVE_ENCHANT_OPTIONS = 4;
    private static final int VISUAL_CHANGED = 8;
    private static final int HAVE_ENSOUL = 16;
    private static final int REUSE_DELAY = 64;
    private static final Logger _log = LoggerFactory.getLogger(L2GameServerPacket.class);

    public final boolean write() {
        if (!this.canWrite()) {
            return false;
        }
        try {
            if (this.writeOpcodes()) {
                this.writeImpl();
                return true;
            }
        }
        catch (Exception e) {
            _log.error("Client: " + this.getClient() + " - Failed writing: " + this.getType() + " - Server Version: " + GameServer.getInstance().getVersion().getRevisionNumber(), (Throwable)e);
        }
        return false;
    }

    protected ServerPacketOpcodes getOpcodes() {
        try {
            return ServerPacketOpcodes.valueOf(this.getClass().getSimpleName());
        }
        catch (Exception e) {
            _log.error("Cannot find serverpacket opcode: " + this.getClass().getSimpleName() + "!");
            return null;
        }
    }

    protected boolean writeOpcodes() {
        ServerPacketOpcodes opcodes = this.getOpcodes();
        if (opcodes == null) {
            return false;
        }
        this.writeC(opcodes.getId());
        int exOpcode = opcodes.getExId();
        if (exOpcode >= 0) {
            this.writeH(exOpcode);
        }
        return true;
    }

    protected abstract void writeImpl();

    protected boolean canWrite() {
        return true;
    }

    protected void writeD(boolean b) {
        this.writeD(b ? 1 : 0);
    }

    protected void writeH(boolean b) {
        this.writeH(b ? 1 : 0);
    }

    protected void writeC(boolean b) {
        this.writeC(b ? 1 : 0);
    }

    protected void writeDD(int[] values, boolean sendCount) {
        if (sendCount) {
            this.getByteBuffer().putInt(values.length);
        }
        for (int value : values) {
            this.getByteBuffer().putInt(value);
        }
    }

    protected void writeDD(int[] values) {
        this.writeDD(values, false);
    }

    protected void writeOptionalD(int value) {
        if (value >= Short.MAX_VALUE) {
            this.writeH(Short.MAX_VALUE);
            this.writeD(value);
        } else {
            this.writeH(value);
        }
    }

    protected void writeItemInfo(ItemInstance item) {
        this.writeItemInfo(null, item, item.getCount());
    }

    protected void writeItemInfo(Player player, ItemInstance item) {
        this.writeItemInfo(player, item, item.getCount());
    }

    protected void writeItemInfo(ItemInstance item, long count) {
        this.writeItemInfo(null, item, count);
    }

    protected void writeItemInfo(Player player, ItemInstance item, long count) {
        TimeStamp sts;
        int flags = 0;
        if (item.isAugmented()) {
            flags |= 1;
        }
        int attackElementValue = item.getAttackElementValue();
        int defenceFire = item.getDefenceFire();
        int defenceWater = item.getDefenceWater();
        int defenceWind = item.getDefenceWind();
        int defenceEarth = item.getDefenceEarth();
        int defenceHoly = item.getDefenceHoly();
        int defenceUnholy = item.getDefenceUnholy();
        if (attackElementValue > 0 || defenceFire > 0 || defenceWater > 0 || defenceWind > 0 || defenceEarth > 0 || defenceHoly > 0 || defenceUnholy > 0) {
            flags |= 2;
        }
        for (int enchantOption : item.getEnchantOptions()) {
            if (enchantOption <= 0) continue;
            flags |= 4;
            break;
        }
        if (item.getVisualId() > 0) {
            flags |= 8;
        }
        Ensoul[] normalEnsouls = item.getNormalEnsouls();
        Ensoul[] specialEnsouls = item.getSpecialEnsouls();
        if (normalEnsouls.length > 0 || specialEnsouls.length > 0) {
            flags |= 0x10;
        }
        int reuseTimeleft = 0;
        if (player != null && (sts = player.getSharedGroupReuse(item.getTemplate().getReuseGroup())) != null && sts.hasNotPassed() && (reuseTimeleft = (int)sts.getReuseCurrent()) > 0) {
            flags |= 0x40;
        }
        this.writeC(flags);
        this.writeD(item.getObjectId());
        this.writeD(item.getItemId());
        this.writeC(item.isEquipped() ? -1 : item.getEquipSlot());
        this.writeQ(count);
        this.writeC(item.getTemplate().getType2());
        this.writeC(item.getCustomType1());
        this.writeH(item.isEquipped() ? 1 : 0);
        this.writeQ(item.getBodyPart());
        this.writeC(item.getFixedEnchantLevel(player));
        this.writeC(item.getCustomType2());
        this.writeD(item.getShadowLifeTime());
        this.writeD(item.getTemporalLifeTime());
        if (player != null) {
            this.writeC(!item.getTemplate().isBlocked(player, item));
        } else {
            this.writeC(1);
        }
        this.writeH(0);
        if ((flags & 1) == 1) {
            this.writeD(item.getVariation1Id());
            this.writeD(item.getVariation2Id());
        }
        if ((flags & 2) == 2) {
            this.writeH(item.getAttackElement().getId());
            this.writeH(attackElementValue);
            this.writeH(defenceFire);
            this.writeH(defenceWater);
            this.writeH(defenceWind);
            this.writeH(defenceEarth);
            this.writeH(defenceHoly);
            this.writeH(defenceUnholy);
        }
        if ((flags & 4) == 4) {
            this.writeD(item.getEnchantOptions()[0]);
            this.writeD(item.getEnchantOptions()[1]);
            this.writeD(item.getEnchantOptions()[2]);
        }
        if ((flags & 8) == 8) {
            this.writeD(item.getVisualId());
        }
        if ((flags & 0x10) == 16) {
            this.writeC(normalEnsouls.length);
            for (Ensoul ensoul : normalEnsouls) {
                this.writeD(ensoul.getId());
            }
            this.writeC(specialEnsouls.length);
            for (Ensoul ensoul : specialEnsouls) {
                this.writeD(ensoul.getId());
            }
        }
        if ((flags & 0x40) == 64) {
            this.writeD(reuseTimeleft);
        }
    }

    protected void writeItemInfo(ItemInfo item) {
        this.writeItemInfo(item, item.getCount());
    }

    protected void writeItemInfo(ItemInfo item, long count) {
        int flags = 0;
        if (item.getVariation1Id() > 0 || item.getVariation2Id() > 0) {
            flags |= 1;
        }
        int attackElementValue = item.getAttackElementValue();
        int defenceFire = item.getDefenceFire();
        int defenceWater = item.getDefenceWater();
        int defenceWind = item.getDefenceWind();
        int defenceEarth = item.getDefenceEarth();
        int defenceHoly = item.getDefenceHoly();
        int defenceUnholy = item.getDefenceUnholy();
        if (attackElementValue > 0 || defenceFire > 0 || defenceWater > 0 || defenceWind > 0 || defenceEarth > 0 || defenceHoly > 0 || defenceUnholy > 0) {
            flags |= 2;
        }
        for (int enchantOption : item.getEnchantOptions()) {
            if (enchantOption <= 0) continue;
            flags |= 4;
            break;
        }
        if (item.getVisualId() > 0) {
            flags |= 8;
        }
        Ensoul[] normalEnsouls = item.getNormalEnsouls();
        Ensoul[] specialEnsouls = item.getSpecialEnsouls();
        if (normalEnsouls.length > 0 || specialEnsouls.length > 0) {
            flags |= 0x10;
        }
        this.writeC(flags);
        this.writeD(item.getObjectId());
        this.writeD(item.getItemId());
        this.writeC(item.isEquipped() ? -1 : item.getEquipSlot());
        this.writeQ(count);
        this.writeC(item.getItem().getType2());
        this.writeC(item.getCustomType1());
        this.writeH(item.isEquipped() ? 1 : 0);
        this.writeQ(item.getItem().getBodyPart());
        this.writeC(item.getEnchantLevel());
        this.writeC(item.getCustomType2());
        this.writeD(item.getShadowLifeTime());
        this.writeD(item.getTemporalLifeTime());
        this.writeC(!item.isBlocked());
        this.writeH(0);
        if ((flags & 1) == 1) {
            this.writeD(item.getVariation1Id());
            this.writeD(item.getVariation2Id());
        }
        if ((flags & 2) == 2) {
            this.writeH(item.getAttackElement());
            this.writeH(attackElementValue);
            this.writeH(defenceFire);
            this.writeH(defenceWater);
            this.writeH(defenceWind);
            this.writeH(defenceEarth);
            this.writeH(defenceHoly);
            this.writeH(defenceUnholy);
        }
        if ((flags & 4) == 4) {
            this.writeD(item.getEnchantOptions()[0]);
            this.writeD(item.getEnchantOptions()[1]);
            this.writeD(item.getEnchantOptions()[2]);
        }
        if ((flags & 8) == 8) {
            this.writeD(item.getVisualId());
        }
        if ((flags & 0x10) == 16) {
            this.writeC(normalEnsouls.length);
            for (Ensoul ensoul : normalEnsouls) {
                this.writeD(ensoul.getId());
            }
            this.writeC(specialEnsouls.length);
            for (Ensoul ensoul : specialEnsouls) {
                this.writeD(ensoul.getId());
            }
        }
        if ((flags & 0x40) == 64) {
            this.writeD(0);
        }
    }

    protected void writeItemElements(MultiSellIngredient item) {
        if (item.getItemId() <= 0) {
            this.writeItemElements();
            return;
        }
        ItemTemplate i = ItemHolder.getInstance().getTemplate(item.getItemId());
        if (item.getItemAttributes().getValue() > 0) {
            if (i.isWeapon()) {
                Element e = item.getItemAttributes().getElement();
                this.writeH(e.getId());
                this.writeH(item.getItemAttributes().getValue(e) + i.getBaseAttributeValue(e));
                this.writeH(0);
                this.writeH(0);
                this.writeH(0);
                this.writeH(0);
                this.writeH(0);
                this.writeH(0);
            } else if (i.isArmor()) {
                this.writeH(-1);
                this.writeH(0);
                for (Element e : Element.VALUES) {
                    this.writeH(item.getItemAttributes().getValue(e) + i.getBaseAttributeValue(e));
                }
            } else {
                this.writeItemElements();
            }
        } else {
            this.writeItemElements();
        }
    }

    protected void writeItemElements() {
        this.writeH(-1);
        this.writeH(0);
        this.writeH(0);
        this.writeH(0);
        this.writeH(0);
        this.writeH(0);
        this.writeH(0);
        this.writeH(0);
    }

    public String getType() {
        return "[S] " + this.getClass().getSimpleName();
    }

    @Override
    public L2GameServerPacket packet(Player player) {
        return this;
    }

    protected static boolean containsMask(int masks, IUpdateTypeComponent type) {
        return (masks & type.getMask()) == type.getMask();
    }
}


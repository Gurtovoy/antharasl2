package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.FishDataHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExAutoFishAvailable;
import l2s.gameserver.templates.fish.LureTemplate;
import l2s.gameserver.templates.fish.RodTemplate;
import l2s.gameserver.templates.item.WeaponTemplate;

public class RequestExAutoFish
extends L2GameClientPacket {
    @Override
    protected boolean readImpl() {
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (activeChar.isFishing()) {
            activeChar.getFishing().stop();
        } else {
            activeChar.sendPacket((IBroadcastPacket)ExAutoFishAvailable.REMOVE);
            if (!activeChar.isInZone(Zone.ZoneType.FISHING)) {
                return;
            }
            if (Config.FISHING_ONLY_PREMIUM_ACCOUNTS && !activeChar.hasPremiumAccount()) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CAN_ONLY_FUSH_DURING_THE_PAID_PERIOD);
                return;
            }
            if (Config.FISHING_MINIMUM_LEVEL > activeChar.getLevel()) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CAN_ONLY_FUSH_DURING_THE_PAID_PERIOD);
                return;
            }
            if (activeChar.getPrivateStoreType() != 0) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_FISH_WHILE_USING_A_RECIPE_BOOK_PRIVATE_MANUFACTURE_OR_PRIVATE_STORE);
                return;
            }
            WeaponTemplate weaponItem = activeChar.getActiveWeaponTemplate();
            if (weaponItem == null || weaponItem.getItemType() != WeaponTemplate.WeaponType.ROD) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_A_FISHING_POLE_EQUIPPED);
                return;
            }
            RodTemplate rod = FishDataHolder.getInstance().getRod(weaponItem.getItemId());
            if (rod == null) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_A_FISHING_POLE_EQUIPPED);
                return;
            }
            ItemInstance lureItem = activeChar.getInventory().getPaperdollItem(8);
            if (lureItem == null || lureItem.getCount() < (long)rod.getShotConsumeCount()) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_MUST_PUT_BAIT_ON_YOUR_HOOK_BEFORE_YOU_CAN_FISH);
                return;
            }
            LureTemplate lure = FishDataHolder.getInstance().getLure(lureItem.getItemId());
            if (lure == null) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_MUST_PUT_BAIT_ON_YOUR_HOOK_BEFORE_YOU_CAN_FISH);
                return;
            }
            if (activeChar.isInWater()) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_FISH_WHILE_UNDER_WATER);
                return;
            }
            if (activeChar.isInBoat() || activeChar.isTransformed()) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_FISH_WHILE_UNDER_WATER);
                return;
            }
            Location hookLoc = activeChar.getFishing().findHookLocation();
            if (hookLoc == null) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANT_FISH_HERE);
                return;
            }
            activeChar.getFishing().start(rod, lure, hookLoc);
        }
    }
}


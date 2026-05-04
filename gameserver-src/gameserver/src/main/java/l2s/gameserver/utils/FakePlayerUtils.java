package l2s.gameserver.utils;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.LineNumberReader;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.ai.FakeAI;
import l2s.gameserver.data.xml.holder.FakeItemHolder;
import l2s.gameserver.data.xml.holder.SkillAcquireHolder;
import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.handler.items.IItemHandler;
import l2s.gameserver.handler.items.impl.BlessedSpiritShotItemHandler;
import l2s.gameserver.handler.items.impl.SoulShotItemHandler;
import l2s.gameserver.handler.items.impl.SpiritShotItemHandler;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.SkillLearn;
import l2s.gameserver.model.base.AcquireType;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.model.base.SoulShotType;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.PcInventory;
import l2s.gameserver.network.l2.c2s.Say2C;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.network.l2.components.ChatType;
import l2s.gameserver.templates.item.ItemGrade;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.item.WeaponTemplate;
import l2s.gameserver.templates.item.data.ItemData;
import l2s.gameserver.utils.ItemFunctions;
import org.apache.commons.lang3.StringUtils;
import org.napile.primitive.collections.IntCollection;
import org.napile.primitive.lists.IntList;
import org.napile.primitive.lists.impl.ArrayIntList;

public class FakePlayerUtils {
    private static final String[] PM_MESSAGES;
    private static final String[] SHOUT_MESSAGES;
    private static final String[] TRADE_MESSAGES;

    public static void writeInPrivateChat(FakeAI ai, String receiver) {
        if (PM_MESSAGES.length > 0 && Rnd.chance((int)80)) {
            ThreadPoolManager.getInstance().schedule(() -> Say2C.writeToChat(ai.getActor(), (String)Rnd.get((Object[])PM_MESSAGES), ChatType.TELL, receiver), Rnd.get((int)3000, (int)20000));
        }
    }

    public static void writeToRandomChat(FakeAI ai) {
        if (SHOUT_MESSAGES.length > 0 && Rnd.chance((int)10)) {
            Say2C.writeToChat(ai.getActor(), (String)Rnd.get((Object[])SHOUT_MESSAGES), ChatType.SHOUT, null);
        } else if (TRADE_MESSAGES.length > 0 && Rnd.chance((int)10)) {
            Say2C.writeToChat(ai.getActor(), (String)Rnd.get((Object[])TRADE_MESSAGES), ChatType.TRADE, null);
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public static void checkInventory(FakeAI ai) {
        Player player = ai.getActor();
        player.getInventory().writeLock();
        try {
            for (ItemInstance item : player.getInventory().getItems()) {
                if (item.isEquipped() || player.isAutoShot(item.getItemId()) || item.getItemId() == 1785 || item.getItemId() == 3031) continue;
                player.getInventory().removeItem(item);
            }
        }
        finally {
            player.getInventory().writeUnlock();
        }
        FakePlayerUtils.addArrow(player);
        FakePlayerUtils.addShot(player);
        if (ItemFunctions.getItemCount(player, 1785) < 1000L) {
            ItemFunctions.addItem(player, 1785, 1000L, false);
        }
        if (ItemFunctions.getItemCount(player, 3031) < 1000L) {
            ItemFunctions.addItem(player, 3031, 1000L, false);
        }
    }

    public static IntList checkEquip(FakeAI ai) {
        IntList cloaks;
        IntList hairs;
        boolean checkAllEquip;
        Player player = ai.getActor();
        int equipedGrade = player.getVarInt("equiped_grade", 0);
        int expertiseIndex = player.getExpertiseIndex();
        PcInventory inventory = player.getInventory();
        boolean checkWeapon = inventory.getPaperdollItem(7) == null;
        boolean checkHead = inventory.getPaperdollItem(6) == null;
        boolean checkGloves = inventory.getPaperdollItem(9) == null;
        boolean checkChest = inventory.getPaperdollItem(10) == null;
        boolean checkLegs = inventory.getPaperdollItem(11) == null;
        boolean checkFeet = inventory.getPaperdollItem(12) == null;
        boolean checkArmor = checkChest && checkLegs;
        boolean checkREar = inventory.getPaperdollItem(1) == null;
        boolean checkLEar = inventory.getPaperdollItem(2) == null;
        boolean checkNeck = inventory.getPaperdollItem(3) == null;
        boolean checkRFinger = inventory.getPaperdollItem(4) == null;
        boolean checkLFinger = inventory.getPaperdollItem(5) == null;
        boolean checkAccessory = checkREar && checkLEar && checkNeck && checkRFinger && checkLFinger;
        boolean checkHair = inventory.getPaperdollItem(15) == null;
        boolean checkDHair = inventory.getPaperdollItem(16) == null;
        boolean checkHairs = player.getLevel() >= 40 && checkHair && checkDHair;
        boolean checkCloak = player.getLevel() >= 85 && inventory.getPaperdollItem(13) == null;
        boolean bl = checkAllEquip = (equipedGrade == 0 || equipedGrade < expertiseIndex) && Rnd.chance((int)player.getLevel());
        if (checkAllEquip) {
            player.setVar("equiped_grade", expertiseIndex);
        }
        ArrayIntList equip = new ArrayIntList();
        if (checkAllEquip || checkAccessory) {
            equip.addAll((IntCollection)FakeItemHolder.getInstance().getRandomItems(player, "Accessory", expertiseIndex));
        }
        if (checkAllEquip || checkArmor) {
            equip.addAll((IntCollection)FakeItemHolder.getInstance().getRandomItems(player, "Armor", expertiseIndex));
        }
        if (checkAllEquip || checkWeapon) {
            equip.addAll((IntCollection)FakeItemHolder.getInstance().getRandomItems(player, "Weapon", expertiseIndex));
        }
        if ((checkHairs && Rnd.chance((int)25) || Rnd.chance((int)5)) && !(hairs = FakeItemHolder.getInstance().getHairAccessories()).isEmpty()) {
            equip.add(Rnd.get((int[])hairs.toArray()));
        }
        if ((checkCloak && Rnd.chance((int)25) || Rnd.chance((int)5)) && !(cloaks = FakeItemHolder.getInstance().getCloaks()).isEmpty()) {
            equip.add(Rnd.get((int[])cloaks.toArray()));
        }
        return equip;
    }

    public static void checkAutoShots(FakeAI ai) {
        Player player = ai.getActor();
        for (ItemInstance item : player.getInventory().getItems()) {
            IItemHandler handler = item.getTemplate().getHandler();
            if (handler == null || !handler.isAutoUse()) continue;
            if (handler instanceof SpiritShotItemHandler || handler instanceof BlessedSpiritShotItemHandler) {
                player.addAutoShot(item.getItemId(), true, SoulShotType.SPIRITSHOT);
            } else if (handler instanceof SoulShotItemHandler) {
                player.addAutoShot(item.getItemId(), true, SoulShotType.SOULSHOT);
            }
            player.useItem(item, false, false);
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public static boolean addEquip(FakeAI ai, int itemId) {
        ItemTemplate item = ItemHolder.getInstance().getTemplate(itemId);
        if (item == null) {
            return false;
        }
        Player player = ai.getActor();
        player.getInventory().writeLock();
        try {
            ItemInstance itemInstance = player.getInventory().addItem(itemId, 1L);
            if (ItemFunctions.checkIfCanEquip(player, itemInstance) == null) {
                if (itemInstance.canBeEnchanted() && itemInstance.getGrade() != ItemGrade.NONE) {
                    int enchant = 0;
                    for (int i = 0; i <= 10 && Rnd.chance((int)30); ++i) {
                        ++enchant;
                    }
                    itemInstance.setEnchantLevel(enchant);
                }
                player.getInventory().equipItem(itemInstance);
                boolean bl = true;
                return bl;
            }
        }
        finally {
            player.getInventory().writeUnlock();
        }
        return false;
    }

    public static void addArrow(Player player) {
        if (player.getActiveWeaponTemplate() != null && (player.getActiveWeaponTemplate().getItemType() == WeaponTemplate.WeaponType.BOW || player.getActiveWeaponTemplate().getItemType() == WeaponTemplate.WeaponType.CROSSBOW || player.getActiveWeaponTemplate().getItemType() == WeaponTemplate.WeaponType.TWOHANDCROSSBOW)) {
            int itemId = 0;
            int itemId2 = 0;
            switch (player.getActiveWeaponTemplate().getGrade()) {
                case NONE: {
                    itemId = 17;
                    break;
                }
                case D: {
                    itemId = 1341;
                    break;
                }
                case C: {
                    itemId = 1342;
                    break;
                }
                case B: {
                    itemId = 1343;
                    break;
                }
                case A: {
                    itemId = 1344;
                }
            }
            if (player.getInventory().getCountOf(itemId) < 1000L) {
                ItemFunctions.addItem(player, itemId, 1000L, false);
            }
            if (player.getInventory().getCountOf(itemId2) < 1000L) {
                ItemFunctions.addItem(player, itemId2, 1000L, false);
            }
        }
    }

    public static void addShot(Player player) {
        if (player.getActiveWeaponTemplate() != null) {
            int itemIdSS = 0;
            int itemIdBSS = 0;
            switch (player.getActiveWeaponTemplate().getGrade()) {
                case NONE: {
                    itemIdSS = 1835;
                    itemIdBSS = 3947;
                    break;
                }
                case D: {
                    itemIdSS = 1463;
                    itemIdBSS = 3948;
                    break;
                }
                case C: {
                    itemIdSS = 1464;
                    itemIdBSS = 3949;
                    break;
                }
                case B: {
                    itemIdSS = 1465;
                    itemIdBSS = 3950;
                    break;
                }
                case A: {
                    itemIdSS = 1466;
                    itemIdBSS = 3951;
                }
            }
            if (itemIdSS > 0) {
                if (player.getInventory().getCountOf(itemIdSS) < 3000L) {
                    ItemFunctions.addItem(player, itemIdSS, 3000L, false);
                }
                player.addAutoShot(itemIdSS, true, SoulShotType.SOULSHOT);
            }
            if (itemIdBSS > 0) {
                if (player.getInventory().getCountOf(itemIdBSS) < 1000L) {
                    ItemFunctions.addItem(player, itemIdBSS, 1000L, false);
                }
                player.addAutoShot(itemIdBSS, true, SoulShotType.SPIRITSHOT);
            }
        }
    }

    /**
     * Learns NORMAL skill-tree skills that match the fake player's level (same rules as a class trainer),
     * including non-{@code autoGet} entries. Repeats until no more skills are available at the current
     * level. SP and spellbooks are subsidized when missing so progression does not stall.
     */
    public static void learnNormalClassSkillsForFake(Player player) {
        if (!player.isFakePlayer()) {
            return;
        }
        int round = 0;
        while (round++ < 512) {
            Collection<SkillLearn> learns = SkillAcquireHolder.getInstance().getAvailableSkills(player, AcquireType.NORMAL);
            if (learns == null || learns.isEmpty()) {
                break;
            }
            int progressed = 0;
            for (SkillLearn sl : learns) {
                if (sl.getMinLevel() > player.getLevel()) {
                    continue;
                }
                SkillEntry skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, sl.getId(), sl.getLevel());
                if (skillEntry == null) {
                    continue;
                }
                if (!SkillAcquireHolder.getInstance().isSkillPossible(player, null, skillEntry.getTemplate(), AcquireType.NORMAL)) {
                    continue;
                }
                int curLvl = player.getSkillLevel(sl.getId(), 0);
                if (curLvl != sl.getLevel() - 1) {
                    continue;
                }
                boolean haveItems = true;
                for (ItemData item : sl.getRequiredItemsForLearn(AcquireType.NORMAL)) {
                    if (!ItemFunctions.haveItem(player, item.getId(), item.getCount())) {
                        haveItems = false;
                        break;
                    }
                }
                if (!haveItems) {
                    continue;
                }
                player.getInventory().writeLock();
                try {
                    for (ItemData item : sl.getRequiredItemsForLearn(AcquireType.NORMAL)) {
                        ItemFunctions.deleteItem((Playable)player, item.getId(), item.getCount(), true);
                    }
                }
                finally {
                    player.getInventory().writeUnlock();
                }
                long cost = sl.getCost();
                if (player.getSp() < cost) {
                    player.setSp(player.getSp() + cost);
                }
                player.setSp(player.getSp() - cost);
                player.addSkill(skillEntry, true);
                progressed++;
            }
            if (progressed == 0) {
                break;
            }
            player.updateStats();
        }
        player.rewardSkills(false, true, true, false);
        player.checkSkills();
    }

    public static void setProf(Player player) {
        List<Integer> allowClassIds = FakePlayerUtils.getAllowClassIds(player);
        if (!allowClassIds.isEmpty()) {
            int classId = allowClassIds.get(Rnd.get((int)allowClassIds.size()));
            player.setClassId(classId, true);
        }
        player.rewardSkills(false, true, true, false);
        player.refreshExpertisePenalty();
    }

    private static List<Integer> getAllowClassIds(Player player) {
        ArrayList<Integer> allowClassId = new ArrayList<Integer>();
        ClassId playerClassId = player.getClassId();
        int playerClassLevel = playerClassId.getClassLevel().ordinal();
        int playerLevel = player.getLevel();
        if (playerLevel >= 20 && playerClassLevel == 0 || playerLevel >= 40 && playerClassLevel == 1 || playerLevel >= 76 && playerClassLevel == 2 || playerLevel >= 85 && playerClassLevel == 3) {
            block3: for (ClassId classId : ClassId.VALUES) {
                if (classId.isDummy()) continue;
                switch (classId) {
                    case WARLOCK: 
                    case CLERIC: 
                    case SWORDSINGER: 
                    case ELEMENTAL_SUMMONER: 
                    case ORACLE: 
                    case PHANTOM_SUMMONER: 
                    case SHILLEN_ORACLE: {
                        continue block3;
                    }
                    default: {
                        if (!classId.childOf(playerClassId) || classId.getClassLevel().ordinal() != playerClassId.getClassLevel().ordinal() + 1) continue block3;
                        allowClassId.add(classId.getId());
                    }
                }
            }
        }
        return allowClassId;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    static {
        String msg;
        String line;
        File file;
        ArrayList<String> messages = new ArrayList<String>();
        BufferedReader reader = null;
        try {
            file = new File(Config.DATAPACK_ROOT, "data/fake_players/shout_messages.txt");
            reader = new LineNumberReader(new FileReader(file));
            line = null;
            while ((line = ((LineNumberReader)reader).readLine()) != null) {
                msg = line.trim();
                if (StringUtils.isEmpty((CharSequence)msg)) continue;
                messages.add(msg);
            }
        }
        catch (Exception e) {
        }
        finally {
            try {
                reader.close();
            }
            catch (Exception e) {}
        }
        SHOUT_MESSAGES = messages.toArray(new String[messages.size()]);
        messages.clear();
        try {
            file = new File(Config.DATAPACK_ROOT, "data/fake_players/private_messages.txt");
            reader = new LineNumberReader(new FileReader(file));
            line = null;
            while ((line = ((LineNumberReader)reader).readLine()) != null) {
                msg = line.trim();
                if (StringUtils.isEmpty((CharSequence)msg)) continue;
                messages.add(msg);
            }
        }
        catch (Exception e) {
        }
        finally {
            try {
                reader.close();
            }
            catch (Exception e) {}
        }
        PM_MESSAGES = messages.toArray(new String[messages.size()]);
        messages.clear();
        try {
            file = new File(Config.DATAPACK_ROOT, "data/fake_players/trade_messages.txt");
            reader = new LineNumberReader(new FileReader(file));
            line = null;
            while ((line = ((LineNumberReader)reader).readLine()) != null) {
                msg = line.trim();
                if (StringUtils.isEmpty((CharSequence)msg)) continue;
                messages.add(msg);
            }
        }
        catch (Exception e) {
        }
        finally {
            try {
                reader.close();
            }
            catch (Exception e) {}
        }
        TRADE_MESSAGES = messages.toArray(new String[messages.size()]);
    }
}


/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import java.util.HashMap;
import l2s.gameserver.Config;
import l2s.gameserver.dao.CharacterDAO;
import l2s.gameserver.data.xml.holder.InitialShortCutsHolder;
import l2s.gameserver.listener.hooks.ListenerHook;
import l2s.gameserver.listener.hooks.ListenerHookType;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.Macro;
import l2s.gameserver.model.actor.instances.player.ShortCut;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.model.base.ClassLevel;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.s2c.CharacterCreateFailPacket;
import l2s.gameserver.network.l2.s2c.CharacterCreateSuccessPacket;
import l2s.gameserver.network.l2.s2c.CharacterSelectionInfoPacket;
import l2s.gameserver.templates.item.StartItem;
import l2s.gameserver.templates.player.PlayerTemplate;
import l2s.gameserver.utils.ItemFunctions;
import l2s.gameserver.utils.Util;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CharacterCreate
extends L2GameClientPacket {
    private static final Logger _log = LoggerFactory.getLogger(CharacterCreate.class);
    private String _name;
    private int _sex;
    private int _classId;
    private int _hairStyle;
    private int _hairColor;
    private int _face;

    @Override
    protected boolean readImpl() {
        this._name = this.readS();
        this.readD();
        this._sex = this.readD();
        this._classId = this.readD();
        this.readD();
        this.readD();
        this.readD();
        this.readD();
        this.readD();
        this.readD();
        this._hairStyle = this.readD();
        this._hairColor = this.readD();
        this._face = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        ClassId cid = ClassId.valueOf(this._classId);
        if (cid == null || !cid.isOfLevel(ClassLevel.NONE)) {
            return;
        }
        if (!Util.isMatchingRegexp(this._name, Config.CNAME_TEMPLATE)) {
            return;
        }
        if (CharacterDAO.getInstance().getObjectIdByName(this._name) > 0) {
            return;
        }
        if (Config.MAX_CHARACTERS_NUMBER_PER_ACCOUNT != 0 && CharacterDAO.getInstance().accountCharNumber(((GameClient)this.getClient()).getLogin()) >= Config.MAX_CHARACTERS_NUMBER_PER_ACCOUNT) {
            return;
        }
        if (this._face > 2 || this._face < 0) {
            _log.warn("Character Creation Failure: Character face " + this._face + " is invalid. Possible client hack. " + this.getClient());
            this.sendPacket(CharacterCreateFailPacket.REASON_CREATION_FAILED);
            return;
        }
        if (this._hairStyle < 0 || this._sex == 0 && this._hairStyle > 4 || this._sex != 0 && this._hairStyle > 6) {
            _log.warn("Character Creation Failure: Character hair style " + this._hairStyle + " is invalid. Possible client hack. " + this.getClient());
            this.sendPacket(CharacterCreateFailPacket.REASON_CREATION_FAILED);
            return;
        }
        if (this._hairColor > 3 || this._hairColor < 0) {
            _log.warn("Character Creation Failure: Character hair color " + this._hairColor + " is invalid. Possible client hack. " + this.getClient());
            this.sendPacket(CharacterCreateFailPacket.REASON_CREATION_FAILED);
            return;
        }
        Player newChar = Player.create(this._classId, this._sex, ((GameClient)this.getClient()).getLogin(), this._name, this._hairStyle, this._hairColor, this._face);
        if (newChar == null) {
            _log.warn("Character Creation Failure: Player.create returned null. Possible client hack. " + this.getClient());
            this.sendPacket(CharacterCreateFailPacket.REASON_CREATION_FAILED);
            return;
        }
        if (!CharacterCreate.initNewChar(newChar)) {
            _log.warn("Character Creation Failure: Could not init new char. Possible client hack. " + this.getClient());
            this.sendPacket(CharacterCreateFailPacket.REASON_CREATION_FAILED);
            return;
        }
        newChar.storeLastIpAndHWID(((GameClient)this.getClient()).getIpAddr(), ((GameClient)this.getClient()).getHWID());
        this.sendPacket(CharacterCreateSuccessPacket.STATIC);
        ((GameClient)this.getClient()).setCharSelection(CharacterSelectionInfoPacket.loadCharacterSelectInfo(((GameClient)this.getClient()).getLogin()));
    }

    public static boolean initNewChar(Player newChar) {
        if (!newChar.getSubClassList().restore()) {
            return false;
        }
        PlayerTemplate template = newChar.getTemplate();
        newChar.setLoc(template.getStartLocation());
        if (Config.CHAR_TITLE) {
            newChar.setTitle(Config.ADD_CHAR_TITLE);
        } else {
            newChar.setTitle("");
        }
        newChar.setCurrentHpMp(newChar.getMaxHp(), newChar.getMaxMp());
        newChar.setCurrentCp(0.0);
        for (StartItem i : template.getStartItems()) {
            ItemInstance item = ItemFunctions.createItem(i.getId());
            if (i.getEnchantLevel() > 0) {
                item.setEnchantLevel(i.getEnchantLevel());
            }
            long count = i.getCount();
            if (item.isStackable()) {
                item.setCount(count);
                newChar.getInventory().addItem(item);
                continue;
            }
            for (long n = 0L; n < count; ++n) {
                item = ItemFunctions.createItem(i.getId());
                if (i.getEnchantLevel() > 0) {
                    item.setEnchantLevel(i.getEnchantLevel());
                }
                newChar.getInventory().addItem(item);
            }
            if (!item.isEquipable() || !i.isEquiped()) continue;
            newChar.getInventory().equipItem(item);
        }
        for (ListenerHook hook : ListenerHook.getGlobalListenerHooks(ListenerHookType.PLAYER_CREATE)) {
            hook.onPlayerCreate(newChar);
        }
        newChar.rewardSkills(false, false, false, true);
        HashMap<Integer, Integer> initedMacroses = new HashMap<Integer, Integer>();
        for (Macro macro : InitialShortCutsHolder.getInstance().getInitialMacroses()) {
            if (!macro.isEnabled()) continue;
            if (newChar.getMacroses().getAllMacroses().length > 48) {
                _log.warn("Character Initial Macro Failure: Cannot register more than 48 macros.");
                break;
            }
            Macro newMacro = new Macro(0, macro.getIcon(), macro.getName(), macro.getDescr(), macro.getAcronym(), macro.getCommands());
            newChar.registerMacro(newMacro);
            initedMacroses.put(macro.getId(), newMacro.getId());
        }
        for (ShortCut shortCut : InitialShortCutsHolder.getInstance().getInitialShortCuts(newChar.getRace(), newChar.getClassId().getType())) {
            if (shortCut.getType() == ShortCut.ShortCutType.MACRO) {
                Integer initedMacroId = (Integer)initedMacroses.get(shortCut.getId());
                if (initedMacroId == null) continue;
                newChar.registerShortCut(new ShortCut(shortCut.getSlot(), shortCut.getPage(), shortCut.getType(), initedMacroId, 0, 1));
                continue;
            }
            newChar.registerShortCut(shortCut);
        }
        newChar.checkLevelUpReward(true);
        newChar.setOnlineStatus(false);
        newChar.store(false);
        newChar.getInventory().store();
        newChar.deleteMe();
        return true;
    }
}


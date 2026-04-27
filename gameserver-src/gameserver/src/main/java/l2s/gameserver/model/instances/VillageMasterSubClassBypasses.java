/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.apache.commons.lang3.ArrayUtils
 */
package l2s.gameserver.model.instances;

import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.SubClass;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.model.base.ClassLevel;
import l2s.gameserver.model.base.Race;
import l2s.gameserver.model.instances.VillageMasterInstance;
import l2s.gameserver.network.l2.components.HtmlMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.tables.SubClassTable;
import l2s.gameserver.utils.HtmlUtils;
import org.apache.commons.lang3.ArrayUtils;

public class VillageMasterSubClassBypasses {
    public static void getSubJobList(VillageMasterInstance npc, Player player, int ask, int state) {
        int subClass3Level;
        String dialogSuffix = npc.getSubClassDialogSuffix();
        if (dialogSuffix == null) {
            return;
        }
        SubClass mainClass = player.getSubClassList().getByIndex(1);
        int mainClassId = mainClass == null ? -1 : mainClass.getClassId();
        int mainClassLevel = mainClass == null ? 0 : mainClass.getLevel();
        SubClass subClass1 = player.getSubClassList().getByIndex(2);
        int subClass1Id = subClass1 == null ? -1 : subClass1.getClassId();
        int subClass1Level = subClass1 == null ? 0 : subClass1.getLevel();
        SubClass subClass2 = player.getSubClassList().getByIndex(3);
        int subClass2Id = subClass2 == null ? -1 : subClass2.getClassId();
        int subClass2Level = subClass2 == null ? 0 : subClass2.getLevel();
        SubClass subClass3 = player.getSubClassList().getByIndex(4);
        int subClass3Id = subClass3 == null ? -1 : subClass3.getClassId();
        int n = subClass3Level = subClass3 == null ? 0 : subClass3.getLevel();
        if (ask >= 1 && ask <= 10) {
            ClassId newSubClassId = npc.getNewSubClassId(ask);
            if (newSubClassId == null) {
                return;
            }
            if (player.getRace() == Race.ELF && newSubClassId.isOfRace(Race.DARKELF) || player.getRace() == Race.DARKELF && newSubClassId.isOfRace(Race.ELF)) {
                npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_15.htm", false, new Object[0]);
                return;
            }
            if (ClassId.isDagger(newSubClassId.getId())) {
                if (state == 0 && (ClassId.isDagger(subClass1Id) || ClassId.isDagger(subClass2Id) || ClassId.isDagger(subClass3Id) || ClassId.isDagger(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_08.htm", false, new Object[0]);
                    return;
                }
                if (state == 1 && (ClassId.isDagger(subClass2Id) || ClassId.isDagger(subClass3Id) || ClassId.isDagger(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_08.htm", false, new Object[0]);
                    return;
                }
                if (state == 2 && (ClassId.isDagger(subClass1Id) || ClassId.isDagger(subClass3Id) || ClassId.isDagger(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_08.htm", false, new Object[0]);
                    return;
                }
                if (state == 3 && (ClassId.isDagger(subClass1Id) || ClassId.isDagger(subClass2Id) || ClassId.isDagger(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_08.htm", false, new Object[0]);
                    return;
                }
            } else if (ClassId.isBow(newSubClassId.getId())) {
                if (state == 0 && (ClassId.isBow(subClass1Id) || ClassId.isBow(subClass2Id) || ClassId.isBow(subClass3Id) || ClassId.isBow(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_09.htm", false, new Object[0]);
                    return;
                }
                if (state == 1 && (ClassId.isBow(subClass2Id) || ClassId.isBow(subClass3Id) || ClassId.isBow(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_09.htm", false, new Object[0]);
                    return;
                }
                if (state == 2 && (ClassId.isBow(subClass1Id) || ClassId.isBow(subClass3Id) || ClassId.isBow(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_09.htm", false, new Object[0]);
                    return;
                }
                if (state == 3 && (ClassId.isBow(subClass1Id) || ClassId.isBow(subClass2Id) || ClassId.isBow(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_09.htm", false, new Object[0]);
                    return;
                }
            } else if (ClassId.isKnight(newSubClassId.getId())) {
                if (state == 0 && (ClassId.isKnight(subClass1Id) || ClassId.isKnight(subClass2Id) || ClassId.isKnight(subClass3Id) || ClassId.isKnight(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_10.htm", false, new Object[0]);
                    return;
                }
                if (state == 1 && (ClassId.isKnight(subClass2Id) || ClassId.isKnight(subClass3Id) || ClassId.isKnight(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_10.htm", false, new Object[0]);
                    return;
                }
                if (state == 2 && (ClassId.isKnight(subClass1Id) || ClassId.isKnight(subClass3Id) || ClassId.isKnight(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_10.htm", false, new Object[0]);
                    return;
                }
                if (state == 3 && (ClassId.isKnight(subClass1Id) || ClassId.isKnight(subClass2Id) || ClassId.isKnight(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_10.htm", false, new Object[0]);
                    return;
                }
            } else if (ClassId.isSummoner(newSubClassId.getId())) {
                if (state == 0 && (ClassId.isSummoner(subClass1Id) || ClassId.isSummoner(subClass2Id) || ClassId.isSummoner(subClass3Id) || ClassId.isSummoner(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_11.htm", false, new Object[0]);
                    return;
                }
                if (state == 1 && (ClassId.isSummoner(subClass2Id) || ClassId.isSummoner(subClass3Id) || ClassId.isSummoner(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_11.htm", false, new Object[0]);
                    return;
                }
                if (state == 2 && (ClassId.isSummoner(subClass1Id) || ClassId.isSummoner(subClass3Id) || ClassId.isSummoner(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_11.htm", false, new Object[0]);
                    return;
                }
                if (state == 3 && (ClassId.isSummoner(subClass1Id) || ClassId.isSummoner(subClass2Id) || ClassId.isSummoner(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_11.htm", false, new Object[0]);
                    return;
                }
            } else if (ClassId.isHalfHealer(newSubClassId.getId())) {
                if (state == 0 && (ClassId.isHalfHealer(subClass1Id) || ClassId.isHalfHealer(subClass2Id) || ClassId.isHalfHealer(subClass3Id) || ClassId.isHalfHealer(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_12.htm", false, new Object[0]);
                    return;
                }
                if (state == 1 && (ClassId.isHalfHealer(subClass2Id) || ClassId.isHalfHealer(subClass3Id) || ClassId.isHalfHealer(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_12.htm", false, new Object[0]);
                    return;
                }
                if (state == 2 && (ClassId.isHalfHealer(subClass1Id) || ClassId.isHalfHealer(subClass3Id) || ClassId.isHalfHealer(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_12.htm", false, new Object[0]);
                    return;
                }
                if (state == 3 && (ClassId.isHalfHealer(subClass1Id) || ClassId.isHalfHealer(subClass2Id) || ClassId.isHalfHealer(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_12.htm", false, new Object[0]);
                    return;
                }
            } else if (ClassId.isDance(newSubClassId.getId())) {
                if (state == 0 && (ClassId.isDance(subClass1Id) || ClassId.isDance(subClass2Id) || ClassId.isDance(subClass3Id) || ClassId.isDance(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_13.htm", false, new Object[0]);
                    return;
                }
                if (state == 1 && (ClassId.isDance(subClass2Id) || ClassId.isDance(subClass3Id) || ClassId.isDance(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_13.htm", false, new Object[0]);
                    return;
                }
                if (state == 2 && (ClassId.isDance(subClass1Id) || ClassId.isDance(subClass3Id) || ClassId.isDance(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_13.htm", false, new Object[0]);
                    return;
                }
                if (state == 3 && (ClassId.isDance(subClass1Id) || ClassId.isDance(subClass2Id) || ClassId.isDance(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_13.htm", false, new Object[0]);
                    return;
                }
            } else if (ClassId.isWizard(newSubClassId.getId())) {
                if (state == 0 && (ClassId.isWizard(subClass1Id) || ClassId.isWizard(subClass2Id) || ClassId.isWizard(subClass3Id) || ClassId.isWizard(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_14.htm", false, new Object[0]);
                    return;
                }
                if (state == 1 && (ClassId.isWizard(subClass2Id) || ClassId.isWizard(subClass3Id) || ClassId.isWizard(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_14.htm", false, new Object[0]);
                    return;
                }
                if (state == 2 && (ClassId.isWizard(subClass1Id) || ClassId.isWizard(subClass3Id) || ClassId.isWizard(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_14.htm", false, new Object[0]);
                    return;
                }
                if (state == 3 && (ClassId.isWizard(subClass1Id) || ClassId.isWizard(subClass2Id) || ClassId.isWizard(mainClassId))) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_14.htm", false, new Object[0]);
                    return;
                }
            }
            int[] availableSubClasses = SubClassTable.getInstance().getAvailableSubClasses(player, player.getActiveClassId());
            if (state == 0) {
                if (subClass1Id == -1 || subClass1Id != -1 && subClass1Level >= Config.ALT_GAME_LEVEL_TO_GET_SUBCLASS && subClass2Id == -1 || subClass2Id != -1 && subClass2Level >= Config.ALT_GAME_LEVEL_TO_GET_SUBCLASS && subClass3Id == -1) {
                    if (ArrayUtils.contains((int[])availableSubClasses, (int)newSubClassId.getId()) && subClass3Id == -1 && (player.getClassId().isOfLevel(ClassLevel.SECOND) || player.getClassId().isOfLevel(ClassLevel.THIRD))) {
                        if (!player.addSubClass(newSubClassId.getId(), true, 0L, 0L)) {
                            npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_17.htm", false, new Object[0]);
                        } else {
                            npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_06.htm", false, new Object[0]);
                        }
                    } else {
                        npc.showChatWindow(player, "villagemaster/subclass/subclass_error_01.htm", false, new Object[0]);
                    }
                } else {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_04.htm", false, new Object[0]);
                }
            } else if (ArrayUtils.contains((int[])availableSubClasses, (int)newSubClassId.getId())) {
                int oldClassId = -1;
                if (state == 1) {
                    if (subClass1Level < 40) {
                        npc.showChatWindow(player, "villagemaster/subclass/master_lv3_hef_19.htm", false, new Object[0]);
                        return;
                    }
                    oldClassId = subClass1Id;
                } else if (state == 2) {
                    if (subClass2Level < 40) {
                        npc.showChatWindow(player, "villagemaster/subclass/master_lv3_hef_19.htm", false, new Object[0]);
                        return;
                    }
                    oldClassId = subClass2Id;
                } else if (state == 3) {
                    if (subClass3Level < 40) {
                        npc.showChatWindow(player, "villagemaster/subclass/master_lv3_hef_19.htm", false, new Object[0]);
                        return;
                    }
                    oldClassId = subClass3Id;
                }
                if (!player.modifySubClass(oldClassId, newSubClassId.getId(), false)) {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_18.htm", false, new Object[0]);
                } else {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_05.htm", false, new Object[0]);
                }
            } else {
                npc.showChatWindow(player, "villagemaster/subclass/subclass_error_02.htm", false, new Object[0]);
            }
        } else if (ask == 11) {
            if (subClass1Id == -1) {
                npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_07.htm", false, new Object[0]);
            } else {
                int stringId;
                state = 0;
                HtmlMessage html = new HtmlMessage(npc, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_03.htm");
                if (npc.isMyApprentice(mainClassId)) {
                    stringId = mainClassId > 87 ? mainClassId + 1114000 : mainClassId + 1000322;
                    html.replace("<?reply1?>", HtmlUtils.htmlNpcString(stringId, new Object[0]));
                } else {
                    ++state;
                    html.replace("<?reply1?>", "");
                }
                if (subClass1Id != -1 && npc.isMyApprentice(subClass1Id)) {
                    stringId = subClass1Id > 87 ? subClass1Id + 1114000 : subClass1Id + 1000322;
                    html.replace("<?reply2?>", HtmlUtils.htmlNpcString(stringId, new Object[0]));
                } else {
                    ++state;
                    html.replace("<?reply2?>", "");
                }
                if (subClass2Id != -1 && npc.isMyApprentice(subClass2Id)) {
                    stringId = subClass2Id > 87 ? subClass2Id + 1114000 : subClass2Id + 1000322;
                    html.replace("<?reply3?>", HtmlUtils.htmlNpcString(stringId, new Object[0]));
                } else {
                    ++state;
                    html.replace("<?reply3?>", "");
                }
                if (subClass3Id != -1 && npc.isMyApprentice(subClass3Id)) {
                    stringId = subClass3Id > 87 ? subClass3Id + 1114000 : subClass3Id + 1000322;
                    html.replace("<?reply4?>", HtmlUtils.htmlNpcString(stringId, new Object[0]));
                } else {
                    ++state;
                    html.replace("<?reply4?>", "");
                }
                if (state != 4) {
                    player.sendPacket((IBroadcastPacket)html);
                } else {
                    npc.showChatWindow(player, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_07a.htm", false, new Object[0]);
                }
            }
        } else if (ask == 20) {
            HtmlMessage html = new HtmlMessage(npc, "villagemaster/subclass/master_lv3_" + dialogSuffix + "_01a.htm");
            int string1Id = subClass1Id > 87 ? subClass1Id + 1110970 : (subClass1Id != -1 ? subClass1Id + 1111000 : 0x1116FF);
            html.replace("<?reply5?>", HtmlUtils.htmlNpcString(string1Id, new Object[0]));
            int string2Id = subClass2Id > 87 ? subClass2Id + 1111970 : (subClass2Id != -1 ? subClass2Id + 1112000 : 0x1116FF);
            html.replace("<?reply6?>", HtmlUtils.htmlNpcString(string2Id, new Object[0]));
            int string3Id = subClass3Id > 87 ? subClass3Id + 1112970 : (subClass3Id != -1 ? subClass3Id + 1113000 : 0x1116FF);
            html.replace("<?reply7?>", HtmlUtils.htmlNpcString(string3Id, new Object[0]));
            player.sendPacket((IBroadcastPacket)html);
        }
    }
}


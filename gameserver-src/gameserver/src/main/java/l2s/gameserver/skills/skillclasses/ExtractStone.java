/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.skillclasses;

import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;
import l2s.commons.util.Rnd;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.PlaySoundPacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.templates.StatsSet;

public class ExtractStone
extends Skill {
    private static final int ExtractScrollSkill = 2630;
    private static final int ExtractedCoarseRedStarStone = 13858;
    private static final int ExtractedCoarseBlueStarStone = 13859;
    private static final int ExtractedCoarseGreenStarStone = 13860;
    private static final int ExtractedRedStarStone = 14009;
    private static final int ExtractedBlueStarStone = 14010;
    private static final int ExtractedGreenStarStone = 14011;
    private static final int RedStarStone1 = 18684;
    private static final int RedStarStone2 = 18685;
    private static final int RedStarStone3 = 18686;
    private static final int BlueStarStone1 = 18687;
    private static final int BlueStarStone2 = 18688;
    private static final int BlueStarStone3 = 18689;
    private static final int GreenStarStone1 = 18690;
    private static final int GreenStarStone2 = 18691;
    private static final int GreenStarStone3 = 18692;
    private static final int FireEnergyCompressionStone = 14015;
    private static final int WaterEnergyCompressionStone = 14016;
    private static final int WindEnergyCompressionStone = 14017;
    private static final int EarthEnergyCompressionStone = 14018;
    private static final int DarknessEnergyCompressionStone = 14019;
    private static final int SacredEnergyCompressionStone = 14020;
    private static final int SeedFire = 18679;
    private static final int SeedWater = 18678;
    private static final int SeedWind = 18680;
    private static final int SeedEarth = 18681;
    private static final int SeedDarkness = 18683;
    private static final int SeedDivinity = 18682;
    private List<Integer> _npcIds = new ArrayList<Integer>();

    public ExtractStone(StatsSet set) {
        super(set);
        StringTokenizer st = new StringTokenizer(set.getString("npcIds", ""), ";");
        while (st.hasMoreTokens()) {
            this._npcIds.add(Integer.valueOf(st.nextToken()));
        }
    }

    @Override
    public boolean checkCondition(SkillEntry skillEntry, Creature activeChar, Creature target, boolean forceUse, boolean dontMove, boolean first, boolean sendMsg, boolean trigger) {
        if (!super.checkCondition(skillEntry, activeChar, target, forceUse, dontMove, first, sendMsg, trigger)) {
            return false;
        }
        if (target == null || !target.isNpc() || this.getItemId(target.getNpcId()) == 0) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
            return false;
        }
        if (!this._npcIds.isEmpty() && !this._npcIds.contains(new Integer(target.getNpcId()))) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
            return false;
        }
        return true;
    }

    private int getItemId(int npcId) {
        switch (npcId) {
            case 18684: 
            case 18685: 
            case 18686: {
                if (this.getId() == 2630) {
                    return 13858;
                }
                return 14009;
            }
            case 18687: 
            case 18688: 
            case 18689: {
                if (this.getId() == 2630) {
                    return 13859;
                }
                return 14010;
            }
            case 18690: 
            case 18691: 
            case 18692: {
                if (this.getId() == 2630) {
                    return 13860;
                }
                return 14011;
            }
            case 18679: {
                return 14015;
            }
            case 18678: {
                return 14016;
            }
            case 18680: {
                return 14017;
            }
            case 18681: {
                return 14018;
            }
            case 18683: {
                return 14019;
            }
            case 18682: {
                return 14020;
            }
        }
        return 0;
    }

    @Override
    protected void useSkill(Creature activeChar, Creature target, boolean reflected) {
        Player player = activeChar.getPlayer();
        if (player == null) {
            return;
        }
        if (this.getItemId(target.getNpcId()) <= 0) {
            return;
        }
        long count = this.getId() == 2630 ? 1L : (long)Math.min(10, Rnd.get((int)((int)((double)this.getLevel() * player.getRateQuestsDrop() + 1.0))));
        int itemId = this.getItemId(target.getNpcId());
        if (count > 0L) {
            player.getInventory().addItem(itemId, count);
            player.sendPacket((IBroadcastPacket)new PlaySoundPacket("ItemSound.quest_itemget"));
            player.sendPacket((IBroadcastPacket)SystemMessagePacket.obtainItems(itemId, count, 0));
            player.sendChanges();
        } else {
            player.sendPacket((IBroadcastPacket)SystemMsg.THE_COLLECTION_HAS_FAILED);
        }
        target.doDie(player);
    }
}


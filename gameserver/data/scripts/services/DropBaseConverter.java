package services;

import handler.bbs.custom.CalculateRewardChances;
import handler.bbs.custom.CalculateRewardChances.DropInfo;
import l2s.gameserver.data.xml.holder.NpcHolder;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.handler.admincommands.AdminCommandHandler;
import l2s.gameserver.handler.admincommands.IAdminCommandHandler;
import l2s.gameserver.listener.script.OnInitScriptListener;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.reward.RewardData;
import l2s.gameserver.templates.npc.NpcTemplate;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class DropBaseConverter implements IAdminCommandHandler, OnInitScriptListener {
	private static final Logger LOG = LoggerFactory.getLogger(DropBaseConverter.class);

	private static final int STAT_NPC_TYPE_ID = 0;
	private static final int STAT_HP_ID = 1;
	private static final int STAT_MP_ID = 2;
	private static final int STAT_XP_ID = 3;
	private static final int STAT_SP_ID = 4;
	private static final int STAT_P_ATK_ID = 5;
	private static final int STAT_P_DEF_ID = 6;
	private static final int STAT_M_ATK_ID = 7;
	private static final int STAT_M_DEF_ID = 8;
	private static final int STAT_LOC_X_ID = 9;
	private static final int STAT_LOC_Y_ID = 10;
	private static final int STAT_LOC_Z_ID = 11;
	private static final int STAT_DROP_SIZE_ID = 12;
	private static final int STAT_SPOIL_SIZE_ID = 13;
	private static final int STAT_QUESTS_SIZE_ID = 14;
	private static final int STAT_SIZE = 15;

	private static final int START_BOOK_ID = 1;
	private static final int START_TROPHY_ID = 5001;
	private static final int SORT_ORDER = 1;
	private static final float NPC_CON_BONUS = 1.0f;
	private static final float NPC_MEN_BONUS = 1.0f;
	private static final String CARD_PANEL = "L2UI_CT1.MonsterBook.panel_monsterbook_01";
	private static final int DEFAULT_ZONE_ID = 700;
	private static final int FACTION_MARKER = 10;
	private static final int[] REWARD_FP = { 480, 1280, 1920, 3200 };
	private static final int[] REWARD_EXP = { 480, 1280, 1920, 3200 };
	private static final int[] REWARD_SP = { 480, 1280, 1920, 3200 };

	private static final int[] BLOCKED_NPC = { 29019, 29066, 29067 };
	private static final int[] BLOCKED_ITEMS = { 17527, 17526, 19448, 19447 };
	private static final int[] CUSTOM_ITEMS = { 26430, 26431, 26432 };
	private static final int[] CUSTOM_NPCS = {};

	private static final String[][] PREDEFINED_NPC_ZONES = new String[][] {
			{ "18", "21006,21007" },
	};

	private static final String[][] ZONES = new String[][] {
			{ "18", "22_21,23_21" },
			{ "145", "23_11,24_11" },
			{ "146", "25_11" },
			{ "140", "23_12" },
			{ "142", "24_12" },
			{ "143", "25_12" },
			{ "134", "20_13" },
			{ "138", "22_13" },
			{ "266", "23_13" },
			{ "131", "18_14" },
			{ "132", "19_14" },
			{ "133", "20_14" },
			{ "154", "21_14" },
			{ "158", "22_14" },
			{ "216", "23_14" },
			{ "184", "24_14" },
			{ "186", "25_14" },
			{ "188", "26_16" },
			{ "205", "21_15" },
			{ "207", "22_15" },
			{ "212", "23_15" },
			{ "189", "24_15" },
			{ "191", "25_15" },
			{ "202", "20_16" },
			{ "208", "21_16" },
			{ "211", "22_16" },
			{ "195", "23_16" },
			{ "180", "24_16" },
			{ "193", "25_16" },
			{ "218", "20_17" },
			{ "209", "21_17" },
			{ "80", "22_17" },
			{ "120", "23_17" },
			{ "99", "24_17" },
			{ "118", "25_17" },
			{ "164", "19_18" },
			{ "75", "20_18" },
			{ "79", "21_18" },
			{ "81", "22_18" },
			{ "98", "23_18" },
			{ "97", "24_18" },
			{ "104", "25_18" },
			{ "244", "16_19" },
			{ "245", "17_19" },
			{ "76", "18_19" },
			{ "77", "19_19" },
			{ "68", "20_19" },
			{ "70", "21_19" },
			{ "67", "22_19" },
			{ "103", "23_19" },
			{ "110", "24_19" },
			{ "115", "25_19" },
			{ "249", "16_20" },
			{ "44", "17_20" },
			{ "78", "18_20" },
			{ "66", "19_20" },
			{ "71", "20_20" },
			{ "72", "21_20" },
			{ "89", "22_20" },
			{ "108", "23_20" },
			{ "105", "24_20" },
			{ "106", "25_20" },
			{ "39", "17_21" },
			{ "32", "18_21" },
			{ "30", "19_21" },
			{ "5", "20_21" },
			{ "15", "21_21" },
			{ "19", "24_21" },
			{ "20", "25_21" },
			{ "35", "17_22" },
			{ "254", "18_22" },
			{ "31", "19_22" },
			{ "1", "20_22" },
			{ "2", "21_22" },
			{ "16", "22_22" },
			{ "27", "23_22" },
			{ "236", "24_22" },
			{ "58", "17_23" },
			{ "40", "18_23" },
			{ "34", "19_23" },
			{ "8", "20_23" },
			{ "165", "21_23" },
			{ "122", "22_23" },
			{ "125", "23_23" },
			{ "234", "24_23" },
			{ "46", "18_24" },
			{ "23", "21_24" },
			{ "123", "22_24" },
			{ "264", "23_24" },
			{ "53", "16_25" },
			{ "49", "17_25" },
			{ "124", "22_25" },
	};

	private static final Comparator<NpcTemplate> NPC_COMPARATOR = new SortNpcByLevel();

	private int currentNpcIndex = 0;

	private enum Commands {
		admin_createdb,
		admin_create_drop_base
	}

	@Override
	public void onInit() {
		AdminCommandHandler.getInstance().registerAdminCommandHandler(this);
		LOG.info("Service: DropBaseConverter loaded.");
	}

	@Override
	public boolean useAdminCommand(Enum<?> comm, String[] wordList, String fullString, Player activeChar) {
		if(!activeChar.getPlayerAccess().IsEventGm)
			return false;

		if(comm == Commands.admin_createdb || comm == Commands.admin_create_drop_base) {
			boolean result = parseNpcInfo(activeChar);
			activeChar.sendMessage(result ? "Drop base created: MonsterBook_client.txt" : "Drop base create failed, check logs.");
			return true;
		}
		return false;
	}

	@Override
	public Enum<?>[] getAdminCommandEnum() {
		return Commands.values();
	}

	private boolean parseNpcInfo(Player player) {
		File file = new File("./MonsterBook_client.txt");
		currentNpcIndex = 0;

		try (BufferedWriter writer = new BufferedWriter(new FileWriter(file, false))) {
			List<NpcTemplate> npcs = new ArrayList<NpcTemplate>();
			for(NpcTemplate template : NpcHolder.getInstance().getAll()) {
				if(template != null)
					npcs.add(template);
			}
			npcs.sort(NPC_COMPARATOR);

			int npcParsed = 0;
			for(NpcTemplate template : npcs) {
				if(!isSupportedNpcType(template))
					continue;

				if(ArrayUtils.contains(BLOCKED_NPC, template.getId()))
					continue;

				if(template.getId() > 36599 && !ArrayUtils.contains(CUSTOM_NPCS, template.getId()))
					continue;

				if(template.level > 120)
					continue;

				String npcName = template.getName(player);
				if(StringUtils.isBlank(npcName))
					continue;

				List<RewardData> dropRewards = CalculateRewardChances.getDrops(template, true, false);
				List<RewardData> spoilRewards = CalculateRewardChances.getDrops(template, false, true);
				if(dropRewards.isEmpty() && spoilRewards.isEmpty())
					continue;

				if(hasBlockedItems(dropRewards) || hasBlockedItems(spoilRewards))
					continue;

				writeMonsterBook(writer, player, template, dropRewards, spoilRewards);
				npcParsed++;
			}

			LOG.info("DropBaseConverter: parsed {} npc entries.", npcParsed);
			return true;
		}
		catch(Exception e) {
			LOG.warn("DropBaseConverter: failed to create MonsterBook_client.txt", e);
			return false;
		}
	}

	private boolean isSupportedNpcType(NpcTemplate template) {
		return template.getRewards() != null && !template.getRewards().isEmpty();
	}

	private boolean hasBlockedItems(List<RewardData> rewards) {
		for(RewardData reward : rewards) {
			if(reward == null)
				continue;

			int itemId = reward.getItemId();
			if(ArrayUtils.contains(BLOCKED_ITEMS, itemId))
				return true;
			if(itemId > 22599 && !ArrayUtils.contains(CUSTOM_ITEMS, itemId))
				return true;
		}
		return false;
	}

	private void writeMonsterBook(BufferedWriter writer, Player player, NpcTemplate template, List<RewardData> dropRewards, List<RewardData> spoilRewards) throws IOException {
		List<Integer> itemList = new ArrayList<Integer>();
		List<Integer> minList = new ArrayList<Integer>();
		List<Integer> maxList = new ArrayList<Integer>();
		List<Integer> chanceList = new ArrayList<Integer>();
		Set<Integer> processedDropItems = new HashSet<Integer>();
		Set<Integer> processedSpoilItems = new HashSet<Integer>();

		int dropSize = fillRewardLists(player, template, dropRewards, true, processedDropItems, itemList, minList, maxList, chanceList);
		int spoilSize = fillRewardLists(player, template, spoilRewards, false, processedSpoilItems, itemList, minList, maxList, chanceList);
		if(dropSize == 0 && spoilSize == 0)
			return;

		Location loc = getAnySpawnLocation(template.getId());
		int[] statsArray = new int[STAT_SIZE];
		statsArray[STAT_NPC_TYPE_ID] = getNpcType(template);
		statsArray[STAT_HP_ID] = (int) template.getBaseHpMax(template.level);
		statsArray[STAT_MP_ID] = (int) template.getBaseMpMax(template.level);
		statsArray[STAT_XP_ID] = safeInt(template.rewardExp);
		statsArray[STAT_SP_ID] = safeInt(template.rewardSp);
		statsArray[STAT_P_ATK_ID] = (int) template.getBasePAtk();
		statsArray[STAT_P_DEF_ID] = (int) template.getBasePDef();
		statsArray[STAT_M_ATK_ID] = (int) template.getBaseMAtk();
		statsArray[STAT_M_DEF_ID] = (int) template.getBaseMDef();
		statsArray[STAT_LOC_X_ID] = loc.getX();
		statsArray[STAT_LOC_Y_ID] = loc.getY();
		statsArray[STAT_LOC_Z_ID] = loc.getZ();
		statsArray[STAT_DROP_SIZE_ID] = dropSize;
		statsArray[STAT_SPOIL_SIZE_ID] = spoilSize;
		statsArray[STAT_QUESTS_SIZE_ID] = 0;

		String cardTexture = "Direction.pic_common." + template.getId();

		String line = "monster_book_begin\t" +
				"id=" + (START_BOOK_ID + currentNpcIndex) + '\t' +
				"trophy_id=" + (START_TROPHY_ID + currentNpcIndex++) + '\t' +
				"npc_id=" + template.getId() + '\t' +
				"sort_order=" + SORT_ORDER + '\t' +
				"npc_level=" + template.level + '\t' +
				"npc_conbonus=" + NPC_CON_BONUS + '\t' +
				"npc_menbonus=" + NPC_MEN_BONUS + '\t' +
				"drop_item={" + StringUtils.join(ArrayUtils.toObject(statsArray), ";") + "}\t" +
				"card_texture=[" + cardTexture + "]\t" +
				"card_panel=[" + CARD_PANEL + "]\t" +
				"zone_id=" + getHuntingZone(template.getId(), loc) + '\t' +
				"faction_id=" + FACTION_MARKER + '\t' +
				"reward_fp={" + StringUtils.join(ArrayUtils.toObject(REWARD_FP), ";") + "}\t" +
				"reward_exp={" + StringUtils.join(ArrayUtils.toObject(REWARD_EXP), ";") + "}\t" +
				"reward_sp={" + StringUtils.join(ArrayUtils.toObject(REWARD_SP), ";") + "}\t" +
				"reward_item_1={" + StringUtils.join(itemList, ";") + "}\t" +
				"reward_item_2={" + StringUtils.join(minList, ";") + "}\t" +
				"reward_item_3={" + StringUtils.join(maxList, ";") + "}\t" +
				"reward_item_4={" + StringUtils.join(chanceList, ";") + "}\t" +
				"view_x=65534\t" +
				"view_y=65532\t" +
				"view_s=1.00\t" +
				"view_rot=34000\t" +
				"view_dist=400\t" +
				"monster_book_end\n";
		writer.write(line);
	}

	private static int normalizeDropMaxCount(long minCount, long maxCount) {
		if(maxCount < 0)
			maxCount = -maxCount;

		if(maxCount < minCount)
			maxCount = minCount;

		if(maxCount <= 0)
			maxCount = 1;

		return (int) maxCount;
	}

	private int fillRewardLists(Player player, NpcTemplate template, List<RewardData> rewards, boolean drop, Set<Integer> processedItems,
								List<Integer> itemList, List<Integer> minList, List<Integer> maxList, List<Integer> chanceList) {
		int count = 0;
		for(RewardData reward : rewards) {
			if(reward == null)
				continue;

			int itemId = reward.getItemId();
			if(!processedItems.add(itemId))
				continue;

			DropInfo[] info = CalculateRewardChances.getDropInfo(player, template, itemId);
			if(info == null)
				continue;

			DropInfo selected = drop ? info[0] : info[1];
			if(selected == null || selected.chance <= 0.0D)
				continue;

			itemList.add(itemId);
			minList.add((int) selected.minCount);
			maxList.add(normalizeDropMaxCount(selected.minCount, selected.maxCount));
			chanceList.add((int) Math.round(selected.chance * 1000000D));
			count++;
		}
		return count;
	}

	private int getNpcType(NpcTemplate template) {
		if(template.isRaid)
			return 1;
		return 0;
	}

	private int safeInt(long value) {
		if(value > Integer.MAX_VALUE)
			return Integer.MAX_VALUE;
		if(value < Integer.MIN_VALUE)
			return Integer.MIN_VALUE;
		return (int) value;
	}

	private int getHuntingZone(int npcId, Location loc) {
		if(loc == null || (loc.getX() == 0 && loc.getY() == 0))
			return DEFAULT_ZONE_ID;

		String region = GeoEngine.getMapX(loc.getX()) + "_" + GeoEngine.getMapY(loc.getY());

		for(String[] zoneId : PREDEFINED_NPC_ZONES) {
			for(String npcs : zoneId[1].split(",")) {
				if(Integer.parseInt(npcs) == npcId)
					return Integer.parseInt(zoneId[0]);
			}
		}

		for(String[] zoneId : ZONES) {
			for(String mappedRegion : zoneId[1].split(",")) {
				if(mappedRegion.equals(region))
					return Integer.parseInt(zoneId[0]);
			}
		}

		return DEFAULT_ZONE_ID;
	}

	private Location getAnySpawnLocation(int npcId) {
		List<NpcInstance> npcList = GameObjectsStorage.getNpcs(false, npcId);
		if(npcList == null || npcList.isEmpty())
			return new Location(0, 0, 0);

		long sumX = 0L;
		long sumY = 0L;
		long sumZ = 0L;
		int count = 0;

		for(NpcInstance npc : npcList) {
			if(npc == null || npc.getSpawnedLoc() == null)
				continue;

			Location loc = npc.getSpawnedLoc();
			if(loc.getX() == 0 && loc.getY() == 0)
				continue;

			sumX += loc.getX();
			sumY += loc.getY();
			sumZ += loc.getZ();
			count++;
		}

		if(count == 0)
			return new Location(0, 0, 0);

		return new Location((int) (sumX / count), (int) (sumY / count), (int) (sumZ / count));
	}

	private static class SortNpcByLevel implements Comparator<NpcTemplate>, Serializable {
		private static final long serialVersionUID = 7691414259610932752L;

		@Override
		public int compare(NpcTemplate o1, NpcTemplate o2) {
			return Integer.compare(o1.level, o2.level);
		}
	}
}

package services;

import handler.bbs.custom.CalculateRewardChances;
import handler.bbs.custom.CalculateRewardChances.DropInfo;
import l2s.gameserver.data.xml.holder.NpcHolder;
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

	private static final int START_BOOK_ID = 1;
	private static final int START_TROPHY_ID = 5001;
	private static final int SORT_ORDER = 1;
	private static final float NPC_CON_BONUS = 1.0f;
	private static final float NPC_MEN_BONUS = 1.0f;
	private static final String CARD_PANEL = "L2UI_CT1.MonsterBook.panel_monsterbook_01";
	private static final int DEFAULT_ZONE_ID = 278;
	private static final int FACTION_MARKER = 1;
	private static final int[] REWARD_FP = { 480, 1280, 1920, 3200 };
	private static final int[] REWARD_EXP = { 480, 1280, 1920, 3200 };
	private static final int[] REWARD_SP = { 480, 1280, 1920, 3200 };

	private static final int[] BLOCKED_NPC = { 29019, 29066, 29067 };
	private static final int[] BLOCKED_ITEMS = { 17527, 17526, 19448, 19447 };
	private static final int[] CUSTOM_ITEMS = { 26430, 26431, 26432 };
	private static final int[] CUSTOM_NPCS = {};

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
		// For this datapack all monster-like entries are exported as regular or raid entries.
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
		String cardTexture = "Direction.pic_common." + template.getId();

		String line = "monster_book_begin\t" +
				"id=" + (START_BOOK_ID + currentNpcIndex) + '\t' +
				"trophy_id=" + (START_TROPHY_ID + currentNpcIndex++) + '\t' +
				"npc_id=" + template.getId() + '\t' +
				"sort_order=" + SORT_ORDER + '\t' +
				"npc_level=" + template.level + '\t' +
				"npc_conbonus=" + NPC_CON_BONUS + '\t' +
				"npc_menbonus=" + NPC_MEN_BONUS + '\t' +
				"drop_item={" + StringUtils.join(itemList, ";") + "}\t" +
				"card_texture=[" + cardTexture + "]\t" +
				"card_panel=[" + CARD_PANEL + "]\t" +
				"zone_id=" + DEFAULT_ZONE_ID + '\t' +
				"faction_id=" + FACTION_MARKER + '\t' +
				"reward_fp={" + StringUtils.join(ArrayUtils.toObject(REWARD_FP), ";") + "}\t" +
				"reward_exp={" + StringUtils.join(ArrayUtils.toObject(REWARD_EXP), ";") + "}\t" +
				"reward_sp={" + StringUtils.join(ArrayUtils.toObject(REWARD_SP), ";") + "}\t" +
				"reward_item_1={}\t" +
				"reward_item_2={}\t" +
				"reward_item_3={}\t" +
				"reward_item_4={}\t" +
				"view_x=65534\t" +
				"view_y=65532\t" +
				"view_s=1.00\t" +
				"view_rot=34000\t" +
				"view_dist=400\t" +
				"monster_book_end\n";
		writer.write(line);
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
			maxList.add((int) selected.maxCount);
			chanceList.add((int) Math.round(selected.chance * 1000000D));
			count++;
		}
		return count;
	}

	private Location getAnySpawnLocation(int npcId) {
		List<NpcInstance> npcList = GameObjectsStorage.getNpcs(false, npcId);
		if(npcList == null || npcList.isEmpty())
			return new Location(0, 0, 0);

		for(NpcInstance npc : npcList) {
			if(npc != null && npc.getSpawnedLoc() != null)
				return npc.getSpawnedLoc();
		}
		return new Location(0, 0, 0);
	}

	private static class SortNpcByLevel implements Comparator<NpcTemplate>, Serializable {
		private static final long serialVersionUID = 7691414259610932752L;

		@Override
		public int compare(NpcTemplate o1, NpcTemplate o2) {
			return Integer.compare(o1.level, o2.level);
		}
	}
}

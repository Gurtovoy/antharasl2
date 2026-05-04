package npc.model.residences.castle;

import java.util.StringTokenizer;

import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.residence.Castle;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.components.NpcString;
import l2s.gameserver.templates.npc.NpcTemplate;
import l2s.gameserver.utils.Functions;
import l2s.gameserver.utils.ItemFunctions;

/**
 * NPC революционного повстанца, размещённого в замке во время осады.
 *
 * <p>Повстанец предлагает атакующим игрокам обменять налоговые ящики (коробки доставки)
 * на оружие по сниженным ценам. Команда {@code take_bundle} позволяет получить
 * «мешок налогов» — набор предметов-наград, если у игрока есть соответствующий предмет.
 *
 * <p>HTML-диалоги: {@code castle/revolutionary/36600.htm} … {@code 36608.htm}
 * (по одному на каждый замок). {@code no_bundle.htm} — нет мешка.
 * {@code no_clan.htm}   — замок не захвачен.
 *
 * <p>Команды bypass:
 * <ul>
 *   <li>{@code take_bundle} — получить мешок налогов (требует предмет и членство в клане)</li>
 *   <li>{@code multisell N} — обмен коробки доставки (стандартный multisell)</li>
 * </ul>
 *
 * @author Bonux
 */
public class RevolutionaryInstance extends NpcInstance
{
	// -----------------------------------------------------------------------
	// Предмет «мешок налогов» (Tax Bundle / Transportation Box).
	// ID нужно уточнить по данным игры — здесь указан предварительный ID
	// из аналогичных реализаций Classic-серверов.
	// TODO: подтвердить ID предмета по таблице items данного сервера.
	// -----------------------------------------------------------------------

	/**
	 * ID предмета «Коробка для доставки» (Transportation Box), который игрок
	 * должен иметь, чтобы получить мешок налогов у Revolutionary NPC.
	 * Значение взято из данных Classic 2.7 (ориентировочно).
	 * TODO: заменить на актуальный ID из базы предметов antharasl2.
	 */
	private static final int TRANSPORTATION_BOX_ID = 13714;

	/**
	 * Количество коробок, потребляемых за одну выдачу мешка.
	 */
	private static final int TRANSPORTATION_BOX_COUNT = 1;

	// -----------------------------------------------------------------------
	// Предметы в мешке налогов (Bundle reward).
	// TODO: заполнить реальными ID и количеством из конфигурации замка/квеста.
	// -----------------------------------------------------------------------

	/**
	 * ID награды в «мешке налогов». Здесь для примера — Adena (ID 57).
	 * TODO: заменить на реальные ID предметов из данных замка.
	 */
	private static final int BUNDLE_REWARD_ITEM_ID = 57;

	/**
	 * Количество единиц награды в «мешке».
	 * TODO: настроить под реальное количество из данных замка.
	 */
	private static final long BUNDLE_REWARD_COUNT = 1_000_000L;

	public RevolutionaryInstance(int objectId, NpcTemplate template, MultiValueSet<String> set)
	{
		super(objectId, template, set);
	}

	@Override
	public String getHtmlDir(String filename, Player player)
	{
		return "castle/revolutionary/";
	}

	@Override
	public String getHtmlFilename(int val, Player player)
	{
		if(val == 0)
		{
			Castle castle = getCastle(player);
			if(castle == null || castle.getOwnerId() == 0)
				return "no_clan.htm";
		}
		return super.getHtmlFilename(val, player);
	}

	@Override
	public void onBypassFeedback(Player player, String command)
	{
		StringTokenizer st = new StringTokenizer(command);
		String cmd = st.nextToken();

		if(cmd.equals("take_bundle"))
		{
			// 1. Проверяем наличие активного владельца замка
			Castle castle = getCastle(player);
			if(castle == null || castle.getOwnerId() == 0)
			{
				// Замок никем не захвачен — выдать диалог «нет клана»
				showChatWindow(player, "castle/revolutionary/no_clan.htm", false);
				return;
			}

			// 2. Проверяем, что игрок состоит в клане-владельце замка
			Clan ownerClan = castle.getOwner();
			Clan playerClan = player.getClan();
			if(playerClan == null || ownerClan == null || playerClan.getClanId() != ownerClan.getClanId())
			{
				// Игрок не из клана-владельца — мешок не положен
				showChatWindow(player, "castle/revolutionary/no_bundle.htm", false);
				return;
			}

			// 3. Проверяем наличие «Коробки для доставки» в инвентаре игрока
			if(ItemFunctions.getItemCount(player, TRANSPORTATION_BOX_ID) < TRANSPORTATION_BOX_COUNT)
			{
				// Коробки нет — показываем диалог «нет мешка»
				showChatWindow(player, "castle/revolutionary/no_bundle.htm", false);
				return;
			}

			// 4. Забираем коробку и выдаём награду
			ItemFunctions.deleteItem(player, TRANSPORTATION_BOX_ID, TRANSPORTATION_BOX_COUNT);

			// TODO: Реализовать полноценную выдачу мешка через конфиг замка.
			//       Набор предметов должен определяться типом/уровнем замка.
			//       Ниже — минимальная заглушка: одиночная выдача adena.
			ItemFunctions.addItem(player, BUNDLE_REWARD_ITEM_ID, BUNDLE_REWARD_COUNT);
		}
		else
			super.onBypassFeedback(player, command);
	}

	@Override
	public void showChatWindow(Player player, int val, boolean firstTalk, Object... arg)
	{
		Castle castle = getCastle(player);
		Clan clan = (castle == null ? null : castle.getOwner());
		if(clan != null)
		{
			if(val == 0)
				Functions.npcSayToPlayer(this, player, NpcString.WE_WILL_EXECUTE_OUR_PLAN_ON_SUNDAY_NIGHT_IF_YOU_JOIN_US_I_WILL_GIVE_YOU_A_SUBSTANTIAL_REWARD);
		}

		super.showChatWindow(player, val, firstTalk, arg);
	}
}

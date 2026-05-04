package npc.model;

import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.quest.QuestState;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.templates.npc.NpcTemplate;
import l2s.gameserver.utils.ItemFunctions;

/**
 * Soul Tracker NPC — страж входа в Тюрьму Бездны (Dungeon of Abyss).
 *
 * <p>NPC ID:
 * <ul>
 *   <li>31774 — Magrit (Западное Крыло, вход 1) — квест 933</li>
 *   <li>31775 — Ingrit (Западное Крыло, вход 2) — квест 933</li>
 *   <li>31776 — Iris   (Восточное Крыло, вход 1) — квест 935</li>
 *   <li>31777 — Rosammy (Восточное Крыло, вход 2) — квест 935</li>
 * </ul>
 *
 * <p>Телепорты:
 * <ul>
 *   <li>reply 5 — в крыло (требует активный квест)</li>
 *   <li>reply 6 — к N-му входу в Тюрьму Бездны (свободно)</li>
 *   <li>reply 7 — в Тюрьму Смертников Вечности (требует ключ, ID см. константы)</li>
 *   <li>reply 8 — возврат в Аден (свободно)</li>
 * </ul>
 *
 * @author Bonux
 */
public class SoulTrackerInstance extends NpcInstance
{
	// -----------------------------------------------------------------------
	// Ключи входа в Тюрьму Смертников Вечности
	// (Condemned of Abyss Prison / "Тюрьма Смертников Вечности")
	// Источник: L2J Mobius Classic 2.7, SoulTracker/Magrit.java & Iris.java
	// -----------------------------------------------------------------------

	/** Ключ для Западного Крыла (используют NPC 31774 и 31775). */
	private static final int KEY_OF_WEST_WING = 90010;

	/** Ключ для Восточного Крыла (используют NPC 31776 и 31777). */
	private static final int KEY_OF_EAST_WING = 90011;

	// -----------------------------------------------------------------------
	// Координаты телепорта в Тюрьму Смертников Вечности
	// Источник: L2J Mobius, LOCATIONS["3"] в каждом SoulTracker-скрипте.
	// West Wing  → -116963, -181492, -6575
	// East Wing  → TODO: уточнить по данным сервера (аналогично West)
	// -----------------------------------------------------------------------

	/** Координаты входа в Тюрьму Смертников для Западного Крыла. */
	private static final int PRISON_WEST_X = -116963;
	private static final int PRISON_WEST_Y = -181492;
	private static final int PRISON_WEST_Z = -6575;

	/**
	 * Координаты входа в Тюрьму Смертников для Восточного Крыла.
	 * TODO: уточнить координаты по актуальным данным карты Восточного Крыла.
	 *       Используется зеркальное смещение относительно West Wing.
	 */
	private static final int PRISON_EAST_X = -116963;
	private static final int PRISON_EAST_Y = -177720;
	private static final int PRISON_EAST_Z = -6575;

	public SoulTrackerInstance(int objectId, NpcTemplate template, MultiValueSet<String> set)
	{
		super(objectId, template, set);
	}

	@Override
	public void onMenuSelect(Player player, int ask, long reply, int state)
	{
		if(ask == 933)
		{
			if(reply == 5) // Переместиться в Западное Крыло Тюрьмы Бездны
			{
				QuestState qs = player.getQuestState(933);
				if(getNpcId() == 31774)
				{
					if(qs != null && qs.isStarted())
						player.teleToLocation(-119440, -182464, -6752, ReflectionManager.MAIN);
					else
						showChatWindow(player, "default/" + getNpcId() + "-no_enter.htm", false);
				}
				else if(getNpcId() == 31775)
				{
					if(qs != null && qs.isStarted())
						player.teleToLocation(-119330, -179608, -6752, ReflectionManager.MAIN);
					else
						showChatWindow(player, "default/" + getNpcId() + "-no_enter.htm", false);
				}
			}
			else if(reply == 6) // Переместиться ко N-му входу в Тюрьму Бездны
			{
				if(getNpcId() == 31774)
					player.teleToLocation(-120313, -179623, -6752, ReflectionManager.MAIN);
				else if(getNpcId() == 31775)
					player.teleToLocation(-120313, -182464, -6752, ReflectionManager.MAIN);
			}
			else if(reply == 7) // Переместиться в Тюрьму Смертников Вечности
			{
				// Требуется ключ Западного Крыла (Key of West Wing, ID 90010).
				// Если ключ есть — забираем его и телепортируем в Тюрьму Смертников.
				// Если ключа нет — показываем диалог об отсутствии ключа.
				if(ItemFunctions.getItemCount(player, KEY_OF_WEST_WING) > 0)
				{
					ItemFunctions.deleteItem(player, KEY_OF_WEST_WING, 1);
					player.teleToLocation(PRISON_WEST_X, PRISON_WEST_Y, PRISON_WEST_Z, ReflectionManager.MAIN);
				}
				else
				{
					showChatWindow(player, "default/" + getNpcId() + "-no_key.htm", false);
				}
			}
			else if(reply == 8) // Вернуться в Аден
			{
				player.teleToLocation(146945, 26764, -2200, ReflectionManager.MAIN);
			}
		}
		else if(ask == 935)
		{
			if(reply == 5) // Переместиться в Восточное Крыло Тюрьмы Бездны
			{
				QuestState qs = player.getQuestState(935);
				if(getNpcId() == 31776)
				{
					if(qs != null && qs.isStarted())
						player.teleToLocation(-110000, -180552, -6752, ReflectionManager.MAIN);
					else
						showChatWindow(player, "default/" + getNpcId() + "-no_enter.htm", false);
				}
				else if(getNpcId() == 31777)
				{
					if(qs != null && qs.isStarted())
						player.teleToLocation(-110000, -177720, -6752, ReflectionManager.MAIN);
					else
						showChatWindow(player, "default/" + getNpcId() + "-no_enter.htm", false);
				}
			}
			else if(reply == 6) // Переместиться ко N-му входу в Тюрьму Бездны
			{
				if(getNpcId() == 31776)
					player.teleToLocation(-109395, -177745, -6752, ReflectionManager.MAIN);
				else if(getNpcId() == 31777)
					player.teleToLocation(-109334, -180564, -6752, ReflectionManager.MAIN);
			}
			else if(reply == 7) // Переместиться в Тюрьму Смертников Вечности
			{
				// Требуется ключ Восточного Крыла (Key of East Wing, ID 90011).
				// Если ключ есть — забираем его и телепортируем в Тюрьму Смертников.
				// Если ключа нет — показываем диалог об отсутствии ключа.
				if(ItemFunctions.getItemCount(player, KEY_OF_EAST_WING) > 0)
				{
					ItemFunctions.deleteItem(player, KEY_OF_EAST_WING, 1);
					player.teleToLocation(PRISON_EAST_X, PRISON_EAST_Y, PRISON_EAST_Z, ReflectionManager.MAIN);
				}
				else
				{
					showChatWindow(player, "default/" + getNpcId() + "-no_key.htm", false);
				}
			}
			else if(reply == 8) // Вернуться в Аден
			{
				player.teleToLocation(146945, 26764, -2200, ReflectionManager.MAIN);
			}
		}
		else
			super.onMenuSelect(player, ask, reply, state);
	}
}

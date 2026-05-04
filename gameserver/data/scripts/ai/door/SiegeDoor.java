package ai.door;

import l2s.gameserver.ai.DoorAI;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.instances.DoorInstance;

/**
 * AI для осадных ворот (Siege Door).
 *
 * <p>При атаке ворот поднимает тревогу у ближайших siege guards в радиусе 900 единиц
 * (z-диапазон: 200 единиц). Реагируют только атакующие, состоящие в кланах-атакерах
 * активной осады на данные ворота. Игроки вне клана-осадника также провоцируют охрану.
 *
 * <p>Механика полностью реализована в базовом {@link DoorAI#onEvtAttacked}:
 * <ul>
 *   <li>Проверка участия атакующего в осаде данных ворот через {@code SiegeEvent}</li>
 *   <li>Поиск NPC-охранников ({@code isSiegeGuard()}) в радиусе 900 / z ±200</li>
 *   <li>С вероятностью 20% — агрессия 10 000, иначе 2 000 (через {@code EVT_AGGRESSION})</li>
 * </ul>
 *
 * @author VISTALL (original stub)
 * @see DoorAI#onEvtAttacked(Creature, Skill, int)
 */
public class SiegeDoor extends DoorAI
{
	public SiegeDoor(DoorInstance actor)
	{
		super(actor);
	}

	/**
	 * Вызывается при получении урона воротами.
	 * Делегирует логику оповещения ближайших охранников в {@link DoorAI}.
	 *
	 * @param attacker атакующий персонаж
	 * @param skill    использованный скилл (может быть {@code null})
	 * @param damage   нанесённый урон
	 */
	@Override
	protected void onEvtAttacked(Creature attacker, Skill skill, int damage)
	{
		// Вся логика обнаружения осадных гвардейцев и выдачи им агрессии
		// реализована в DoorAI.onEvtAttacked. SiegeDoor расширяет её при необходимости.
		super.onEvtAttacked(attacker, skill, damage);
	}
}

package handler.bbs.custom;

import java.util.StringTokenizer;

import l2s.gameserver.data.htm.HtmCache;
import l2s.gameserver.instancemanager.ServerStagesManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.ShowBoardPacket;

/**
 * Community board: server progression stages (goals, %, cap).
 */
public class CommunityServerStages extends CustomCommunityHandler
{
	@Override
	public String[] getBypassCommands()
	{
		return new String[] { "_cbbsserverstages" };
	}

	@Override
	protected void doBypassCommand(Player player, String bypass)
	{
		StringTokenizer st = new StringTokenizer(bypass, "_");
		String cmd = st.nextToken();
		if(!"cbbsserverstages".equals(cmd))
			return;

		if(!BBSConfig.CUSTOM_COMMUNITY_ENABLED)
		{
			player.sendMessage(player.isLangRus() ? "Кастомный community board отключен." : "Custom community board is disabled.");
			player.sendPacket(ShowBoardPacket.CLOSE);
			return;
		}

		if(!ServerStagesManager.getInstance().isEnabled())
		{
			String html = HtmCache.getInstance().getHtml("scripts/handler/bbs/pages/server_stages_off.htm", player);
			ShowBoardPacket.separateAndSend(html, player);
			return;
		}

		if(!BBSConfig.GLOBAL_USE_FUNCTIONS_CONFIGS && !checkUseCondition(player))
		{
			onWrongCondition(player);
			return;
		}

		ServerStagesManager mgr = ServerStagesManager.getInstance();
		ServerStagesManager.StageDef s = mgr.getCurrentStageDef();
		int stageNum = mgr.getCurrentStageNumber();
		int cap = mgr.getEffectiveMaxPlayerLevelForCap();
		String capStr = cap > 0 ? String.valueOf(cap) : (player.isLangRus() ? "нет" : "none");

		long pk = mgr.getPkDeltaThisStage();
		long pvp = mgr.getPvpDeltaThisStage();
		int raid = mgr.getRaidKillsThisStage();
		double avg = mgr.getAverageLevel();
		int totalPct = mgr.getOverallProgressPercent();
		boolean done = mgr.isStageComplete();
		boolean pending = mgr.isPendingAdvanceAfterRestart();
		boolean mailed = mgr.isCompletionMailSent();

		String html = HtmCache.getInstance().getHtml("scripts/handler/bbs/pages/server_stages.htm", player);
		html = html.replace("<?stage?>", String.valueOf(stageNum));
		html = html.replace("<?cap?>", capStr);
		html = html.replace("<?total_pct?>", String.valueOf(totalPct));
		html = html.replace("<?pk_c?>", String.valueOf(pk));
		html = html.replace("<?pk_t?>", s.reqPk > 0 ? String.valueOf(s.reqPk) : "—");
		html = html.replace("<?pk_p?>", s.reqPk > 0 ? String.valueOf(pct(pk, s.reqPk)) : "—");
		html = html.replace("<?pvp_c?>", String.valueOf(pvp));
		html = html.replace("<?pvp_t?>", s.reqPvp > 0 ? String.valueOf(s.reqPvp) : "—");
		html = html.replace("<?pvp_p?>", s.reqPvp > 0 ? String.valueOf(pct(pvp, s.reqPvp)) : "—");
		html = html.replace("<?raid_c?>", String.valueOf(raid));
		html = html.replace("<?raid_t?>", s.reqRaid > 0 ? String.valueOf(s.reqRaid) : "—");
		html = html.replace("<?raid_p?>", s.reqRaid > 0 ? String.valueOf(pct(raid, s.reqRaid)) : "—");
		html = html.replace("<?avg_c?>", String.format("%.2f", avg));
		html = html.replace("<?avg_t?>", s.reqAvgLevel > 0 ? String.format("%.1f", s.reqAvgLevel) : "—");
		html = html.replace("<?avg_p?>", s.reqAvgLevel > 0 ? String.valueOf(pct(avg, s.reqAvgLevel)) : "—");

		String status;
		if(player.isLangRus())
		{
			if(done && mailed && pending)
				status = "Стадия выполнена. Награды отправлены на почту. Следующая стадия начнётся после рестарта сервера.";
			else if(done)
				status = "Все условия выполнены, ожидайте обработки.";
			else
				status = "Выполняйте условия ниже. Значения PK/PvP считаются приростом с начала текущей стадии.";
		}
		else
		{
			if(done && mailed && pending)
				status = "Stage complete. Rewards sent by mail. Next stage starts after server restart.";
			else if(done)
				status = "All conditions met; processing.";
			else
				status = "Meet the goals below. PK/PvP values are gains since this stage started.";
		}
		html = html.replace("<?status?>", status);

		ShowBoardPacket.separateAndSend(html, player);
	}

	private static int pct(long cur, long req)
	{
		if(req <= 0)
			return 100;
		return (int) Math.min(100L, cur * 100L / req);
	}

	private static int pct(double cur, double req)
	{
		if(req <= 0.0)
			return 100;
		return (int) Math.min(100.0, cur / req * 100.0);
	}
}

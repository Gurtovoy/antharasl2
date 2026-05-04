package l2s.gameserver.model.autobot;

import java.util.HashMap;
import java.util.Map;

import l2s.commons.util.Rnd;
import l2s.gameserver.model.Player;

/**
 * Walking routes from starter zones into each village.
 * Human fighter/mage paths — user-provided actions (Cedric / Magic school → south → village);
 * other races — user coordinates + elven town tail for elves.
 */
public final class StarterPackTownPaths
{
	private static final Map<Integer, int[][]> PATH_BY_CLASS_ID = new HashMap<>();

	/** Human Fighter (0) — exit Cedric school, bridge south, into village (actions 1–3) */
	private static final int[][] PATH_HUMAN_FIGHTER = {
		{-71512, 258200, -3104},
		{-71688, 257976, -3096},
		{-72104, 257480, -3120},
		{-72712, 256792, -3120},
		{-73192, 256200, -3120},
		{-73752, 255704, -3136},
		{-74440, 254952, -3248},
		{-75064, 254152, -3328},
		{-75832, 253096, -3328},
		{-76440, 252360, -3328},
		{-77048, 251640, -3328},
		{-77272, 251368, -3360},
		{-77592, 251000, -3424},
		{-77848, 250696, -3472},
		{-78072, 250424, -3552},
		{-78536, 249864, -3568},
		{-79384, 248872, -3568},
		{-79912, 248280, -3632},
		{-80456, 247704, -3632},
		{-81144, 246792, -3664},
		{-81560, 246200, -3696},
		{-82200, 245256, -3712},
		{-82872, 244504, -3728},
		{-83336, 244056, -3728},
		{-83944, 243384, -3728}
	};

	/**
	 * Human Mage (10) — exit Magic school, first branch of {@code random_action}, then actions 2–3
	 * (same action 2–3 as fighter from south into village).
	 */
	private static final int[][] PATH_HUMAN_MAGE = {
		{-90296, 248504, -3568},
		{-89608, 248968, -3568},
		{-89080, 248760, -3568},
		{-88264, 248936, -3568},
		{-88200, 249512, -3584},
		{-88008, 250072, -3600},
		{-87704, 250216, -3616},
		{-87000, 250840, -3616},
		{-86376, 251608, -3600},
		{-86360, 250824, -3584},
		{-85352, 250600, -3456},
		{-84440, 250120, -3440},
		{-83224, 249176, -3576},
		{-81848, 248200, -3696},
		{-81496, 246936, -3664},
		{-81144, 246792, -3664},
		{-81560, 246200, -3696},
		{-82200, 245256, -3712},
		{-82872, 244504, -3728},
		{-83336, 244056, -3728},
		{-83944, 243384, -3728}
	};

	/** Elf Fighter / Mage (18, 25) — user path + {@code town/[1] elven_village.xml} entry to center */
	private static final int[][] PATH_ELF = {
		{46056, 42088, -3472},
		{45976, 43000, -3304},
		{45912, 43816, -3184},
		{45800, 44680, -3080},
		{45736, 45320, -3016},
		{45656, 46360, -2992},
		{45560, 47192, -2992},
		{45416, 48104, -3056},
		{45336, 48520, -3056},
		{45768, 49064, -3056},
		{46120, 49544, -3056},
		{46360, 50056, -3056},
		{46760, 50520, -3056},
		{47064, 50936, -2992},
		{46920, 51416, -2976}
	};

	/** Dark Elf Fighter / Mage (31, 38) */
	private static final int[][] PATH_DARK_ELF = {
		{24712, 11080, -3728},
		{23048, 11032, -3728},
		{21640, 11304, -3728},
		{20104, 12024, -3728},
		{18632, 12680, -3728},
		{17576, 13096, -3744},
		{16632, 13464, -3736},
		{16104, 13896, -3720},
		{15912, 14280, -3776},
		{16056, 14696, -3912},
		{16504, 14904, -4024},
		{16808, 15112, -4152},
		{16776, 15560, -4256},
		{16360, 15752, -4336},
		{15720, 15816, -4392},
		{15128, 15976, -4376},
		{14056, 16248, -4584},
		{12904, 16520, -4584},
		{12312, 16648, -4584}
	};

	/** Orc Fighter / Mage (44, 49) */
	private static final int[][] PATH_ORC = {
		{-50184, -113608, -176},
		{-49048, -113608, -240},
		{-47864, -113608, -224},
		{-46920, -113608, -200},
		{-46376, -113608, -200},
		{-45512, -113608, -240},
		{-45192, -113592, -224}
	};

	/** Dwarf Fighter (53) — user {@code on_obtain_max_level} chain */
	private static final int[][] PATH_DWARF = {
		{109256, -173752, -544},
		{109688, -173720, -544},
		{110456, -173704, -544},
		{111480, -173544, -608},
		{112568, -173672, -608},
		{113240, -174328, -608},
		{113432, -175112, -608},
		{113656, -175768, -672},
		{114120, -176280, -736},
		{114664, -176424, -752},
		{115048, -176664, -784},
		{115272, -177416, -912},
		{115416, -178296, -928}
	};

	static
	{
		PATH_BY_CLASS_ID.put(0, PATH_HUMAN_FIGHTER);
		PATH_BY_CLASS_ID.put(10, PATH_HUMAN_MAGE);
		for(int c : new int[] {18, 25})
			PATH_BY_CLASS_ID.put(c, PATH_ELF);
		for(int c : new int[] {31, 38})
			PATH_BY_CLASS_ID.put(c, PATH_DARK_ELF);
		for(int c : new int[] {44, 49})
			PATH_BY_CLASS_ID.put(c, PATH_ORC);
		PATH_BY_CLASS_ID.put(53, PATH_DWARF);
	}

	public static int[][] getPathForClass(int classId)
	{
		return PATH_BY_CLASS_ID.get(classId);
	}

	/** Per-bot copy of the route with small XY jitter so paths do not stack. */
	public static int[][] buildJitteredPath(int[][] base, int jitter)
	{
		if(base == null)
			return null;
		if(jitter <= 0)
		{
			int[][] c = new int[base.length][3];
			for(int i = 0; i < base.length; i++)
			{
				c[i][0] = base[i][0];
				c[i][1] = base[i][1];
				c[i][2] = base[i][2];
			}
			return c;
		}
		int[][] out = new int[base.length][3];
		for(int i = 0; i < base.length; i++)
		{
			out[i][0] = base[i][0] + Rnd.get(-jitter, jitter);
			out[i][1] = base[i][1] + Rnd.get(-jitter, jitter);
			out[i][2] = base[i][2];
		}
		return out;
	}

	/**
	 * Index of the waypoint to walk toward first. Chooses the closest point on the polyline
	 * so different spawns do not walk backward to waypoint 0.
	 */
	public static int findStartWaypointIndex(Player player, int[][] path)
	{
		if(path == null || path.length == 0 || player == null)
			return 0;

		int px = player.getX();
		int py = player.getY();
		long bestDist = Long.MAX_VALUE;
		int bestIdx = 0;
		for(int i = 0; i < path.length; i++)
		{
			long dx = px - path[i][0];
			long dy = py - path[i][1];
			long d = dx * dx + dy * dy;
			if(d < bestDist)
			{
				bestDist = d;
				bestIdx = i;
			}
		}
		return bestIdx;
	}
}

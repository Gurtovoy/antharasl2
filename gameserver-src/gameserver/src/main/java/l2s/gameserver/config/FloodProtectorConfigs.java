/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.config;

import java.util.ArrayList;
import java.util.List;
import l2s.commons.configuration.ExProperties;
import l2s.gameserver.Config;
import l2s.gameserver.config.FloodProtectorConfig;
import org.apache.commons.lang3.StringUtils;

public final class FloodProtectorConfigs {
    public static final String FLOOD_PROTECTOR_FILE = "config/flood_protector.properties";
    public static final List<FloodProtectorConfig> FLOOD_PROTECTORS = new ArrayList<FloodProtectorConfig>();

    public static void load() {
        String[] floodProtectorTypes;
        ExProperties floodProtectors = Config.load(FLOOD_PROTECTOR_FILE);
        for (String type : floodProtectorTypes = floodProtectors.getProperty("FLOOD_PROTECTORS_TYPES", "").split(";")) {
            FloodProtectorConfig floodProtector;
            if (StringUtils.isEmpty((CharSequence)type) || (floodProtector = FloodProtectorConfig.load(type, floodProtectors)) == null) continue;
            FLOOD_PROTECTORS.add(floodProtector);
        }
    }
}


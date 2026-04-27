/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.config.xml;

import l2s.gameserver.config.xml.parser.HostsConfigParser;
import l2s.gameserver.config.xml.parser.VoteRewardConfigParser;

public abstract class ConfigParsers {
    public static void parseAllOnLoad() {
        HostsConfigParser.getInstance().load();
    }

    public static void parseAllOnInit() {
        VoteRewardConfigParser.getInstance().load();
    }
}


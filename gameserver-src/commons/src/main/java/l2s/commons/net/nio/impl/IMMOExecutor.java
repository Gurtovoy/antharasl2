package l2s.commons.net.nio.impl;

import l2s.commons.net.nio.impl.MMOClient;

public interface IMMOExecutor<T extends MMOClient> {
    public void execute(Runnable var1);
}


package l2s.gameserver.network.l2.c2s;

public class ExSendClientINI2 extends L2GameClientPacket {

    private int _iniType;

    @Override
    protected boolean readImpl() {
        _iniType = readH();
        return true;
    }

    @Override
    protected void runImpl() {
    }
}

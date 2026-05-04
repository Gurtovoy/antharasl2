package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestHardWareInfo
extends L2GameClientPacket {
    private String _mac;
    private String _cpu;
    private String _vgaName;
    private String _driverVersion;
    private int _windowsPlatformId;
    private int _windowsMajorVersion;
    private int _windowsMinorVersion;
    private int _windowsBuildNumber;
    private int _DXVersion;
    private int _DXRevision;
    private int _cpuSpeed;
    private int _cpuCoreCount;
    private int _unk8;
    private int _unk9;
    private int _PhysMemory1;
    private int _PhysMemory2;
    private int _unk12;
    private int _videoMemory;
    private int _unk14;
    private int _vgaVersion;

    @Override
    protected boolean readImpl() {
        this._mac = this.readS();
        this._windowsPlatformId = this.readD();
        this._windowsMajorVersion = this.readD();
        this._windowsMinorVersion = this.readD();
        this._windowsBuildNumber = this.readD();
        this._DXVersion = this.readD();
        this._DXRevision = this.readD();
        this._cpu = this.readS();
        this._cpuSpeed = this.readD();
        this._cpuCoreCount = this.readD();
        this._unk8 = this.readD();
        this._unk9 = this.readD();
        this._PhysMemory1 = this.readD();
        this._PhysMemory2 = this.readD();
        this._unk12 = this.readD();
        this._videoMemory = this.readD();
        this._unk14 = this.readD();
        this._vgaVersion = this.readD();
        this._vgaName = this.readS();
        this._driverVersion = this.readS();
        return true;
    }

    @Override
    protected void runImpl() {
    }
}


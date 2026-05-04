package l2s.gameserver.network.l2.s2c;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class AdminForgePacket
extends L2GameServerPacket {
    private List<Part> _parts = new ArrayList<Part>();

    @Override
    protected boolean writeOpcodes() {
        return true;
    }

    @Override
    protected void writeImpl() {
        for (Part p : this._parts) {
            this.generate(p.b, p.str);
        }
    }

    public boolean generate(byte b, String string) {
        if (b == 67 || b == 99) {
            this.writeC(Integer.decode(string));
            return true;
        }
        if (b == 68 || b == 100) {
            this.writeD(Integer.decode(string));
            return true;
        }
        if (b == 72 || b == 104) {
            this.writeH(Integer.decode(string));
            return true;
        }
        if (b == 70 || b == 102) {
            this.writeF(Double.parseDouble(string));
            return true;
        }
        if (b == 83 || b == 115) {
            this.writeS(string);
            return true;
        }
        if (b == 84 || b == 116) {
            this.writeString(string);
            return true;
        }
        if (b == 66 || b == 98 || b == 88 || b == 120) {
            this.writeB(new BigInteger(string).toByteArray());
            return true;
        }
        if (b == 81 || b == 113) {
            this.writeQ(Long.decode(string));
            return true;
        }
        return false;
    }

    public void addPart(byte b, String string) {
        this._parts.add(new Part(b, string));
    }

    private static class Part {
        public byte b;
        public String str;

        public Part(byte bb, String string) {
            this.b = bb;
            this.str = string;
        }
    }
}


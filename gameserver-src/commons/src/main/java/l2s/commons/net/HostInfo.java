package l2s.commons.net;

import java.util.Map;
import java.util.TreeMap;
import l2s.commons.net.utils.Net;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class HostInfo {
    private static final Logger _log = LoggerFactory.getLogger(HostInfo.class);
    private final int _id;
    private final String _address;
    private final int _port;
    private final String _key;
    private final Map<Net, String> _subnets = new TreeMap<Net, String>();

    public HostInfo(int id, String address, int port, String key) {
        this._id = id;
        this._address = address;
        this._port = port;
        this._key = key;
    }

    public HostInfo(String address, int port) {
        this._id = 0;
        this._address = address;
        this._port = port;
        this._key = null;
    }

    public int getId() {
        return this._id;
    }

    public String getAddress() {
        return this._address;
    }

    public int getPort() {
        return this._port;
    }

    public String getKey() {
        return this._key;
    }

    public void addSubnet(String address, String subnet) {
        try {
            this._subnets.put(Net.valueOf(subnet), address);
        }
        catch (Exception e) {
            _log.error("", (Throwable)e);
        }
    }

    public void addSubnet(String address, byte[] subnetAddress, byte[] subnetMask) {
        try {
            this._subnets.put(Net.valueOf(subnetAddress, subnetMask), address);
        }
        catch (Exception e) {
            _log.error("", (Throwable)e);
        }
    }

    public Map<Net, String> getSubnets() {
        return this._subnets;
    }

    public String checkAddress(String address) {
        for (Map.Entry<Net, String> m : this.getSubnets().entrySet()) {
            if (!m.getKey().matches(address)) continue;
            return m.getValue();
        }
        return this.getAddress();
    }
}


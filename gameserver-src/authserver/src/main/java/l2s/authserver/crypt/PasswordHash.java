package l2s.authserver.crypt;

import jonelo.jacksum.JacksumAPI;
import jonelo.jacksum.algorithm.AbstractChecksum;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PasswordHash {
    private static final Logger _log = LoggerFactory.getLogger(PasswordHash.class);
    private final String name;

    public PasswordHash(String name) {
        this.name = name;
    }

    public boolean compare(String password, String expected) {
        try {
            return this.encrypt(password).equals(expected);
        }
        catch (Exception e) {
            _log.error(this.name + ": encryption error!", (Throwable)e);
            return false;
        }
    }

    public String encrypt(String password) throws Exception {
        AbstractChecksum checksum = JacksumAPI.getChecksumInstance((String)this.name);
        checksum.setEncoding("BASE64");
        checksum.update(password.getBytes());
        return checksum.format("#CHECKSUM");
    }
}


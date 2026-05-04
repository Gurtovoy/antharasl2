/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.config.xml.parser;

import java.io.File;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.commons.net.HostInfo;
import l2s.gameserver.GameServer;
import l2s.gameserver.config.xml.holder.HostsConfigHolder;
import org.dom4j.Element;

public final class HostsConfigParser
extends AbstractParser<HostsConfigHolder> {
    private static final HostsConfigParser _instance = new HostsConfigParser();

    public static HostsConfigParser getInstance() {
        return _instance;
    }

    protected HostsConfigParser() {
        super(HostsConfigHolder.getInstance());
    }

    public File getXMLPath() {
        return new File("config/hostsconfig.xml");
    }

    public String getDTDFileName() {
        return "hostsconfig.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            if ("authserver".equalsIgnoreCase(element.getName())) {
                String address = element.attributeValue("address");
                int port = Integer.parseInt(element.attributeValue("port"));
                ((HostsConfigHolder)this.getHolder()).setAuthServerHost(new HostInfo(address, port));
                continue;
            }
            if (!"gameserver".equalsIgnoreCase(element.getName())) continue;
            Iterator subIterator = element.elementIterator("host");
            while (subIterator.hasNext()) {
                Element subElement = (Element)subIterator.next();
                int id = Integer.parseInt(subElement.attributeValue("id"));
                String address = GameServer.DEVELOP ? "127.0.0.1" : subElement.attributeValue("address");
                int port = Integer.parseInt(subElement.attributeValue("port"));
                String key = subElement.attributeValue("key");
                HostInfo hostInfo = new HostInfo(id, address, port, key);
                if (!GameServer.DEVELOP) {
                    Iterator advancedIterator = subElement.elementIterator("advanced");
                    while (advancedIterator.hasNext()) {
                        Element advancedElement = (Element)advancedIterator.next();
                        String advanced_address = advancedElement.attributeValue("address");
                        String advanced_subnet = advancedElement.attributeValue("subnet");
                        hostInfo.addSubnet(advanced_address, advanced_subnet);
                    }
                }
                ((HostsConfigHolder)this.getHolder()).addGameServerHost(hostInfo);
            }
        }
    }

    protected void onParsed() {
        if (((HostsConfigHolder)this.getHolder()).getAuthServerHost() == null) {
            this._log.error("Could not load authserver host config. Configure your hostsconfig.xml!");
            Runtime.getRuntime().exit(0);
        }
        if (((HostsConfigHolder)this.getHolder()).getGameServerHosts().length == 0) {
            this._log.error("Could not load gameserver host config. Configure your hostsconfig.xml!");
            Runtime.getRuntime().exit(0);
        }
    }
}


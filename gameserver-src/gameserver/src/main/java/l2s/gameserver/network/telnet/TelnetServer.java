/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.telnet;

import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;
import l2s.gameserver.Config;
import l2s.gameserver.network.telnet.TelnetPipelineFactory;
import l2s.gameserver.network.telnet.TelnetServerHandler;
import org.jboss.netty.bootstrap.ServerBootstrap;
import org.jboss.netty.channel.ChannelFactory;
import org.jboss.netty.channel.ChannelHandler;
import org.jboss.netty.channel.ChannelPipelineFactory;
import org.jboss.netty.channel.socket.nio.NioServerSocketChannelFactory;

public class TelnetServer {
    public TelnetServer() {
        ServerBootstrap bootstrap = new ServerBootstrap((ChannelFactory)new NioServerSocketChannelFactory((Executor)Executors.newFixedThreadPool(1), (Executor)Executors.newFixedThreadPool(1), 1));
        TelnetServerHandler handler = new TelnetServerHandler();
        bootstrap.setPipelineFactory((ChannelPipelineFactory)new TelnetPipelineFactory((ChannelHandler)handler));
        bootstrap.bind((SocketAddress)new InetSocketAddress(Config.TELNET_HOSTNAME.equals("*") ? null : Config.TELNET_HOSTNAME, Config.TELNET_PORT));
    }
}


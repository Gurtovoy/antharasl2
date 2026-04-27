/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.jboss.netty.channel.ChannelFuture
 *  org.jboss.netty.channel.ChannelFutureListener
 *  org.jboss.netty.channel.ChannelHandlerContext
 *  org.jboss.netty.channel.ChannelStateEvent
 *  org.jboss.netty.channel.ExceptionEvent
 *  org.jboss.netty.channel.MessageEvent
 *  org.jboss.netty.channel.SimpleChannelUpstreamHandler
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.network.telnet;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import l2s.gameserver.Config;
import l2s.gameserver.network.telnet.TelnetCommand;
import l2s.gameserver.network.telnet.TelnetCommandHolder;
import l2s.gameserver.network.telnet.commands.TelnetBan;
import l2s.gameserver.network.telnet.commands.TelnetConfig;
import l2s.gameserver.network.telnet.commands.TelnetDebug;
import l2s.gameserver.network.telnet.commands.TelnetPerfomance;
import l2s.gameserver.network.telnet.commands.TelnetSay;
import l2s.gameserver.network.telnet.commands.TelnetServer;
import l2s.gameserver.network.telnet.commands.TelnetStatus;
import l2s.gameserver.network.telnet.commands.TelnetWorld;
import org.jboss.netty.channel.ChannelFuture;
import org.jboss.netty.channel.ChannelFutureListener;
import org.jboss.netty.channel.ChannelHandlerContext;
import org.jboss.netty.channel.ChannelStateEvent;
import org.jboss.netty.channel.ExceptionEvent;
import org.jboss.netty.channel.MessageEvent;
import org.jboss.netty.channel.SimpleChannelUpstreamHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TelnetServerHandler
extends SimpleChannelUpstreamHandler
implements TelnetCommandHolder {
    private static final Logger _log = LoggerFactory.getLogger(TelnetServerHandler.class);
    private static final Pattern COMMAND_ARGS_PATTERN = Pattern.compile("\"([^\"]*)\"|([^\\s]+)");
    private Set<TelnetCommand> _commands = new LinkedHashSet<TelnetCommand>();

    public TelnetServerHandler() {
        this._commands.add(new TelnetCommand("help", new String[]{"h"}){

            @Override
            public String getUsage() {
                return "help [command]";
            }

            @Override
            public String handle(String[] args) {
                if (args.length == 0) {
                    StringBuilder sb = new StringBuilder();
                    sb.append("Available commands:\n");
                    for (TelnetCommand cmd : TelnetServerHandler.this._commands) {
                        sb.append(cmd.getCommand()).append("\n");
                    }
                    return sb.toString();
                }
                TelnetCommand cmd = TelnetServerHandler.this.getCommand(args[0]);
                if (cmd == null) {
                    return "Unknown command.\n";
                }
                return "usage:\n" + cmd.getUsage() + "\n";
            }
        });
        this.addHandler(new TelnetBan());
        this.addHandler(new TelnetConfig());
        this.addHandler(new TelnetDebug());
        this.addHandler(new TelnetPerfomance());
        this.addHandler(new TelnetSay());
        this.addHandler(new TelnetServer());
        this.addHandler(new TelnetStatus());
        this.addHandler(new TelnetWorld());
    }

    public void addHandler(TelnetCommandHolder handler) {
        for (TelnetCommand cmd : handler.getCommands()) {
            this._commands.add(cmd);
        }
    }

    @Override
    public Set<TelnetCommand> getCommands() {
        return this._commands;
    }

    private TelnetCommand getCommand(String command) {
        for (TelnetCommand cmd : this._commands) {
            if (!cmd.equals(command)) continue;
            return cmd;
        }
        return null;
    }

    private String tryHandleCommand(String command, String[] args) {
        TelnetCommand cmd = this.getCommand(command);
        if (cmd == null) {
            return "Unknown command.\n";
        }
        String response = cmd.handle(args);
        if (response == null) {
            response = "usage:\n" + cmd.getUsage() + "\n";
        }
        return response;
    }

    public void channelConnected(ChannelHandlerContext ctx, ChannelStateEvent e) throws Exception {
        e.getChannel().write((Object)"Welcome to L2 GameServer telnet console.\n");
        e.getChannel().write((Object)("It is " + new Date() + " now.\n"));
        if (!Config.TELNET_PASSWORD.isEmpty()) {
            e.getChannel().write((Object)"Password:");
            ctx.setAttachment((Object)Boolean.FALSE);
        } else {
            e.getChannel().write((Object)"Type 'help' to see all available commands.\n");
            ctx.setAttachment((Object)Boolean.TRUE);
        }
    }

    public void messageReceived(ChannelHandlerContext ctx, MessageEvent e) {
        String request = (String)e.getMessage();
        String response = null;
        boolean close = false;
        if (Boolean.FALSE.equals(ctx.getAttachment())) {
            if (Config.TELNET_PASSWORD.equals(request)) {
                ctx.setAttachment((Object)Boolean.TRUE);
                request = "";
            } else {
                response = "Wrong password!\n";
                close = true;
            }
        }
        if (Boolean.TRUE.equals(ctx.getAttachment())) {
            if (request.isEmpty()) {
                response = "Type 'help' to see all available commands.\n";
            } else if (request.toLowerCase().equals("exit")) {
                response = "Have a good day!\n";
                close = true;
            } else {
                Matcher m = COMMAND_ARGS_PATTERN.matcher(request);
                m.find();
                String command = m.group();
                ArrayList<String> args = new ArrayList<String>();
                while (m.find()) {
                    String arg = m.group(1);
                    if (arg == null) {
                        arg = m.group(0);
                    }
                    args.add(arg);
                }
                response = this.tryHandleCommand(command, args.toArray(new String[args.size()]));
            }
        }
        ChannelFuture future = e.getChannel().write((Object)response);
        if (close) {
            future.addListener(ChannelFutureListener.CLOSE);
        }
    }

    public void exceptionCaught(ChannelHandlerContext ctx, ExceptionEvent e) {
        if (e.getCause() instanceof IOException) {
            e.getChannel().close();
        } else {
            _log.error("", e.getCause());
        }
    }
}


/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.utils.velocity;

import java.io.Writer;
import java.lang.reflect.Field;
import java.util.HashMap;
import java.util.Map;
import l2s.gameserver.Config;
import l2s.gameserver.utils.velocity.VelocityVariable;
import org.apache.commons.io.output.StringBuilderWriter;
import org.apache.velocity.VelocityContext;
import org.apache.velocity.app.Velocity;
import org.apache.velocity.context.Context;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class VelocityUtils {
    private static final Logger _log = LoggerFactory.getLogger(VelocityUtils.class);
    public static final Map<String, Object> GLOBAL_VARIABLES = new HashMap<String, Object>();

    public static void init() {
        Field[] fields;
        Velocity.setProperty((String)"input.encoding", (Object)"UTF-8");
        Velocity.setProperty((String)"runtime.log.instance", (Object)_log);
        Velocity.setProperty((String)"runtime.log.name", (Object)VelocityUtils.class.getName());
        Velocity.init();
        for (Field f : fields = Config.class.getDeclaredFields()) {
            try {
                if (!f.isAnnotationPresent(VelocityVariable.class)) continue;
                GLOBAL_VARIABLES.put(f.getName(), f.get(null));
            }
            catch (IllegalAccessException e) {
                throw new Error(e);
            }
        }
    }

    public static void reload() {
        Field[] fields;
        for (Field f : fields = Config.class.getDeclaredFields()) {
            try {
                if (!f.isAnnotationPresent(VelocityVariable.class)) continue;
                GLOBAL_VARIABLES.put(f.getName(), f.get(null));
            }
            catch (IllegalAccessException e) {
                throw new Error(e);
            }
        }
    }

    private static String evaluate0(String text, Map<String, Object> variables) {
        if (variables.isEmpty()) {
            return text;
        }
        try {
            VelocityContext velocityContext = new VelocityContext(variables);
            StringBuilderWriter writer = new StringBuilderWriter(new StringBuilder(text.length() + 32));
            if (!Velocity.evaluate((Context)velocityContext, (Writer)writer, (String)"", (String)text)) {
                _log.warn("Fail to evaluate: \n" + text);
                return "";
            }
            return writer.toString();
        }
        catch (Exception exception) {
            return text;
        }
    }

    public static String evaluate(String text, Map<String, Object> variables) {
        if (variables != null) {
            variables.putAll(GLOBAL_VARIABLES);
        } else {
            variables = GLOBAL_VARIABLES;
        }
        return VelocityUtils.evaluate0(text, variables);
    }
}


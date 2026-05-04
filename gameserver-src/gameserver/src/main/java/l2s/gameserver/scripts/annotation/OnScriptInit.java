/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.scripts.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Retention(value=RetentionPolicy.RUNTIME)
@Target(value={ElementType.METHOD})
public @interface OnScriptInit {
}


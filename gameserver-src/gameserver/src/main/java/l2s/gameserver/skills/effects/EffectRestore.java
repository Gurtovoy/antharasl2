/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.effects;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.templates.skill.EffectTemplate;

public abstract class EffectRestore
extends EffectHandler {
    protected final boolean _ignoreBonuses = this.getParams().getBool("ignore_bonuses", false);
    protected final boolean _percent = this.getParams().getBool("percent", false);
    protected final boolean _staticPower;

    public EffectRestore(EffectTemplate template) {
        super(template);
        this._staticPower = this.getParams().getBool("static_power", this._percent || !template.isInstant());
    }
}


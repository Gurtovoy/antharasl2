/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.effects;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.network.l2.s2c.FlyToLocationPacket;
import l2s.gameserver.templates.skill.EffectTemplate;

public abstract class EffectFlyAbstract
extends EffectHandler {
    private final FlyToLocationPacket.FlyType _flyType = (FlyToLocationPacket.FlyType)this.getParams().getEnum("fly_type", FlyToLocationPacket.FlyType.class, this.getSkill().getFlyType());
    private final double _flyCourse = this.getParams().getDouble("fly_course", 0.0);
    private final int _flySpeed = this.getParams().getInteger("fly_speed", this.getSkill().getFlySpeed());
    private final int _flyDelay = this.getParams().getInteger("fly_delay", this.getSkill().getFlyDelay());
    private final int _flyAnimationSpeed = this.getParams().getInteger("fly_animation_speed", this.getSkill().getFlyAnimationSpeed());
    private final int _flyRadius = this.getParams().getInteger("fly_radius", this.getSkill().getFlyRadius());

    public EffectFlyAbstract(EffectTemplate template) {
        super(template);
    }

    public FlyToLocationPacket.FlyType getFlyType() {
        return this._flyType;
    }

    public double getFlyCourse() {
        return this._flyCourse;
    }

    public int getFlySpeed() {
        return this._flySpeed;
    }

    public int getFlyDelay() {
        return this._flyDelay;
    }

    public int getFlyAnimationSpeed() {
        return this._flyAnimationSpeed;
    }

    public int getFlyRadius() {
        return this._flyRadius;
    }
}


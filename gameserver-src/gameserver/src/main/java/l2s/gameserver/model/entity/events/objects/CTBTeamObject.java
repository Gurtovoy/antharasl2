package l2s.gameserver.model.entity.events.objects;

import l2s.gameserver.data.xml.holder.NpcHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.idfactory.IdFactory;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.objects.CTBSiegeClanObject;
import l2s.gameserver.model.entity.events.objects.SpawnableObject;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.instances.residences.clanhall.CTBBossInstance;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.npc.NpcTemplate;

public class CTBTeamObject
implements SpawnableObject {
    private CTBSiegeClanObject _siegeClan;
    private final NpcTemplate _mobTemplate;
    private final NpcTemplate _flagTemplate;
    private final Location _flagLoc;
    private NpcInstance _flag;
    private CTBBossInstance _mob;

    public CTBTeamObject(int mobTemplate, int flagTemplate, Location flagLoc) {
        this._mobTemplate = NpcHolder.getInstance().getTemplate(mobTemplate);
        this._flagTemplate = NpcHolder.getInstance().getTemplate(flagTemplate);
        this._flagLoc = flagLoc;
    }

    @Override
    public void spawnObject(Event event, Reflection reflection) {
        if (this._flag == null) {
            this._flag = new NpcInstance(IdFactory.getInstance().getNextId(), this._flagTemplate, StatsSet.EMPTY);
            this._flag.setCurrentHpMp(this._flag.getMaxHp(), this._flag.getMaxMp());
            this._flag.setHasChatWindow(false);
            this._flag.spawnMe(this._flagLoc);
        } else if (this._mob == null) {
            NpcTemplate template = this._siegeClan == null || this._siegeClan.getParam() == 0L ? this._mobTemplate : NpcHolder.getInstance().getTemplate((int)this._siegeClan.getParam());
            this._mob = (CTBBossInstance)template.getNewInstance();
            this._mob.setCurrentHpMp(this._mob.getMaxHp(), this._mob.getMaxMp());
            this._mob.setMatchTeamObject(this);
            this._mob.addEvent(event);
            int x = (int)((double)this._flagLoc.x + 300.0 * Math.cos(this._mob.headingToRadians(this._flag.getHeading() - 32768)));
            int y = (int)((double)this._flagLoc.y + 300.0 * Math.sin(this._mob.headingToRadians(this._flag.getHeading() - 32768)));
            Location loc = new Location(x, y, this._flag.getZ(), this._flag.getHeading());
            this._mob.setSpawnedLoc(loc);
            this._mob.spawnMe(loc);
        } else {
            throw new IllegalArgumentException("Cant spawn twice");
        }
    }

    @Override
    public void despawnObject(Event event, Reflection reflection) {
        if (this._mob != null) {
            this._mob.deleteMe();
            this._mob = null;
        }
        if (this._flag != null) {
            this._flag.deleteMe();
            this._flag = null;
        }
        this._siegeClan = null;
    }

    @Override
    public void respawnObject(Event event, Reflection reflection) {
    }

    @Override
    public void refreshObject(Event event, Reflection reflection) {
    }

    public CTBSiegeClanObject getSiegeClan() {
        return this._siegeClan;
    }

    public void setSiegeClan(CTBSiegeClanObject siegeClan) {
        this._siegeClan = siegeClan;
    }

    public boolean isParticle() {
        return this._flag != null && this._mob != null;
    }

    public NpcInstance getFlag() {
        return this._flag;
    }
}


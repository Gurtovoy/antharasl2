/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.skills.EffectUseType;
import l2s.gameserver.utils.SqlBatch;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class EffectsDAO {
    private static final int SUMMON_SKILL_OFFSET = 100000;
    private static final Logger _log = LoggerFactory.getLogger(EffectsDAO.class);
    private static final EffectsDAO _instance = new EffectsDAO();

    EffectsDAO() {
    }

    public static EffectsDAO getInstance() {
        return _instance;
    }

    
    public void restoreEffects(Playable playable) {
        int id;
        int objectId;
        if (playable.isPlayer()) {
            objectId = playable.getObjectId();
            id = ((Player)playable).getActiveClassId();
        } else if (playable.isServitor()) {
            objectId = playable.getPlayer().getObjectId();
            id = ((Servitor)playable).getEffectIdentifier();
            if (playable.isSummon()) {
                id += 100000;
                id *= 10;
            }
        } else {
            return;
        }
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT `skill_id`,`skill_level`,`duration`,`left_time`,`is_self` FROM `character_effects_save` WHERE `object_id`=? AND `id`=?");
            statement.setInt(1, objectId);
            statement.setInt(2, id);
            rset = statement.executeQuery();
            while (rset.next()) {
                int skillId = rset.getInt("skill_id");
                int skillLvl = rset.getInt("skill_level");
                Skill skill = SkillHolder.getInstance().getSkill(skillId, skillLvl);
                if (skill == null) continue;
                boolean isSelf = rset.getInt("is_self") > 0;
                int duration = rset.getInt("duration");
                int leftTime = rset.getInt("left_time");
                EffectUseType useType = isSelf ? EffectUseType.SELF : EffectUseType.NORMAL;
                Abnormal abnormal = new Abnormal(playable, playable, skill, useType, true);
                if (!abnormal.isSaveable()) continue;
                abnormal.setDuration(duration);
                abnormal.setTimeLeft(leftTime);
                playable.getAbnormalList().add(abnormal);
            }
            DbUtils.closeQuietly((Statement)statement, (ResultSet)rset);
            statement = con.prepareStatement("DELETE FROM character_effects_save WHERE object_id = ? AND id=?");
            statement.setInt(1, objectId);
            statement.setInt(2, id);
            statement.execute();
            DbUtils.close((Statement)statement);
        }
        catch (Exception e) {
            _log.error("Could not restore active effects data!", (Throwable)e);
        }
        finally {
            DbUtils.closeQuietly((Connection)con);
        }
    }

    
    public void insert(Playable playable) {
        Statement statement;
        Connection con;
        block11: {
            int id;
            int objectId;
            if (playable.isPlayer()) {
                objectId = playable.getObjectId();
                id = ((Player)playable).getActiveClassId();
            } else if (playable.isServitor()) {
                objectId = playable.getPlayer().getObjectId();
                id = ((Servitor)playable).getEffectIdentifier();
                if (playable.isSummon()) {
                    id += 100000;
                    id *= 10;
                }
            } else {
                return;
            }
            Abnormal[] effects = playable.getAbnormalList().toArray();
            if (effects.length == 0) {
                return;
            }
            con = null;
            statement = null;
            try {
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.createStatement();
                SqlBatch b = new SqlBatch("INSERT IGNORE INTO `character_effects_save` (`object_id`,`skill_id`,`skill_level`,`duration`,`left_time`,`id`,`is_self`) VALUES");
                for (Abnormal effect : effects) {
                    if (effect == null || !effect.isOfUseType(EffectUseType.SELF) && !effect.isOfUseType(EffectUseType.NORMAL) || !effect.isSaveable()) continue;
                    StringBuilder sb = new StringBuilder("(");
                    sb.append(objectId).append(",");
                    sb.append(effect.getSkill().getId()).append(",");
                    sb.append(effect.getSkill().getLevel()).append(",");
                    sb.append(effect.getDuration()).append(",");
                    sb.append(effect.getTimeLeft()).append(",");
                    sb.append(id).append(",");
                    sb.append(effect.isOfUseType(EffectUseType.SELF) ? 1 : 0).append(")");
                    b.write(sb.toString());
                }
                if (b.isEmpty()) break block11;
                statement.executeUpdate(b.close());
            }
            catch (Exception e) {
                try {
                    _log.error("Could not store active effects data!", (Throwable)e);
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly((Connection)con, statement);
                    throw throwable;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement);
            }
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    
    public void deleteBySkillId(int skillId) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("DELETE FROM character_effects_save WHERE skill_id=?");
            statement.setInt(1, skillId);
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("Could not delete effects data by skillId!", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }
}


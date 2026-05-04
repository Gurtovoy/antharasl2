package l2s.gameserver.network.l2.s2c;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.Config;
import l2s.gameserver.dao.CharacterDAO;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.CharSelectInfoPackage;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.model.base.Experience;
import l2s.gameserver.model.base.Race;
import l2s.gameserver.model.base.SubClassType;
import l2s.gameserver.model.items.Inventory;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.utils.AutoBan;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CharacterSelectionInfoPacket
extends L2GameServerPacket {
    private static final Logger _log = LoggerFactory.getLogger(CharacterSelectionInfoPacket.class);
    private final String _loginName;
    private final int _sessionId;
    private final CharSelectInfoPackage[] _characterPackages;
    private final boolean _hasPremiumAccount;

    public CharacterSelectionInfoPacket(GameClient client) {
        this._loginName = client.getLogin();
        this._sessionId = client.getSessionKey().playOkID1;
        this._characterPackages = CharacterSelectionInfoPacket.loadCharacterSelectInfo(this._loginName);
        this._hasPremiumAccount = client.getPremiumAccountType() > 0 && (long)client.getPremiumAccountExpire() > System.currentTimeMillis() / 1000L;
    }

    public CharSelectInfoPackage[] getCharInfo() {
        return this._characterPackages;
    }

    @Override
    protected final void writeImpl() {
        int i;
        int size = this._characterPackages != null ? this._characterPackages.length : 0;
        this.writeD(size);
        this.writeD(Config.MAX_CHARACTERS_NUMBER_PER_ACCOUNT);
        this.writeC(size >= Config.MAX_CHARACTERS_NUMBER_PER_ACCOUNT);
        this.writeC(0);
        this.writeD(2);
        this.writeC(0);
        this.writeC(0);
        long lastAccess = -1L;
        int lastUsed = -1;
        for (i = 0; i < size; ++i) {
            if (lastAccess >= this._characterPackages[i].getLastAccess()) continue;
            lastAccess = this._characterPackages[i].getLastAccess();
            lastUsed = i;
        }
        for (i = 0; i < size; ++i) {
            CharSelectInfoPackage charInfoPackage = this._characterPackages[i];
            this.writeS(charInfoPackage.getName(false));
            this.writeD(charInfoPackage.getCharId());
            this.writeS(this._loginName);
            this.writeD(this._sessionId);
            this.writeD(charInfoPackage.getClanId());
            this.writeD(0);
            this.writeD(charInfoPackage.getSex());
            this.writeD(charInfoPackage.getRace());
            this.writeD(charInfoPackage.getBaseClassId());
            this.writeD(Config.REQUEST_ID);
            this.writeD(charInfoPackage.getX());
            this.writeD(charInfoPackage.getY());
            this.writeD(charInfoPackage.getZ());
            this.writeF(charInfoPackage.getCurrentHp());
            this.writeF(charInfoPackage.getCurrentMp());
            this.writeQ(charInfoPackage.getSp());
            this.writeQ(charInfoPackage.getExp());
            int lvl = Experience.getLevel(charInfoPackage.getExp());
            this.writeF(Experience.getExpPercent(lvl, charInfoPackage.getExp()));
            this.writeD(lvl);
            this.writeD(charInfoPackage.getKarma());
            this.writeD(charInfoPackage.getPk());
            this.writeD(charInfoPackage.getPvP());
            this.writeD(0);
            this.writeD(0);
            this.writeD(0);
            this.writeD(0);
            this.writeD(0);
            this.writeD(0);
            this.writeD(0);
            this.writeD(0);
            this.writeD(0);
            for (int PAPERDOLL_ID : Inventory.PAPERDOLL_ORDER) {
                this.writeD(charInfoPackage.getPaperdollItemId(PAPERDOLL_ID));
            }
            this.writeD(charInfoPackage.getPaperdollVisualId(7));
            this.writeD(charInfoPackage.getPaperdollVisualId(8));
            this.writeD(charInfoPackage.getPaperdollVisualId(9));
            this.writeD(charInfoPackage.getPaperdollVisualId(10));
            this.writeD(charInfoPackage.getPaperdollVisualId(11));
            this.writeD(charInfoPackage.getPaperdollVisualId(12));
            this.writeD(charInfoPackage.getPaperdollVisualId(14));
            this.writeD(charInfoPackage.getPaperdollVisualId(15));
            this.writeD(charInfoPackage.getPaperdollVisualId(16));
            this.writeH(charInfoPackage.getPaperdollEnchantEffect(10));
            this.writeH(charInfoPackage.getPaperdollEnchantEffect(11));
            this.writeH(charInfoPackage.getPaperdollEnchantEffect(6));
            this.writeH(charInfoPackage.getPaperdollEnchantEffect(9));
            this.writeH(charInfoPackage.getPaperdollEnchantEffect(12));
            this.writeD(charInfoPackage.getPaperdollItemId(15) > 0 ? charInfoPackage.getSex() : charInfoPackage.getHairStyle());
            this.writeD(charInfoPackage.getHairColor());
            this.writeD(charInfoPackage.getFace());
            this.writeF(charInfoPackage.getMaxHp());
            this.writeF(charInfoPackage.getMaxMp());
            this.writeD(charInfoPackage.getAccessLevel() > -100 ? charInfoPackage.getDeleteTimer() : -1);
            this.writeD(charInfoPackage.getClassId());
            this.writeD(i == lastUsed ? 1 : 0);
            this.writeC(Math.min(charInfoPackage.getPaperdollEnchantEffect(7), 127));
            this.writeD(charInfoPackage.getPaperdollVariation1Id(7));
            this.writeD(charInfoPackage.getPaperdollVariation2Id(7));
            this.writeD(0);
            this.writeD(0);
            this.writeD(0);
            this.writeD(0);
            this.writeD(0);
            this.writeF(0.0);
            this.writeF(0.0);
            this.writeD(0);
            this.writeD(0);
            this.writeD(0);
            this.writeD(charInfoPackage.isAvailable());
            this.writeC(0);
            this.writeC(charInfoPackage.isHero());
            this.writeC(charInfoPackage.isHairAccessoryEnabled() ? 1 : 0);
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public static CharSelectInfoPackage[] loadCharacterSelectInfo(String loginName) {
        ArrayList<CharSelectInfoPackage> characterList = new ArrayList<CharSelectInfoPackage>();
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT * FROM characters AS c LEFT JOIN character_subclasses AS cs ON (c.obj_Id=cs.char_obj_id AND cs.active=1) WHERE account_name=? ORDER BY createtime LIMIT " + Config.MAX_CHARACTERS_NUMBER_PER_ACCOUNT);
            statement.setString(1, loginName);
            rset = statement.executeQuery();
            while (rset.next()) {
                CharSelectInfoPackage charInfopackage = CharacterSelectionInfoPacket.restoreChar(rset);
                if (charInfopackage == null) continue;
                characterList.add(charInfopackage);
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        }
        catch (Exception e) {
            _log.error("could not restore charinfo:", (Throwable)e);
        }
        finally {
            DbUtils.closeQuietly((Connection)con, statement, rset);
        }
        return characterList.toArray(new CharSelectInfoPackage[characterList.size()]);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private static int restoreBaseClassId(int objId) {
        int classId = 0;
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT class_id FROM character_subclasses WHERE char_obj_id=? AND type=?");
            statement.setInt(1, objId);
            statement.setInt(2, SubClassType.BASE_CLASS.ordinal());
            rset = statement.executeQuery();
            while (rset.next()) {
                classId = rset.getInt("class_id");
            }
        }
        catch (Exception e) {
            try {
                _log.error("could not restore base class id:", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        return classId;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private static String restoreChangedOldName(int objId) {
        ResultSet rset;
        PreparedStatement statement;
        Connection con;
        String suffix;
        block4: {
            suffix = null;
            con = null;
            statement = null;
            rset = null;
            try {
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.prepareStatement("SELECT value FROM character_variables WHERE obj_id=? AND name=? AND (expire_time=-1 OR expire_time>=?)");
                statement.setInt(1, objId);
                statement.setString(2, "changed_old_name");
                statement.setLong(3, System.currentTimeMillis());
                rset = statement.executeQuery();
                if (!rset.next()) break block4;
                suffix = rset.getString("value");
            }
            catch (Exception e) {
                try {
                    _log.error("could not restore changed old name:", (Throwable)e);
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly((Connection)con, statement, rset);
                    throw throwable;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement, rset);
            }
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        return suffix;
    }

    private static CharSelectInfoPackage restoreChar(ResultSet chardata) {
        CharSelectInfoPackage charInfopackage = null;
        try {
            Race race;
            boolean useBaseClass;
            int classid;
            int objectId = chardata.getInt("obj_Id");
            int baseClassId = classid = chardata.getInt("class_id");
            boolean bl = useBaseClass = chardata.getInt("type") == SubClassType.BASE_CLASS.ordinal();
            if (!useBaseClass) {
                baseClassId = CharacterSelectionInfoPacket.restoreBaseClassId(objectId);
            }
            if ((race = ClassId.VALUES[baseClassId].getRace()) == null) {
                _log.warn(CharacterSelectionInfoPacket.class.getSimpleName() + ": Race was not found for the class id: " + baseClassId);
                return null;
            }
            String name = chardata.getString("char_name");
            charInfopackage = new CharSelectInfoPackage(objectId, name);
            charInfopackage.setMaxHp(chardata.getInt("maxHp"));
            charInfopackage.setCurrentHp(chardata.getDouble("curHp"));
            charInfopackage.setMaxMp(chardata.getInt("maxMp"));
            charInfopackage.setCurrentMp(chardata.getDouble("curMp"));
            charInfopackage.setX(chardata.getInt("x"));
            charInfopackage.setY(chardata.getInt("y"));
            charInfopackage.setZ(chardata.getInt("z"));
            charInfopackage.setPk(chardata.getInt("pkkills"));
            charInfopackage.setPvP(chardata.getInt("pvpkills"));
            int face = chardata.getInt("beautyFace");
            charInfopackage.setFace(face > 0 ? face : chardata.getInt("face"));
            int hairstyle = chardata.getInt("beautyHairstyle");
            charInfopackage.setHairStyle(hairstyle > 0 ? hairstyle : chardata.getInt("hairstyle"));
            int haircolor = chardata.getInt("beautyHaircolor");
            charInfopackage.setHairColor(haircolor > 0 ? haircolor : chardata.getInt("haircolor"));
            charInfopackage.setSex(chardata.getInt("sex"));
            charInfopackage.setExp(chardata.getLong("exp"));
            charInfopackage.setSp(chardata.getLong("sp"));
            charInfopackage.setClanId(chardata.getInt("clanid"));
            charInfopackage.setKarma(chardata.getInt("karma"));
            charInfopackage.setRace(race.ordinal());
            charInfopackage.setClassId(classid);
            charInfopackage.setBaseClassId(baseClassId);
            long deletetime = chardata.getLong("deletetime");
            int deletehours = 0;
            if (Config.CHARACTER_DELETE_AFTER_HOURS > 0) {
                if (deletetime > 0L) {
                    deletetime = (int)(System.currentTimeMillis() / 1000L - deletetime);
                    deletehours = (int)(deletetime / 3600L);
                    if (deletehours >= Config.CHARACTER_DELETE_AFTER_HOURS) {
                        CharacterDAO.getInstance().deleteCharByObjId(objectId);
                        return null;
                    }
                    deletetime = (long)(Config.CHARACTER_DELETE_AFTER_HOURS * 3600) - deletetime;
                } else {
                    deletetime = 0L;
                }
            }
            charInfopackage.setDeleteTimer((int)deletetime);
            charInfopackage.setLastAccess(chardata.getLong("lastAccess") * 1000L);
            charInfopackage.setAccessLevel(chardata.getInt("accesslevel"));
            charInfopackage.setHairAccessoryEnabled(chardata.getInt("hide_head_accessories") == 0);
            if (charInfopackage.getAccessLevel() < 0 && !AutoBan.isBanned(objectId)) {
                charInfopackage.setAccessLevel(0);
            }
            charInfopackage.setChangedOldName(CharacterSelectionInfoPacket.restoreChangedOldName(objectId));
        }
        catch (Exception e) {
            _log.error("", (Throwable)e);
        }
        return charInfopackage;
    }
}


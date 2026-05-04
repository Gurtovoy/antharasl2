package l2s.commons.dao;

import java.io.Serializable;
import l2s.commons.dao.JdbcEntityState;

public interface JdbcEntity
extends Serializable {
    public void setJdbcState(JdbcEntityState var1);

    public JdbcEntityState getJdbcState();

    public void save();

    public void update();

    public void delete();
}


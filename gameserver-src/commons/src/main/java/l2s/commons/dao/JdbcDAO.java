package l2s.commons.dao;

import java.io.Serializable;
import l2s.commons.dao.JdbcEntity;
import l2s.commons.dao.JdbcEntityStats;

public interface JdbcDAO<K extends Serializable, E extends JdbcEntity> {
    public E load(K var1);

    public void save(E var1);

    public void update(E var1);

    public void saveOrUpdate(E var1);

    public void delete(E var1);

    public JdbcEntityStats getStats();
}


package l2s.gameserver.utils;

public class SqlBatch {
    private String _header;
    private String _tail;
    private StringBuilder _sb;
    private StringBuilder _result;
    private long _limit = Long.MAX_VALUE;
    private boolean isEmpty = true;

    public SqlBatch(String header, String tail) {
        this._header = header + "\n";
        this._tail = tail != null && tail.length() > 0 ? " " + tail + ";\n" : ";\n";
        this._sb = new StringBuilder(this._header);
        this._result = new StringBuilder();
    }

    public SqlBatch(String header) {
        this(header, null);
    }

    public void writeStructure(String str) {
        this._result.append(str);
    }

    public void write(String str) {
        this.isEmpty = false;
        if ((long)(this._sb.length() + str.length()) < this._limit - (long)this._tail.length()) {
            this._sb.append(str + ",\n");
        } else {
            this._sb.append(str + this._tail);
            this._result.append(this._sb.toString());
            this._sb = new StringBuilder(this._header);
        }
    }

    public void writeBuffer() {
        String last = this._sb.toString();
        if (last.length() > 0) {
            this._result.append(last.substring(0, last.length() - 2) + this._tail);
        }
        this._sb = new StringBuilder(this._header);
    }

    public String close() {
        if (this._sb.length() > this._header.length()) {
            this.writeBuffer();
        }
        return this._result.toString();
    }

    public void setLimit(long l) {
        this._limit = l;
    }

    public boolean isEmpty() {
        return this.isEmpty;
    }
}


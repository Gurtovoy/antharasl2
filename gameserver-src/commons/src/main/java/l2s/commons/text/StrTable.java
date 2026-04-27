/*
 * Decompiled with CFR 0.152.
 */
package l2s.commons.text;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class StrTable {
    private final Map<Integer, Map<String, String>> rows = new HashMap<Integer, Map<String, String>>();
    private final Map<String, Integer> columns = new LinkedHashMap<String, Integer>();
    private final List<String> titles = new ArrayList<String>();

    public StrTable(String title) {
        if (title != null) {
            this.titles.add(title);
        }
    }

    public StrTable() {
        this(null);
    }

    public StrTable set(int rowIndex, String colName, boolean val) {
        return this.set(rowIndex, colName, Boolean.toString(val));
    }

    public StrTable set(int rowIndex, String colName, byte val) {
        return this.set(rowIndex, colName, Byte.toString(val));
    }

    public StrTable set(int rowIndex, String colName, char val) {
        return this.set(rowIndex, colName, String.valueOf(val));
    }

    public StrTable set(int rowIndex, String colName, short val) {
        return this.set(rowIndex, colName, Short.toString(val));
    }

    public StrTable set(int rowIndex, String colName, int val) {
        return this.set(rowIndex, colName, Integer.toString(val));
    }

    public StrTable set(int rowIndex, String colName, long val) {
        return this.set(rowIndex, colName, Long.toString(val));
    }

    public StrTable set(int rowIndex, String colName, float val) {
        return this.set(rowIndex, colName, Float.toString(val));
    }

    public StrTable set(int rowIndex, String colName, double val) {
        return this.set(rowIndex, colName, Double.toString(val));
    }

    public StrTable set(int rowIndex, String colName, Object val) {
        return this.set(rowIndex, colName, String.valueOf(val));
    }

    public StrTable set(int rowIndex, String colName, String val) {
        int columnSize;
        Map<String, String> row;
        if (this.rows.containsKey(rowIndex)) {
            row = this.rows.get(rowIndex);
        } else {
            row = new HashMap<String, String>();
            this.rows.put(rowIndex, row);
        }
        row.put(colName, val);
        if (!this.columns.containsKey(colName)) {
            columnSize = Math.max(colName.length(), val.length());
        } else {
            columnSize = val.length();
            if (this.columns.get(colName) >= columnSize) {
                return this;
            }
        }
        this.columns.put(colName, columnSize);
        return this;
    }

    public StrTable addTitle(String s) {
        this.titles.add(s);
        return this;
    }

    private static StringBuilder right(StringBuilder result, String s, int sz) {
        result.append(s);
        if ((sz -= s.length()) > 0) {
            for (int i = 0; i < sz; ++i) {
                result.append(" ");
            }
        }
        return result;
    }

    private static StringBuilder center(StringBuilder result, String s, int sz) {
        int i;
        int offset = result.length();
        result.append(s);
        while ((i = sz - (result.length() - offset)) > 0) {
            result.append(" ");
            if (i <= 1) continue;
            result.insert(offset, " ");
        }
        return result;
    }

    private static StringBuilder repeat(StringBuilder result, String s, int sz) {
        for (int i = 0; i < sz; ++i) {
            result.append(s);
        }
        return result;
    }

    public String toString() {
        StringBuilder result = new StringBuilder();
        if (this.columns.isEmpty()) {
            return result.toString();
        }
        StringBuilder header = new StringBuilder("|");
        StringBuilder line = new StringBuilder("|");
        for (String string : this.columns.keySet()) {
            StrTable.center(header, string, this.columns.get(string) + 2).append("|");
            StrTable.repeat(line, "-", this.columns.get(string) + 2).append("|");
        }
        if (!this.titles.isEmpty()) {
            result.append(" ");
            StrTable.repeat(result, "-", header.length() - 2).append(" ").append("\n");
            for (String string : this.titles) {
                result.append("| ");
                StrTable.right(result, string, header.length() - 3).append("|").append("\n");
            }
        }
        result.append(" ");
        StrTable.repeat(result, "-", header.length() - 2).append(" ").append("\n");
        result.append((CharSequence)header).append("\n");
        result.append((CharSequence)line).append("\n");
        for (Map<String, String> map : this.rows.values()) {
            result.append("|");
            for (String c : this.columns.keySet()) {
                StrTable.center(result, map.containsKey(c) ? (String)map.get(c) : "-", this.columns.get(c) + 2).append("|");
            }
            result.append("\n");
        }
        result.append(" ");
        StrTable.repeat(result, "-", header.length() - 2).append(" ").append("\n");
        return result.toString();
    }
}


/*
 * Decompiled with CFR 0.152.
 */
package l2s.commons.text;

import java.text.DecimalFormatSymbols;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class PrintfFormat {
    private List<ConversionSpecification> vFmt = new ArrayList<ConversionSpecification>();
    private int cPos = 0;
    private DecimalFormatSymbols dfs = null;

    public PrintfFormat(String fmtArg) throws IllegalArgumentException {
        this(Locale.getDefault(), fmtArg);
    }

    public PrintfFormat(Locale locale, String fmtArg) throws IllegalArgumentException {
        this.dfs = new DecimalFormatSymbols(locale);
        int ePos = 0;
        ConversionSpecification sFmt = null;
        String unCS = this.nonControl(fmtArg, 0);
        if (unCS != null) {
            sFmt = new ConversionSpecification();
            sFmt.setLiteral(unCS);
            this.vFmt.add(sFmt);
        }
        while (this.cPos != -1 && this.cPos < fmtArg.length()) {
            for (ePos = this.cPos + 1; ePos < fmtArg.length(); ++ePos) {
                char c = '\u0000';
                c = fmtArg.charAt(ePos);
                if (c == 'i' || c == 'd' || c == 'f' || c == 'g' || c == 'G' || c == 'o' || c == 'x' || c == 'X' || c == 'e' || c == 'E' || c == 'c' || c == 's' || c == '%') break;
            }
            ePos = Math.min(ePos + 1, fmtArg.length());
            sFmt = new ConversionSpecification(fmtArg.substring(this.cPos, ePos));
            this.vFmt.add(sFmt);
            unCS = this.nonControl(fmtArg, ePos);
            if (unCS == null) continue;
            sFmt = new ConversionSpecification();
            sFmt.setLiteral(unCS);
            this.vFmt.add(sFmt);
        }
    }

    private String nonControl(String s, int start) {
        this.cPos = s.indexOf("%", start);
        if (this.cPos == -1) {
            this.cPos = s.length();
        }
        return s.substring(start, this.cPos);
    }

    public String sprintf(Object ... o) {
        char c = '\u0000';
        int i = 0;
        StringBuilder sb = new StringBuilder();
        for (ConversionSpecification cs : this.vFmt) {
            c = cs.getConversionCharacter();
            if (c == '\u0000') {
                sb.append(cs.getLiteral());
                continue;
            }
            if (c == '%') {
                sb.append("%");
                continue;
            }
            if (cs.isPositionalSpecification()) {
                i = cs.getArgumentPosition() - 1;
                if (cs.isPositionalFieldWidth()) {
                    int ifw = cs.getArgumentPositionForFieldWidth() - 1;
                    cs.setFieldWidthWithArg((Integer)o[ifw]);
                }
                if (cs.isPositionalPrecision()) {
                    int ipr = cs.getArgumentPositionForPrecision() - 1;
                    cs.setPrecisionWithArg((Integer)o[ipr]);
                }
            } else {
                if (cs.isVariableFieldWidth()) {
                    cs.setFieldWidthWithArg((Integer)o[i]);
                    ++i;
                }
                if (cs.isVariablePrecision()) {
                    cs.setPrecisionWithArg((Integer)o[i]);
                    ++i;
                }
            }
            if (o[i] instanceof Byte) {
                sb.append(cs.internalsprintf(((Byte)o[i]).byteValue()));
            } else if (o[i] instanceof Short) {
                sb.append(cs.internalsprintf(((Short)o[i]).shortValue()));
            } else if (o[i] instanceof Integer) {
                sb.append(cs.internalsprintf((Integer)o[i]));
            } else if (o[i] instanceof Long) {
                sb.append(cs.internalsprintf((Long)o[i]));
            } else if (o[i] instanceof Float) {
                sb.append(cs.internalsprintf(((Float)o[i]).floatValue()));
            } else if (o[i] instanceof Double) {
                sb.append(cs.internalsprintf((Double)o[i]));
            } else if (o[i] instanceof Character) {
                sb.append(cs.internalsprintf(((Character)o[i]).charValue()));
            } else if (o[i] instanceof String) {
                sb.append(cs.internalsprintf((String)o[i]));
            } else {
                sb.append(cs.internalsprintf(o[i]));
            }
            if (cs.isPositionalSpecification()) continue;
            ++i;
        }
        return sb.toString();
    }

    public String sprintf() {
        char c = '\u0000';
        StringBuilder sb = new StringBuilder();
        for (ConversionSpecification cs : this.vFmt) {
            c = cs.getConversionCharacter();
            if (c == '\u0000') {
                sb.append(cs.getLiteral());
                continue;
            }
            if (c != '%') continue;
            sb.append("%");
        }
        return sb.toString();
    }

    public String sprintf(int x) throws IllegalArgumentException {
        char c = '\u0000';
        StringBuilder sb = new StringBuilder();
        for (ConversionSpecification cs : this.vFmt) {
            c = cs.getConversionCharacter();
            if (c == '\u0000') {
                sb.append(cs.getLiteral());
                continue;
            }
            if (c == '%') {
                sb.append("%");
                continue;
            }
            sb.append(cs.internalsprintf(x));
        }
        return sb.toString();
    }

    public String sprintf(long x) throws IllegalArgumentException {
        char c = '\u0000';
        StringBuilder sb = new StringBuilder();
        for (ConversionSpecification cs : this.vFmt) {
            c = cs.getConversionCharacter();
            if (c == '\u0000') {
                sb.append(cs.getLiteral());
                continue;
            }
            if (c == '%') {
                sb.append("%");
                continue;
            }
            sb.append(cs.internalsprintf(x));
        }
        return sb.toString();
    }

    public String sprintf(double x) throws IllegalArgumentException {
        char c = '\u0000';
        StringBuilder sb = new StringBuilder();
        for (ConversionSpecification cs : this.vFmt) {
            c = cs.getConversionCharacter();
            if (c == '\u0000') {
                sb.append(cs.getLiteral());
                continue;
            }
            if (c == '%') {
                sb.append("%");
                continue;
            }
            sb.append(cs.internalsprintf(x));
        }
        return sb.toString();
    }

    public String sprintf(String x) throws IllegalArgumentException {
        char c = '\u0000';
        StringBuilder sb = new StringBuilder();
        for (ConversionSpecification cs : this.vFmt) {
            c = cs.getConversionCharacter();
            if (c == '\u0000') {
                sb.append(cs.getLiteral());
                continue;
            }
            if (c == '%') {
                sb.append("%");
                continue;
            }
            sb.append(cs.internalsprintf(x));
        }
        return sb.toString();
    }

    public String sprintf(Object x) throws IllegalArgumentException {
        char c = '\u0000';
        StringBuilder sb = new StringBuilder();
        for (ConversionSpecification cs : this.vFmt) {
            c = cs.getConversionCharacter();
            if (c == '\u0000') {
                sb.append(cs.getLiteral());
                continue;
            }
            if (c == '%') {
                sb.append("%");
                continue;
            }
            if (x instanceof Byte) {
                sb.append(cs.internalsprintf(((Byte)x).byteValue()));
                continue;
            }
            if (x instanceof Short) {
                sb.append(cs.internalsprintf(((Short)x).shortValue()));
                continue;
            }
            if (x instanceof Integer) {
                sb.append(cs.internalsprintf((Integer)x));
                continue;
            }
            if (x instanceof Long) {
                sb.append(cs.internalsprintf((Long)x));
                continue;
            }
            if (x instanceof Float) {
                sb.append(cs.internalsprintf(((Float)x).floatValue()));
                continue;
            }
            if (x instanceof Double) {
                sb.append(cs.internalsprintf((Double)x));
                continue;
            }
            if (x instanceof Character) {
                sb.append(cs.internalsprintf(((Character)x).charValue()));
                continue;
            }
            if (x instanceof String) {
                sb.append(cs.internalsprintf((String)x));
                continue;
            }
            sb.append(cs.internalsprintf(x));
        }
        return sb.toString();
    }

    private class ConversionSpecification {
        private boolean thousands = false;
        private boolean leftJustify = false;
        private boolean leadingSign = false;
        private boolean leadingSpace = false;
        private boolean alternateForm = false;
        private boolean leadingZeros = false;
        private boolean variableFieldWidth = false;
        private int fieldWidth = 0;
        private boolean fieldWidthSet = false;
        private int precision = 0;
        private static final int defaultDigits = 6;
        private boolean variablePrecision = false;
        private boolean precisionSet = false;
        private boolean positionalSpecification = false;
        private int argumentPosition = 0;
        private boolean positionalFieldWidth = false;
        private int argumentPositionForFieldWidth = 0;
        private boolean positionalPrecision = false;
        private int argumentPositionForPrecision = 0;
        private boolean optionalh = false;
        private boolean optionall = false;
        private boolean optionalL = false;
        private char conversionCharacter = '\u0000';
        private int pos = 0;
        private String fmt;

        ConversionSpecification() {
        }

        /*
         * Enabled force condition propagation
         * Lifted jumps to return sites
         */
        ConversionSpecification(String fmtArg) throws IllegalArgumentException {
            if (fmtArg == null) {
                throw new NullPointerException();
            }
            if (fmtArg.length() == 0) {
                throw new IllegalArgumentException("Control strings must have positive lengths.");
            }
            if (fmtArg.charAt(0) != '%') throw new IllegalArgumentException("Control strings must begin with %.");
            this.fmt = fmtArg;
            this.pos = 1;
            this.setArgPosition();
            this.setFlagCharacters();
            this.setFieldWidth();
            this.setPrecision();
            this.setOptionalHL();
            if (!this.setConversionCharacter()) throw new IllegalArgumentException("Malformed conversion specification=" + fmtArg);
            if (this.pos != fmtArg.length()) throw new IllegalArgumentException("Malformed conversion specification=" + fmtArg);
            if (this.leadingZeros && this.leftJustify) {
                this.leadingZeros = false;
            }
            if (!this.precisionSet || !this.leadingZeros || this.conversionCharacter != 'd' && this.conversionCharacter != 'i' && this.conversionCharacter != 'o' && this.conversionCharacter != 'x') return;
            this.leadingZeros = false;
        }

        void setLiteral(String s) {
            this.fmt = s;
        }

        String getLiteral() {
            StringBuilder sb = new StringBuilder();
            int i = 0;
            while (i < this.fmt.length()) {
                if (this.fmt.charAt(i) == '\\') {
                    if (++i < this.fmt.length()) {
                        char c = this.fmt.charAt(i);
                        switch (c) {
                            case 'a': {
                                sb.append('\u0007');
                                break;
                            }
                            case 'b': {
                                sb.append('\b');
                                break;
                            }
                            case 'f': {
                                sb.append('\f');
                                break;
                            }
                            case 'n': {
                                sb.append(System.getProperty("line.separator"));
                                break;
                            }
                            case 'r': {
                                sb.append('\r');
                                break;
                            }
                            case 't': {
                                sb.append('\t');
                                break;
                            }
                            case 'v': {
                                sb.append('\u000b');
                                break;
                            }
                            case '\\': {
                                sb.append('\\');
                            }
                        }
                        ++i;
                        continue;
                    }
                    sb.append('\\');
                    continue;
                }
                ++i;
            }
            return this.fmt;
        }

        char getConversionCharacter() {
            return this.conversionCharacter;
        }

        boolean isVariableFieldWidth() {
            return this.variableFieldWidth;
        }

        void setFieldWidthWithArg(int fw) {
            if (fw < 0) {
                this.leftJustify = true;
            }
            this.fieldWidthSet = true;
            this.fieldWidth = Math.abs(fw);
        }

        boolean isVariablePrecision() {
            return this.variablePrecision;
        }

        void setPrecisionWithArg(int pr) {
            this.precisionSet = true;
            this.precision = Math.max(pr, 0);
        }

        String internalsprintf(int s) throws IllegalArgumentException {
            String s2 = "";
            switch (this.conversionCharacter) {
                case 'd': 
                case 'i': {
                    if (this.optionalh) {
                        s2 = this.printDFormat((short)s);
                        break;
                    }
                    if (this.optionall) {
                        s2 = this.printDFormat((long)s);
                        break;
                    }
                    s2 = this.printDFormat(s);
                    break;
                }
                case 'X': 
                case 'x': {
                    if (this.optionalh) {
                        s2 = this.printXFormat((short)s);
                        break;
                    }
                    if (this.optionall) {
                        s2 = this.printXFormat((long)s);
                        break;
                    }
                    s2 = this.printXFormat(s);
                    break;
                }
                case 'o': {
                    if (this.optionalh) {
                        s2 = this.printOFormat((short)s);
                        break;
                    }
                    if (this.optionall) {
                        s2 = this.printOFormat((long)s);
                        break;
                    }
                    s2 = this.printOFormat(s);
                    break;
                }
                case 'C': 
                case 'c': {
                    s2 = this.printCFormat((char)s);
                    break;
                }
                default: {
                    throw new IllegalArgumentException("Cannot format a int with a format using a " + this.conversionCharacter + " conversion character.");
                }
            }
            return s2;
        }

        String internalsprintf(long s) throws IllegalArgumentException {
            String s2 = "";
            switch (this.conversionCharacter) {
                case 'd': 
                case 'i': {
                    if (this.optionalh) {
                        s2 = this.printDFormat((short)s);
                        break;
                    }
                    if (this.optionall) {
                        s2 = this.printDFormat(s);
                        break;
                    }
                    s2 = this.printDFormat((int)s);
                    break;
                }
                case 'X': 
                case 'x': {
                    if (this.optionalh) {
                        s2 = this.printXFormat((short)s);
                        break;
                    }
                    if (this.optionall) {
                        s2 = this.printXFormat(s);
                        break;
                    }
                    s2 = this.printXFormat((int)s);
                    break;
                }
                case 'o': {
                    if (this.optionalh) {
                        s2 = this.printOFormat((short)s);
                        break;
                    }
                    if (this.optionall) {
                        s2 = this.printOFormat(s);
                        break;
                    }
                    s2 = this.printOFormat((int)s);
                    break;
                }
                case 'C': 
                case 'c': {
                    s2 = this.printCFormat((char)s);
                    break;
                }
                default: {
                    throw new IllegalArgumentException("Cannot format a long with a format using a " + this.conversionCharacter + " conversion character.");
                }
            }
            return s2;
        }

        String internalsprintf(double s) throws IllegalArgumentException {
            String s2 = "";
            switch (this.conversionCharacter) {
                case 'f': {
                    s2 = this.printFFormat(s);
                    break;
                }
                case 'E': 
                case 'e': {
                    s2 = this.printEFormat(s);
                    break;
                }
                case 'G': 
                case 'g': {
                    s2 = this.printGFormat(s);
                    break;
                }
                default: {
                    throw new IllegalArgumentException("Cannot format a double with a format using a " + this.conversionCharacter + " conversion character.");
                }
            }
            return s2;
        }

        String internalsprintf(String s) throws IllegalArgumentException {
            String s2 = "";
            if (this.conversionCharacter != 's' && this.conversionCharacter != 'S') {
                throw new IllegalArgumentException("Cannot format a String with a format using a " + this.conversionCharacter + " conversion character.");
            }
            s2 = this.printSFormat(s);
            return s2;
        }

        String internalsprintf(Object s) {
            String s2 = "";
            if (this.conversionCharacter != 's' && this.conversionCharacter != 'S') {
                throw new IllegalArgumentException("Cannot format a String with a format using a " + this.conversionCharacter + " conversion character.");
            }
            s2 = this.printSFormat(s.toString());
            return s2;
        }

        private char[] fFormatDigits(double x) {
            int dp;
            char[] ca5;
            char[] ca4;
            char[] ca3;
            int k;
            int j;
            String sx;
            int expon = 0;
            boolean minusSign = false;
            if (x > 0.0) {
                sx = Double.toString(x);
            } else if (x < 0.0) {
                sx = Double.toString(-x);
                minusSign = true;
            } else {
                sx = Double.toString(x);
                if (sx.charAt(0) == '-') {
                    minusSign = true;
                    sx = sx.substring(1);
                }
            }
            int ePos = sx.indexOf(69);
            int rPos = sx.indexOf(46);
            int n1In = rPos != -1 ? rPos : (ePos != -1 ? ePos : sx.length());
            int n2In = rPos != -1 ? (ePos != -1 ? ePos - rPos - 1 : sx.length() - rPos - 1) : 0;
            if (ePos != -1) {
                int ie = ePos + 1;
                expon = 0;
                if (sx.charAt(ie) == '-') {
                    ++ie;
                    while (ie < sx.length() && sx.charAt(ie) == '0') {
                        ++ie;
                    }
                    if (ie < sx.length()) {
                        expon = -Integer.parseInt(sx.substring(ie));
                    }
                } else {
                    if (sx.charAt(ie) == '+') {
                        ++ie;
                    }
                    while (ie < sx.length() && sx.charAt(ie) == '0') {
                        ++ie;
                    }
                    if (ie < sx.length()) {
                        expon = Integer.parseInt(sx.substring(ie));
                    }
                }
            }
            int p = this.precisionSet ? this.precision : 5;
            char[] ca1 = sx.toCharArray();
            char[] ca2 = new char[n1In + n2In];
            for (j = 0; j < n1In; ++j) {
                ca2[j] = ca1[j];
            }
            int i = j + 1;
            for (k = 0; k < n2In; ++k) {
                ca2[j] = ca1[i];
                ++j;
                ++i;
            }
            if (n1In + expon <= 0) {
                ca3 = new char[-expon + n2In];
                j = 0;
                k = 0;
                while (k < -n1In - expon) {
                    ca3[j] = 48;
                    ++k;
                    ++j;
                }
                i = 0;
                while (i < n1In + n2In) {
                    ca3[j] = ca2[i];
                    ++i;
                    ++j;
                }
            } else {
                ca3 = ca2;
            }
            boolean carry = false;
            if (p < -expon + n2In && (carry = this.checkForCarry(ca3, i = expon < 0 ? p : p + n1In))) {
                carry = this.startSymbolicCarry(ca3, i - 1, 0);
            }
            if (n1In + expon <= 0) {
                ca4 = new char[2 + p];
                ca4[0] = !carry ? (char)48 : (char)49;
                if (this.alternateForm || !this.precisionSet || this.precision != 0) {
                    ca4[1] = 46;
                    i = 0;
                    j = 2;
                    while (i < Math.min(p, ca3.length)) {
                        ca4[j] = ca3[i];
                        ++i;
                        ++j;
                    }
                    while (j < ca4.length) {
                        ca4[j] = 48;
                        ++j;
                    }
                }
            } else {
                if (!carry) {
                    ca4 = this.alternateForm || !this.precisionSet || this.precision != 0 ? new char[n1In + expon + p + 1] : new char[n1In + expon];
                    j = 0;
                } else {
                    ca4 = this.alternateForm || !this.precisionSet || this.precision != 0 ? new char[n1In + expon + p + 2] : new char[n1In + expon + 1];
                    ca4[0] = 49;
                    j = 1;
                }
                i = 0;
                while (i < Math.min(n1In + expon, ca3.length)) {
                    ca4[j] = ca3[i];
                    ++i;
                    ++j;
                }
                while (i < n1In + expon) {
                    ca4[j] = 48;
                    ++i;
                    ++j;
                }
                if (this.alternateForm || !this.precisionSet || this.precision != 0) {
                    ca4[j] = 46;
                    ++j;
                    for (k = 0; i < ca3.length && k < p; ++k) {
                        ca4[j] = ca3[i];
                        ++i;
                        ++j;
                    }
                    while (j < ca4.length) {
                        ca4[j] = 48;
                        ++j;
                    }
                }
            }
            int nZeros = 0;
            if (!this.leftJustify && this.leadingZeros) {
                int xThousands = 0;
                if (this.thousands) {
                    int xdp;
                    int xlead = 0;
                    if (ca4[0] == '+' || ca4[0] == '-' || ca4[0] == ' ') {
                        xlead = 1;
                    }
                    for (xdp = xlead; xdp < ca4.length && ca4[xdp] != '.'; ++xdp) {
                    }
                    xThousands = (xdp - xlead) / 3;
                }
                if (this.fieldWidthSet) {
                    nZeros = this.fieldWidth - ca4.length;
                }
                if (!minusSign && (this.leadingSign || this.leadingSpace) || minusSign) {
                    --nZeros;
                }
                if ((nZeros -= xThousands) < 0) {
                    nZeros = 0;
                }
            }
            j = 0;
            if (!minusSign && (this.leadingSign || this.leadingSpace) || minusSign) {
                ca5 = new char[ca4.length + nZeros + 1];
                ++j;
            } else {
                ca5 = new char[ca4.length + nZeros];
            }
            if (!minusSign) {
                if (this.leadingSign) {
                    ca5[0] = 43;
                }
                if (this.leadingSpace) {
                    ca5[0] = 32;
                }
            } else {
                ca5[0] = 45;
            }
            i = 0;
            while (i < nZeros) {
                ca5[j] = 48;
                ++i;
                ++j;
            }
            i = 0;
            while (i < ca4.length) {
                ca5[j] = ca4[i];
                ++i;
                ++j;
            }
            int lead = 0;
            if (ca5[0] == '+' || ca5[0] == '-' || ca5[0] == ' ') {
                lead = 1;
            }
            for (dp = lead; dp < ca5.length && ca5[dp] != '.'; ++dp) {
            }
            int nThousands = (dp - lead) / 3;
            if (dp < ca5.length) {
                ca5[dp] = PrintfFormat.this.dfs.getDecimalSeparator();
            }
            char[] ca6 = ca5;
            if (this.thousands && nThousands > 0) {
                ca6 = new char[ca5.length + nThousands + lead];
                ca6[0] = ca5[0];
                k = lead;
                for (i = lead; i < dp; ++i) {
                    if (i > 0 && (dp - i) % 3 == 0) {
                        ca6[k] = PrintfFormat.this.dfs.getGroupingSeparator();
                        ca6[k + 1] = ca5[i];
                        k += 2;
                        continue;
                    }
                    ca6[k] = ca5[i];
                    ++k;
                }
                while (i < ca5.length) {
                    ca6[k] = ca5[i];
                    ++i;
                    ++k;
                }
            }
            return ca6;
        }

        private String fFormatString(double x) {
            char[] ca6 = Double.isInfinite(x) ? (x == Double.POSITIVE_INFINITY ? (this.leadingSign ? "+Inf".toCharArray() : (this.leadingSpace ? " Inf".toCharArray() : "Inf".toCharArray())) : "-Inf".toCharArray()) : (Double.isNaN(x) ? (this.leadingSign ? "+NaN".toCharArray() : (this.leadingSpace ? " NaN".toCharArray() : "NaN".toCharArray())) : this.fFormatDigits(x));
            char[] ca7 = this.applyFloatPadding(ca6, false);
            return new String(ca7);
        }

        private char[] eFormatDigits(double x, char eChar) {
            int dp;
            char[] ca3;
            int k;
            int i;
            int j;
            char[] ca2;
            String sx;
            int expon = 0;
            boolean minusSign = false;
            if (x > 0.0) {
                sx = Double.toString(x);
            } else if (x < 0.0) {
                sx = Double.toString(-x);
                minusSign = true;
            } else {
                sx = Double.toString(x);
                if (sx.charAt(0) == '-') {
                    minusSign = true;
                    sx = sx.substring(1);
                }
            }
            int ePos = sx.indexOf(69);
            if (ePos == -1) {
                ePos = sx.indexOf(101);
            }
            int rPos = sx.indexOf(46);
            if (ePos != -1) {
                int ie = ePos + 1;
                expon = 0;
                if (sx.charAt(ie) == '-') {
                    ++ie;
                    while (ie < sx.length() && sx.charAt(ie) == '0') {
                        ++ie;
                    }
                    if (ie < sx.length()) {
                        expon = -Integer.parseInt(sx.substring(ie));
                    }
                } else {
                    if (sx.charAt(ie) == '+') {
                        ++ie;
                    }
                    while (ie < sx.length() && sx.charAt(ie) == '0') {
                        ++ie;
                    }
                    if (ie < sx.length()) {
                        expon = Integer.parseInt(sx.substring(ie));
                    }
                }
            }
            if (rPos != -1) {
                expon += rPos - 1;
            }
            int p = this.precisionSet ? this.precision : 5;
            char[] ca1 = rPos != -1 && ePos != -1 ? (sx.substring(0, rPos) + sx.substring(rPos + 1, ePos)).toCharArray() : (rPos != -1 ? (sx.substring(0, rPos) + sx.substring(rPos + 1)).toCharArray() : (ePos != -1 ? sx.substring(0, ePos).toCharArray() : sx.toCharArray()));
            boolean carry = false;
            int i0 = 0;
            if (ca1[0] != '0') {
                i0 = 0;
            } else {
                for (i0 = 0; i0 < ca1.length && ca1[i0] == '0'; ++i0) {
                }
            }
            if (i0 + p < ca1.length - 1) {
                carry = this.checkForCarry(ca1, i0 + p + 1);
                if (carry) {
                    carry = this.startSymbolicCarry(ca1, i0 + p, i0);
                }
                if (carry) {
                    ca2 = new char[i0 + p + 1];
                    ca2[i0] = 49;
                    for (j = 0; j < i0; ++j) {
                        ca2[j] = 48;
                    }
                    i = i0;
                    for (j = i0 + 1; j < p + 1; ++j) {
                        ca2[j] = ca1[i];
                        ++i;
                    }
                    ++expon;
                    ca1 = ca2;
                }
            }
            int eSize = Math.abs(expon) < 100 && !this.optionalL ? 4 : 5;
            ca2 = this.alternateForm || !this.precisionSet || this.precision != 0 ? new char[2 + p + eSize] : new char[1 + eSize];
            if (ca1[0] != '0') {
                ca2[0] = ca1[0];
                j = 1;
            } else {
                for (j = 1; j < (ePos == -1 ? ca1.length : ePos) && ca1[j] == '0'; ++j) {
                }
                if (ePos != -1 && j < ePos || ePos == -1 && j < ca1.length) {
                    ca2[0] = ca1[j];
                    expon -= j;
                    ++j;
                } else {
                    ca2[0] = 48;
                    j = 2;
                }
            }
            if (this.alternateForm || !this.precisionSet || this.precision != 0) {
                ca2[1] = 46;
                i = 2;
            } else {
                i = 1;
            }
            for (k = 0; k < p && j < ca1.length; ++k) {
                ca2[i] = ca1[j];
                ++j;
                ++i;
            }
            while (i < ca2.length - eSize) {
                ca2[i] = 48;
                ++i;
            }
            ca2[i++] = eChar;
            ca2[i++] = (char)(expon < 0 ? 45 : 43);
            if ((expon = Math.abs(expon)) >= 100) {
                switch (expon / 100) {
                    case 1: {
                        ca2[i] = 49;
                        break;
                    }
                    case 2: {
                        ca2[i] = 50;
                        break;
                    }
                    case 3: {
                        ca2[i] = 51;
                        break;
                    }
                    case 4: {
                        ca2[i] = 52;
                        break;
                    }
                    case 5: {
                        ca2[i] = 53;
                        break;
                    }
                    case 6: {
                        ca2[i] = 54;
                        break;
                    }
                    case 7: {
                        ca2[i] = 55;
                        break;
                    }
                    case 8: {
                        ca2[i] = 56;
                        break;
                    }
                    case 9: {
                        ca2[i] = 57;
                    }
                }
                ++i;
            }
            switch (expon % 100 / 10) {
                case 0: {
                    ca2[i] = 48;
                    break;
                }
                case 1: {
                    ca2[i] = 49;
                    break;
                }
                case 2: {
                    ca2[i] = 50;
                    break;
                }
                case 3: {
                    ca2[i] = 51;
                    break;
                }
                case 4: {
                    ca2[i] = 52;
                    break;
                }
                case 5: {
                    ca2[i] = 53;
                    break;
                }
                case 6: {
                    ca2[i] = 54;
                    break;
                }
                case 7: {
                    ca2[i] = 55;
                    break;
                }
                case 8: {
                    ca2[i] = 56;
                    break;
                }
                case 9: {
                    ca2[i] = 57;
                }
            }
            ++i;
            switch (expon % 10) {
                case 0: {
                    ca2[i] = 48;
                    break;
                }
                case 1: {
                    ca2[i] = 49;
                    break;
                }
                case 2: {
                    ca2[i] = 50;
                    break;
                }
                case 3: {
                    ca2[i] = 51;
                    break;
                }
                case 4: {
                    ca2[i] = 52;
                    break;
                }
                case 5: {
                    ca2[i] = 53;
                    break;
                }
                case 6: {
                    ca2[i] = 54;
                    break;
                }
                case 7: {
                    ca2[i] = 55;
                    break;
                }
                case 8: {
                    ca2[i] = 56;
                    break;
                }
                case 9: {
                    ca2[i] = 57;
                }
            }
            int nZeros = 0;
            if (!this.leftJustify && this.leadingZeros) {
                int xThousands = 0;
                if (this.thousands) {
                    int xdp;
                    int xlead = 0;
                    if (ca2[0] == '+' || ca2[0] == '-' || ca2[0] == ' ') {
                        xlead = 1;
                    }
                    for (xdp = xlead; xdp < ca2.length && ca2[xdp] != '.'; ++xdp) {
                    }
                    xThousands = (xdp - xlead) / 3;
                }
                if (this.fieldWidthSet) {
                    nZeros = this.fieldWidth - ca2.length;
                }
                if (!minusSign && (this.leadingSign || this.leadingSpace) || minusSign) {
                    --nZeros;
                }
                if ((nZeros -= xThousands) < 0) {
                    nZeros = 0;
                }
            }
            j = 0;
            if (!minusSign && (this.leadingSign || this.leadingSpace) || minusSign) {
                ca3 = new char[ca2.length + nZeros + 1];
                ++j;
            } else {
                ca3 = new char[ca2.length + nZeros];
            }
            if (!minusSign) {
                if (this.leadingSign) {
                    ca3[0] = 43;
                }
                if (this.leadingSpace) {
                    ca3[0] = 32;
                }
            } else {
                ca3[0] = 45;
            }
            for (k = 0; k < nZeros; ++k) {
                ca3[j] = 48;
                ++j;
            }
            for (i = 0; i < ca2.length && j < ca3.length; ++i, ++j) {
                ca3[j] = ca2[i];
            }
            int lead = 0;
            if (ca3[0] == '+' || ca3[0] == '-' || ca3[0] == ' ') {
                lead = 1;
            }
            for (dp = lead; dp < ca3.length && ca3[dp] != '.'; ++dp) {
            }
            int nThousands = dp / 3;
            if (dp < ca3.length) {
                ca3[dp] = PrintfFormat.this.dfs.getDecimalSeparator();
            }
            char[] ca4 = ca3;
            if (this.thousands && nThousands > 0) {
                ca4 = new char[ca3.length + nThousands + lead];
                ca4[0] = ca3[0];
                k = lead;
                for (i = lead; i < dp; ++i) {
                    if (i > 0 && (dp - i) % 3 == 0) {
                        ca4[k] = PrintfFormat.this.dfs.getGroupingSeparator();
                        ca4[k + 1] = ca3[i];
                        k += 2;
                        continue;
                    }
                    ca4[k] = ca3[i];
                    ++k;
                }
                while (i < ca3.length) {
                    ca4[k] = ca3[i];
                    ++i;
                    ++k;
                }
            }
            return ca4;
        }

        private boolean checkForCarry(char[] ca1, int icarry) {
            boolean carry = false;
            if (icarry < ca1.length) {
                if (ca1[icarry] == '6' || ca1[icarry] == '7' || ca1[icarry] == '8' || ca1[icarry] == '9') {
                    carry = true;
                } else if (ca1[icarry] == '5') {
                    int ii;
                    for (ii = icarry + 1; ii < ca1.length && ca1[ii] == '0'; ++ii) {
                    }
                    boolean bl = carry = ii < ca1.length;
                    if (!carry && icarry > 0) {
                        carry = ca1[icarry - 1] == '1' || ca1[icarry - 1] == '3' || ca1[icarry - 1] == '5' || ca1[icarry - 1] == '7' || ca1[icarry - 1] == '9';
                    }
                }
            }
            return carry;
        }

        private boolean startSymbolicCarry(char[] ca, int cLast, int cFirst) {
            boolean carry = true;
            block12: for (int i = cLast; carry && i >= cFirst; --i) {
                carry = false;
                switch (ca[i]) {
                    case '0': {
                        ca[i] = 49;
                        continue block12;
                    }
                    case '1': {
                        ca[i] = 50;
                        continue block12;
                    }
                    case '2': {
                        ca[i] = 51;
                        continue block12;
                    }
                    case '3': {
                        ca[i] = 52;
                        continue block12;
                    }
                    case '4': {
                        ca[i] = 53;
                        continue block12;
                    }
                    case '5': {
                        ca[i] = 54;
                        continue block12;
                    }
                    case '6': {
                        ca[i] = 55;
                        continue block12;
                    }
                    case '7': {
                        ca[i] = 56;
                        continue block12;
                    }
                    case '8': {
                        ca[i] = 57;
                        continue block12;
                    }
                    case '9': {
                        ca[i] = 48;
                        carry = true;
                    }
                }
            }
            return carry;
        }

        private String eFormatString(double x, char eChar) {
            char[] ca4 = Double.isInfinite(x) ? (x == Double.POSITIVE_INFINITY ? (this.leadingSign ? "+Inf".toCharArray() : (this.leadingSpace ? " Inf".toCharArray() : "Inf".toCharArray())) : "-Inf".toCharArray()) : (Double.isNaN(x) ? (this.leadingSign ? "+NaN".toCharArray() : (this.leadingSpace ? " NaN".toCharArray() : "NaN".toCharArray())) : this.eFormatDigits(x, eChar));
            char[] ca5 = this.applyFloatPadding(ca4, false);
            return new String(ca5);
        }

        /*
         * WARNING - void declaration
         */
        private char[] applyFloatPadding(char[] ca4, boolean noDigits) {
            char[] ca5;
            block8: {
                int nBlanks;
                block10: {
                    int i;
                    block9: {
                        int i2;
                        ca5 = ca4;
                        if (!this.fieldWidthSet) break block8;
                        if (!this.leftJustify) break block9;
                        int nBlanks2 = this.fieldWidth - ca4.length;
                        if (nBlanks2 <= 0) break block8;
                        ca5 = new char[ca4.length + nBlanks2];
                        for (i2 = 0; i2 < ca4.length; ++i2) {
                            ca5[i2] = ca4[i2];
                        }
                        int j = 0;
                        while (j < nBlanks2) {
                            ca5[i2] = 32;
                            ++j;
                            ++i2;
                        }
                        break block8;
                    }
                    if (this.leadingZeros && !noDigits) break block10;
                    int nBlanks3 = this.fieldWidth - ca4.length;
                    if (nBlanks3 <= 0) break block8;
                    ca5 = new char[ca4.length + nBlanks3];
                    for (i = 0; i < nBlanks3; ++i) {
                        ca5[i] = 32;
                    }
                    for (int j = 0; j < ca4.length; ++j) {
                        ca5[i] = ca4[j];
                        ++i;
                    }
                    break block8;
                }
                if (this.leadingZeros && (nBlanks = this.fieldWidth - ca4.length) > 0) {
                    ca5 = new char[ca4.length + nBlanks];
                    int i = 0;
                    int j = 0;
                    if (ca4[0] == '-') {
                        ca5[0] = 45;
                        ++i;
                        ++j;
                    }
                    for (int k = 0; k < nBlanks; ++k) {
                        ca5[i] = 48;
                        ++i;
                    }
                    while (j < ca4.length) {
                        ca5[i] = ca4[j];
                        ++i;
                        ++j;
                    }
                }
            }
            return ca5;
        }

        private String printFFormat(double x) {
            return this.fFormatString(x);
        }

        private String printEFormat(double x) {
            if (this.conversionCharacter == 'e') {
                return this.eFormatString(x, 'e');
            }
            return this.eFormatString(x, 'E');
        }

        private String printGFormat(double x) {
            char[] ca4;
            int savePrecision = this.precision;
            if (Double.isInfinite(x)) {
                ca4 = x == Double.POSITIVE_INFINITY ? (this.leadingSign ? "+Inf".toCharArray() : (this.leadingSpace ? " Inf".toCharArray() : "Inf".toCharArray())) : "-Inf".toCharArray();
            } else if (Double.isNaN(x)) {
                ca4 = this.leadingSign ? "+NaN".toCharArray() : (this.leadingSpace ? " NaN".toCharArray() : "NaN".toCharArray());
            } else {
                String ret;
                String sx;
                if (!this.precisionSet) {
                    this.precision = 6;
                }
                if (this.precision == 0) {
                    this.precision = 1;
                }
                int ePos = -1;
                if (this.conversionCharacter == 'g') {
                    sx = this.eFormatString(x, 'e').trim();
                    ePos = sx.indexOf(101);
                } else {
                    sx = this.eFormatString(x, 'E').trim();
                    ePos = sx.indexOf(69);
                }
                int i = ePos + 1;
                int expon = 0;
                if (sx.charAt(i) == '-') {
                    ++i;
                    while (i < sx.length() && sx.charAt(i) == '0') {
                        ++i;
                    }
                    if (i < sx.length()) {
                        expon = -Integer.parseInt(sx.substring(i));
                    }
                } else {
                    if (sx.charAt(i) == '+') {
                        ++i;
                    }
                    while (i < sx.length() && sx.charAt(i) == '0') {
                        ++i;
                    }
                    if (i < sx.length()) {
                        expon = Integer.parseInt(sx.substring(i));
                    }
                }
                if (!this.alternateForm) {
                    String sy = expon >= -4 && expon < this.precision ? this.fFormatString(x).trim() : sx.substring(0, ePos);
                    for (i = sy.length() - 1; i >= 0 && sy.charAt(i) == '0'; --i) {
                    }
                    if (i >= 0 && sy.charAt(i) == '.') {
                        --i;
                    }
                    String sz = i == -1 ? "0" : (!Character.isDigit(sy.charAt(i)) ? sy.substring(0, i + 1) + "0" : sy.substring(0, i + 1));
                    ret = expon >= -4 && expon < this.precision ? sz : sz + sx.substring(ePos);
                } else {
                    ret = expon >= -4 && expon < this.precision ? this.fFormatString(x).trim() : sx;
                }
                if (this.leadingSpace && x >= 0.0) {
                    ret = " " + ret;
                }
                ca4 = ret.toCharArray();
            }
            char[] ca5 = this.applyFloatPadding(ca4, false);
            this.precision = savePrecision;
            return new String(ca5);
        }

        private String printDFormat(short x) {
            return this.printDFormat(Short.toString(x));
        }

        private String printDFormat(long x) {
            return this.printDFormat(Long.toString(x));
        }

        private String printDFormat(int x) {
            return this.printDFormat(Integer.toString(x));
        }

        private String printDFormat(String sx) {
            char[] ca;
            block30: {
                int j;
                boolean neg;
                int jFirst;
                int i;
                int nLeadingZeros;
                block33: {
                    int nBlanks;
                    block31: {
                        block34: {
                            block32: {
                                block29: {
                                    int j2;
                                    nLeadingZeros = 0;
                                    nBlanks = 0;
                                    int n = 0;
                                    i = 0;
                                    jFirst = 0;
                                    boolean bl = neg = sx.charAt(0) == '-';
                                    if (sx.equals("0") && this.precisionSet && this.precision == 0) {
                                        sx = "";
                                    }
                                    if (!neg) {
                                        if (this.precisionSet && sx.length() < this.precision) {
                                            nLeadingZeros = this.precision - sx.length();
                                        }
                                    } else if (this.precisionSet && sx.length() - 1 < this.precision) {
                                        nLeadingZeros = this.precision - sx.length() + 1;
                                    }
                                    if (nLeadingZeros < 0) {
                                        nLeadingZeros = 0;
                                    }
                                    if (this.fieldWidthSet) {
                                        nBlanks = this.fieldWidth - nLeadingZeros - sx.length();
                                        if (!neg && (this.leadingSign || this.leadingSpace)) {
                                            --nBlanks;
                                        }
                                    }
                                    if (nBlanks < 0) {
                                        nBlanks = 0;
                                    }
                                    if (this.leadingSign) {
                                        ++n;
                                    } else if (this.leadingSpace) {
                                        ++n;
                                    }
                                    n += nBlanks;
                                    n += nLeadingZeros;
                                    ca = new char[n += sx.length()];
                                    if (!this.leftJustify) break block29;
                                    if (neg) {
                                        ca[i++] = 45;
                                    } else if (this.leadingSign) {
                                        ca[i++] = 43;
                                    } else if (this.leadingSpace) {
                                        ca[i++] = 32;
                                    }
                                    char[] csx = sx.toCharArray();
                                    jFirst = neg ? 1 : 0;
                                    for (j2 = 0; j2 < nLeadingZeros; ++j2) {
                                        ca[i] = 48;
                                        ++i;
                                    }
                                    j2 = jFirst;
                                    while (j2 < csx.length) {
                                        ca[i] = csx[j2];
                                        ++j2;
                                        ++i;
                                    }
                                    for (j2 = 0; j2 < nBlanks; ++j2) {
                                        ca[i] = 32;
                                        ++i;
                                    }
                                    break block30;
                                }
                                if (this.leadingZeros) break block31;
                                for (i = 0; i < nBlanks; ++i) {
                                    ca[i] = 32;
                                }
                                if (!neg) break block32;
                                ca[i++] = 45;
                                break block33;
                            }
                            if (!this.leadingSign) break block34;
                            ca[i++] = 43;
                            break block33;
                        }
                        if (!this.leadingSpace) break block33;
                        ca[i++] = 32;
                        break block33;
                    }
                    if (neg) {
                        ca[i++] = 45;
                    } else if (this.leadingSign) {
                        ca[i++] = 43;
                    } else if (this.leadingSpace) {
                        ca[i++] = 32;
                    }
                    j = 0;
                    while (j < nBlanks) {
                        ca[i] = 48;
                        ++j;
                        ++i;
                    }
                }
                j = 0;
                while (j < nLeadingZeros) {
                    ca[i] = 48;
                    ++j;
                    ++i;
                }
                char[] csx = sx.toCharArray();
                int j3 = jFirst = neg ? 1 : 0;
                while (j3 < csx.length) {
                    ca[i] = csx[j3];
                    ++j3;
                    ++i;
                }
            }
            return new String(ca);
        }

        private String printXFormat(short x) {
            String sx = null;
            if (x == Short.MIN_VALUE) {
                sx = "8000";
            } else if (x < 0) {
                String t;
                if (x == Short.MIN_VALUE) {
                    t = "0";
                } else {
                    t = Integer.toString(~(-x - 1) ^ Short.MIN_VALUE, 16);
                    if (t.charAt(0) == 'F' || t.charAt(0) == 'f') {
                        t = t.substring(16, 32);
                    }
                }
                block0 : switch (t.length()) {
                    case 1: {
                        sx = "800" + t;
                        break;
                    }
                    case 2: {
                        sx = "80" + t;
                        break;
                    }
                    case 3: {
                        sx = "8" + t;
                        break;
                    }
                    case 4: {
                        switch (t.charAt(0)) {
                            case '1': {
                                sx = "9" + t.substring(1, 4);
                                break block0;
                            }
                            case '2': {
                                sx = "a" + t.substring(1, 4);
                                break block0;
                            }
                            case '3': {
                                sx = "b" + t.substring(1, 4);
                                break block0;
                            }
                            case '4': {
                                sx = "c" + t.substring(1, 4);
                                break block0;
                            }
                            case '5': {
                                sx = "d" + t.substring(1, 4);
                                break block0;
                            }
                            case '6': {
                                sx = "e" + t.substring(1, 4);
                                break block0;
                            }
                            case '7': {
                                sx = "f" + t.substring(1, 4);
                            }
                        }
                    }
                }
            } else {
                sx = Integer.toString(x, 16);
            }
            return this.printXFormat(sx);
        }

        private String printXFormat(long x) {
            String sx = null;
            if (x == Long.MIN_VALUE) {
                sx = "8000000000000000";
            } else if (x < 0L) {
                String t = Long.toString(-x - 1L ^ 0xFFFFFFFFFFFFFFFFL ^ Long.MIN_VALUE, 16);
                block0 : switch (t.length()) {
                    case 1: {
                        sx = "800000000000000" + t;
                        break;
                    }
                    case 2: {
                        sx = "80000000000000" + t;
                        break;
                    }
                    case 3: {
                        sx = "8000000000000" + t;
                        break;
                    }
                    case 4: {
                        sx = "800000000000" + t;
                        break;
                    }
                    case 5: {
                        sx = "80000000000" + t;
                        break;
                    }
                    case 6: {
                        sx = "8000000000" + t;
                        break;
                    }
                    case 7: {
                        sx = "800000000" + t;
                        break;
                    }
                    case 8: {
                        sx = "80000000" + t;
                        break;
                    }
                    case 9: {
                        sx = "8000000" + t;
                        break;
                    }
                    case 10: {
                        sx = "800000" + t;
                        break;
                    }
                    case 11: {
                        sx = "80000" + t;
                        break;
                    }
                    case 12: {
                        sx = "8000" + t;
                        break;
                    }
                    case 13: {
                        sx = "800" + t;
                        break;
                    }
                    case 14: {
                        sx = "80" + t;
                        break;
                    }
                    case 15: {
                        sx = "8" + t;
                        break;
                    }
                    case 16: {
                        switch (t.charAt(0)) {
                            case '1': {
                                sx = "9" + t.substring(1, 16);
                                break block0;
                            }
                            case '2': {
                                sx = "a" + t.substring(1, 16);
                                break block0;
                            }
                            case '3': {
                                sx = "b" + t.substring(1, 16);
                                break block0;
                            }
                            case '4': {
                                sx = "c" + t.substring(1, 16);
                                break block0;
                            }
                            case '5': {
                                sx = "d" + t.substring(1, 16);
                                break block0;
                            }
                            case '6': {
                                sx = "e" + t.substring(1, 16);
                                break block0;
                            }
                            case '7': {
                                sx = "f" + t.substring(1, 16);
                            }
                        }
                    }
                }
            } else {
                sx = Long.toString(x, 16);
            }
            return this.printXFormat(sx);
        }

        private String printXFormat(int x) {
            String sx = null;
            if (x == Integer.MIN_VALUE) {
                sx = "80000000";
            } else if (x < 0) {
                String t = Integer.toString(~(-x - 1) ^ Integer.MIN_VALUE, 16);
                block0 : switch (t.length()) {
                    case 1: {
                        sx = "8000000" + t;
                        break;
                    }
                    case 2: {
                        sx = "800000" + t;
                        break;
                    }
                    case 3: {
                        sx = "80000" + t;
                        break;
                    }
                    case 4: {
                        sx = "8000" + t;
                        break;
                    }
                    case 5: {
                        sx = "800" + t;
                        break;
                    }
                    case 6: {
                        sx = "80" + t;
                        break;
                    }
                    case 7: {
                        sx = "8" + t;
                        break;
                    }
                    case 8: {
                        switch (t.charAt(0)) {
                            case '1': {
                                sx = "9" + t.substring(1, 8);
                                break block0;
                            }
                            case '2': {
                                sx = "a" + t.substring(1, 8);
                                break block0;
                            }
                            case '3': {
                                sx = "b" + t.substring(1, 8);
                                break block0;
                            }
                            case '4': {
                                sx = "c" + t.substring(1, 8);
                                break block0;
                            }
                            case '5': {
                                sx = "d" + t.substring(1, 8);
                                break block0;
                            }
                            case '6': {
                                sx = "e" + t.substring(1, 8);
                                break block0;
                            }
                            case '7': {
                                sx = "f" + t.substring(1, 8);
                            }
                        }
                    }
                }
            } else {
                sx = Integer.toString(x, 16);
            }
            return this.printXFormat(sx);
        }

        private String printXFormat(String sx) {
            char[] csx;
            int nLeadingZeros = 0;
            int nBlanks = 0;
            if (sx.equals("0") && this.precisionSet && this.precision == 0) {
                sx = "";
            }
            if (this.precisionSet) {
                nLeadingZeros = this.precision - sx.length();
            }
            if (nLeadingZeros < 0) {
                nLeadingZeros = 0;
            }
            if (this.fieldWidthSet) {
                nBlanks = this.fieldWidth - nLeadingZeros - sx.length();
                if (this.alternateForm) {
                    nBlanks -= 2;
                }
            }
            if (nBlanks < 0) {
                nBlanks = 0;
            }
            int n = 0;
            if (this.alternateForm) {
                n += 2;
            }
            n += nLeadingZeros;
            n += sx.length();
            char[] ca = new char[n += nBlanks];
            int i = 0;
            if (this.leftJustify) {
                if (this.alternateForm) {
                    ca[i++] = 48;
                    ca[i++] = 120;
                }
                int j = 0;
                while (j < nLeadingZeros) {
                    ca[i] = 48;
                    ++j;
                    ++i;
                }
                csx = sx.toCharArray();
                int j2 = 0;
                while (j2 < csx.length) {
                    ca[i] = csx[j2];
                    ++j2;
                    ++i;
                }
                j2 = 0;
                while (j2 < nBlanks) {
                    ca[i] = 32;
                    ++j2;
                    ++i;
                }
            } else {
                int j;
                if (!this.leadingZeros) {
                    j = 0;
                    while (j < nBlanks) {
                        ca[i] = 32;
                        ++j;
                        ++i;
                    }
                }
                if (this.alternateForm) {
                    ca[i++] = 48;
                    ca[i++] = 120;
                }
                if (this.leadingZeros) {
                    j = 0;
                    while (j < nBlanks) {
                        ca[i] = 48;
                        ++j;
                        ++i;
                    }
                }
                j = 0;
                while (j < nLeadingZeros) {
                    ca[i] = 48;
                    ++j;
                    ++i;
                }
                csx = sx.toCharArray();
                int j3 = 0;
                while (j3 < csx.length) {
                    ca[i] = csx[j3];
                    ++j3;
                    ++i;
                }
            }
            String caReturn = new String(ca);
            if (this.conversionCharacter == 'X') {
                caReturn = caReturn.toUpperCase();
            }
            return caReturn;
        }

        private String printOFormat(short x) {
            String sx = null;
            if (x == Short.MIN_VALUE) {
                sx = "100000";
            } else if (x < 0) {
                String t = Integer.toString(~(-x - 1) ^ Short.MIN_VALUE, 8);
                switch (t.length()) {
                    case 1: {
                        sx = "10000" + t;
                        break;
                    }
                    case 2: {
                        sx = "1000" + t;
                        break;
                    }
                    case 3: {
                        sx = "100" + t;
                        break;
                    }
                    case 4: {
                        sx = "10" + t;
                        break;
                    }
                    case 5: {
                        sx = "1" + t;
                    }
                }
            } else {
                sx = Integer.toString(x, 8);
            }
            return this.printOFormat(sx);
        }

        private String printOFormat(long x) {
            String sx = null;
            if (x == Long.MIN_VALUE) {
                sx = "1000000000000000000000";
            } else if (x < 0L) {
                String t = Long.toString(-x - 1L ^ 0xFFFFFFFFFFFFFFFFL ^ Long.MIN_VALUE, 8);
                switch (t.length()) {
                    case 1: {
                        sx = "100000000000000000000" + t;
                        break;
                    }
                    case 2: {
                        sx = "10000000000000000000" + t;
                        break;
                    }
                    case 3: {
                        sx = "1000000000000000000" + t;
                        break;
                    }
                    case 4: {
                        sx = "100000000000000000" + t;
                        break;
                    }
                    case 5: {
                        sx = "10000000000000000" + t;
                        break;
                    }
                    case 6: {
                        sx = "1000000000000000" + t;
                        break;
                    }
                    case 7: {
                        sx = "100000000000000" + t;
                        break;
                    }
                    case 8: {
                        sx = "10000000000000" + t;
                        break;
                    }
                    case 9: {
                        sx = "1000000000000" + t;
                        break;
                    }
                    case 10: {
                        sx = "100000000000" + t;
                        break;
                    }
                    case 11: {
                        sx = "10000000000" + t;
                        break;
                    }
                    case 12: {
                        sx = "1000000000" + t;
                        break;
                    }
                    case 13: {
                        sx = "100000000" + t;
                        break;
                    }
                    case 14: {
                        sx = "10000000" + t;
                        break;
                    }
                    case 15: {
                        sx = "1000000" + t;
                        break;
                    }
                    case 16: {
                        sx = "100000" + t;
                        break;
                    }
                    case 17: {
                        sx = "10000" + t;
                        break;
                    }
                    case 18: {
                        sx = "1000" + t;
                        break;
                    }
                    case 19: {
                        sx = "100" + t;
                        break;
                    }
                    case 20: {
                        sx = "10" + t;
                        break;
                    }
                    case 21: {
                        sx = "1" + t;
                    }
                }
            } else {
                sx = Long.toString(x, 8);
            }
            return this.printOFormat(sx);
        }

        private String printOFormat(int x) {
            String sx = null;
            if (x == Integer.MIN_VALUE) {
                sx = "20000000000";
            } else if (x < 0) {
                String t = Integer.toString(~(-x - 1) ^ Integer.MIN_VALUE, 8);
                switch (t.length()) {
                    case 1: {
                        sx = "2000000000" + t;
                        break;
                    }
                    case 2: {
                        sx = "200000000" + t;
                        break;
                    }
                    case 3: {
                        sx = "20000000" + t;
                        break;
                    }
                    case 4: {
                        sx = "2000000" + t;
                        break;
                    }
                    case 5: {
                        sx = "200000" + t;
                        break;
                    }
                    case 6: {
                        sx = "20000" + t;
                        break;
                    }
                    case 7: {
                        sx = "2000" + t;
                        break;
                    }
                    case 8: {
                        sx = "200" + t;
                        break;
                    }
                    case 9: {
                        sx = "20" + t;
                        break;
                    }
                    case 10: {
                        sx = "2" + t;
                        break;
                    }
                    case 11: {
                        sx = "3" + t.substring(1);
                    }
                }
            } else {
                sx = Integer.toString(x, 8);
            }
            return this.printOFormat(sx);
        }

        private String printOFormat(String sx) {
            int nLeadingZeros = 0;
            int nBlanks = 0;
            if (sx.equals("0") && this.precisionSet && this.precision == 0) {
                sx = "";
            }
            if (this.precisionSet) {
                nLeadingZeros = this.precision - sx.length();
            }
            if (this.alternateForm) {
                ++nLeadingZeros;
            }
            if (nLeadingZeros < 0) {
                nLeadingZeros = 0;
            }
            if (this.fieldWidthSet) {
                nBlanks = this.fieldWidth - nLeadingZeros - sx.length();
            }
            if (nBlanks < 0) {
                nBlanks = 0;
            }
            int n = nLeadingZeros + sx.length() + nBlanks;
            char[] ca = new char[n];
            if (this.leftJustify) {
                int i;
                for (i = 0; i < nLeadingZeros; ++i) {
                    ca[i] = 48;
                }
                char[] csx = sx.toCharArray();
                int j = 0;
                while (j < csx.length) {
                    ca[i] = csx[j];
                    ++j;
                    ++i;
                }
                j = 0;
                while (j < nBlanks) {
                    ca[i] = 32;
                    ++j;
                    ++i;
                }
            } else {
                int i;
                if (this.leadingZeros) {
                    for (i = 0; i < nBlanks; ++i) {
                        ca[i] = 48;
                    }
                } else {
                    for (i = 0; i < nBlanks; ++i) {
                        ca[i] = 32;
                    }
                }
                int j = 0;
                while (j < nLeadingZeros) {
                    ca[i] = 48;
                    ++j;
                    ++i;
                }
                char[] csx = sx.toCharArray();
                int j2 = 0;
                while (j2 < csx.length) {
                    ca[i] = csx[j2];
                    ++j2;
                    ++i;
                }
            }
            return new String(ca);
        }

        private String printCFormat(char x) {
            int nPrint = 1;
            int width = this.fieldWidth;
            if (!this.fieldWidthSet) {
                width = nPrint;
            }
            char[] ca = new char[width];
            int i = 0;
            if (this.leftJustify) {
                ca[0] = x;
                for (i = 1; i <= width - nPrint; ++i) {
                    ca[i] = 32;
                }
            } else {
                for (i = 0; i < width - nPrint; ++i) {
                    ca[i] = 32;
                }
                ca[i] = x;
            }
            return new String(ca);
        }

        private String printSFormat(String x) {
            int nPrint = x.length();
            int width = this.fieldWidth;
            if (this.precisionSet && nPrint > this.precision) {
                nPrint = this.precision;
            }
            if (!this.fieldWidthSet) {
                width = nPrint;
            }
            int n = 0;
            if (width > nPrint) {
                n += width - nPrint;
            }
            n = nPrint >= x.length() ? (n += x.length()) : (n += nPrint);
            char[] ca = new char[n];
            int i = 0;
            if (this.leftJustify) {
                char[] csx;
                if (nPrint >= x.length()) {
                    csx = x.toCharArray();
                    for (i = 0; i < x.length(); ++i) {
                        ca[i] = csx[i];
                    }
                } else {
                    csx = x.substring(0, nPrint).toCharArray();
                    for (i = 0; i < nPrint; ++i) {
                        ca[i] = csx[i];
                    }
                }
                int j = 0;
                while (j < width - nPrint) {
                    ca[i] = 32;
                    ++j;
                    ++i;
                }
            } else {
                for (i = 0; i < width - nPrint; ++i) {
                    ca[i] = 32;
                }
                if (nPrint >= x.length()) {
                    char[] csx = x.toCharArray();
                    for (int j = 0; j < x.length(); ++j) {
                        ca[i] = csx[j];
                        ++i;
                    }
                } else {
                    char[] csx = x.substring(0, nPrint).toCharArray();
                    for (int j = 0; j < nPrint; ++j) {
                        ca[i] = csx[j];
                        ++i;
                    }
                }
            }
            return new String(ca);
        }

        private boolean setConversionCharacter() {
            char c;
            boolean ret = false;
            this.conversionCharacter = '\u0000';
            if (this.pos < this.fmt.length() && ((c = this.fmt.charAt(this.pos)) == 'i' || c == 'd' || c == 'f' || c == 'g' || c == 'G' || c == 'o' || c == 'x' || c == 'X' || c == 'e' || c == 'E' || c == 'c' || c == 's' || c == '%')) {
                this.conversionCharacter = c;
                ++this.pos;
                ret = true;
            }
            return ret;
        }

        private void setOptionalHL() {
            this.optionalh = false;
            this.optionall = false;
            this.optionalL = false;
            if (this.pos < this.fmt.length()) {
                char c = this.fmt.charAt(this.pos);
                if (c == 'h') {
                    this.optionalh = true;
                    ++this.pos;
                } else if (c == 'l') {
                    this.optionall = true;
                    ++this.pos;
                } else if (c == 'L') {
                    this.optionalL = true;
                    ++this.pos;
                }
            }
        }

        private void setPrecision() {
            int firstPos = this.pos;
            this.precisionSet = false;
            if (this.pos < this.fmt.length() && this.fmt.charAt(this.pos) == '.') {
                char c;
                ++this.pos;
                if (this.pos < this.fmt.length() && this.fmt.charAt(this.pos) == '*') {
                    ++this.pos;
                    if (!this.setPrecisionArgPosition()) {
                        this.variablePrecision = true;
                        this.precisionSet = true;
                    }
                    return;
                }
                while (this.pos < this.fmt.length() && Character.isDigit(c = this.fmt.charAt(this.pos))) {
                    ++this.pos;
                }
                if (this.pos > firstPos + 1) {
                    String sz = this.fmt.substring(firstPos + 1, this.pos);
                    this.precision = Integer.parseInt(sz);
                    this.precisionSet = true;
                }
            }
        }

        private void setFieldWidth() {
            int firstPos = this.pos;
            this.fieldWidth = 0;
            this.fieldWidthSet = false;
            if (this.pos < this.fmt.length() && this.fmt.charAt(this.pos) == '*') {
                ++this.pos;
                if (!this.setFieldWidthArgPosition()) {
                    this.variableFieldWidth = true;
                    this.fieldWidthSet = true;
                }
            } else {
                char c;
                while (this.pos < this.fmt.length() && Character.isDigit(c = this.fmt.charAt(this.pos))) {
                    ++this.pos;
                }
                if (firstPos < this.pos && firstPos < this.fmt.length()) {
                    String sz = this.fmt.substring(firstPos, this.pos);
                    this.fieldWidth = Integer.parseInt(sz);
                    this.fieldWidthSet = true;
                }
            }
        }

        private void setArgPosition() {
            int xPos;
            for (xPos = this.pos; xPos < this.fmt.length() && Character.isDigit(this.fmt.charAt(xPos)); ++xPos) {
            }
            if (xPos > this.pos && xPos < this.fmt.length() && this.fmt.charAt(xPos) == '$') {
                this.positionalSpecification = true;
                this.argumentPosition = Integer.parseInt(this.fmt.substring(this.pos, xPos));
                this.pos = xPos + 1;
            }
        }

        private boolean setFieldWidthArgPosition() {
            int xPos;
            boolean ret = false;
            for (xPos = this.pos; xPos < this.fmt.length() && Character.isDigit(this.fmt.charAt(xPos)); ++xPos) {
            }
            if (xPos > this.pos && xPos < this.fmt.length() && this.fmt.charAt(xPos) == '$') {
                this.positionalFieldWidth = true;
                this.argumentPositionForFieldWidth = Integer.parseInt(this.fmt.substring(this.pos, xPos));
                this.pos = xPos + 1;
                ret = true;
            }
            return ret;
        }

        private boolean setPrecisionArgPosition() {
            int xPos;
            boolean ret = false;
            for (xPos = this.pos; xPos < this.fmt.length() && Character.isDigit(this.fmt.charAt(xPos)); ++xPos) {
            }
            if (xPos > this.pos && xPos < this.fmt.length() && this.fmt.charAt(xPos) == '$') {
                this.positionalPrecision = true;
                this.argumentPositionForPrecision = Integer.parseInt(this.fmt.substring(this.pos, xPos));
                this.pos = xPos + 1;
                ret = true;
            }
            return ret;
        }

        boolean isPositionalSpecification() {
            return this.positionalSpecification;
        }

        int getArgumentPosition() {
            return this.argumentPosition;
        }

        boolean isPositionalFieldWidth() {
            return this.positionalFieldWidth;
        }

        int getArgumentPositionForFieldWidth() {
            return this.argumentPositionForFieldWidth;
        }

        boolean isPositionalPrecision() {
            return this.positionalPrecision;
        }

        int getArgumentPositionForPrecision() {
            return this.argumentPositionForPrecision;
        }

        private void setFlagCharacters() {
            this.thousands = false;
            this.leftJustify = false;
            this.leadingSign = false;
            this.leadingSpace = false;
            this.alternateForm = false;
            this.leadingZeros = false;
            while (this.pos < this.fmt.length()) {
                char c = this.fmt.charAt(this.pos);
                if (c == '\'') {
                    this.thousands = true;
                } else if (c == '-') {
                    this.leftJustify = true;
                    this.leadingZeros = false;
                } else if (c == '+') {
                    this.leadingSign = true;
                    this.leadingSpace = false;
                } else if (c == ' ') {
                    if (!this.leadingSign) {
                        this.leadingSpace = true;
                    }
                } else if (c == '#') {
                    this.alternateForm = true;
                } else {
                    if (c != '0') break;
                    if (!this.leftJustify) {
                        this.leadingZeros = true;
                    }
                }
                ++this.pos;
            }
        }
    }
}


package l2s.commons.data.xml;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.Collection;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.helpers.ErrorHandlerImpl;
import l2s.commons.data.xml.helpers.SimpleDTDEntityResolver;
import l2s.commons.logging.LoggerObject;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.filefilter.FileFilterUtils;
import org.apache.commons.io.filefilter.IOFileFilter;
import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;
import org.xml.sax.EntityResolver;
import org.xml.sax.ErrorHandler;

public abstract class AbstractParser<H extends AbstractHolder>
extends LoggerObject {
    protected final H _holder;
    protected String _currentFile;
    protected SAXReader _reader;

    protected AbstractParser(H holder) {
        this._holder = holder;
        this._reader = new SAXReader();
        this._reader.setValidation(true);
        this._reader.setErrorHandler((ErrorHandler)new ErrorHandlerImpl(this));
    }

    public abstract File getXMLPath();

    public File getCustomXMLPath() {
        return null;
    }

    public abstract String getDTDFileName();

    public boolean isIgnored(File f) {
        return false;
    }

    public boolean isDisabled() {
        return false;
    }

    protected void initDTD(File f) {
        this._reader.setEntityResolver((EntityResolver)new SimpleDTDEntityResolver(f));
    }

    protected void parseDocument(InputStream f, String name) throws Exception {
        this._currentFile = name;
        Document document = this._reader.read(f);
        this.readData(document.getRootElement());
    }

    protected abstract void readData(Element var1) throws Exception;

    protected final void parse() {
        File path = this.getXMLPath();
        if (!path.exists()) {
            this.warn("directory or file " + path.getAbsolutePath() + " not exists");
            return;
        }
        if (path.isDirectory()) {
            File dtd = new File(path, this.getDTDFileName());
            if (!dtd.exists()) {
                this.error("DTD file: " + dtd.getName() + " not exists.");
                return;
            }
            this.initDTD(dtd);
            this.parseDir(path);
            this.parseDir(this.getCustomXMLPath());
        } else {
            File dtd = new File(path.getParent(), this.getDTDFileName());
            if (!dtd.exists()) {
                this.info("DTD file: " + dtd.getName() + " not exists.");
                return;
            }
            this.initDTD(dtd);
            try {
                this.parseDocument(new FileInputStream(path), path.getName());
            }
            catch (Exception e) {
                this.warn("Exception: " + e, e);
            }
            File customPath = this.getCustomXMLPath();
            if (customPath != null && customPath.exists()) {
                try {
                    this.parseDocument(new FileInputStream(customPath), customPath.getName());
                }
                catch (Exception e) {
                    this.warn("Exception: " + e, e);
                }
            }
        }
        this.onParsed();
    }

    protected void onParsed() {
    }

    protected H getHolder() {
        return this._holder;
    }

    public String getCurrentFileName() {
        return this._currentFile;
    }

    public void load() {
        if (this.isDisabled()) {
            this.info("disabled.");
            return;
        }
        this.parse();
        ((AbstractHolder)this._holder).process();
        ((AbstractHolder)this._holder).log();
    }

    public void reload() {
        this.info("reload start...");
        ((AbstractHolder)this._holder).clear();
        this.load();
    }

    private void parseDir(File dir) {
        if (dir == null) {
            return;
        }
        if (!dir.exists()) {
            this.warn("Dir " + dir.getAbsolutePath() + " not exists");
            return;
        }
        try {
            Collection<File> files = FileUtils.listFiles((File)dir, (IOFileFilter)FileFilterUtils.suffixFileFilter((String)".xml"), (IOFileFilter)FileFilterUtils.directoryFileFilter());
            for (File f : files) {
                if (f.isHidden() || this.isIgnored(f)) continue;
                try {
                    this.parseDocument(new FileInputStream(f), f.getName());
                }
                catch (Exception e) {
                    this.info("Exception: " + e + " in file: " + f.getName(), e);
                }
            }
        }
        catch (Exception e) {
            this.warn("Exception: " + e, e);
        }
    }

    public String parseString(Element element, String param, String defaultValue) {
        String value = element.attributeValue(param);
        if (value == null) {
            return defaultValue;
        }
        return value;
    }

    public String parseString(Element element, String param) {
        return element.attributeValue(param);
    }

    public int parseInt(Element element, String param, int defaultValue) {
        String value = element.attributeValue(param);
        if (value == null) {
            return defaultValue;
        }
        return Integer.parseInt(value);
    }

    public int parseInt(Element element, String param) {
        return Integer.parseInt(element.attributeValue(param));
    }

    public long parseLong(Element element, String param, long defaultValue) {
        String value = element.attributeValue(param);
        if (value == null) {
            return defaultValue;
        }
        return Long.parseLong(value);
    }

    public long parseLong(Element element, String param) {
        return Long.parseLong(element.attributeValue(param));
    }

    public double parseDouble(Element element, String param, double defaultValue) {
        String value = element.attributeValue(param);
        if (value == null) {
            return defaultValue;
        }
        return Double.parseDouble(value);
    }

    public double parseDouble(Element element, String param) {
        return Double.parseDouble(element.attributeValue(param));
    }

    public boolean parseBoolean(Element element, String param, boolean defaultValue) {
        String value = element.attributeValue(param);
        if (value == null) {
            return defaultValue;
        }
        return Boolean.parseBoolean(value);
    }

    public boolean parseBoolean(Element element, String param) {
        return Boolean.parseBoolean(element.attributeValue(param));
    }
}


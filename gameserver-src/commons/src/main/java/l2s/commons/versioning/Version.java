package l2s.commons.versioning;

import java.io.File;
import java.io.IOException;
import java.util.jar.Attributes;
import java.util.jar.JarFile;
import l2s.commons.versioning.Locator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Version {
    private static final Logger _log = LoggerFactory.getLogger(Version.class);
    private String _revisionNumber = "exported";
    private String _versionNumber = "-1";
    private String _buildDate = "";
    private String _buildJdk = "";
    private String _builderName = "";

    public Version(Class<?> c) {
        File jarName = null;
        try {
            jarName = Locator.getClassSource(c);
            JarFile jarFile = new JarFile(jarName);
            Attributes attrs = jarFile.getManifest().getMainAttributes();
            this.setBuildJdk(attrs);
            this.setBuildDate(attrs);
            this.setRevisionNumber(attrs);
            this.setVersionNumber(attrs);
            this.setBuilderName(attrs);
        }
        catch (IOException e) {
            _log.error("Unable to get soft information\nFile name '" + (jarName == null ? "null" : jarName.getAbsolutePath()) + "' isn't a valid jar", (Throwable)e);
        }
    }

    private void setBuilderName(Attributes attrs) {
        String builderName = attrs.getValue("Builder-Name");
        this._builderName = builderName != null ? builderName : ((builderName = attrs.getValue("Created-By")) != null ? builderName : "L2-Scripts");
    }

    private void setVersionNumber(Attributes attrs) {
        String versionNumber = attrs.getValue("Implementation-Version");
        this._versionNumber = versionNumber != null ? versionNumber : "-1";
    }

    private void setRevisionNumber(Attributes attrs) {
        String revisionNumber = attrs.getValue("Implementation-Build");
        this._revisionNumber = revisionNumber != null ? revisionNumber : "-1";
    }

    private void setBuildJdk(Attributes attrs) {
        String buildJdk = attrs.getValue("Build-Jdk");
        this._buildJdk = buildJdk != null ? buildJdk : ((buildJdk = attrs.getValue("Created-By")) != null ? buildJdk : "-1");
    }

    private void setBuildDate(Attributes attrs) {
        String buildDate = attrs.getValue("Build-Date");
        this._buildDate = buildDate != null ? buildDate : "-1";
    }

    public String getRevisionNumber() {
        return this._revisionNumber;
    }

    public String getVersionNumber() {
        return this._versionNumber;
    }

    public String getBuildDate() {
        return this._buildDate;
    }

    public String getBuildJdk() {
        return this._buildJdk;
    }

    public String getBuilderName() {
        return this._builderName;
    }
}


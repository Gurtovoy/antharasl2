package l2s.gameserver.cache;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import java.util.regex.Pattern;
import javax.imageio.ImageIO;
import l2s.commons.formats.dds.DDSConverter;
import l2s.gameserver.Config;
import org.apache.commons.lang3.builder.HashCodeBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ImagesCache {
    private static final Logger _log = LoggerFactory.getLogger(ImagesCache.class);
    private static final int[] SIZES = new int[]{1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024};
    private static final int MAX_SIZE = SIZES[SIZES.length - 1];
    public static final Pattern HTML_PATTERN = Pattern.compile("%image:(.*?)%", 32);
    private static final ImagesCache _instance = new ImagesCache();
    private final Map<String, Integer> _imagesId = new HashMap<String, Integer>();
    private final TIntObjectMap<byte[]> _images = new TIntObjectHashMap();
    private final ReentrantReadWriteLock lock = new ReentrantReadWriteLock();
    private final Lock readLock = this.lock.readLock();
    private final Lock writeLock = this.lock.writeLock();

    public static final ImagesCache getInstance() {
        return _instance;
    }

    private ImagesCache() {
        this.load();
    }

    public void load() {
        _log.info("ImagesCache: Loading images...");
        File dir = new File(Config.DATAPACK_ROOT, "images");
        if (!dir.exists() || !dir.isDirectory()) {
            _log.info("ImagesCache: Files missing, loading aborted.");
            return;
        }
        int count = this.loadImagesDir(dir);
        _log.info("ImagesCache: Loaded " + count + " images");
    }

    private int loadImagesDir(File dir) {
        int count = 0;
        for (File file : dir.listFiles()) {
            if (file.isDirectory()) {
                count += this.loadImagesDir(file);
                continue;
            }
            if (!ImagesCache.checkImageFormat(file)) continue;
            String fileName = file.getName();
            if (this._imagesId.containsKey(fileName.toLowerCase())) {
                _log.warn("Duplicate image name \"" + fileName + "\". Replacing with " + file.getPath());
                continue;
            }
            BufferedImage image = ImagesCache.resizeImage(file);
            if (image == null) continue;
            try {
                ByteBuffer buffer = DDSConverter.convertToDxt1NoTransparency((BufferedImage)image);
                byte[] array = buffer.array();
                int imageId = Math.abs(new HashCodeBuilder(15, 87).append((Object)fileName).append(array).toHashCode());
                this._imagesId.put(fileName.toLowerCase(), imageId);
                this._images.put(imageId, array);
            }
            catch (Exception e) {
                _log.error("ImagesChache: Error while loading " + fileName + " (" + image.getWidth() + "x" + image.getHeight() + ") image.", (Throwable)e);
            }
            ++count;
        }
        return count;
    }

    private static BufferedImage resizeImage(File file) {
        BufferedImage image;
        try {
            image = ImageIO.read(file);
        }
        catch (IOException ioe) {
            _log.error("ImagesCache: Error while resizing " + file.getName() + " image.");
            return null;
        }
        if (image == null) {
            return null;
        }
        int width = image.getWidth();
        int height = image.getHeight();
        int resizedWidth = width;
        if (width > MAX_SIZE) {
            resizedWidth = MAX_SIZE;
        } else {
            for (int size : SIZES) {
                if (size < width) continue;
                resizedWidth = size;
                break;
            }
        }
        int resizedHeight = height;
        if (height > MAX_SIZE) {
            resizedHeight = MAX_SIZE;
        } else {
            for (int size : SIZES) {
                if (size < height) continue;
                resizedHeight = size;
                break;
            }
        }
        if (resizedWidth != width || resizedHeight != height) {
            BufferedImage resizedImage = new BufferedImage(resizedWidth, resizedHeight, image.getType());
            Graphics2D g = resizedImage.createGraphics();
            g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
            g.drawImage(image, 0, 0, image.getWidth(), image.getHeight(), Color.BLACK, null);
            g.dispose();
            return resizedImage;
        }
        return image;
    }

    public int getImageId(String val) {
        int imageId = -1;
        this.readLock.lock();
        try {
            if (this._imagesId.get(val.toLowerCase()) != null) {
                imageId = this._imagesId.get(val.toLowerCase());
            }
        }
        finally {
            this.readLock.unlock();
        }
        return imageId;
    }

    public byte[] getImage(int imageId) {
        byte[] image = null;
        this.readLock.lock();
        try {
            image = (byte[])this._images.get(imageId);
        }
        finally {
            this.readLock.unlock();
        }
        return image;
    }

    private static boolean checkImageFormat(File file) {
        String filename = file.getName();
        return filename.endsWith(".jpg") || filename.endsWith(".png") || filename.endsWith(".bmp");
    }
}


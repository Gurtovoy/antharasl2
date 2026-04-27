// Ported from L2J_Mobius - Bresenham 3D grid line iterator
package l2s.gameserver.geodata;

/**
 * An iterator that steps through points on a straight line using Bresenham's line-drawing algorithm.
 * <p>
 * Bresenham's algorithm calculates which grid points should be part of a straight line between two points.
 * </p>
 */
public class GridLineIterator3D {
    // Current position of the iterator.
    private int _currentX;
    private int _currentY;
    private int _currentZ;

    // Target endpoint of the line.
    private final int _targetX;
    private final int _targetY;
    private final int _targetZ;

    // Absolute distances along X, Y, and Z axes.
    private final int _deltaX;
    private final int _deltaY;
    private final int _deltaZ;

    // Step directions for movement along the X, Y, and Z axes.
    private final int _stepX;
    private final int _stepY;
    private final int _stepZ;

    // Tracks the accumulated error terms for adjusting the minor axes.
    private int _accumulatedErrorXY;
    private int _accumulatedErrorXZ;

    // Indicates whether the iteration has started.
    private boolean _hasStarted;

    /**
     * Initializes the iterator to step through points along a 3D line from (startX, startY, startZ) to (endX, endY, endZ).
     * @param startX the X-coordinate of the start point
     * @param startY the Y-coordinate of the start point
     * @param startZ the Z-coordinate of the start point
     * @param endX the X-coordinate of the end point
     * @param endY the Y-coordinate of the end point
     * @param endZ the Z-coordinate of the end point
     */
    public GridLineIterator3D(int startX, int startY, int startZ, int endX, int endY, int endZ) {
        _currentX = startX;
        _currentY = startY;
        _currentZ = startZ;

        _targetX = endX;
        _targetY = endY;
        _targetZ = endZ;

        _deltaX = Math.abs(endX - startX);
        _deltaY = Math.abs(endY - startY);
        _deltaZ = Math.abs(endZ - startZ);

        _stepX = Integer.compare(endX, startX);
        _stepY = Integer.compare(endY, startY);
        _stepZ = Integer.compare(endZ, startZ);

        if ((_deltaX >= _deltaY) && (_deltaX >= _deltaZ)) {
            _accumulatedErrorXY = _accumulatedErrorXZ = _deltaX / 2;
        } else if ((_deltaY >= _deltaX) && (_deltaY >= _deltaZ)) {
            _accumulatedErrorXY = _accumulatedErrorXZ = _deltaY / 2;
        } else {
            _accumulatedErrorXY = _accumulatedErrorXZ = _deltaZ / 2;
        }

        _hasStarted = false;
    }

    /**
     * Advances the iterator to the next point on the line.
     * @return {@code true} if the iterator successfully moved to the next point;
     *         {@code false} if the end of the line has been reached.
     */
    public boolean next() {
        if (!_hasStarted) {
            _hasStarted = true;
            return true;
        }

        if ((_currentX == _targetX) && (_currentY == _targetY) && (_currentZ == _targetZ)) {
            return false;
        }

        if ((_deltaX >= _deltaY) && (_deltaX >= _deltaZ)) {
            // Dominant axis X.
            _currentX += _stepX;

            _accumulatedErrorXY += _deltaY;
            if (_accumulatedErrorXY >= _deltaX) {
                _currentY += _stepY;
                _accumulatedErrorXY -= _deltaX;
            }

            _accumulatedErrorXZ += _deltaZ;
            if (_accumulatedErrorXZ >= _deltaX) {
                _currentZ += _stepZ;
                _accumulatedErrorXZ -= _deltaX;
            }
        } else if ((_deltaY >= _deltaX) && (_deltaY >= _deltaZ)) {
            // Dominant axis Y.
            _currentY += _stepY;

            _accumulatedErrorXY += _deltaX;
            if (_accumulatedErrorXY >= _deltaY) {
                _currentX += _stepX;
                _accumulatedErrorXY -= _deltaY;
            }

            _accumulatedErrorXZ += _deltaZ;
            if (_accumulatedErrorXZ >= _deltaY) {
                _currentZ += _stepZ;
                _accumulatedErrorXZ -= _deltaY;
            }
        } else {
            // Dominant axis Z.
            _currentZ += _stepZ;

            _accumulatedErrorXY += _deltaX;
            if (_accumulatedErrorXY >= _deltaZ) {
                _currentX += _stepX;
                _accumulatedErrorXY -= _deltaZ;
            }

            _accumulatedErrorXZ += _deltaY;
            if (_accumulatedErrorXZ >= _deltaZ) {
                _currentY += _stepY;
                _accumulatedErrorXZ -= _deltaZ;
            }
        }

        return true;
    }

    /**
     * Returns the current X-coordinate of the iterator's position.
     * @return the current X-coordinate
     */
    public int x() {
        return _currentX;
    }

    /**
     * Returns the current Y-coordinate of the iterator's position.
     * @return the current Y-coordinate
     */
    public int y() {
        return _currentY;
    }

    /**
     * Returns the current Z-coordinate of the iterator's position.
     * @return the current Z-coordinate
     */
    public int z() {
        return _currentZ;
    }

    @Override
    public String toString() {
        return "[" + _currentX + ", " + _currentY + ", " + _currentZ + "]";
    }
}

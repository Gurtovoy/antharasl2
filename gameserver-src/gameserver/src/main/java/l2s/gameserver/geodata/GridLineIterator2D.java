// Ported from L2J_Mobius - Bresenham 2D grid line iterator
package l2s.gameserver.geodata;

/**
 * An iterator that steps through points on a straight line using Bresenham's line-drawing algorithm.
 * <p>
 * Bresenham's algorithm calculates which grid points should be part of a straight line between two points.
 * </p>
 */
public class GridLineIterator2D {
    // Current position of the iterator.
    private int _currentX;
    private int _currentY;

    // Target endpoint of the line.
    private final int _targetX;
    private final int _targetY;

    // Step directions for movement along the X and Y axes.
    private final int _stepX;
    private final int _stepY;

    // Absolute distances along X and Y axes.
    private final int _deltaX;
    private final int _deltaY;

    // Indicates whether the line is steep (Y changes faster than X).
    private final boolean _isSteep;

    // Tracks the accumulated error term for adjusting the minor axis.
    private int _accumulatedError;

    // Indicates whether the iteration has started.
    private boolean _hasStarted;

    /**
     * Initializes the iterator to step through points along a line from (startX, startY) to (endX, endY).
     * @param startX the X-coordinate of the start point
     * @param startY the Y-coordinate of the start point
     * @param endX the X-coordinate of the end point
     * @param endY the Y-coordinate of the end point
     */
    public GridLineIterator2D(int startX, int startY, int endX, int endY) {
        _currentX = startX;
        _currentY = startY;

        _targetX = endX;
        _targetY = endY;

        _deltaX = Math.abs(endX - startX);
        _deltaY = Math.abs(endY - startY);

        _stepX = Integer.compare(endX, startX);
        _stepY = Integer.compare(endY, startY);

        _isSteep = _deltaY > _deltaX;

        _accumulatedError = (_isSteep ? _deltaY : _deltaX) / 2;

        _hasStarted = false;
    }

    /**
     * Advances the iterator to the next point on the line.
     * @return {@code true} if the iterator successfully moved to the next point or
     *         {@code false} if the end of the line has been reached.
     */
    public boolean next() {
        if (!_hasStarted) {
            _hasStarted = true;
            return true;
        }

        if ((_currentX == _targetX) && (_currentY == _targetY)) {
            return false;
        }

        if (_isSteep) {
            _currentY += _stepY;
            _accumulatedError -= _deltaX;
            if (_accumulatedError < 0) {
                _currentX += _stepX;
                _accumulatedError += _deltaY;
            }
        } else {
            _currentX += _stepX;
            _accumulatedError -= _deltaY;
            if (_accumulatedError < 0) {
                _currentY += _stepY;
                _accumulatedError += _deltaX;
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

    @Override
    public String toString() {
        return "[" + _currentX + ", " + _currentY + "]";
    }
}

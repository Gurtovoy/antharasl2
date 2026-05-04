package l2s.commons.geometry;

public interface CoordsConverter {
    public static final CoordsConverter DEFAULT_CONVERTER = new CoordsConverter(){

        @Override
        public int convertX(int x) {
            return x;
        }

        @Override
        public int convertY(int y) {
            return y;
        }

        @Override
        public int convertDistance(int distance) {
            return distance;
        }
    };

    public int convertX(int var1);

    public int convertY(int var1);

    public int convertDistance(int var1);
}


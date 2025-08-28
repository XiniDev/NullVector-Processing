final class Platform extends RigidBody {

    private int tileSize;
    private int rows, cols;
    private PGraphics floorBuffer;

    Platform(int x, int y, int cols, int rows, int tileSize) {
        // single collider for the entire floor based on cols and rows
        super(x, y, 0.0f, new BoxCollider(cols * tileSize, rows * tileSize, 0, 0));
        
        this.cols = cols;
        this.rows = rows;
        this.tileSize = tileSize;

        PImage spriteSrc = loadImage("assets/tiles/tiles.png");

        restitution = 0.8f;
        friction = 10.0f;

        floorBuffer = createGraphics(cols * tileSize, rows * tileSize);
        floorBuffer.beginDraw();
        for (int r = 0; r < rows; r++) {
            for (int c = 0; c < cols; c++) {
                int drawX = c * tileSize;
                int drawY = r * tileSize;

                int srcX;
                if (c == 0) srcX = 0;
                else if (c == cols - 1) srcX = 3;
                else if (c % 2 == 1) srcX = 1;
                else srcX = 2;

                int srcY;
                if (rows == 1) {
                    srcY = 4;
                } else {
                    if (r == 0) srcY = 0;
                    else if (r == rows - 1) srcY = 3;
                    else if (r % 2 == 1) srcY = 1;
                    else srcY = 2;
                }

                // instead of using sprite to draw (with push/popMatrix), use the graphics buffer
                // because using sprite to draw lags the program as it needs to draw a lot of blocks
                floorBuffer.image(spriteSrc, drawX, drawY, tileSize, tileSize, tileSize * srcX, tileSize * srcY, tileSize * (srcX + 1), tileSize * (srcY + 1));
            }
        }
        floorBuffer.endDraw();
    }

    @Override
    void draw() {
        image(floorBuffer, getX(), getY());
        box.draw(getX(), getY());
    }

    @Override
    int getW() {
        return cols * tileSize;
    }

    @Override
    int getH() {
        return rows * tileSize;
    }

    int getCols() {
        return cols;
    }

    int getRows() {
        return rows;
    }

    int getTileSize() {
        return tileSize;
    }
}
final class BoxCollider {

    int boxW;
    int boxH;
    int boxOffsetX;
    int boxOffsetY;

    BoxCollider(int boxW, int boxH, int boxOffsetX, int boxOffsetY) {
        this.boxW = boxW;
        this.boxH = boxH;
        this.boxOffsetX = boxOffsetX;
        this.boxOffsetY = boxOffsetY;
    }

    void draw(int x, int y) {
        if (Globals.getDebug()) {
            stroke(0, 255, 255);
            noFill();
            rect(x + getBoxOffsetX(), y + getBoxOffsetY(), getBoxW(), getBoxH());
        }
    }

    int getBoxW() {
        return boxW;
    }

    int getBoxH() {
        return boxH;
    }

    int getBoxOffsetX() {
        return boxOffsetX;
    }

    int getBoxOffsetY() {
        return boxOffsetY;
    }

    void setBoxSize(int boxW, int boxH, int boxOffsetX, int boxOffsetY) {
        this.boxW = boxW;
        this.boxH = boxH;
        this.boxOffsetX = boxOffsetX;
        this.boxOffsetY = boxOffsetY;
    }
}
class Sprite {

    PImage src;
    int sw;
    int sh;
    int sx;
    int sy;
    boolean hFlip;

    Sprite(PImage img, int sw, int sh, int sx, int sy) {
        src = img;
        this.sw = sw;
        this.sh = sh;
        this.sx = sx;
        this.sy = sy;
        this.hFlip = false;
    }

    Sprite(String path, int sw, int sh, int sx, int sy) {
        this(loadImage(path), sw, sh, sx, sy);
    }

    void draw(int x, int y) {
        int xSign = getHFlip() ? -1 : 1;
        int xTranslate = getHFlip() ? -getSrcW() : 0;
        pushMatrix();
        scale(xSign * 1.0, 1.0);
        copy(getSrc(),
             getSrcX(), getSrcY(), getSrcW(), getSrcH(),
             xSign * x + xTranslate, y, getSrcW(), getSrcH());
        popMatrix();
    }

    PImage getSrc() {
        return src;
    }

    int getSrcW() {
        return sw;
    }

    int getSrcH() {
        return sh;
    }

    int getSrcX() {
        return sx;
    }

    int getSrcY() {
        return sy;
    }

    boolean getHFlip() {
        return hFlip;
    }

    void setHFlip(boolean hFlip) {
        this.hFlip = hFlip;
    }
}
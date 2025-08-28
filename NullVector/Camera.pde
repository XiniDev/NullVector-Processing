class Camera {
    public PVector position;
    public float zoom = 2.0f;

    public Camera(int xCoord, int yCoord, float zoom) {
        this.position = new PVector(xCoord * Globals.STRIDE, yCoord * Globals.STRIDE);
        this.zoom = zoom;
    }

    public void begin() {
        pushMatrix();
        translate(width / 2, height / 2);
        scale(zoom);
        translate(-position.x, -position.y);
    }

    public void end() {
        popMatrix();
    }

    int getX() {
        return (int) position.x;
    }

    int getY() {
        return (int) position.y;
    }

    float getXf() {
        return position.x;
    }

    float getYf() {
        return position.y;
    }

    int getW() {
        return width;
    }

    int getH() {
        return height;
    }
}
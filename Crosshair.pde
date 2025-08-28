final class Crosshair extends Entity {

    Camera camera;
    int size;

    Crosshair(Camera camera) {
        super(0, 0);
        this.camera = camera;
        setPositionF(getWorldMouseX(), getWorldMouseY());
        size = 2;

        // ensures crosshair is on the top layer
        layer = Integer.MAX_VALUE;
    }

    void draw() {
        stroke(255, 255, 255);
        setPositionF(getWorldMouseX(), getWorldMouseY());

        // draw crosshair with the transformed world coordinates
        line(getWorldMouseX() - size, getWorldMouseY(), getWorldMouseX() + size, getWorldMouseY());
        line(getWorldMouseX(), getWorldMouseY() - size, getWorldMouseX(), getWorldMouseY() + size);
    }

    float getWorldMouseX() {
        return (mouseX / Globals.SCALE) + camera.position.x - (screen_width / 2) / Globals.SCALE;
    }

    float getWorldMouseY() {
        return (mouseY / Globals.SCALE) + camera.position.y - (screen_height / 2) / Globals.SCALE;
    }

    @Override
    int getW() {
        return size * 2;
    }

    @Override
    int getH() {
        return size * 2;
    }
}
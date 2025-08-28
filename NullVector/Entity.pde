abstract class Entity {

    PVector position;
    boolean active;

    // draw priority on screen, some things are drawn on top of some things
    // used for sorting
    int layer;

    Entity(int xCoord, int yCoord) {
        // xCoord and yCoord is the artificial coordinates that will be multiplied by stride
        position = new PVector(xCoord * Globals.STRIDE, yCoord * Globals.STRIDE);
        active = true;
        layer = 0;
    }

    int getXCoord() {
        return (int) (position.x / Globals.STRIDE);
    }

    int getYCoord() {
        return (int) (position.y / Globals.STRIDE);
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

    // override these for entities with size
    int getW() {
        return 0;
    }

    int getH() {
        return 0;
    }

    PVector getPosition() {
        return new PVector(getXf(), getYf());
    }

    void setPosition(int x, int y) {
        position.x = x;
        position.y = y;
    }

    void setPositionF(float x, float y) {
        position.x = x;
        position.y = y;
    }

    boolean isActive() {
        return active;
    }

    void setActive(boolean active) {
        this.active = active;
    }

    void dispose() {
        this.active = false;
    }

    int getLayer() {
        return layer;
    }

    void setLayer(int layer) {
        this.layer = layer;
    }

    void update(float dt) {}

    void draw() {}

    // subentities functions inside an entity if needed
    List<Entity> getNewEntities() {
        return null;
    }

    void clearNewEntities() {}
    void addEntities(List<Entity> entities) {}
}
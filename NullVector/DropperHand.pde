final class DropperHand extends RigidBody {

    // offset to parent
    int offsetX;
    int offsetY;
    int hFlipOffsetX;

    int dropDuration;
    int restDuration;

    DropperHand(int x, int y, int offsetX, int offsetY, int hFlipOffsetX) {
        super(x + offsetX, y + offsetY, 0.0f, new BoxCollider(1, 1, 0, 0));

        this.offsetX = offsetX;
        this.offsetY = offsetY;

        this.hFlipOffsetX = hFlipOffsetX;

        restitution = 0.0f;
        isNotAffectedByGravity();
    }

    void updateByParent(float dt, int x, int y, boolean hFlip, boolean isAttacking) {
        // different to update function because its only activated by parent
        int newOffsetX = hFlip ? offsetX + hFlipOffsetX: offsetX;
        // set position based on the parent's position
        setPosition(x + newOffsetX, y + offsetY);
    }

    void update(float dt) {
        super.update(dt);
    }

    void draw() {
        box.draw(getX(), getY());
    }
}
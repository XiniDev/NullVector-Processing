final class PlayerShooter<T extends Bullet> extends Shooter<T> {

    private static final int r = 5;

    // sprite rendering
    Sprite sprite;
    PVector pivot;

    PlayerShooter(int x, int y, CharacterBody owner, Supplier<T> bulletFactory, float shooterDamage, float bulletImpulse, Sprite sprite) {
        super(x, y, owner, bulletFactory, shooterDamage, bulletImpulse);
        this.sprite = sprite;
        pivot = new PVector(0, 0);
    }

    void updateByParent(float dt, int x, int y, float targetX, float targetY) {
        super.updateByParent(dt, x, y, targetX, targetY);
        pivot.x = (float) (getXf() + Math.cos(rotation) * r);
        pivot.y = (float) (getYf() - Math.sin(rotation) * r);
    }

    void draw() {
        pushMatrix();

        // anticlockwise rotation
        translate(pivot.x, pivot.y);
        rotate(-rotation);

        sprite.draw((int) -sprite.getSrcW() / 2, (int) -sprite.getSrcH() / 2);

        popMatrix();

        super.draw();
    }

    @Override
    int getW() {
        return (int) (sprite.getSrcW() * cos(rotation));
    }

    @Override
    int getH() {
        return (int) (sprite.getSrcH() * sin(rotation));
    }
}
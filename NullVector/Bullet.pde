abstract class Bullet extends Projectile {

    Bullet(int x, int y, float mass, BoxCollider box, Sprite sprite, float damage, float knockbackForce, boolean canBounce) {
        super(x, y, mass, box, sprite, damage, knockbackForce, canBounce);

        active = false;
    }

    void getBullet(int x, int y) {
        // called by pool to reuse a pre-existing bullet
        super.reset(x, y);
        setActive(true);
    }

    void update(float dt) {
        super.update(dt);
    }

    void draw() {
        super.draw();
    }
}
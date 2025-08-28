final class Plasma extends Bullet {

    boolean isStrong;

    Plasma(int x, int y) {
        super(x, y, 1.0f,
              new BoxCollider(4, 4, 2, 2),
              new Sprite("assets/projectiles/plasma.png", 8, 8, 0, 0),
              1.0f, 1000.0f, false);

        restitution = 0.5f;
        friction = 0.0f;
        isNotAffectedByGravity();

        isStrong = false;
    }

    void update(float dt) {
        super.update(dt);
    }

    void draw() {
        super.draw();
    }

    void makeWeak() {
        isStrong = false;
        sprite.sx = 0;
    }

    void makeStrong() {
        if (!isStrong) {
            isStrong = true;
            sprite.sx = 8;
            damage = damage * 2;
        }
    }

    void reset() {
        super.reset();
        makeWeak();
    }
}
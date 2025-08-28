final class Zap extends Bullet {

    Zap(int x, int y) {
        super(x, y, 1.0f,
              new BoxCollider(6, 1, 0, 0),
              new Sprite("assets/projectiles/zap.png", 6, 1, 0, 0),
              1.0f, 1000.0f, false);

        restitution = 0.5f;
        friction = 0.0f;
        isNotAffectedByGravity();
    }

    void update(float dt) {
        super.update(dt);
    }

    void draw() {
        super.draw();
    }
}
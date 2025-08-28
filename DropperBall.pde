final class DropperBall extends Projectile {

    boolean dropped;
    boolean bounced;

    DropperBall(int x, int y, CharacterBody owner) {
        super(x, y, 1.0f,
              new BoxCollider(5, 5, 0, 0),
              new Sprite("assets/projectiles/dropperBall.png", 5, 5, 0, 0),
              2.0f, 1000.0f, true);

        setOwner(owner);

        dropped = false;
        bounced = false;

        restitution = 0.5f;
        friction = 0.5f;
    }

    void update(float dt) {
        if (!dropped) setStationaryTime(0.0f);
        super.update(dt);
    }

    void draw() {
        super.draw();
    }

    void bounce() {
        if (!bounced) {
            damage = damage / 2.0f;
            bounced = true;
        }
    }

    boolean isDropped() {
        return dropped;
    }

    void regenerate(int x, int y) {
        super.reset(x, y);
        setActive(true);
        dropped = false;
    }

    void drop() {
        dropped = true;
    }

    void reset() {
        drop();
        super.reset();
    }
}
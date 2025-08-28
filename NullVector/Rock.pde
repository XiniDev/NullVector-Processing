final class Rock extends Bullet {

    boolean bounced;

    Rock(int x, int y) {
        super(x, y, 2.0f,
              new BoxCollider(6, 6, 0, 0),
              new Sprite("assets/projectiles/rock.png", 6, 6, 0, 0),
              1.0f, 2000.0f, true);

        restitution = 0.5f;
        friction = 0.5f;

        bounced = false;
    }

    void update(float dt) {
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
}
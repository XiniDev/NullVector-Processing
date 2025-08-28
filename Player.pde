import java.util.List;

final class Player extends CharacterBody {

    // shooter attached on the player
    PlayerShooter<Rock> shooter;

    int attackSpeed;
    int attackSpeedCounter;

    // references
    Camera camera;
    Crosshair crosshair;

    Waypoint waypoint;

    Player(int x, int y, Camera camera, Crosshair crosshair, Graph<Waypoint> waypointGraph) {
        super(x, y, 20.0f,
              new BoxCollider(6, 19, 5, 5),
              new AnimatedSprite("assets/sprites/player.png", 16, 24, 16, 24, 6, new boolean[]{false, false}),
              new CharacterProperties(15.0f, 3.0f, 300.0f, 0.5f, 10),
              10.0f, waypointGraph);

        this.camera = camera;
        this.crosshair = crosshair;

        PVector center = getCenter();
        shooter = new PlayerShooter<>((int) center.x, (int) center.y, this,
                                      () -> new Rock(0, 0),
                                      1.0f, 400.0f,
                                      new Sprite("assets/sprites/playerShooter.png", 16, 16, 0, 0));

        attackSpeed = 60;
        attackSpeedCounter = attackSpeed;

        waypoint = null;

        // player always on top of everything
        layer = 1000;
    }

    void update(float dt) {
        super.update(dt);

        // set move animation
        if (moveDirection == 0) sprite.setAnimation(0);
        else sprite.setAnimation(1);

        // camera follow player (center based on sprite)
        // lerp for smooth following the player (gives slight delay, makes it more comfortable to the eye)
        float smoothing = 0.1f;
        camera.position.x = lerp(camera.position.x, getXf() + sprite.getSrcW() / 2, smoothing);
        camera.position.y = lerp(camera.position.y, getYf() + sprite.getSrcH() / 2 - (Globals.STRIDE * 1.5f), smoothing);

        // attack speed
        if (attackSpeedCounter < attackSpeed) attackSpeedCounter++;

        // shooter updates
        updateShooter(dt);

        // update waypoint for all enemies to know
        if (waypoint != null) waypoint.setPlayerOnTop(false);
        Waypoint wp = getCurrentWaypoint();
        if (wp != null) waypoint = wp;
        waypoint.setPlayerOnTop(true);
    }

    void updateShooter(float dt) {
        PVector center = getCenter();
        shooter.updateByParent(dt, (int) center.x, (int) center.y, crosshair.getWorldMouseX(), crosshair.getWorldMouseY());
        shooter.cleanupOffScreen(camera);
    }

    void draw() {
        super.draw();
    }

    Waypoint getWaypoint() {
        return waypoint;
    }

    boolean[] setNoRepeats() {
        return new boolean[]{false, false};
    }

    void camera_begin() {
        this.camera.begin();
    }

    void camera_end() {
        this.camera.end();
    }

    void incMoveDirection() {
        if (moveDirection < 1) moveDirection++;
    }

    void decMoveDirection() {
        if (moveDirection > -1) moveDirection--;
    }

    void jump() {
        super.jump();
    }

    void shoot() {
        if (attackSpeedCounter >= attackSpeed) {
            shooter.shoot();
            attackSpeedCounter = 0;
        }
    }

    void die() {
        super.die();
        shooter.dispose();
    }

    float getDamage() {
        return shooter.getDamage();
    }

    void addEntities(List<Entity> entities) {
        shooter.addEntities(entities);
        entities.add(this);
    }

    boolean isEnemy() {
        return false;
    }
}
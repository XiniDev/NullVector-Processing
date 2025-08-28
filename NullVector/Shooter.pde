import java.util.List;
import java.util.function.Supplier;

class Shooter<T extends Bullet> extends Entity {

    CharacterBody owner;

    private List<Entity> newEntities;

    private BulletPool<T> bulletPool;
    private BulletManager<T> bulletManager;

    float bulletImpulse;
    float baseBulletImpulse;
    float damage;

    float rotation = 0.0f;

    boolean sightBlocked;
    Ray lineOfSightRay;

    // shooter is always attached to a parent entity
    Shooter(int x, int y, CharacterBody owner, Supplier<T> bulletFactory, float shooterDamage, float bulletImpulse) {
        super(x, y);
        this.owner = owner;

        this.bulletPool = new BulletPool<>(bulletFactory);
        this.bulletManager = new BulletManager<>(bulletPool);

        this.damage = shooterDamage;
        this.bulletImpulse = bulletImpulse;
        baseBulletImpulse = bulletImpulse;
        active = true;

        newEntities = new ArrayList<>();

        sightBlocked = false;
        lineOfSightRay = new Ray(0, 0, 0, this.owner);
        lineOfSightRay.rayColor = color(255, 255, 0);

        // ensures shooters are on top of bullets
        layer = 5;
    }

    void updateByParent(float dt, int x, int y, float targetX, float targetY) {
        // set position based on the parent's position
        setPosition(x, y);

        // calculate the direction from the shooter to the crosshair
        // negate y for cartesian arctan
        float dx = targetX - getXf();
        float dy = -(targetY - getYf());

        // angle in radians
        rotation = (float) atan2(dy, dx);

        lineOfSightRay.setLength(new PVector(x, y).dist(new PVector(targetX, targetY)));
        lineOfSightRay.updateByParent(dt, (int) x, (int) y, cos(rotation), sin(-rotation));

        if (lineOfSightRay.isIntersectingPlatforms()) setSightBlocked(true);
        else setSightBlocked(false);

        updateBullets(dt);
    }

    void draw() {
        drawBullets();
    }

    void setSightBlocked(boolean value) {
        this.sightBlocked = value;
    }

    boolean getSightBlocked() {
        return sightBlocked;
    }

    @Override
    int getW() {
        return (int) (Globals.STRIDE * cos(rotation));
    }

    @Override
    int getH() {
        return (int) (Globals.STRIDE * sin(rotation));
    }

    void shoot() {
        // acceleration of x and y based on sin and cos of angle (x is adjacent, y is opposite)
        float ax = bulletImpulse * cos(rotation);
        float ay = bulletImpulse * sin(rotation);

        T bullet = bulletManager.spawnBullet(getX(), getY(), ax, ay);
        modifyBullet(bullet);

        if (bullet != null) {
            bullet.setOwner(owner);
        }

        if (newEntities != null) {
            newEntities.add(bullet);
        }
    }

    // override this for modifiers
    void modifyBullet(T bullet) {
        return;
    }

    void updateBullets(float dt) {
        bulletManager.update(dt);
    }

    void drawBullets() {
        bulletManager.draw();
    }

    void cleanupOffScreen(Camera camera) {
        bulletManager.cleanupOffScreen(camera);
    }

    List<T> getActiveBullets() {
        return bulletManager.getActiveBullets();
    }

    float getDamage() {
        return damage;
    }

    void dispose() {
        super.dispose();
        lineOfSightRay.dispose();
    }

    List<Entity> getNewEntities() {
        return newEntities;
    }

    void clearNewEntities() {
        newEntities.clear();
    }

    void addEntities(List<Entity> entities) {
        entities.add(this);
        entities.add(lineOfSightRay);
    }
}
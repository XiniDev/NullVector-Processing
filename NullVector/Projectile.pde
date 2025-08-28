abstract class Projectile extends RigidBody {

    private static final float STATIONARY_TIME_LIMIT = 2.0f;

    private CharacterBody owner;

    // check for staying at same position for too long -> remove projectile
    float stationaryTime;
    int lastIntX, lastIntY;

    Sprite sprite;

    float baseDamage;
    float damage;

    float knockbackForce;

    boolean canBounce;

    Projectile(int x, int y, float mass, BoxCollider box, Sprite sprite, float damage, float knockbackForce, boolean canBounce) {
        super(x, y, mass, box);
        this.sprite = sprite;

        active = true;

        stationaryTime = 0.0f;

        this.baseDamage = damage;
        this.damage = damage;

        this.knockbackForce = knockbackForce;

        this.canBounce = canBounce;
    }

    void update(float dt) {
        // only update if active
        if (!active) return;

        super.update(dt);

        // if stayed in the same position for too long, projectile should disappear after set time
        if (getX() == lastIntX && getY() == lastIntY) {
            setStationaryTime(getStationaryTime() + dt);
        } else {
            setStationaryTime(0.0f);
            lastIntX = getX();
            lastIntY = getY();
        }

        // make projectile disappear after set time
        if (getStationaryTime() > STATIONARY_TIME_LIMIT) {
            reset();
        }
    }

    void draw() {
        // only draw if active
        if (!active) return;

        sprite.draw(getX(), getY());
        box.draw(getX(), getY());
    }

    @Override
    int getW() {
        return sprite.getSrcW();
    }

    @Override
    int getH() {
        return sprite.getSrcH();
    }

    void reset() {
        super.reset(0, 0);
        setActive(false);
        setStationaryTime(0.0f);
        lastIntX = 0;
        lastIntY = 0;
        damage = baseDamage;
    }

    float getStationaryTime() {
        return stationaryTime;
    }

    void setStationaryTime(float time) {
        this.stationaryTime = time;
    }

    float getDamage() {
        return damage;
    }

    float getKnockbackForce() {
        return knockbackForce;
    }

    boolean canBounce() {
        return canBounce;
    }

    void setOwner(CharacterBody owner) {
        this.owner = owner;
    }

    CharacterBody getOwner() {
        return owner;
    }
}
final class PlasmaShooter<T extends Bullet> extends Shooter<T> {

    boolean isStrong;

    PlasmaShooter(int x, int y, CharacterBody owner, Supplier<T> bulletFactory, float shooterDamage, float bulletImpulse) {
        super(x, y, owner, bulletFactory, shooterDamage, bulletImpulse);
        isStrong = false;
    }

    void updateByParent(float dt, int x, int y, float targetX, float targetY) {
        super.updateByParent(dt, x, y, targetX, targetY);
    }

    void draw() {
        super.draw();
    }

    @Override
    void modifyBullet(T bullet) {
        if (bullet instanceof Plasma) {
            if (isStrong()) {
                ((Plasma) bullet).makeStrong();
            }
        }
    }

    boolean isStrong() {
        return isStrong;
    }

    void setIsStrong(boolean value) {
        isStrong = value;

        // damage already modified in bullet
        bulletImpulse = isStrong ? baseBulletImpulse * 1.5 : baseBulletImpulse;
    }
}
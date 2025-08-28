import java.util.ArrayList;
import java.util.List;

public final class BulletManager<T extends Bullet> {

    private final BulletPool<T> bulletPool;
    private final List<T> activeBullets = new ArrayList<>();

    public BulletManager(BulletPool bulletPool) {
        this.bulletPool = bulletPool;
    }

    public T spawnBullet(int x, int y, float ax, float ay) {
        // spawns new bullet from the pool
        T bullet = bulletPool.getBullet(x, y);
        if (bullet != null) {
            bullet.addForce(new PVector(ax, ay));
            activeBullets.add(bullet);
        }
        return bullet;
    }

    public void update(float dt) {
        // update only active bullets
        for (int i = activeBullets.size() - 1; i >= 0; i--) {
            T bullet = activeBullets.get(i);
            bullet.update(dt);
            if (!bullet.isActive()) activeBullets.remove(i);
        }
    }

    public void draw() {
        // draw only active bullets
        for (T bullet : activeBullets) {
            bullet.draw();
        }
    }

    public void cleanupOffScreen(Camera camera) {
        // clear off screen bullets and recycle them
        // cleared with a margin - so its not immediately cleared right when hitting the edge

        for (int i = activeBullets.size() - 1; i >= 0; i--) {
            T bullet = activeBullets.get(i);

            if (!Globals.isOnScreen(camera, bullet.getX(), bullet.getY(), bullet.getW(), bullet.getH())) {
                activeBullets.remove(i);
                bulletPool.recycleBullet(bullet);
            }
        }
    }

    public List<T> getActiveBullets() {
        // used for collision for active bullets only
        return activeBullets;
    }
}

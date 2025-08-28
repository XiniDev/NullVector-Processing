import java.util.ArrayList;
import java.util.List;
import java.util.function.Supplier;

class BulletPool<T extends Bullet> {
    private static final int MAX_BULLETS = 50;
    private final List<T> pool = new ArrayList<>(MAX_BULLETS);
    private final Supplier<T> factory;

    BulletPool(Supplier<T> factory) {
        this.factory = factory;
        // pooling by pre-creating bullets
        for (int i = 0; i < MAX_BULLETS; i++) {
            T bullet = factory.get();
            bullet.setActive(false);
            pool.add(bullet);
        }
    }

    T getBullet(int x, int y) {
        // get an inactive bullet from the pool unless all bullets are used
        for (T bullet : pool) {
            if (!bullet.isActive()) {
                bullet.getBullet(x, y);
                return bullet;
            }
        }
        return null;
    }

    void recycleBullet(T bullet) {
        // recycle a bullet back into the pool so it can be reused
        bullet.reset();
    }
}
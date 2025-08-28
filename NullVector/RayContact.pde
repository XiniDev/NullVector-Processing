final class RayContact extends Contact {

    Ray ray;
    PVector intersection;

    RayContact(Ray ray, RigidBody rb2, PVector intersection) {
        super(null, rb2, 0, null, 0);
        this.ray = ray;
        this.intersection = intersection;
    }

    void resolve() {
        if (rb2 instanceof Platform) {
            ray.addIntersectingPlatform(intersection, (Platform) rb2);
        }
    }
}
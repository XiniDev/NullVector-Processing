final class Drag extends ForceGenerator {

    // coefficients for linear part (b) and quadratic part (c) for drag
    private float b;
    private float c;

    Drag(float b, float c) {
        this.b = b;
        this.c = c;
    }

    @Override
    void updateForce(RigidBody rb, float dt) {
        // no drag for infinite mass
        if (rb.invMass <= 0) return;

        PVector v = rb.getVelocity();

        // no drag if velocity too small
        float speed = v.mag();
        if (speed < 1e-6f) return;

        // get direction by normalising the velocity
        PVector dragDir = v.copy();
        dragDir.normalize();

        // equation of drag:
        // F_drag = - b * v - c * |v| * v
        float linear = b * speed;
        float quadratic = c * (speed * speed);
        float dragMag = linear + quadratic;

        // total drag force vector
        PVector dragForce = dragDir.mult(-dragMag);

        rb.addForce(dragForce);
    }
}

final class Gravity extends ForceGenerator {

    private final static float GRAVITY_SCALAR = 1.0f;
    private PVector gravity;

    Gravity(PVector gravity) {
        this.gravity = gravity;
    }

    @Override
    void updateForce(RigidBody rb, float dt) {
        //apply mass-scaled force to the rigidBody
        PVector resultingForce = gravity.copy();
        resultingForce.mult(rb.getMass() * GRAVITY_SCALAR);
        rb.addForce(resultingForce);
    }
}
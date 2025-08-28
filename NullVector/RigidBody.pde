abstract class RigidBody extends Entity {

    // physics
    PVector velocity;
    PVector acceleration;
    PVector forceAccumulator;
    float invMass;
    float restitution;
    float friction;

    // collision
    BoxCollider box;

    // is affected by gravity
    private boolean affectedByGravity;

    RigidBody(int x, int y, float mass, BoxCollider box) {
        super(x, y);
        velocity = new PVector(0, 0);
        acceleration = new PVector(0, 0);
        forceAccumulator = new PVector(0, 0);

        // mass is used instead of invMass as parameter so that its more intuitive
        // so its not inversed when tweaking
        if (mass == 0.0f) this.invMass = 0.0f;
        else this.invMass = 1 / mass;

        this.restitution = 0.0f;
        this.friction = 10.0f;

        // default affected by natural forces (some aren't)
        affectedByGravity = true;

        this.box = box;
        // this.box.debugMode();
    }

    PVector getVelocity() {
        return velocity;
    }

    float getMass() {
        return 1 / invMass;
    }

    float getRestitution() {
        return restitution;
    }

    void addForce(PVector force) {
        // all y forces are reversed because of how processing handles y axis
        forceAccumulator.add(new PVector(force.x, -force.y));
    }

    void integrate(float dt) {
        // no integrate on infinite mass
        if (invMass <= 0.0f) return;

        // add accumulated force (considering mass)
        PVector resultingAcceleration = forceAccumulator.copy();
        resultingAcceleration.mult(invMass);

        // external acceleration doesn't account for mass for ease of tweaking values (especially for movement)
        resultingAcceleration.add(new PVector(acceleration.x, -acceleration.y));

        // update velocity with acceleration with delta time
        // (using semi-implicit Euler: so this is done before position update)
        velocity.add(resultingAcceleration.mult(dt));

        // apply damping with delta time
        float dampingFactor = 1 / (1 + (dt * friction));
        velocity.x *= dampingFactor;

        // then update position based on velocity
        position.add(velocity);

        // clear accumulator
        forceAccumulator.x = 0;
        forceAccumulator.y = 0; 
    }

    void update(float dt) {
        super.update(dt);
        integrate(dt);
    }

    void reset(int x, int y) {
        // reset forces and position if needed
        setPosition(x, y);
        velocity.set(0, 0);
        acceleration.set(0, 0);
        forceAccumulator.set(0, 0);
    }

    @Override
    int getW() {
        return getBoxW();
    }

    @Override
    int getH() {
        return getBoxH();
    }

    int getBoxW() {
        return box.getBoxW();
    }

    int getBoxH() {
        return box.getBoxH();
    }

    int getBoxXEnd() {
        return getBoxX() + box.getBoxW();
    }

    int getBoxYEnd() {
        return getBoxY() + box.getBoxH();
    }

    int getBoxX() {
        return getX() + box.getBoxOffsetX();
    }

    int getBoxY() {
        return getY() + box.getBoxOffsetY();
    }

    float getBoxXf() {
        return getXf() + box.getBoxOffsetX();
    }

    float getBoxYf() {
        return getYf() + box.getBoxOffsetY();
    }

    boolean isAffectedByGravity() {
        return affectedByGravity;
    }

    void setAffectedByGravity(boolean effect) {
        affectedByGravity = effect;
    }

    void isNotAffectedByGravity() {
        affectedByGravity = false;
    }
}
class Contact {

    RigidBody rb1;
    RigidBody rb2;

    // coefficient of restitution
    float restitution;

    // direction of contact from rb1 (normal of rb1 - rb2)
    PVector contactNormal;

    // penetration size
    float penetration;

    Contact(RigidBody rb1, RigidBody rb2, float restitution, PVector contactNormal, float penetration) {
        this.rb1 = rb1;
        this.rb2 = rb2;
        this.restitution = restitution;
        this.contactNormal = contactNormal;
        this.penetration = penetration;
    }

    void resolve() {
        resolvePosition();
        resolveVelocity();
    }

    void resolvePosition() {
        // push out the intersecting bodies so they are no longer penetrating
        float totalInverseMass = rb1.invMass + rb2.invMass;
        if (totalInverseMass <= 0) return;

        // distribute the correction proportionally to inverse mass
        float correctionMagnitude = penetration / totalInverseMass;
        // the direction is along contactNormal
        PVector correction = contactNormal.copy();
        correction.mult(correctionMagnitude);

        // move bodies against normal (sub rb2 for opposite direction)
        PVector rb1Move = correction.copy();
        rb1Move.mult(rb1.invMass);

        PVector rb2Move = correction.copy();
        rb2Move.mult(rb2.invMass);

        rb1.position.add(rb1Move);
        rb2.position.sub(rb2Move);
    }

    float calculateSeparatingVelocity() {
        PVector relativeVelocity = rb1.velocity.copy();
        relativeVelocity.sub(rb2.velocity);
        return relativeVelocity.dot(contactNormal);
    }

    void resolveVelocity() {
        if (rb1 instanceof Rock && rb2 instanceof Platform) {
            ((Rock) rb1).bounce();
        }
        if (rb1 instanceof DropperBall && rb2 instanceof Platform) {
            ((DropperBall) rb1).bounce();
        }

        if (restitution == 0) {
            // if has finite mass, remove velocity in normal direction
            if (rb1.invMass > 0) {
                float normalVel1 = rb1.velocity.dot(contactNormal);
                rb1.velocity.sub(PVector.mult(contactNormal, normalVel1));
            }

            if (rb2.invMass > 0) {
                float normalVel2 = rb2.velocity.dot(contactNormal);
                rb2.velocity.sub(PVector.mult(contactNormal, normalVel2));
            }

            // set grounded property for CharacterBodies
            if (rb1 instanceof CharacterBody) ((CharacterBody) rb1).isGrounded = true;
            if (rb2 instanceof CharacterBody) ((CharacterBody) rb2).isGrounded = true;

            return;
        }

        // find the velocity in the direction of the contact
        float separatingVelocity = calculateSeparatingVelocity();

        // if already moving apart then do nothing
        if (separatingVelocity > 0) return;

        // calculate new separating velocity and change required to achieve it
        float newSepVelocity = -separatingVelocity * restitution;
        float deltaVelocity = newSepVelocity - separatingVelocity;

        // apply change in velocity to each object in proportion inverse mass (higher actual mass -> less vel change)
        float totalInverseMass = rb1.invMass + rb2.invMass;
        if (totalInverseMass <= 0) return;

        // calculate impulse to apply and amount of impulse per unit of inverse mass
        float impulse = deltaVelocity / totalInverseMass;
        PVector impulsePerIMass = PVector.mult(contactNormal.copy(), impulse);

        // calculate and apply both rb1 and rb2 impulse (sub rb2 for opposite direction)
        rb1.velocity.add(PVector.mult(impulsePerIMass.copy(), rb1.invMass));
        rb2.velocity.sub(PVector.mult(impulsePerIMass.copy(), rb2.invMass));
    }
}
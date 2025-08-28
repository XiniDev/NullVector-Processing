abstract class CharacterBody extends RigidBody {

    CharacterProperties properties;

    int moveDirection;
    // default all character bodies can jump
    boolean canJump;

    int jumpState; // 0 is none, 1 is start, 2 is jumping, 3 is falling, 4 is coyote
    int coyoteTime;

    // need this for character bodies because they might have different physics to normal rigidbodies
    boolean isGrounded;
    boolean groundCheck;

    // sprite rendering
    AnimatedSprite sprite;

    float health;
    float maxHealth;
    boolean isDamaged;
    int damageBlinkMax;
    int damageBlinkCounter;
    int damageBlinkNumMax;
    int damageBlinkNumCounter;
    boolean dead;

    Platform lastPlatform;
    Graph<Waypoint> waypointGraph;

    CharacterBody(int x, int y, float invMass,
                  BoxCollider box,
                  AnimatedSprite sprite,
                  CharacterProperties props,
                  float health,
                  Graph<Waypoint> waypointGraph) {
        super(x, y, invMass, box);
        this.properties = props;
        moveDirection = 0;
        canJump = true;
        jumpState = 0;
        coyoteTime = 0;
        isGrounded = false;
        groundCheck = false;
        this.sprite = sprite;
        this.health = health;
        maxHealth = health;
        isDamaged = false;
        damageBlinkMax = 2;
        damageBlinkCounter = 0;
        damageBlinkNumMax = 3;
        damageBlinkNumCounter = 0;
        dead = false;

        lastPlatform = null;
        this.waypointGraph = waypointGraph;

        // character bodies always on top of background
        layer = 10;
    }

    void update(float dt) {
        // damage blink update
        if (isDamaged) {
            if (damageBlinkCounter >= damageBlinkMax) {
                damageBlinkCounter = 0;
                if (damageBlinkNumCounter >= damageBlinkNumMax) {
                    damageBlinkNumCounter = 0;
                    isDamaged = false;
                } else {
                    damageBlinkNumCounter++;
                }
            } else {
                damageBlinkCounter++;
            }
        }

        // movement calculation for x
        // find the target velocity to lerp towards
        float targetVelX = moveDirection * properties.maxVelX;
        targetVelX = lerp(velocity.x, targetVelX, 0.6f);

        // get the difference between target velocity and velocity now
        float velDiffX = targetVelX - velocity.x;

        // set acceleration using the vel diff
        acceleration.x = velDiffX * properties.accelSpeed;

        // hflip for sprite facing direction
        if (moveDirection < 0) {
            sprite.setHFlip(true);
        }
        if (moveDirection > 0) {
            sprite.setHFlip(false);
        }

        // movement calculation for y
        // if ground check is true, meaning it is at least on top of one platform,
        // then make grounded, and change ground check back to false for next iteration
        if (!canJump) {
            super.update(dt);
            return;
        }

        if (groundCheck) {
            isGrounded = true;
            groundCheck = false;
        } else isGrounded = false;

        // reset y acceleration
        acceleration.y = 0.0f;

        // jumping calculation by states of jumping
        if (jumpState == 1) {
            // if at the start of jump, then give impulse on jump force
            jumpState = 2;
            isGrounded = false;
            acceleration.y += properties.jumpForce;
            velocity.y = 0.0f;
        } else if (jumpState == 2) {
            // if jumping, then change jump state to next after peak of jump (vel y is negative)
            if (velocity.y < 0.0f) jumpState = 3;

            // weaker gravity so jump feels like hanging mid-air (within threshold) - more comfortable jumps to the eye
            if (abs(velocity.y) < properties.jumpHangThreshold) forceAccumulator.y *= 0.75f;
        } else if (jumpState == 3 || jumpState == 4) {
            // if jump state is falling, then alter the hang times
            // hang time exists for falling state too, but gravity can be increased on fall to give a less floaty jump
            if (abs(velocity.y) < properties.jumpHangThreshold) forceAccumulator.y *= 0.75f;
            else forceAccumulator.y *= 1.5f;

            // if in coyote jump state, change back to falling when hitting max coyote time
            if (jumpState == 4 && coyoteTime == properties.maxCoyoteTime) jumpState = 3;
        }

        // if grounded, then y vel should be 0 to stop jitter
        // because this happens before the rigidbody update,
        // so it removes any form of y acceleration (by gravity etc)
        // also change state of jumping to none
        // also resets coyote time
        if (isGrounded) {
            jumpState = 0;
            forceAccumulator.y = 0.0f;
            velocity.y = 0.0f;
            coyoteTime = 0;
        } else {
            // transition to falling state if falling off platform (no jump state, but not grounded)
            if (jumpState == 0) jumpState = 4;

            // increment coyote time when not grounded
            // coyote time gives grace for the player when jumping off a ledge
            // so they don't feel like they failed a ledge jump accidentally
            coyoteTime++;
        }

        super.update(dt);
    }

    void draw() {
        // damage blink
        if (!isDamaged || damageBlinkNumCounter % 2 == 1) {
            sprite.draw(getX(), getY());
        }
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

    PVector getCenter() {
        return new PVector(getX() + getW() / 2, getY() + getH() / 2);
    }

    PVector getBoxCenter() {
        return new PVector(getBoxX() + getBoxW() / 2, getBoxY() + getBoxH() / 2);
    }

    boolean isGrounded() {
        return isGrounded;
    }

    boolean canJump() {
        return canJump;
    }

    void jump() {
        if ((jumpState == 0 || jumpState == 4) && (isGrounded || coyoteTime < properties.maxCoyoteTime)) jumpState = 1;
    }

    float getHealth() {
        return health;
    }

    void takeDamage(float damage) {
        isDamaged = true;
        health = damage >= health ? 0 : health - damage;
        if (health == 0) die();
    }

    void die() {
        dead = true;
        health = 0;
        dispose();
    }

    boolean isDead() {
        return dead;
    }

    boolean checkFallDeath(int y) {
        if (getY() > y) {
            takeDamage(health);
            return true;
        } else return false;
    }

    Platform getLastPlatform() {
        return lastPlatform;
    }

    void setLastPlatform(Platform lastPlatform) {
        this.lastPlatform = lastPlatform;
    }

    Waypoint findNearestWaypoint() {
        // nearest based on distance of current position to waypoint
        Waypoint nearest = null;
        float minDist = Float.MAX_VALUE;
        for (Waypoint wp : getWaypointGraph().getNodes()) {
            float dist = getBoxCenter().dist(wp.getPosition());
            if (dist < minDist) {
                minDist = dist;
                nearest = wp;
            }
        }
        return nearest;
    }

    Waypoint getCurrentWaypoint() {
        // Dirichlet Domains for waypoints
        // different to nearest because its based on x distance and also check if y is within the domain
        // also ensures that the waypoint is on the same platform the characterBody is on
        Waypoint current = null;
        float minXDist = Float.MAX_VALUE;
        for (Waypoint wp : getWaypointGraph().getNodes()) {
            if (getLastPlatform() != null && getLastPlatform() != wp.getPlatform()) continue;

            float xDist = abs(getBoxCenter().x - wp.getXf());
            boolean setCondition = false;
            if (xDist < minXDist) {
                setCondition = true;
            } else if (xDist == minXDist) {
                if (getBoxCenter().y >= wp.getDomainHeight() && getBoxCenter().y <= wp.getPlatform().getY()) {
                    setCondition = true;
                }
            }

            if (setCondition) {
                minXDist = xDist;
                current = wp;
            }
        }
        return current;
    }

    Graph<Waypoint> getWaypointGraph() {
        return waypointGraph;
    }

    abstract float getDamage();

    abstract void addEntities(List<Entity> entities);

    abstract boolean isEnemy();
}
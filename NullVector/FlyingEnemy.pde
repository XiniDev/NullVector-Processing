abstract class FlyingEnemy extends Enemy {

    int hoverHeight;

    int wallRayMargin;
    Ray wallRay;
    Ray floorRay;

    boolean isAdjustingHeight;
    Waypoint restLocation;

    boolean isBacktracking;

    FlyingEnemy(int x, int y, float mass,
                BoxCollider box,
                AnimatedSprite sprite,
                CharacterProperties props,
                float health, int attackSpeed, int attackDelay, int attackRange, int wakeRange,
                int idleFrameY, int attackFrameY, int asleepFrameY, int awakenFrameY, int toSleepFrameY,
                Player target, Graph<Waypoint> waypointGraph,
                int hoverHeight) {
        super(x, y, mass,
              box,
              sprite,
              props,
              health, attackSpeed, attackDelay, attackRange, wakeRange,
              idleFrameY, attackFrameY, asleepFrameY, awakenFrameY, toSleepFrameY,
              target, waypointGraph);
        canJump = false;

        this.hoverHeight = hoverHeight;

        wallRayMargin = 4;
        wallRay = new Ray(0, 0, getBoxH() - wallRayMargin, this);
        floorRay = new Ray(0, 0, Globals.STRIDE * Globals.MAX_LEVEL_HEIGHT, this);

        isAdjustingHeight = false;
        restLocation = null;

        isBacktracking = false;
    }

    void update(float dt) {
        super.update(dt);

        if (isAdjustingHeight && restLocation != null) {
            if (currWP == restLocation) {
                isAdjustingHeight = false;
            }
        }

        if (!isAdjustingHeight) {
            restLocation = null;
        }

        if (isAsleep()) {
            setAffectedByGravity(true);
        }

        int facingDirection = sprite.getHFlip() ? -1 : 1;
        wallRay.updateByParent(dt, (int) (getCenter().x + (getBoxH() / 2 + Globals.STRIDE / 2) * facingDirection), (int) getBoxY() + 2, 0, 1);
        floorRay.updateByParent(dt, (int) getCenter().x, (int) getCenter().y, 0, 1);
    }

    @Override
    boolean canUpdateNextWP() {
        return !isBacktracking;
    }

    @Override
    float reconfigurePath(PVector nextPos) {
        float xDiff = super.reconfigurePath(nextPos);
        if (xDiff == 0.0f) {
            if (nextWP.getY() < getY()) {
                isBacktracking = true;
                nextWP = currWP;
                xDiff = nextPos.x - getBoxCenter().x;
            } else {
                isBacktracking = false;
            }
        }
        return xDiff;
    }

    void moveWithDirection(int direction) {
        moveDirection = direction;

        if (!isAsleep() && !isWaking()) {
            if (isAffectedByGravity()) {
                isNotAffectedByGravity();
            }

            if (isAdjustingHeight && restLocation != null) {
                movementY(restLocation.getY(), restLocation.getY());
            } else {
                movementY(target.getY(), target.getBoxCenter().y);
            }

            if (floorRay.isIntersectingPlatforms()) {
                Platform lastPlatform = floorRay.getNearestPlatform();
                if (lastPlatform != null) setLastPlatform(lastPlatform);
            }
        }
    }

    void movementY(float targetY, float targetCenterY) {
        if (targetY - hoverHeight <= getY()) acceleration.y = 1f;
        else acceleration.y = -1f;

        if (wallRay.isIntersectingPlatforms()) {
            if (targetCenterY <= getBoxCenter().y) acceleration.y = 1;
            else acceleration.y = -1;
        }
    }

    void draw() {
        super.draw();
    }

    void die() {
        super.die();
        wallRay.dispose();
        floorRay.dispose();
    }

    void sleep() {
        if (!floorRay.isIntersectingPlatforms()) {
            isAdjustingHeight = true;
            restLocation = findNearestWaypoint();
        }

        if (restLocation != null) movementUpdate(restLocation);

        if (!isAdjustingHeight) {
            super.sleep();
        }
    }

    void addEntities(List<Entity> entities) {
        entities.add(this);
        entities.add(wallRay);
        entities.add(floorRay);
    }
}
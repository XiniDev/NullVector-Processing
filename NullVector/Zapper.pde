final class Zapper extends Enemy {

    Shooter shooter;
    int shooterOffsetX;
    int shooterOffsetY;

    float aggroChance;
    boolean isAggro;
    int aggroRollCD;
    int aggroRollCounter;
    Waypoint aggroPrevWP;
    Waypoint aggroWP;

    Zapper(int x, int y, Player target, Graph<Waypoint> waypointGraph) {
        super(x, y, 10.0f,
              new BoxCollider(10, 14, 3, 2),
              new AnimatedSprite("assets/sprites/zapper.png", 16, 16, 16, 16, 6, new boolean[]{false, true, false, true, true}),
              new CharacterProperties(12.0f, 2.0f, 300.0f, 2.0f, 10),
              12.0f, 100, 3, 140, 200,
              0, 1, 2, 3, 4,
              target, waypointGraph);

        shooterOffsetX = 7;
        shooterOffsetY = 8;
        shooter = new Shooter((int) x + shooterOffsetX, (int) y + shooterOffsetY, this, () -> new Zap(0, 0), 1.0f, 100.0f);

        // every x seconds it has a chance of aggroing while attacking
        // when it aggros it moves towards the player by 1 tile and continues shooting
        aggroChance = 0.5;
        isAggro = false;
        aggroRollCD = 2 * (int) frameRate;
        aggroRollCounter = 0;
        aggroPrevWP = null;
        aggroWP = null;
    }

    void update(float dt) {
        super.update(dt);

        updateShooter(dt);
    }

    @Override
    boolean isInSpecialState() {
        return isAggro();
    }

    @Override
    void specialUpdate() {
        movementUpdate(target.getWaypoint());
        aggroWP = currWP;
        if (aggroPrevWP != aggroWP) {
            aggroPrevWP = null;
            aggroWP = null;
            setIsAggro(false);
        }
    }

    @Override
    boolean canUpdateNextWP() {
        return isGrounded();
    }

    @Override
    boolean canTraverse(Waypoint current, Waypoint neighbor) {
        float jumpDist = properties.accelSpeed * properties.maxVelX * properties.jumpForce / 100;
        float dist = current.getPosition().dist(neighbor.getPosition());
        if (dist > jumpDist) return false;
        else return true;
    }

    void moveWithDirection(int direction) {
        // if attacking or in range stand still
        if (!isAggro() && (isAttacking || metAttackCondition())) {
            moveDirection = 0;
            if (target.getX() > this.getX()) sprite.setHFlip(false);
            else if (target.getX() < this.getX()) sprite.setHFlip(true);

            rollAggro();
        } else {
            moveDirection = direction;

            // if zapper is continuously moving forwards and the next platform is higher or far
            if (nextWP != null && currWP != null &&
                (nextWP.getY() < currWP.getY() ||
                 abs(nextWP.getXCoord() - currWP.getXCoord()) > 1)) {
                jump();
            }
        }
    }

    void rollAggro() {
        if (aggroRollCounter >= aggroRollCD) {
            if (Math.random() < aggroChance) {
                setIsAggro(true);
                aggroPrevWP = currWP;
            }
            aggroRollCounter = 0;
        } else {
            if (!isAggro()) {
                aggroRollCounter++;
            }
        }
    }

    void updateShooter(float dt) {
        PVector pos = new PVector(getX() + shooterOffsetX, getY() + shooterOffsetY);
        // can only shoot forwards
        int xSign = sprite.getHFlip() ? -1 : 1;
        shooter.updateByParent(dt, (int) pos.x, (int) pos.y, pos.x + (10 * xSign), pos.y);
        shooter.cleanupOffScreen(target.camera);
    }

    void draw() {
        super.draw();
    }

    void die() {
        super.die();
        shooter.dispose();
    }

    boolean isAggro() {
        return isAggro;
    }

    void setIsAggro(boolean value) {
        this.isAggro = value;
    }

    boolean isInAttackRange() {
        boolean superRange = super.isInAttackRange();
        return superRange && (target.getLastPlatform() == getLastPlatform());
    }

    boolean metAttackCondition() {
        return isInAttackRange();
    }

    void attack() {
        shooter.shoot();
    }

    float getDamage() {
        return shooter.getDamage();
    }

    void addEntities(List<Entity> entities) {
        entities.add(this);
        shooter.addEntities(entities);
    }
}
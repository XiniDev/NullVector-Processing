import java.util.List;

final class Zorp extends FlyingEnemy {

    int phase;
    boolean isPhaseSwitching;
    int phaseSwitchFrameY;

    int phase1IdleFrameY;
    int phase2IdleFrameY;

    int phase1AttackFrameY;
    int phase2AttackFrameY1;
    int phase2AttackFrameY2;

    int phase1AsleepFrameY;
    int phase2AsleepFrameY;

    int phase1AwakenFrameY;
    int phase2AwakenFrameY;

    int phase1ToSleepFrameY;
    int phase2ToSleepFrameY;

    PlasmaShooter plasmaShooter;

    float phase2TeleportChance;

    Zorp(int x, int y, Player target, Graph<Waypoint> waypointGraph) {
        super(x, y, 40.0f,
              new BoxCollider(28, 28, 2, 2),
              new AnimatedSprite("assets/sprites/zorp.png", 32, 32, 32, 32, 6, new boolean[]{false, true, false, false, true, true, true, true, false, true, true, true}),
              new CharacterProperties(16.0f, 2.0f, 0.0f, 0.0f, 0),
              40.0f, 20, 2, 70, 200,
              0, 6, 3, 4, 5,
              target, waypointGraph,
              Globals.STRIDE / 2);

        phase = 1;
        isPhaseSwitching = false;

        // animation frames
        phaseSwitchFrameY = 1;

        phase1IdleFrameY = 0;
        phase2IdleFrameY = 2;

        phase1AttackFrameY = 6;
        phase2AttackFrameY1 = 7;
        phase2AttackFrameY2 = 11;

        phase1AsleepFrameY = 3;
        phase2AsleepFrameY = 8;

        phase1AwakenFrameY = 4;
        phase2AwakenFrameY = 9;

        phase1ToSleepFrameY = 5;
        phase2ToSleepFrameY = 10;

        idleFrameY = phase1IdleFrameY;
        attackFrameY = phase1AttackFrameY;
        asleepFrameY = phase1AsleepFrameY;
        awakenFrameY = phase1AwakenFrameY;
        toSleepFrameY = phase1ToSleepFrameY;

        plasmaShooter = new PlasmaShooter((int) getBoxCenter().x, (int) getBoxCenter().y, this, () -> new Plasma(0, 0), 1.0f, 100.0f);

        phase2TeleportChance = 0.2;
    }

    void update(float dt) {
        super.update(dt);

        if (phase == 1) {
            if (health <= maxHealth / 2) {
                setPhaseSwitching(true);
            }
        }

        updatePlasmaShooter(dt);
    }

    @Override
    boolean isInSpecialState() {
        return isPhaseSwitching();
    }

    @Override
    void specialUpdate() {
        if (phase == 1) {
            phase = 2;
            sprite.playNoRepeatAnimation(phase2IdleFrameY, phaseSwitchFrameY);
        } else if (phase == 2) {
            if (sprite.getFrameY() == phase2IdleFrameY) {
                // set phase 2 animation
                idleFrameY = phase2IdleFrameY;
                attackFrameY = phase2AttackFrameY1;
                asleepFrameY = phase2AsleepFrameY;
                awakenFrameY = phase2AwakenFrameY;
                toSleepFrameY = phase2ToSleepFrameY;

                // phase 2 increased stats
                attackSpeed = 10;
                attackRange = 90;

                // phase 2 plasma shooter becomes stronger
                plasmaShooter.setIsStrong(true);

                // phase 2 hitbox size reduction
                box.setBoxSize(24, 24, 4, 4);
                wallRay.setLength(getBoxH() - wallRayMargin);

                setPhaseSwitching(false);
            }
        }
    }

    void moveWithDirection(int direction) {
        if (isAttacking || isInAttackRange()) {
            moveDirection = 0;
        } else {
            super.moveWithDirection(direction);
        }
    }

    void startAttack() {
        if (phase == 1) {
            attackFrameY = phase1AttackFrameY;
        } else if (phase == 2) {
            // if attack managed to be started during blocked line of sight
            // it means it hit the teleport chance during blocked line of sight
            // so must use teleport
            if (plasmaShooter.getSightBlocked() || Math.random() < phase2TeleportChance) {
                attackFrameY = phase2AttackFrameY2;
            } else {
                attackFrameY = phase2AttackFrameY1;
            }
        }
        super.startAttack();
    }

    void updatePlasmaShooter(float dt) {
        plasmaShooter.updateByParent(dt, (int) getBoxCenter().x, (int) getBoxCenter().y, target.getBoxCenter().x, target.getBoxCenter().y);
        plasmaShooter.cleanupOffScreen(target.camera);
    }

    boolean isPhaseSwitching() {
        return isPhaseSwitching;
    }

    void setPhaseSwitching(boolean value) {
        this.isPhaseSwitching = value;
    }

    void phase2Teleport() {
        List<Waypoint> neighbors = getWaypointGraph().getNeighbors(target.getWaypoint());
        if (neighbors != null) {
            Waypoint neighbor = neighbors.get((int) (Math.random() * neighbors.size()));
            reset(neighbor.getX() - Globals.WP_BUFFER, neighbor.getY() + Globals.WP_BUFFER - getBoxH());
            currWP = neighbor;
        }
    }

    void draw() {
        super.draw();
    }

    void die() {
        super.die();
        plasmaShooter.dispose();
    }

    boolean isInAttackRange() {
        boolean superRange = super.isInAttackRange();
        return superRange && (!plasmaShooter.getSightBlocked() || (phase == 2 && Math.random() < phase2TeleportChance));
    }

    boolean metAttackCondition() {
        return isInAttackRange();
    }

    void attack() {
        if (phase == 2 && attackFrameY == phase2AttackFrameY2) {
            phase2Teleport();
        } else {
            plasmaShooter.shoot();
        }
    }

    float getDamage() {
        return plasmaShooter.getDamage();
    }

    void addEntities(List<Entity> entities) {
        super.addEntities(entities);
        plasmaShooter.addEntities(entities);
    }
}
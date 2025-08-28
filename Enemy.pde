import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

abstract class Enemy extends CharacterBody {

    Player target;

    boolean isAttacking;
    boolean isWaking;
    boolean isAsleep;

    int attackSpeed;
    int attackSpeedCounter;
    int attackDelay;
    int attackDelayCounter;
    int attackRange;
    int wakeRange;

    int idleFrameY;
    int attackFrameY;
    int asleepFrameY;
    int awakenFrameY;
    int toSleepFrameY;

    List<Waypoint> currentPath;
    int currentWaypointIndex;
    Waypoint currWP;
    Waypoint prevWP;
    Waypoint targetPrevWP;
    Waypoint nextWP;
    Waypoint paintedWP;

    Enemy(int x, int y, float mass,
          BoxCollider box,
          AnimatedSprite sprite,
          CharacterProperties props,
          float health, int attackSpeed, int attackDelay, int attackRange, int wakeRange,
          int idleFrameY, int attackFrameY, int asleepFrameY, int awakenFrameY, int toSleepFrameY,
          Player target, Graph<Waypoint> waypointGraph) {
        super(x, y, mass, box, sprite, props, health, waypointGraph);

        this.target = target;

        isAttacking = false;
        isWaking = false;
        isAsleep = true;

        this.attackSpeed = attackSpeed;
        attackSpeedCounter = 0;
        this.attackDelay = attackDelay * (int) frameRate / Globals.ANIMATION_FPS;
        attackDelayCounter = 0;
        this.attackRange = attackRange;
        this.wakeRange = wakeRange;

        this.idleFrameY = idleFrameY;
        this.attackFrameY = attackFrameY;
        this.asleepFrameY = asleepFrameY;
        this.awakenFrameY = awakenFrameY;
        this.toSleepFrameY = toSleepFrameY;

        // start being asleep
        sprite.setAnimation(asleepFrameY);

        currentPath = null;
        currentWaypointIndex = 0;
        currWP = findNearestWaypoint();
        prevWP = currWP;
        targetPrevWP = null;
        nextWP = null;
        paintedWP = null;
    }

    void update(float dt) {
        if (isInSpecialState()) {
            specialUpdate();
        } else if (!isInWakeRange()) {
            sleep();
        } else if (isAsleep()) {
            awaken();
        } else if (isWaking() && sprite.getFrameY() == idleFrameY) {
            isWaking = false;
            movementUpdate(target.getWaypoint());
            attackUpdate();
        } else if (!isWaking()) {
            movementUpdate(target.getWaypoint());
            attackUpdate();
        }

        super.update(dt);
    }

    void draw() {
        super.draw();
        if (Globals.getDebug()) showPath();
    }

    boolean isInSpecialState() {
        // override for special states in enemies
        return false;
    }

    void specialUpdate() {};

    boolean pathNeedsUpdate(Waypoint targetWP) {
        return targetWP != targetPrevWP || currWP != prevWP;
    }

    List<Waypoint> computePath(Waypoint start, Waypoint goal) {
        // A* search
        List<Waypoint> closedSet = new ArrayList<>();
        List<Waypoint> openSet = new ArrayList<>();
        openSet.add(start);

        Map<Waypoint, Waypoint> cameFrom = new HashMap<>();
        Map<Waypoint, Float> gScore = new HashMap<>();
        Map<Waypoint, Float> fScore = new HashMap<>();

        // initialise scores
        for (Waypoint wp : getWaypointGraph().getNodes()) {
            gScore.put(wp, Float.MAX_VALUE);
            fScore.put(wp, Float.MAX_VALUE);
        }
        gScore.put(start, 0f);
        fScore.put(start, heuristicCostEstimate(start, goal));

        // algorithm
        while (!openSet.isEmpty()) {
            Waypoint current = openSet.get(0);
            for (Waypoint wp : openSet) {
                if (fScore.get(wp) < fScore.get(current)) {
                    current = wp;
                }
            }

            if (current.equals(goal)) {
                return reconstructPath(cameFrom, current);
            }

            openSet.remove(current);
            closedSet.add(current);

            for (Waypoint neighbor : getWaypointGraph().getNeighbors(current)) {
                if (!canTraverse(current, neighbor)) continue;

                if (closedSet.contains(neighbor)) continue;

                float tentativeGScore = gScore.get(current) + current.getPosition().dist(neighbor.getPosition());

                if (!openSet.contains(neighbor)) {
                    openSet.add(neighbor);
                } else if (tentativeGScore >= gScore.get(neighbor)) {
                    continue;
                }

                cameFrom.put(neighbor, current);
                gScore.put(neighbor, tentativeGScore);
                fScore.put(neighbor, tentativeGScore + heuristicCostEstimate(neighbor, goal));
            }
        }

        return new ArrayList<>();
    }

    float heuristicCostEstimate(Waypoint a, Waypoint b) {
        // using euclidean distance for the A* search heuristic
        return a.getPosition().dist(b.getPosition());
    }

    List<Waypoint> reconstructPath(Map<Waypoint, Waypoint> cameFrom, Waypoint current) {
        List<Waypoint> totalPath = new ArrayList<>();
        totalPath.add(current);
        while (cameFrom.containsKey(current)) {
            current = cameFrom.get(current);
            totalPath.add(0, current);
        }
        return totalPath;
    }

    void showPath() {
        // debug show path
        if (currentPath == null || currentPath.isEmpty()) return;

        stroke(128, 0, 128);
        strokeWeight(2);

        for (int i = 0; i < currentPath.size() - 1; i++) {
            Waypoint wp1 = currentPath.get(i);
            Waypoint wp2 = currentPath.get(i + 1);
            line(wp1.getX(), wp1.getY(), wp2.getX(), wp2.getY());
        }

        strokeWeight(1);
    }

    void movementUpdate(Waypoint targetWP) {
        Waypoint wp = getCurrentWaypoint();

        // threshold of arriving at the waypoint is determined by width of character
        if (wp != null) {
            if (getBoxW() <= Globals.STRIDE) {
                if (abs(getBoxCenter().x - wp.getX()) < (Globals.STRIDE - getBoxW()) / 2) {
                    currWP = wp;
                }
            } else {
                // enemies like zorp are super large so they cannot use the method above
                if (currWP.getX() < wp.getX() && (getBoxX() >= wp.getX() - Globals.STRIDE / 2.0f)) {
                    currWP = wp;
                } else if (currWP.getX() > wp.getX() && (getBoxXEnd() <= wp.getX() + Globals.STRIDE / 2.0f)) {
                    currWP = wp;
                }
            }
        }

        // recompute path if need update
        if (pathNeedsUpdate(targetWP)) {
            prevWP = currWP;
            currentPath = computePath(currWP, targetWP);
            currentWaypointIndex = 1;
        }

        // only update nextWP if path exists or index is within bounds
        if (currentPath != null && !currentPath.isEmpty() && currentWaypointIndex < currentPath.size() && canUpdateNextWP()) {
            nextWP = currentPath.get(currentWaypointIndex);
        }

        if (nextWP == null) return;

        PVector nextPos = nextWP.getPosition();
        float xDiff = reconfigurePath(nextPos);

        if (paintedWP != null) paintedWP.setEnemyNextWP(false);
        paintedWP = nextWP;
        nextWP.setEnemyNextWP(true);

        int direction = (int) Math.signum((int) xDiff);

        // always move depending on xDiff no matter what
        moveWithDirection(direction);
    }

    boolean canUpdateNextWP() {
        return true;
    }

    float reconfigurePath(PVector nextPos) {
        float xDiff = nextPos.x - getBoxCenter().x;

        // for larger enemies
        if (getBoxW() > Globals.STRIDE) {
            // if there is no waypoint after the nextWP then use center for xDiff
            if (currentPath.size() <= 2) return xDiff;

            if (currWP.getX() < nextWP.getX()) {
                xDiff = (nextWP.getX() - Globals.STRIDE / 2.0f) - getBoxX();
            } else if (currWP.getX() > nextWP.getX()) {
                xDiff = (nextWP.getX() + Globals.STRIDE / 2.0f) - getBoxXEnd();
            }
        }
        return xDiff;
    }

    boolean canTraverse(Waypoint current, Waypoint neighbor) {
        return true;
    }

    abstract void moveWithDirection(int direction);

    void startAttack() {
        if (isAttacking) return;

        isAttacking = true;
        attackSpeedCounter = 0;
        attackDelayCounter = 0;
        sprite.playNoRepeatAnimation(idleFrameY, attackFrameY);
    }

    void attackUpdate() {
        // attack if too close to player
        // attack with delay
        if (!isAttacking()) {
            if (metAttackCondition() &&
                attackSpeedCounter >= attackSpeed) startAttack();
            else if (attackSpeedCounter < attackSpeed) attackSpeedCounter++;
        } else {
            if (attackDelayCounter < attackDelay) attackDelayCounter++;
            else {
                attackDelayCounter = 0;
                attack();
                isAttacking = false;
            }
        }
    }

    void sleep() {
        if (!isGrounded()) return;
        if (isAsleep()) return;

        isAsleep = true;
        moveDirection = 0;
        sprite.playNoRepeatAnimation(asleepFrameY, toSleepFrameY);
    }

    void awaken() {
        if (!isAsleep()) return;

        isAsleep = false;
        isWaking = true;
        sprite.playNoRepeatAnimation(idleFrameY, awakenFrameY);
    }

    boolean isAttacking() {
        return isAttacking;
    }

    boolean isAsleep() {
        return isAsleep;
    }

    boolean isWaking() {
        return isWaking;
    }

    boolean isInAttackRange() {
        PVector currPosition = position.copy();
        return PVector.dist(currPosition, target.position) - attackRange < 0;
    }

    boolean isInWakeRange() {
        PVector currPosition = position.copy();
        return PVector.dist(currPosition, target.position) - wakeRange < 0;
    }

    abstract boolean metAttackCondition();

    abstract void attack();

    abstract void addEntities(List<Entity> entities);

    boolean isEnemy() {
        return true;
    }
}
import java.util.ArrayList;
import java.util.List;

class Level {

    private List<Platform> platforms;
    private List<Platform> levelPlatforms;
    private Graph<Waypoint> waypointGraph;
    private int fallDeath;

    private List<Enemy> enemies;
    private Zorp zorp;

    public Level() {
        platforms = new ArrayList<>();
        levelPlatforms = new ArrayList<>();
        waypointGraph = new Graph<>();
        fallDeath = Integer.MAX_VALUE;
        enemies = new ArrayList<>();
    }

    public void generate(Player player) {
        Platform floor1 = new Platform(12, 23, 10, 11, Globals.STRIDE);
        Platform floor2 = new Platform(23, 26, 15, 8, Globals.STRIDE);
        Platform floor3 = new Platform(27, 23, 3, 1, Globals.STRIDE);
        Platform floor4 = new Platform(33, 22, 2, 1, Globals.STRIDE);
        Platform floor5 = new Platform(40, 24, 5, 1, Globals.STRIDE);
        Platform floor6 = new Platform(43, 21, 5, 1, Globals.STRIDE);
        Platform floor7 = new Platform(50, 22, 3, 1, Globals.STRIDE);
        Platform floor8 = new Platform(45, 27, 18, 7, Globals.STRIDE);

        Platform floor9 = new Platform(66, 27, 26, 7, Globals.STRIDE);
        Platform floor10 = new Platform(69, 22, 5, 1, Globals.STRIDE);
        Platform floor11 = new Platform(84, 22, 5, 1, Globals.STRIDE);
        Platform floor12 = new Platform(77, 24, 4, 1, Globals.STRIDE);

        Platform ceiling1 = new Platform(12, 11, 51, 7, Globals.STRIDE);
        Platform ceiling2 = new Platform(63, 11, 29, 5, Globals.STRIDE);

        Platform wall1 = new Platform(5, 11, 7, 23, Globals.STRIDE);
        Platform wall2 = new Platform(92, 11, 7, 23, Globals.STRIDE);

        platforms.add(floor1);
        platforms.add(floor2);
        platforms.add(floor3);
        platforms.add(floor4);
        platforms.add(floor5);
        platforms.add(floor6);
        platforms.add(floor7);
        platforms.add(floor8);

        platforms.add(floor9);
        platforms.add(floor10);
        platforms.add(floor11);
        platforms.add(floor12);

        levelPlatforms.addAll(platforms);

        platforms.add(ceiling1);
        platforms.add(ceiling2);

        platforms.add(wall1);
        platforms.add(wall2);

        generateWaypoints();

        fallDeath = (30 + 5) *  Globals.STRIDE;

        enemies.add(new Zapper(28, 22, player, getWaypointGraph()));
        enemies.add(new Zapper(37, 25, player, getWaypointGraph()));
        enemies.add(new Zapper(51, 24, player, getWaypointGraph()));
        enemies.add(new Zapper(71, 21, player, getWaypointGraph()));
        enemies.add(new Zapper(86, 21, player, getWaypointGraph()));
        enemies.add(new Dropper(33, 25, player, getWaypointGraph()));
        enemies.add(new Dropper(34, 21, player, getWaypointGraph()));
        enemies.add(new Dropper(45, 20, player, getWaypointGraph()));

        zorp = new Zorp(78, 22, player, getWaypointGraph());
        enemies.add(zorp);
    }

    private void generateWaypoints() {
        initNodes();
        initEdges();
    }

    private void initNodes() {
        for (Platform platform : levelPlatforms) {
            Waypoint wpPrev = null;
            for (int col = 0; col < platform.getCols(); col++) {
                // check if waypoint is a corner
                boolean isLeftCorner = false;
                boolean isRightCorner = false;
                if (col == 0) isLeftCorner = true;
                if (col == platform.getCols() - 1) isRightCorner = true;

                // add waypoint to graph
                Waypoint wp = new Waypoint(platform.getX() + col * platform.getTileSize() + Globals.WP_BUFFER,
                                           platform.getY() - Globals.WP_BUFFER,
                                           isLeftCorner,
                                           isRightCorner,
                                           platform);
                waypointGraph.addNode(wp);

                // connect the waypoints on the same platform
                if (wpPrev != null) {
                    waypointGraph.addEdge(wpPrev, wp);
                }
                wpPrev = wp;
            }
        }

        // set Dirichlet Domains for waypoints
        // this is done by setting domain heights for all waypoints until it hits the bottom of another waypoint
        for (Waypoint wp : waypointGraph.getNodes()) {
            for (Waypoint wp2 : waypointGraph.getNodes()) {
                if (wp == wp2) continue;
                if (wp.getX() != wp2.getX()) continue;
                if (wp.getY() <= wp2.getY()) continue;

                // waypoint is directly under another waypoint
                int newDomainHeight = wp2.getY() + Globals.WP_BUFFER + wp2.getPlatform().getRows() * wp2.getPlatform().getTileSize();
                if (wp.getDomainHeight() < newDomainHeight) {
                    wp.setDomainHeight(newDomainHeight);
                }
                
            }
        }
    }

    private void initEdges() {
        for (Waypoint corner : waypointGraph.getNodes()) {
            if (!corner.isCorner()) continue;

            for (Waypoint wp : waypointGraph.getNodes()) {
                if (waypointGraph.getNeighbors(corner).contains(wp)) continue;

                // if corner y coordinate is lower (inverted from coordinate system) than wp,
                // then not a wp the corner can drop to
                if (corner.getYCoord() < wp.getYCoord()) {
                    // check if wp is adjacent
                    if (corner.isLeftCorner() && corner.getXCoord() - wp.getXCoord() == 1) {
                        waypointGraph.addEdge(corner, wp);
                    }
                    if (corner.isRightCorner() && corner.getXCoord() - wp.getXCoord() == -1) {
                        waypointGraph.addEdge(corner, wp);
                    }
                }

                // platform to platform corners (how to get from one platform to another)
                // maybe via jumping etc...
                if (corner.isRightCorner() && wp.isLeftCorner() && corner.getXCoord() - wp.getXCoord() < 0) {
                    waypointGraph.addEdge(corner, wp);
                }
            }
        }

        // purges excess corners connections
        // ensures one to one connections for right and left corners, based on shortest distance
        for (Waypoint corner : waypointGraph.getNodes()) {
            if (!corner.isCorner()) continue;

            List<Waypoint> candidateCorners = new ArrayList<>();
            for (Waypoint neighbor : waypointGraph.getNeighbors(corner)) {
                if (neighbor.isCorner() && corner.isDifferentPlatform(neighbor)) {
                    candidateCorners.add(neighbor);
                }
            }

            if (candidateCorners.isEmpty()) continue;

            Waypoint nearestCorner = candidateCorners.get(0);
            float minDist = corner.getPosition().dist(nearestCorner.getPosition());
            for (Waypoint candidate : candidateCorners) {
                float dist = corner.getPosition().dist(candidate.getPosition());
                if (dist < minDist) {
                    nearestCorner = candidate;
                    minDist = dist;
                }
            }

            for (Waypoint candidate : candidateCorners) {
                if (candidate != nearestCorner) {
                    waypointGraph.removeEdge(corner, candidate);
                }
            }

            // if nearest corner is too far in the end
            if (corner.getPosition().dist(nearestCorner.getPosition()) > 150.0f) {
                    waypointGraph.removeEdge(corner, nearestCorner);
            }
        }
    }

    void showWaypoints(Camera camera) {
        stroke(255, 0, 0);

        for (Waypoint wp : level.getWaypointGraph().getNodes()) {
            if (!Globals.isOnScreen(camera, wp.getX(), wp.getY(), 0, 0)) continue;
            for (Waypoint neighbor : level.getWaypointGraph().getNeighbors(wp)) {
                line(wp.getX(), wp.getY(), neighbor.getX(), neighbor.getY());
            }
        }

        noStroke();
        for (Waypoint wp : level.getWaypointGraph().getNodes()) {
        if (!Globals.isOnScreen(camera, wp.getX(), wp.getY(), 0, 0)) continue;

            if (wp.isCorner()) fill(255, 255, 0);
            else fill(0, 255, 0);

            if (wp.isEnemyNextWP()) fill(255, 0, 255);
            if (wp.isPlayerOnTop()) fill(255, 255, 255);

            ellipse(wp.getX(), wp.getY(), 8, 8);
        }
    }

    boolean areAllEnemiesDead() {
        boolean allDead = true;
        for (Enemy enemy : getEnemies()) {
            if (!enemy.isDead()) allDead = false;
        }
        return allDead;
    }

    void addEntities(List<Entity> entities) {
        entities.addAll(getPlatforms());
        for (Enemy enemy : getEnemies()) {
            enemy.addEntities(entities);
        }
    }

    List<Platform> getPlatforms() {
        return platforms;
    }

    Graph<Waypoint> getWaypointGraph() {
        return waypointGraph;
    }

    int getFallDeath() {
        return fallDeath;
    }

    List<Enemy> getEnemies() {
        return enemies;
    }

    Zorp getZorp() {
        return zorp;
    }
}
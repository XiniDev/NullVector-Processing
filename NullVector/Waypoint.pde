import java.util.ArrayList;
import java.util.List;

class Waypoint {

    PVector position;
    boolean isLeftCorner;
    boolean isRightCorner;
    Platform platform;
    int domainHeight;

    // for debugging
    boolean playerOnTop;
    boolean enemyNextWP;

    Waypoint(float x, float y, boolean isLeftCorner, boolean isRightCorner, Platform platform) {
        this.position = new PVector(x, y);
        this.isLeftCorner = isLeftCorner;
        this.isRightCorner = isRightCorner;
        this.platform = platform;
        domainHeight = Integer.MIN_VALUE;

        playerOnTop = false;
        enemyNextWP = false;
    }

    int getXCoord() {
        return (int) (position.x / Globals.STRIDE);
    }

    int getYCoord() {
        return (int) (position.y / Globals.STRIDE);
    }

    int getX() {
        return (int) position.x;
    }

    int getY() {
        return (int) position.y;
    }

    float getXf() {
        return position.x;
    }

    float getYf() {
        return position.y;
    }

    PVector getPosition() {
        return new PVector(getXf(), getYf());
    }

    boolean isLeftCorner() {
        return isLeftCorner;
    }

    boolean isRightCorner() {
        return isRightCorner;
    }

    boolean isSoloCorner() {
        return isLeftCorner && isRightCorner;
    }

    boolean isCorner() {
        return isLeftCorner || isRightCorner;
    }

    Platform getPlatform() {
        return platform;
    }

    boolean isDifferentPlatform(Waypoint wp) {
        return this.getPlatform() != wp.getPlatform();
    }

    boolean isPlayerOnTop() {
        return playerOnTop;
    }

    void setPlayerOnTop(boolean value) {
        this.playerOnTop = value;
    }

    boolean isEnemyNextWP() {
        return enemyNextWP;
    }

    void setEnemyNextWP(boolean value) {
        this.enemyNextWP = value;
    }

    int getDomainHeight() {
        return domainHeight;
    }

    void setDomainHeight(int domainHeight) {
        this.domainHeight = domainHeight;
    }
}
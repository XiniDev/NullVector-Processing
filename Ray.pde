import java.util.HashMap;
import java.util.Map;

final class Ray extends Entity {

    PVector direction;
    float length;
    CharacterBody owner;

    Map<PVector, Platform> intersectingPlatforms;

    color rayColor;

    Ray(int x, int y, float length, CharacterBody owner) {
        super(x, y);
        direction = new PVector(0, 0);
        this.length = length;
        this.owner = owner;
        intersectingPlatforms = new HashMap<>();

        // for debug default red
        rayColor = color(255, 0, 0);
    }

    void updateByParent(float dt, int x, int y, float dirX, float dirY) {
        setPosition(x, y);
        direction.x = dirX;
        direction.y = dirY;
    }

    void draw() {
        // debug line
        if (Globals.getDebug()) {
            pushMatrix();
    
            // anticlockwise rotation
            translate(getXf(), getYf());

            stroke(rayColor);
            line(0, 0, direction.x * length, direction.y * length);

            popMatrix();
        }
    }

    @Override
    int getW() {
        return (int) (length * direction.x);
    }

    @Override
    int getH() {
        return (int) (length * direction.y);
    }

    PVector getDirection() {
        return direction;
    }

    float getLength() {
        return length;
    }

    void setLength(float length) {
        this.length = length;
    }

    CharacterBody getOwner() {
        return owner;
    }

    void resetIntersections() {
        intersectingPlatforms.clear();
    }

    Map<PVector, Platform> getIntersectingPlatforms() {
        return intersectingPlatforms;
    }

    void addIntersectingPlatform(PVector intersection, Platform platform) {
        intersectingPlatforms.put(intersection, platform);
    }

    boolean isIntersectingPlatforms() {
        return !intersectingPlatforms.isEmpty();
    }

    Platform getNearestPlatform() {
        PVector nearest = null;
        float minDist = Float.MAX_VALUE;
        for (PVector intersection : intersectingPlatforms.keySet()) {
            float dist = getPosition().dist(intersection);
            if (dist < minDist) {
                minDist = dist;
                nearest = intersection;
            }
        }
        return intersectingPlatforms.get(nearest);
    }
}
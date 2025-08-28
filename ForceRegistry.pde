import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

final class ForceRegistry {

    private final Map<ForceGenerator, List<RigidBody>> registry = new HashMap<>();

    void add(RigidBody rb, ForceGenerator generator) {
        // get the list of bodies for this generator, or create a new one if needed
        List<RigidBody> bodies = registry.get(generator);
        if (bodies == null) {
            bodies = new ArrayList<>();
            registry.put(generator, bodies);
        }
        // add if not already present
        if (!bodies.contains(rb)) {
            bodies.add(rb);
        }
    }

    void remove(RigidBody rb, ForceGenerator generator) {
        List<RigidBody> bodies = registry.get(generator);
        if (bodies != null) {
            bodies.remove(rb);
            // remove the generator from the map if no bodies in generator left
            if (bodies.isEmpty()) {
                registry.remove(generator);
            }
        }
    }

    void clear() {
        registry.clear();
    }

    void updateForces(float dt) {
        for (Map.Entry<ForceGenerator, List<RigidBody>> entry : registry.entrySet()) {
            ForceGenerator generator = entry.getKey();
            List<RigidBody> bodies = entry.getValue();
            for (RigidBody rb : bodies) {
                generator.updateForce(rb, dt);
            }
        }
    }
}
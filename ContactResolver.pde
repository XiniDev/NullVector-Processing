import java.util.Iterator;
import java.util.List;

final class ContactResolver {

    // resolves a set of particle contacts
    void resolveContacts(List<Contact> contacts) {
        Iterator itr = contacts.iterator();
        while (itr.hasNext()) {
            Contact contact = (Contact)itr.next();
            contact.resolve();
        }
    }

    Contact detectCollision(RigidBody rb1, RigidBody rb2) {
        // aabb collision algorithm
        // uses box float coordinates for better precision of resolving collisions
        float overlapX1 = (rb2.getBoxXf() + rb2.getBoxW()) - rb1.getBoxXf();
        float overlapX2 = (rb1.getBoxXf() + rb1.getBoxW()) - rb2.getBoxXf();
        float overlapY1 = (rb2.getBoxYf() + rb2.getBoxH()) - rb1.getBoxYf();
        float overlapY2 = (rb1.getBoxYf() + rb1.getBoxH()) - rb2.getBoxYf();

        boolean overlap = overlapX1 > 0 && overlapX2 > 0 && overlapY1 > 0 && overlapY2 > 0;

        if (!overlap) {
            boolean leftInBox = rb1.getBoxXf() >= rb2.getBoxXf() && rb1.getBoxXf() <= rb2.getBoxXf() + rb2.getBoxW();
            boolean rightInBox = rb1.getBoxXf() + rb1.getBoxW() <= rb2.getBoxXf() && rb1.getBoxXf() + rb1.getBoxW() >= rb2.getBoxXf() + rb2.getBoxW();
            // only need to check rb1 because platforms will always be rb2 if rb1 is characterBody
            if (rb1 instanceof CharacterBody && overlapY2 == 0 && (leftInBox || rightInBox)) {
                ((CharacterBody) rb1).groundCheck = true;
                ((CharacterBody) rb1).setLastPlatform((Platform) rb2);
            }
            return null;
        }

        // for projectiles that don't bounce
        if (rb1 instanceof Projectile && rb2 instanceof Platform) {
            Projectile projectile = (Projectile) rb1;
            if (!projectile.canBounce()) {
                projectile.reset();
                return null;
            }
        }

        float overlapX = min(overlapX1, overlapX2);
        float overlapY = min(overlapY1, overlapY2);

        // normal is talking about rb1's normal
        PVector normal = new PVector();
        float penetration;

        // set the normal based on the positions of the bodies
        if (overlapX < overlapY) {
            // collided in x direction
            penetration = overlapX;
            float center1 = rb1.getBoxXf() + rb1.getBoxW() * 0.5f;
            float center2 = rb2.getBoxXf() + rb2.getBoxW() * 0.5f;
            if (center1 < center2) {
                normal.set(-1, 0);
            } else {
                normal.set(1, 0);
            }
        } else {
            // collided in y direction
            penetration = overlapY;
            float center1 = rb1.getBoxYf() + rb1.getBoxH() * 0.5f;
            float center2 = rb2.getBoxYf() + rb2.getBoxH() * 0.5f;
            if (center1 < center2) {
                normal.set(0, -1);
            } else {
                normal.set(0, 1);
            }

            // if overlap mainly on y and is character body then must be grounded
            if (rb1 instanceof CharacterBody && ((CharacterBody) rb1).canJump) {
                if (center1 < center2) {
                    ((CharacterBody) rb1).groundCheck = true;
                    ((CharacterBody) rb1).setLastPlatform((Platform) rb2);
                }
            }
        }

        // multiply the 2 bodies' restitution for physically accurate bounce
        float restitution = rb1.getRestitution() * rb2.getRestitution();

        return new Contact(rb1, rb2, restitution, normal, penetration);
    }

    Contact detectPlatformCollision(RigidBody rb1, RigidBody rb2) {
        return detectCollision(rb1, rb2);
    }

    ProjectileContact detectProjectileCollision(RigidBody rb1, RigidBody rb2) {
        Contact baseContact = detectCollision(rb1, rb2);
        if (baseContact != null) {
            return new ProjectileContact(baseContact.rb1, baseContact.rb2, baseContact.restitution, baseContact.contactNormal, baseContact.penetration);
        } else {
            return null;
        }
    }

    RayContact detectRayCollision(Ray ray, RigidBody rb2) {
        // because ray has direction, and aabb assumes that the x and y starts from the top left corner
        // therefore get min value for x and y start, and max for end
        float rx = min(ray.getXf(), ray.getXf() + ray.getLength() * ray.getDirection().x);
        float rxEnd = max(ray.getXf(), ray.getXf() + ray.getLength() * ray.getDirection().x);

        float ry = min(ray.getYf(), ray.getYf() + ray.getLength() * ray.getDirection().y);
        float ryEnd = max(ray.getYf(), ray.getYf() + ray.getLength() * ray.getDirection().y);

        float overlapX1 = (rb2.getBoxXf() + rb2.getBoxW()) - rx;
        float overlapX2 = rxEnd - rb2.getBoxXf();
        float overlapY1 = (rb2.getBoxYf() + rb2.getBoxH()) - ry;
        float overlapY2 = ryEnd - rb2.getBoxYf();

        boolean overlap = overlapX1 > 0 && overlapX2 > 0 && overlapY1 > 0 && overlapY2 > 0;

        if (!overlap) {
            return null;
        }

        float intersectionX = rx;
        if (ray.getDirection().x > 0) intersectionX = rb2.getBoxXf();
        else if (ray.getDirection().x < 0) intersectionX = rb2.getBoxXf() + rb2.getBoxW();

        float intersectionY = ry;
        if (ray.getDirection().y > 0) intersectionY = rb2.getBoxYf();
        else if (ray.getDirection().y < 0) intersectionY = rb2.getBoxYf() + rb2.getBoxH();

        return new RayContact(ray, rb2, new PVector(intersectionX, intersectionY));
    }
}
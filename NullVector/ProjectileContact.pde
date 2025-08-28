final class ProjectileContact extends Contact {

    ProjectileContact(RigidBody rb1, RigidBody rb2, float restitution, PVector contactNormal, float penetration) {
        super(rb1, rb2, restitution, contactNormal, penetration);
    }

    void resolve() {
        if (rb1 instanceof Projectile && rb2 instanceof CharacterBody) {
            Projectile projectile = (Projectile) rb1;
            CharacterBody target = (CharacterBody) rb2;

            float friendlyFireMod = 1;
            if (projectile.getOwner().isEnemy() && target.isEnemy()) friendlyFireMod /= 2;

            target.takeDamage(projectile.getOwner().getDamage() * projectile.getDamage() * friendlyFireMod);

            // knockback on hit
            PVector knockbackDirection = new PVector(contactNormal.x, -contactNormal.y);
            knockbackDirection.normalize();
            knockbackDirection.mult(-projectile.getKnockbackForce());

            target.addForce(knockbackDirection);

            projectile.reset();
        }
    }
}
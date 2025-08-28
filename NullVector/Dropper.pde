final class Dropper extends FlyingEnemy {

    private DropperHand dropperHand;
    private DropperBall dropperBall;

    private Cable cable;

    private List<Entity> newEntities;

    int dropperBallRegeneration;
    int dropperBallRegenerationCounter;

    Dropper(int x, int y, Player target, Graph<Waypoint> waypointGraph) {
        super(x, y, 10.0f,
              new BoxCollider(10, 14, 3, 2),
              new AnimatedSprite("assets/sprites/dropper.png", 16, 16, 16, 16, 6, new boolean[]{false, true, false, true, true}),
              new CharacterProperties(12.0f, 2.0f, 0.0f, 0.0f, 0),
              10.0f, 250, 3, 0, 200,
              0, 1, 2, 3, 4,
              target, waypointGraph,
              Globals.STRIDE);

        dropperHand = new DropperHand(x, y, 9, 12, -3);
        dropperBall = new DropperBall(x, y, this);
        regenerateDropperBall(x, y);

        dropperBallRegeneration = attackSpeed / 2;
        dropperBallRegenerationCounter = 0;

        newEntities = new ArrayList<>();
    }

    void update(float dt) {
        if (dropperBall.isDropped()) {
            if (dropperBallRegenerationCounter >= dropperBallRegeneration) {
                regenerateDropperBall(getX(), getY());
            } else {
                dropperBallRegenerationCounter++;
            }
        }

        super.update(dt);

        // no need to update dropper ball because its an entity with a default update funciton
        dropperHand.updateByParent(dt, getX(), getY(), sprite.getHFlip(), isAttacking);
    }

    void draw() {
        super.draw();

        // cable draw (not entity)
        if (!dropperBall.isDropped()) cable.draw();
    }

    void regenerateDropperBall(int x, int y) {
        cable = new Cable(dropperHand, dropperBall, 16.0f, 1.0f);
        dropperBall.regenerate(x, y);

        if (newEntities != null) {
            newEntities.add(dropperBall);
        }

        dropperBallRegenerationCounter = 0;
    }

    List<Entity> getNewEntities() {
        return newEntities;
    }

    void clearNewEntities() {
        newEntities.clear();
    }

    void addContact(List<Contact> contacts) {
        Contact contact = cable.addContact();
        if (contact != null) contacts.add(contact);
    }

    void die() {
        super.die();
        cable.dispose();
        dropperHand.dispose();
        dropperBall.drop();
    }

    boolean metAttackCondition() {
        // close to player or ball still attached
        return abs(target.getX() - getX()) < 10 && !dropperBall.isDropped();
    }

    void attack() {
        cable.dispose();
        dropperBall.drop();
    }

    float getDamage() {
        return 1.0f;
    }

    void addEntities(List<Entity> entities) {
        super.addEntities(entities);
        entities.add(dropperHand);
        entities.add(dropperBall);
    }
}
import java.awt.event.KeyEvent;
import java.util.ArrayList;
import java.util.List;

final int screen_width = 1920;
final int screen_height = 1080;

int gameState = 0;

boolean gameWin = false;
boolean gamePaused = false;

// systems
ForceRegistry forceRegistry;
ContactResolver contactResolver;

// forces
Gravity gravity;
Drag drag;

// contacts
List<Contact> contacts;

// camera
Camera camera;

// entities
Player player;
Crosshair crosshair;

Level level;

List<Entity> entities;

HealthIndicator healthIndicator;
HealthBar healthBar;

void settings() {
    size(screen_width,screen_height);
    noSmooth();
}

void setup() {
    frameRate(60);

    // setup systems
    forceRegistry = new ForceRegistry();
    contactResolver = new ContactResolver();

    // setup camera
    camera = new Camera(16, 22, Globals.SCALE);

    // setup level
    level = new Level();

    // setup entities
    crosshair = new Crosshair(camera);
    player = new Player(16, 22, camera, crosshair, level.getWaypointGraph());

    // generate level
    level.generate(player);

    entities = new ArrayList<>();
    level.addEntities(entities);

    player.addEntities(entities);

    entities.add(crosshair);

    // setup forces
    gravity = new Gravity(new PVector(0.0f, -9.81f));
    drag = new Drag(1f, 0.2f);

    // setup contacts
    contacts = new ArrayList();

    // setup gui
    healthIndicator = new HealthIndicator(10, 10, 5, player.getHealth());
    healthBar = new HealthBar((int) (width / 2 - 128 / 2 * Globals.SCALE), (int) (height - 16 * Globals.SCALE - 10), level.getZorp().getHealth());
}

void update(float dt) {
    // add subentities per entity
    List<Entity> newEntities = new ArrayList<>();
    for (Entity entity: entities) {
        List<Entity> subEntities = entity.getNewEntities();
        if (subEntities != null) {
            newEntities.addAll(subEntities);
            entity.clearNewEntities();
        }
    }

    entities.addAll(newEntities);

    // add forces to registry
    for (Entity entity : entities) {
        if (!(entity instanceof Platform) && entity instanceof RigidBody && ((RigidBody) entity).isAffectedByGravity()) {
            forceRegistry.add((RigidBody) entity, gravity);
            forceRegistry.add((RigidBody) entity, drag);
        }
    }

    forceRegistry.updateForces(dt);

    // collision
    for (Entity entity : entities) {
        // platform collision
        // for all entities that aren't platforms but are rigidbodies, check their collision with platforms
        if (!(entity instanceof Platform) && entity instanceof RigidBody) {
            for (Entity entity2 : entities) {
                if (entity2 instanceof Platform) {
                    Contact platformContact = contactResolver.detectPlatformCollision((RigidBody) entity, (Platform) entity2);
                    if (platformContact != null) contacts.add(platformContact);
                }
            }
            // projectile collision
            // for all entities that are projectiles, check their collision with character bodies
            if (entity instanceof Projectile) {
                for (Entity entity2 : entities) {
                    if (!(entity2 instanceof Platform) && entity2 instanceof CharacterBody) {
                        if (((Projectile) entity).getOwner() == ((CharacterBody) entity2)) continue;
                        ProjectileContact projectileContact = contactResolver.detectProjectileCollision((Projectile) entity, (CharacterBody) entity2);
                        if (projectileContact != null) contacts.add(projectileContact);
                    }
                }
            }
        }
        // ray collision
        // used for raycasts
        if (entity instanceof Ray) {
            ((Ray) entity).resetIntersections();
            for (Entity entity2: entities) {
                if (entity2 instanceof Platform) {
                    RayContact rayContact = contactResolver.detectRayCollision((Ray) entity, (Platform) entity2);
                    if (rayContact != null) contacts.add(rayContact);
                }
            }
        }
    }

    for (Enemy enemy : level.getEnemies()) {
        if (enemy instanceof Dropper) {
            ((Dropper) enemy).addContact(contacts);
        }
    }

    contactResolver.resolveContacts(contacts);

    // sort entities by layer and then display them accordingly
    entities.sort((e1, e2) -> Integer.compare(e1.getLayer(), e2.getLayer()));

    for (Entity entity : entities) {
        entity.update(dt);
    }

    forceRegistry.clear();
    contacts.clear();

    for (Entity entity: entities) {
        if (entity instanceof CharacterBody) {
            CharacterBody ch = (CharacterBody) entity;
            if (ch.checkFallDeath(level.getFallDeath())) {
                if (ch instanceof Player) println("Player is dead due to fall!");
            }
        }
    }

    // remove dead / inactive entities
    for (Iterator<Entity> it = entities.iterator(); it.hasNext();) {
        Entity e = it.next();
        if (!e.isActive()) {
            it.remove();
        }
    }

    healthIndicator.update(player.getHealth());
    healthBar.update(level.getZorp().getHealth());
}

void drawGrid() {
    fill(255, 255, 255);
    textAlign(LEFT, CENTER);
    textSize(3);

    float camL = (camera.getX() - camera.getW() / 2 / camera.zoom) / Globals.STRIDE;
    float camR = (camera.getX() + camera.getW() / 2 / camera.zoom) / Globals.STRIDE;
    float camT = (camera.getY() - camera.getH() / 2 / camera.zoom) / Globals.STRIDE;
    float camB = (camera.getY() + camera.getH() / 2 / camera.zoom) / Globals.STRIDE;

    int left = max(0, (int) camL);
    int right = min(99, (int) camR + 1);
    int top = max(0, (int) camT);
    int bottom = min(49, (int) camB + 1);

    for (int c = left; c < right; c++) {
        for (int r = top; r < bottom; r++) {
            text(". (" + c + ", " + r + ")", c * Globals.STRIDE, r * Globals.STRIDE);
        }
    }
}

void checkGameOver() {
    if (player.getHealth() <= 0) {
        gameWin = false;
        gameState = 2;
        textAlign(CENTER, CENTER);
        textSize(64);
        fill(255, 0, 0);
    } else if (level.areAllEnemiesDead()) {
        gameWin = true;
        gameState = 2;
        textAlign(CENTER, CENTER);
        textSize(64);
        fill(255, 0, 0);
    }
}

void restartGame() {
    setup();
    gameState = 1;
}

void drawMenu() {
    background(0);
    fill(255);
    textAlign(CENTER, CENTER);

    textSize(64);
    text("StoneAge.exe", width / 2, height / 2 - 100);

    textSize(32);
    text("Press ENTER or CLICK anywhere to Start", width / 2, height / 2);
}

void drawGame() {
    if (gamePaused) {
        textAlign(CENTER, CENTER);
        textSize(64);
        fill(255);
        // text("Game Paused, Press P to Unpause.", width / 2, height / 2);
        return;
    }

    float dt = 1.0f / frameRate;

    update(dt);

    background(0);

    player.camera_begin();

    // debug
    if (Globals.getDebug()) {
        drawGrid();
        level.showWaypoints(camera);
    }

    for (Entity entity : entities) {
        if (!Globals.isOnScreen(camera, entity.getX(), entity.getY(), entity.getW(), entity.getH())) continue;
        entity.draw();
    }

    player.camera_end();

    healthIndicator.draw();
    if (!level.getZorp().isDead() && !level.getZorp().isAsleep()) healthBar.draw();

    checkGameOver();
}

void drawGameOver() {
    background(0);
    fill(255, 0, 0);
    textAlign(CENTER, CENTER);

    textSize(64);
    if (gameWin) text("YOU WIN", width / 2, height / 2);
    else text("GAME OVER", width / 2, height / 2);

    textSize(32);
    text("Press ENTER or CLICK anywhere to Restart", width / 2, height / 2 + 50);
}

void keyPressed() {
    if (gameState == 0) {
        if (keyCode == KeyEvent.VK_ENTER) gameState = 1;
    } else if (gameState == 1) {
        if (keyCode == KeyEvent.VK_P) {
            if (gamePaused) gamePaused = false;
            else gamePaused = true;
        }

        if (gamePaused) return;

        if (keyCode == KeyEvent.VK_A) player.decMoveDirection();
        if (keyCode == KeyEvent.VK_D) player.incMoveDirection();
        if (keyCode == KeyEvent.VK_SPACE) player.jump();

        if (keyCode == KeyEvent.VK_B) Globals.toggleDebug();
    } else if (gameState == 2) {
        if (keyCode == KeyEvent.VK_ENTER) restartGame();
    }
}

void keyReleased() {
    if (gameState != 1) return;
    if (gamePaused) return;
    if (keyCode == KeyEvent.VK_A) player.incMoveDirection();
    if (keyCode == KeyEvent.VK_D) player.decMoveDirection();
}

void mousePressed() {
    if (gameState == 0) {
        if (mouseButton == LEFT) gameState = 1;
    } else if (gameState == 1) {
        if (gamePaused) return;
        if (mouseButton == LEFT) {
            player.shoot();
        }
    } else if (gameState == 2) {
        if (mouseButton == LEFT) restartGame();
    }
}

void draw() {
    if (gameState == 0) {
        cursor();
        drawMenu();
    } else if (gameState == 1) {
        noCursor();
        drawGame();
    } else if (gameState == 2) {
        cursor();
        drawGameOver();
    }
}
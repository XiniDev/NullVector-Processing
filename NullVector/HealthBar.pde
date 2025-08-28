final class HealthBar {

    PImage barImage;
    int x, y;
    int fullWidth, barHeight;
    float maxHealth;
    float currentHealth;
    PGraphics buffer;

    HealthBar(int x, int y, float health) {
        barImage = loadImage("assets/gui/healthBar.png");
        this.x = x;
        this.y = y;
        this.maxHealth = health;
        this.currentHealth = health;
        fullWidth = barImage.width;
        barHeight = barImage.height / 3;

        buffer = createGraphics((int) (fullWidth * Globals.SCALE), (int) (barHeight * Globals.SCALE));
    }

    void update(float health) {
        currentHealth = health;

        buffer.beginDraw();
        buffer.clear();

        float ratio = currentHealth / maxHealth;
        int redWidth = (int) (fullWidth * ratio);

        int redDrawW = (int) (redWidth * Globals.SCALE);
        int drawW = (int) (fullWidth * Globals.SCALE);
        int drawH = (int) (barHeight * Globals.SCALE);

        buffer.image(barImage, 0, 0, drawW, drawH, 0, barHeight * 2, fullWidth, barHeight * 3);
        buffer.image(barImage, 0, 0, redDrawW, drawH, 0, barHeight, redWidth, barHeight * 2);
        buffer.image(barImage, 0, 0, drawW, drawH, 0, 0, fullWidth, barHeight);

        buffer.endDraw();
    }

    void draw() {
        image(buffer, x, y);
    }
}
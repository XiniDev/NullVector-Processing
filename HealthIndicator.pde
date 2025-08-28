final class HealthIndicator {

    // not displayed within camera (so fixed position, but pixels are smaller)
    PImage heartsSheet;
    int heartW, heartH;
    int maxHearts;
    int x, y;
    int spacing;
    PGraphics buffer;
    float lastHealth;

    HealthIndicator(int x, int y, int spacing, float health) {
        heartsSheet = loadImage("assets/gui/health.png");
        heartW = heartsSheet.width / 3;
        heartH = heartsSheet.height;
        this.x = x;
        this.y = y;
        this.spacing = spacing;
        maxHearts = (int) (health / 2.0f);

        int bufferWidth = maxHearts * heartW + (maxHearts - 1) * spacing;
        buffer = createGraphics((int) (bufferWidth * Globals.SCALE), (int) (heartH * Globals.SCALE));

        lastHealth = -1;
    }

    void update(float health) {
        if (health != lastHealth) {
            buffer.beginDraw();
            buffer.clear();

            int fullHearts = (int) (health / 2.0f);
            float remainder = health - fullHearts * 2.0f;
            int halfHearts = (remainder >= 1.0f) ? 1 : 0;
            int emptyHearts = maxHearts - fullHearts - halfHearts;

            int posX = 0;

            int drawW = (int) (heartW * Globals.SCALE);
            int drawH = (int) (heartH * Globals.SCALE);

            // full hearts draw
            for (int i = 0; i < fullHearts; i++) {
                buffer.image(heartsSheet, posX, 0, drawW, drawH, 0, 0, heartW, heartH);
                posX += (int) ((heartW + spacing) * Globals.SCALE);
            }
            // half hearts draw
            if (halfHearts == 1) {
                buffer.image(heartsSheet, posX, 0, drawW, drawH, heartW, 0, heartW * 2, heartH);
                posX += (int) ((heartW + spacing) * Globals.SCALE);
            }
            // empty hearts draw
            for (int i = 0; i < emptyHearts; i++) {
                buffer.image(heartsSheet, posX, 0, drawW, drawH, 2 * heartW, 0, heartW * 3, heartH);
                posX += (int) ((heartW + spacing) * Globals.SCALE);
            }

            buffer.endDraw();
            lastHealth = health;
        }
    }

    void draw() {
        image(buffer, x, y);
    }
}
final static class Globals {

    final static float SCALE = 4.0f;
    final static int STRIDE = 16;
    final static int ANIMATION_FPS = 6;
    final static int WP_BUFFER = STRIDE / 2;
    final static float CLEAR_BUFFER = 100.0f;
    final static int MAX_LEVEL_HEIGHT = 12;
    private static boolean debug = false;

    static boolean getDebug() {
        return debug;
    }

    static void toggleDebug() {
        debug = !debug;
    }

    static boolean isOnScreen(Camera camera, float x, float y, float w, float h) {
        float margin = Globals.CLEAR_BUFFER;

        float camL = camera.getX() - camera.getW() / 2 / camera.zoom;
        float camT = camera.getY() - camera.getH() / 2 / camera.zoom;
        float camR = camera.getX() + camera.getW() / 2 / camera.zoom;
        float camB = camera.getY() + camera.getH() / 2 / camera.zoom;

        if (x + w < camL - margin || x > camR + margin ||
            y + h < camT - margin || y > camB + margin) {
            return false;
        }

        return true;
    }
}
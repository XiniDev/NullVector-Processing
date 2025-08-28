final class AnimatedSprite extends Sprite {

    // default animation being 0 (usually idle animation)
    int maxFrames;
    int frameX;
    int frameY;

    int maxCount;
    int counter;

    boolean[] noRepeats;
    boolean animationFinished;

    int queuedAnimation;

    AnimatedSprite(String path, int sw, int sh, int sx, int sy, int maxFrames, boolean[] noRepeats) {
        super(path, sw, sh, sx, sy);
        this.maxFrames = maxFrames;
        frameX = 0;
        frameY = 0;
        maxCount = (int) (frameRate / Globals.ANIMATION_FPS);
        counter = 0;
        this.noRepeats = noRepeats;
        animationFinished = false;

        queuedAnimation = 0;
    }

    void draw(int x, int y) {
        animationFinished = false;
        if (counter == maxCount) {
            if (frameX == maxFrames - 1) {
                frameX = 0;
                animationFinished = true;
                if (noRepeats[frameY]) setAnimation(queuedAnimation);
            } else frameX += 1;
            counter = 1;
        } else {
            counter += 1;
        }
        super.draw(x, y);
        // println(counter + " " + maxCount);
    }

    void reset() {
        frameX = 0;
    }

    void setAnimation(int frameY) {
        this.frameY = frameY;
    }

    int getFrameX() {
        return frameX;
    }

    int getFrameY() {
        return frameY;
    }

    boolean isAnimationFinished() {
        return animationFinished;
    }

    void setQueuedAnimation(int animation) {
        queuedAnimation = animation;
    }

    void playNoRepeatAnimation(int queued, int animation) {
        reset();
        setQueuedAnimation(queued);
        setAnimation(animation);
    }

    @Override
    int getSrcX() {
        return super.getSrcX() * getFrameX();
    }

    @Override
    int getSrcY() {
        return super.getSrcY() * getFrameY();
    }
}
public class CharacterProperties {
    public final float maxVelX;
    public final float accelSpeed;
    public final float jumpForce;
    public final float jumpHangThreshold;
    public final int maxCoyoteTime;
    
    public CharacterProperties(float maxVelX, float accelSpeed, float jumpForce, float jumpHangThreshold, int maxCoyoteTime) {
        this.maxVelX = maxVelX;
        this.accelSpeed = accelSpeed;
        this.jumpForce = jumpForce;
        this.jumpHangThreshold = jumpHangThreshold;
        this.maxCoyoteTime = maxCoyoteTime;
    }
}
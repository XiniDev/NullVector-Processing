public final class Cable extends ContactGenerator {

    RigidBody rb1;
    RigidBody rb2;

    float maxLength;

    float restitution;

    public Cable(RigidBody rb1, RigidBody rb2, float maxLength, float restitution) {
        super();
        this.rb1 = rb1;
        this.rb2 = rb2;
        this.maxLength = maxLength;
        this.restitution = restitution;
    }

    float currentLength() {
        float cx1 = rb1.getBoxXf() + rb1.getBoxW() / 2.0f;
        float cy1 = rb1.getBoxYf() + rb1.getBoxH() / 2.0f;
        float cx2 = rb2.getBoxXf() + rb2.getBoxW() / 2.0f;
        float cy2 = rb2.getBoxYf() + rb2.getBoxH() / 2.0f;

        PVector center1 = new PVector(cx1, cy1);
        PVector center2 = new PVector(cx2, cy2);
        PVector relativePos = PVector.sub(center2, center1);
        return relativePos.mag();
    }

    Contact addContact() {
        if (!isActive()) return null;
        float len = currentLength();

        // if overextended then return contact else nothing
        if (len < maxLength) return null;

        // calculate the normal for the contact
        float cx1 = rb1.getBoxXf() + rb1.getBoxW() / 2.0f;
        float cy1 = rb1.getBoxYf() + rb1.getBoxH() / 2.0f;
        float cx2 = rb2.getBoxXf() + rb2.getBoxW() / 2.0f;
        float cy2 = rb2.getBoxYf() + rb2.getBoxH() / 2.0f;
        PVector center1 = new PVector(cx1, cy1);
        PVector center2 = new PVector(cx2, cy2);
        PVector contactNormal = PVector.sub(center2, center1);
        contactNormal.normalize();

        return new Contact(rb1, rb2, restitution, contactNormal, len - maxLength);
    }

    void draw() {
        float x1 = rb1.getX() + rb1.getBoxW() / 2.0f;
        float y1 = rb1.getY() + rb1.getBoxH() / 2.0f;
        float x2 = rb2.getX() + rb2.getBoxW() / 2.0f;
        float y2 = rb2.getY() + rb2.getBoxH() / 2.0f;
        stroke(255);
        line(x1, y1, x2, y2);
    }
}
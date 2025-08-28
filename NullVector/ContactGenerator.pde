abstract class ContactGenerator {

    boolean active;

    ContactGenerator() {
        active = true;
    }

    abstract Contact addContact();

    public void dispose() {
        active = false;
    }

    public boolean isActive() {
        return active;
    }
}
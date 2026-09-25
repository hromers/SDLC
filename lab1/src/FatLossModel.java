import java.beans.PropertyChangeListener;
import java.beans.PropertyChangeSupport;

public class FatLossModel {
    private int lastAge = 30;
    private int lastRestingPulse = 60;
    private Equipment lastEquipment = Equipment.BIKE;
    private int startPulse;
    private int targetPulse;

    private final PropertyChangeSupport support = new PropertyChangeSupport(this);

    public enum Equipment {
        BIKE("Велотренажер"),
        STEP("Степ-тренажер"),
        ROWING("Гребной тренажер"),
        ELLIPTICAL("Эллипсоид");

        private final String name;

        Equipment(String name) {
            this.name = name;
        }

        @Override
        public String toString() {
            return name;
        }
    }

    public void addPropertyChangeListener(PropertyChangeListener listener) {
        support.addPropertyChangeListener(listener);
    }

    public void calculateAndSave(int age, int restingPulse, Equipment equipment) {
        lastAge = age;
        lastRestingPulse = restingPulse;
        lastEquipment = equipment;

        int maximumPulse = 220 - age;
        int reserve = maximumPulse - restingPulse;
        int oldStartPulse = startPulse;
        int oldTargetPulse = targetPulse;
        startPulse = (int) Math.round(restingPulse + reserve * 0.50);
        targetPulse = (int) Math.round(restingPulse + reserve * 0.70);

        support.firePropertyChange(
            "calculationResult",
            oldStartPulse + ":" + oldTargetPulse,
            startPulse + ":" + targetPulse
        );
    }

    public int getLastAge() {
        return lastAge;
    }

    public int getLastRestingPulse() {
        return lastRestingPulse;
    }

    public Equipment getLastEquipment() {
        return lastEquipment;
    }

    public int getStartPulse() {
        return startPulse;
    }

    public int getTargetPulse() {
        return targetPulse;
    }

}

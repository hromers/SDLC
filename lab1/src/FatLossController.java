public class FatLossController {
    private final FatLossModel model;

    public FatLossController(FatLossModel model) {
        this.model = model;
    }

    public void processInput(String ageText, String restingPulseText, FatLossModel.Equipment equipment)
        throws NumberFormatException {
        int age = parse(ageText, "Возраст должен быть целым числом.");
        int restingPulse = parse(restingPulseText, "Пульс в состоянии покоя должен быть целым числом.");

        if (age < 1 || age > 120) {
            throw new NumberFormatException("Возраст должен быть от 1 до 120 лет.");
        }
        if (restingPulse < 30 || restingPulse > 120) {
            throw new NumberFormatException("Пульс в состоянии покоя должен быть от 30 до 120 уд/мин.");
        }
        if (restingPulse >= 220 - age) {
            throw new NumberFormatException("Пульс в состоянии покоя должен быть ниже максимального пульса.");
        }

        model.calculateAndSave(age, restingPulse, equipment);
    }

    private int parse(String value, String message) {
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException exception) {
            throw new NumberFormatException(message);
        }
    }
}

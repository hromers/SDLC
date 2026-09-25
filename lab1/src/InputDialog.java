import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JTextField;
import java.awt.GridLayout;

public class InputDialog extends JDialog {
    private final JTextField ageField;
    private final JTextField restingPulseField;
    private final JComboBox<FatLossModel.Equipment> equipmentBox;

    public InputDialog(MainView parent, FatLossModel model, FatLossController controller) {
        super(parent, "Ввод данных", true);
        setSize(380, 220);
        setLocationRelativeTo(parent);
        setLayout(new GridLayout(4, 2, 10, 10));

        add(new JLabel("Возраст, лет:"));
        ageField = new JTextField(String.valueOf(model.getLastAge()));
        add(ageField);

        add(new JLabel("Пульс покоя, уд/мин:"));
        restingPulseField = new JTextField(String.valueOf(model.getLastRestingPulse()));
        add(restingPulseField);

        add(new JLabel("Тренажер:"));
        equipmentBox = new JComboBox<>(FatLossModel.Equipment.values());
        equipmentBox.setSelectedItem(model.getLastEquipment());
        add(equipmentBox);

        add(new JLabel());
        JButton submitButton = new JButton("Рассчитать");
        submitButton.addActionListener(event -> submit(controller));
        add(submitButton);
    }

    private void submit(FatLossController controller) {
        try {
            controller.processInput(
                ageField.getText(),
                restingPulseField.getText(),
                (FatLossModel.Equipment) equipmentBox.getSelectedItem()
            );
            dispose();
        } catch (NumberFormatException exception) {
            JOptionPane.showMessageDialog(
                this,
                "Некорректные данные: " + exception.getMessage(),
                "Ошибка",
                JOptionPane.ERROR_MESSAGE
            );
        }
    }
}

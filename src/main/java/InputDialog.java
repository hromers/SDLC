import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JTextField;
import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridLayout;

public class InputDialog extends JDialog {
    private final JTextField age;
    private final JTextField pulse;
    private final JComboBox<FatLossModel.Equipment> equipment;

    public InputDialog(MainView parent, FatLossModel model, FatLossController controller) {
        super(parent, "Ввод данных", true);
        setDefaultCloseOperation(DISPOSE_ON_CLOSE);
        JPanel content = new JPanel(new BorderLayout(0, 18));
        content.setBorder(BorderFactory.createEmptyBorder(20, 22, 20, 22));
        content.add(new JLabel("Укажите параметры для расчета"), BorderLayout.NORTH);
        JPanel fields = new JPanel(new GridLayout(3, 2, 16, 12));
        fields.add(new JLabel("Возраст, лет (1–120):"));
        age = new JTextField(String.valueOf(model.getLastAge()), 12);
        fields.add(age);
        fields.add(new JLabel("Пульс покоя, уд/мин (30–120):"));
        pulse = new JTextField(String.valueOf(model.getLastRestingPulse()), 12);
        fields.add(pulse);
        fields.add(new JLabel("Тренажер:"));
        equipment = new JComboBox<>(FatLossModel.Equipment.values());
        equipment.setSelectedItem(model.getLastEquipment());
        fields.add(equipment);
        content.add(fields, BorderLayout.CENTER);
        JPanel buttons = new JPanel(new FlowLayout(FlowLayout.RIGHT, 8, 0));
        JButton cancel = new JButton("Отмена");
        cancel.addActionListener(event -> dispose());
        buttons.add(cancel);
        JButton submit = new JButton("Рассчитать");
        submit.addActionListener(event -> submit(controller));
        buttons.add(submit);
        content.add(buttons, BorderLayout.SOUTH);
        setContentPane(content);
        getRootPane().setDefaultButton(submit);
        pack();
        setResizable(false);
        setLocationRelativeTo(parent);
    }

    private void submit(FatLossController controller) {
        try {
            controller.processInput(age.getText(), pulse.getText(),
                (FatLossModel.Equipment) equipment.getSelectedItem());
            dispose();
        } catch (NumberFormatException exception) {
            JOptionPane.showMessageDialog(this, exception.getMessage(),
                "Ошибка ввода", JOptionPane.ERROR_MESSAGE);
        }
    }
}

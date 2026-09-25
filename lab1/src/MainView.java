import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.SwingConstants;
import java.awt.BorderLayout;
import java.awt.Font;
import java.awt.GridLayout;
import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;

public class MainView extends JFrame implements PropertyChangeListener {
    private final FatLossModel model;
    private final FatLossController controller;
    private JLabel inputInfoLabel;
    private JLabel resultLabel;

    public MainView(FatLossModel model, FatLossController controller) {
        this.model = model;
        this.controller = controller;
        model.addPropertyChangeListener(this);
        initUI();
    }

    private void initUI() {
        setTitle("Идеальное похудение");
        setSize(500, 270);
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setLocationRelativeTo(null);
        setLayout(new BorderLayout(12, 12));

        JPanel topPanel = new JPanel(new GridLayout(2, 1, 0, 4));
        inputInfoLabel = new JLabel("Данные еще не введены");
        inputInfoLabel.setFont(new Font("Arial", Font.PLAIN, 13));
        topPanel.add(inputInfoLabel);
        topPanel.add(new JLabel("Формула Карвонена, аэробная зона 50–70%"));
        add(topPanel, BorderLayout.NORTH);

        resultLabel = new JLabel("Ожидание ввода данных...", SwingConstants.CENTER);
        resultLabel.setFont(new Font("Arial", Font.BOLD, 15));
        add(resultLabel, BorderLayout.CENTER);

        JButton inputButton = new JButton("Ввод данных");
        inputButton.addActionListener(event -> openInputWindow());
        add(inputButton, BorderLayout.SOUTH);
    }

    private void openInputWindow() {
        InputDialog dialog = new InputDialog(this, model, controller);
        dialog.setVisible(true);
    }

    @Override
    public void propertyChange(PropertyChangeEvent event) {
        if ("calculationResult".equals(event.getPropertyName())) {
            inputInfoLabel.setText(String.format(
                "Исходные данные: %d лет, пульс покоя %d уд/мин, %s",
                model.getLastAge(),
                model.getLastRestingPulse(),
                model.getLastEquipment()
            ));
            resultLabel.setText(String.format(
                "Начать с %d уд/мин, постепенно выйти на %d уд/мин",
                model.getStartPulse(),
                model.getTargetPulse()
            ));
        }
    }
}

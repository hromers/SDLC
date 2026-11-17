import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.SwingConstants;
import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.GridLayout;
import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;

public class MainView extends JFrame implements PropertyChangeListener {
    private final FatLossModel model;
    private final FatLossController controller;
    private final JLabel input = new JLabel("Данные еще не введены");
    private final JLabel result = new JLabel("Введите данные для расчета", SwingConstants.CENTER);

    public MainView(FatLossModel model, FatLossController controller) {
        super("Идеальное похудение");
        this.model = model;
        this.controller = controller;
        model.addPropertyChangeListener(this);
        setDefaultCloseOperation(EXIT_ON_CLOSE);

        JPanel content = new JPanel(new BorderLayout(0, 20));
        content.setBorder(BorderFactory.createEmptyBorder(22, 24, 22, 24));
        JPanel header = new JPanel(new GridLayout(3, 1, 0, 8));
        JLabel title = new JLabel("Расчет тренировочного пульса");
        title.setFont(title.getFont().deriveFont(Font.BOLD, 20f));
        header.add(title);
        header.add(new JLabel("Формула Карвонена · интенсивность 50–70% резерва пульса"));
        header.add(input);
        content.add(header, BorderLayout.NORTH);

        result.setFont(result.getFont().deriveFont(Font.BOLD, 18f));
        result.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createEtchedBorder(),
            BorderFactory.createEmptyBorder(20, 12, 20, 12)
        ));
        content.add(result, BorderLayout.CENTER);

        JPanel footer = new JPanel(new BorderLayout(0, 12));
        footer.add(new JLabel("Учебный расчет. Не является медицинской рекомендацией."), BorderLayout.NORTH);
        JButton button = new JButton("Ввод данных");
        button.addActionListener(event -> new InputDialog(this, model, controller).setVisible(true));
        footer.add(button, BorderLayout.SOUTH);
        content.add(footer, BorderLayout.SOUTH);
        setContentPane(content);
        setMinimumSize(new Dimension(680, 350));
        pack();
        setLocationRelativeTo(null);
    }

    @Override
    public void propertyChange(PropertyChangeEvent event) {
        if ("calculationResult".equals(event.getPropertyName())) {
            input.setText(String.format("%d лет · пульс покоя %d уд/мин · %s",
                model.getLastAge(), model.getLastRestingPulse(), model.getLastEquipment()));
            result.setText(String.format("Начальный: %d уд/мин     Целевой: %d уд/мин",
                model.getStartPulse(), model.getTargetPulse()));
        }
    }
}

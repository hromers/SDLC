import javax.swing.SwingUtilities;

public class Main {
    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            FatLossModel model = new FatLossModel();
            FatLossController controller = new FatLossController(model);
            MainView view = new MainView(model, controller);
            view.setVisible(true);
        });
    }
}

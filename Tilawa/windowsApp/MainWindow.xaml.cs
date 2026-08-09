using Microsoft.UI.Xaml;

namespace TilawaWindows
{
    public sealed partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
            GreetingText.Text = Shared.Greet();
        }
    }
}

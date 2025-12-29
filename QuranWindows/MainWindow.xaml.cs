using Microsoft.UI.Xaml;
using QuranWindows.ViewModels;

namespace QuranWindows;

public sealed partial class MainWindow : Window
{
    public MainWindow()
    {
        this.InitializeComponent();
        this.Title = "Quran Windows";
        this.DataContext = new MainViewModel();
    }
}

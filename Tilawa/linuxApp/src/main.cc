// Tilawa Linux shell — GTK 4 + libadwaita (gtkmm-4.0) over the KMP shared core
// (libShared.so C ABI; see .agents/skills/kmp-linux-bridge).
#include <adwaita.h>
#include <gtkmm.h>

#if __has_include(<libShared_api.h>)
#include <libShared_api.h>
#elif __has_include(<Shared_api.h>)
#include <Shared_api.h>
#endif

namespace {

class ShellWindow : public Gtk::ApplicationWindow {
public:
    ShellWindow() {
        set_title("Tilawa");
        set_default_size(960, 640);

        header_ = Gtk::HeaderBar();
        set_titlebar(header_);

        title_ = Gtk::Label("Tilawa — Linux shell");
        title_.set_vexpand(true);
        greeting_.set_halign(Gtk::Align::CENTER);

        layout_ = Gtk::Box(Gtk::Orientation::VERTICAL);
        layout_.append(title_);
        layout_.append(greeting_);
        set_child(layout_);

        if (auto* greet = static_cast<char*>(shared_greet())) {
            greeting_.set_text(greet);
            shared_string_free(greet);
        }
    }

private:
    Gtk::HeaderBar header_;
    Gtk::Label title_;
    Gtk::Label greeting_;
    Gtk::Box layout_;
};

} // namespace

int main(int argc, char* argv[]) {
    adw_init(); // ponytail: Adw widgets (C API only) enter with the first real screen
    auto app = Gtk::Application::create("com.hashem.Tilawa");
    return app->make_window_and_run<ShellWindow>(argc, argv);
}

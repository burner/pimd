module gui.pimd;

import gtk.MainWindow;
import gtk.AboutDialog;
import gtk.Dialog;
import gtk.Menu;
import gtk.MenuBar;
import gtk.Notebook;
import gtk.MenuItem;
import gtk.Label;
import gtk.Button;
import gtk.VBox;
import gtk.HBox;
import gtk.Main;

private import stdlib = core.stdc.stdlib : exit;

import gui.mailwindow;

class Pimd : MainWindow {
	this() {
		super("pimd");
		//setDefaultSize(200, 100);
		VBox box = new VBox(false, 2);

		box.packStart(this.createMainMenuBar(), false, true, 0);
		box.add(this.createMainTabBox());

		add(box);
		showAll();	
	}

	MenuBar createMainMenuBar() {
		auto mb = new MenuBar();
		auto fm = new Menu();
		auto hm = new Menu();

		auto f = new MenuItem("_File");
		auto q = new MenuItem("_Quit", &pimdQuit, "Quit");

		auto h = new MenuItem("_Help");
		auto a = new MenuItem("_Help", &about, "About");

		f.setSubmenu(fm);
		fm.append(q);

		h.setSubmenu(hm);
		hm.append(a);

		mb.append(f);
		mb.append(h);

		return mb;
	}

	Notebook createMainTabBox() {
		auto ret = new Notebook();	

		// make the tabs and append the widgets
		auto l = new Label("_Pimd");
		l.setAngle(90.0);
		ret.appendPage(new HBox(false, 2), l);
		l = new Label("_Mail");
		l.setAngle(90.0);
		ret.appendPage(new MailWindow(), l);
		l = new Label("_Calendar");
		l.setAngle(90.0);
		ret.appendPage(new HBox(false, 2), l);
		l = new Label("_Im");
		l.setAngle(90.0);
		ret.appendPage(new HBox(false, 2), l);
		l = new Label("I_rc");
		l.setAngle(90.0);
		ret.appendPage(new HBox(false, 2), l);
		l = new Label("F_eed");
		l.setAngle(90.0);
		ret.appendPage(new HBox(false, 2), l);
		l = new Label("_Logger");
		l.setAngle(90.0);
		ret.appendPage(new HBox(false, 2), l);

		ret.setTabPos(GtkPositionType.LEFT);

		return ret;
	}

	void pimdQuit(MenuItem button) {
		stdlib.exit(0);
	}

	void pimdQuit(Button button) {
		stdlib.exit(0);
	}

	void about(MenuItem mi) {
		auto ad = new AboutDialog();
		string names[] = ["Robert Burner Schadek rburners@gmail.com"];
		ad.setAuthors(names);
		ad.setWebsite("http://github.com/burner/pimd");
		ad.addOnResponse((int v, Dialog da) => da.destroy());
		ad.addOnClose((Dialog da) => da.destroy());
		ad.showAll();
	}
}

void main(string[] args) {
	Main.init(args);
	new Pimd();
	Main.run();
}

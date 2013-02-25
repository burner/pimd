module gui.mailwindow;

import gtk.Widget;
import gtk.VBox;
import gtk.HBox;
import gtk.TreeView;

class MailWindow : Widget {
	private HBox mainBox;
	private TreeView folderTree;
	private TreeView mailFolder;

	this() {
		this.mainBox = new HBox(false, 2);
		super(cast(GtkWidget*)this.mainBox.getHBoxStruct());

		this.mailFolder = new TreeView();
		this.folderTree = new TreeView();
		this.mainBox.add(this.folderTree);
		this.mainBox.add(this.mailFolder);
	}
}

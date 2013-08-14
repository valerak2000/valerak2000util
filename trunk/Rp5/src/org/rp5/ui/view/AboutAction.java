package org.rp5.ui.view;

import org.eclipse.jface.action.*;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.resource.ImageDescriptor;
import org.rp5.Rp5;

/**
 * This action class shows an About box
 */
public class AboutAction extends Action {
	/**
	 * AboutAction constructor
	 */
	public AboutAction() {
		super("About", Rp5.getApp().getImageFor("about"));
/*    setDisabledImageDescriptor(ImageDescriptor.createFromFile(AboutAction.class,
        "/images/disabledAbout.gif"));*/
		setToolTipText("About");
	}

	/**
	 * Shows an about box
	 */
	public void run() {
		MessageDialog.openInformation(Rp5.getApp().getShell(), "About",
				"");
	}
}

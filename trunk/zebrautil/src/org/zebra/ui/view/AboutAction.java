package org.zebra.ui.view;

import org.eclipse.jface.action.*;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.resource.ImageDescriptor;
import org.zebra.ui.Zebra;

/**
 * This action class shows an About box
 */
public class AboutAction extends Action {
	/**
	 * AboutAction constructor
	 */
	public AboutAction() {
		super(Zebra.getApp().getConfZebra().getMString("About"), Zebra.getApp().getImageFor("about"));
/*    setDisabledImageDescriptor(ImageDescriptor.createFromFile(AboutAction.class,
        "/images/disabledAbout.gif"));*/
		setToolTipText(Zebra.getApp().getConfZebra().getMString("About"));
	}

	/**
	 * Shows an about box
	 */
	public void run() {
		MessageDialog.openInformation(Zebra.getApp().getShell(), Zebra.getApp().getConfZebra().getMString("About"),
				"Zebra--to manage your books");
	}
}

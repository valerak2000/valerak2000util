package org.zebra.ui;

import org.eclipse.jface.action.*;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.FileDialog;

/**
 * This action class responds to close zebra-format a file
 */
public class CloseAction extends Action {
	/**
	 * CloseAction constructor
   	*/
	public CloseAction() {
		super(Zebra.getApp().getConfZebra().getMString("Close_zebra_file"), Zebra.getApp().getImageFor("close"));
 /*   setDisabledImageDescriptor(ImageDescriptor.createFromFile(OpenAction.class,
        "/images/disabledOpen.gif"));*/
		setToolTipText("Close_zebra_file");
	}

	/**
	 * Close an zebra-format file
	 */
	public void run() {
		Zebra.getApp().closeZebraFile();
	}
}

package org.zebra.ui.view;

import org.eclipse.jface.action.*;
/*import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.FileDialog;*/
import org.zebra.ui.Zebra;

/**
 * This action class responds to close zebra-format a file
 */
public class CloseAction extends Action {
	/**
	 * CloseAction constructor
   	*/
	public CloseAction() {
		super(Zebra.getApp().getConfZebra().getString("Close_zebra_file"), Zebra.getApp().getImageFor("close"));
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

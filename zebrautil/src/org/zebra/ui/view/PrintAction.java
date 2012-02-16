package org.zebra.ui.view;

import org.eclipse.jface.action.*;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.FileDialog;
import org.zebra.ui.Zebra;

/**
 * This action class responds to print zebra-format a file
 */
public class PrintAction extends Action {
	/**
	 * CloseAction constructor
   	*/
	public PrintAction() {
		super(Zebra.getApp().getConfZebra().getMString("Print_zebra_file"), Zebra.getApp().getImageFor("print"));
 /*   setDisabledImageDescriptor(ImageDescriptor.createFromFile(OpenAction.class,
        "/images/disabledOpen.gif"));*/
		setToolTipText("Print_zebra_file");
	}

	/**
	 * Close an zebra-format file
	 */
	public void run() {
		Zebra.getApp().printZebraFile();
	}
}

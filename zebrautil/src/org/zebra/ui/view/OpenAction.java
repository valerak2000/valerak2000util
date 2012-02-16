package org.zebra.ui.view;

import org.eclipse.jface.action.*;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.FileDialog;
import org.zebra.ui.Zebra;

/**
 * This action class responds to requests to zebra-format a file
 */
public class OpenAction extends Action {
	/**
	 * OpenAction constructor
   	*/
	public OpenAction() {
		super(Zebra.getApp().getConfZebra().getMString("Open_zebra_file"), Zebra.getApp().getImageFor("open"));
 /*   setDisabledImageDescriptor(ImageDescriptor.createFromFile(OpenAction.class,
        "/images/disabledOpen.gif"));*/
		setToolTipText("Open_zebra_file");
	}

	/**
	 * Opens an zebra-format file
	 */
	public void run() {
		Zebra.getApp().choiceZebraFile();
	}
}

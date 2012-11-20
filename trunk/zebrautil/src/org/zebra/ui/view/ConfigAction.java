package org.zebra.ui.view;

import org.eclipse.jface.action.*;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.FileDialog;
import org.zebra.ui.Zebra;

/**
 * This action class responds to configure to zebra-format a file
 */
public class ConfigAction extends Action {
	/**
	 * ConfigAction constructor
   	*/
	public ConfigAction() {
		super(Zebra.getApp().getConfZebra().getString("Config_print_file"), Zebra.getApp().getImageFor("configure"));
 /*   setDisabledImageDescriptor(ImageDescriptor.createFromFile(OpenAction.class,
        "/images/disabledOpen.gif"));*/
		setToolTipText("Config_print_file");
	}

	/**
	 * Close an zebra-format file
	 */
	public void run() {
		Zebra.getApp().configZebraFile();
	}
}

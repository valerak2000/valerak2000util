package org.zebra.ui;

//import org.apache.commons.configuration.XMLConfiguration;
//import org.apache.commons.configuration.Configuration;
import org.eclipse.swt.*;
import org.eclipse.swt.events.*;
import org.eclipse.swt.layout.*;
import org.eclipse.swt.widgets.*;

import org.mconfig.MXMLConfiguration;

public class ConfigDialog {
	MXMLConfiguration confZebra;
	Shell shell;
	String[] values;
	String[] labels;

	public ConfigDialog(Zebra appZebra, Shell parent) {
		confZebra = appZebra.getConfZebra();
		shell = new Shell(parent, SWT.DIALOG_TRIM | SWT.PRIMARY_MODAL);
		shell.setLayout(new GridLayout());		
	}

	private void createControlButtons() {
		Composite composite = new Composite(shell, SWT.NONE);
		composite.setLayoutData(new GridData(GridData.HORIZONTAL_ALIGN_CENTER));
		GridLayout layout = new GridLayout();
		layout.numColumns = 2;
		composite.setLayout(layout);
		
		Button okButton = new Button(composite, SWT.PUSH);
		okButton.setText(confZebra.getString("OK"));
		okButton.addSelectionListener(new SelectionAdapter() {
			public void widgetSelected(SelectionEvent e) {
				shell.close();
			}
		});
		
		Button cancelButton = new Button(composite, SWT.PUSH);
		cancelButton.setText(confZebra.getString("Cancel"));
		cancelButton.addSelectionListener(new SelectionAdapter() {
			public void widgetSelected(SelectionEvent e) {
				values = null;
				shell.close();
			}
		});
		
		shell.setDefaultButton(okButton);
	}

	private void addTextListener(final Text text) {
		text.addModifyListener(new ModifyListener() {
			public void modifyText(ModifyEvent e){
				Integer index = (Integer)(text.getData("index"));
				values[index.intValue()] = text.getText();
			}
		});
	}

	private void createTextWidgets() {
		if (labels == null) return;
		
		Composite composite = new Composite(shell, SWT.NONE);
		composite.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));
		GridLayout layout= new GridLayout();
		layout.numColumns = 2;
		composite.setLayout(layout);
		
		if (values == null)
			values = new String[labels.length];
		
		for (int i = 0; i < labels.length; i++) {
			Label label = new Label(composite, SWT.RIGHT);
			label.setText(labels[i]);	
			Text text = new Text(composite, SWT.BORDER);
			GridData gridData = new GridData();
			gridData.widthHint = 400;
			text.setLayoutData(gridData);

			if (values[i] != null) {
				text.setText(values[i]);
			}

			text.setData("index", new Integer(i));
			addTextListener(text);	
		}
	}

	public String[] getValues() {
		return values;
	}

	public void setValues(String[] itemInfo) {
		if (labels == null) return;
		
		if (values == null)
			values = new String[labels.length];

		int numItems = Math.min(values.length, itemInfo.length);

		for(int i = 0; i < numItems; i++) {
			values[i] = itemInfo[i];
		}	
	}

	public void setLabels(String[] labels) {
		this.labels = labels;
	}

	public String[] open() {
		createTextWidgets();
		createControlButtons();
		shell.pack();
		shell.open();

		Display display = shell.getDisplay();

		while(!shell.isDisposed()){
			if(!display.readAndDispatch())
				display.sleep();
		}
		
		return getValues();
	}
}

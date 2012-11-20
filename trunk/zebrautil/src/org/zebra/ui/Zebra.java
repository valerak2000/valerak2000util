package org.zebra.ui;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.StringWriter;
import java.util.Arrays;
import java.util.Comparator;
import java.util.Iterator;
import java.util.HashMap;

import javax.print.PrintException;
//import javax.xml.transform.OutputKeys;

import org.eclipse.jface.action.CoolBarManager;
import org.eclipse.jface.action.MenuManager;
import org.eclipse.jface.action.Separator;
import org.eclipse.jface.action.StatusLineManager;
import org.eclipse.jface.action.ToolBarManager;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.jface.viewers.CellEditor;
import org.eclipse.jface.viewers.CheckboxCellEditor;
import org.eclipse.jface.viewers.ColorCellEditor;
import org.eclipse.jface.viewers.ComboBoxCellEditor;
import org.eclipse.jface.viewers.TableViewer;
import org.eclipse.jface.viewers.TextCellEditor;
import org.eclipse.jface.window.ApplicationWindow;
import org.eclipse.swt.*;
import org.eclipse.swt.events.*;
import org.eclipse.swt.graphics.*;
import org.eclipse.swt.layout.*;
import org.eclipse.swt.printing.PrintDialog;
import org.eclipse.swt.printing.PrinterData;
import org.eclipse.swt.widgets.*;

import org.apache.commons.configuration.ConfigurationException;

import org.library.config.MenuXMLConfiguration;
import org.library.csv.CSV;
import org.apache.commons.csv.*;
//import org.library.swt.BasicApplication;

import org.zebra.ui.model.ZebraTableModel;
import org.zebra.ui.view.AboutAction;
import org.zebra.ui.view.CloseAction;
import org.zebra.ui.view.ConfigAction;
import org.zebra.ui.view.ConfigDialog;
import org.zebra.ui.view.ExitAction;
import org.zebra.ui.view.OpenAction;
import org.zebra.ui.view.PrintAction;
import org.zebra.ui.view.ZebraContentProvider;
import org.zebra.ui.view.ZebraLabelProvider;
import org.zebra.util.FormPrintUnilever;

public class Zebra extends ApplicationWindow {
	// A static instance to the running application
	final private static Zebra APP;
	private TableViewer tv;

	// The actions
	private OpenAction openAction;
	private CloseAction closeAction;
	private ConfigAction configAction;
	private PrintAction printAction;
	private AboutAction aboutAction;
	private ExitAction exitAction;

	private static MenuXMLConfiguration confZebra = null;

	private static final String[] columnNames = new String[3];
	private CSV csv = new CSV(';');

	private static HashMap<String, ImageDescriptor> hashImages;

	/**
	 * Gets the running application
	*/
	public static final Zebra getApp() {
	    return APP;
	}

	public Zebra() throws ConfigurationException {
		super(null);

	    APP = this;

	    hashImages = new HashMap<String, ImageDescriptor>();
		hashImages.put("open", ImageDescriptor.createFromFile(Zebra.class, "/org/images/fileopen.png"));
		hashImages.put("close", ImageDescriptor.createFromFile(Zebra.class, "/org/images/fileclose.png"));
		hashImages.put("print", ImageDescriptor.createFromFile(Zebra.class, "/org/images/fileprint.png"));
		hashImages.put("configure", ImageDescriptor.createFromFile(Zebra.class, "/org/images/configure.png"));
		hashImages.put("help", ImageDescriptor.createFromFile(Zebra.class, "/org/images/help.png"));
		hashImages.put("about", ImageDescriptor.createFromFile(Zebra.class, "/org/images/about.png"));
		hashImages.put("exit", ImageDescriptor.createFromFile(Zebra.class, "/org/images/exit.png"));

		try	{
			confZebra = new MenuXMLConfiguration();
			confZebra.setFile(new File("Zebra.xml"));
			//запрет использования разделителей списков
/*			confZebra.setDelimiterParsingDisabled(true);
			confZebra.setAttributeSplittingDisabled(true);
			confZebra.load("Zebra.xml");*/
			confZebra.load();
	
			columnNames[0] = confZebra.getString("Goods_name");
			columnNames[1] = confZebra.getString("Goods_barcode");
			columnNames[2] = confZebra.getString("Number_copies");
		} catch (ConfigurationException cex) {
		    // something went wrong, e.g. the file was not found
			showError(cex.getMessage());

			return;
		}

	    // Create the actions
	    openAction = new OpenAction();
	    closeAction = new CloseAction();
	    configAction = new ConfigAction();
	    printAction = new PrintAction();
	    aboutAction = new AboutAction();
	    exitAction = new ExitAction();

	    addMenuBar();
	    addCoolBar(SWT.NONE);
	    addStatusLine();
	}

	public void run() {
	    // Don't return from open() until window closes
		setBlockOnOpen(true);
	    // Open the main window
	    open();
	    // Dispose the display
	    Display.getCurrent().dispose();
	}

	protected void configureShell(Shell shell) {
		super.configureShell(shell);
//		this.shell = shell;

		// Set the title bar text and the size
		shell.setText("");
		//reaction on close main window by "close button" 
		shell.addShellListener(new ShellAdapter() {
			public void shellClosed(ShellEvent e) {
//				e.doit = closeZebraFile();
			}
		});
	}

	protected Control createContents(Composite parent) {
	    Composite composite = new Composite(parent, SWT.NONE);
	    composite.setLayout(new GridLayout(1, false));


	    // Add the TableViewer
	    final TableViewer tv = new TableViewer(composite, SWT.FULL_SELECTION);
	    tv.setContentProvider(new ZebraContentProvider());
	    tv.setLabelProvider(new ZebraLabelProvider());
//	    tv.setSorter(new ZebraViewerSorter());

	    // Set up the table
	    createTable(tv, SWT.SINGLE | SWT.BORDER | SWT.FULL_SELECTION | 
                		SWT.V_SCROLL | SWT.H_SCROLL);

	    //set size of window like table
	    getShell().setSize(tv.getTable().computeSize(SWT.DEFAULT, SWT.DEFAULT).x, 300);

	    return composite;
	}

	public ImageDescriptor getImageFor(String cmd) {
		return (ImageDescriptor) hashImages.get(cmd.toLowerCase());
	}

	public MenuXMLConfiguration getConfZebra() {
		return (MenuXMLConfiguration) confZebra;
	}

	protected Table createTable(TableViewer tv, int mode) {
		Table table = tv.getTable();
		table.setLayoutData(new GridData(GridData.FILL_BOTH));

		for (int i = 0; i < columnNames.length; i++) {
		    createTableColumn(table, SWT.NONE, columnNames[i], 150);
		}

//		addTableContents(new Object[] {new String[] {""}});
	    table.setHeaderVisible(true);
	    table.setLinesVisible(true);

/*	    // Create the cell editors
	    CellEditor[] editors = new CellEditor[4];
	    editors[0] = new TextCellEditor(table);
	    editors[1] = new CheckboxCellEditor(table);
	    editors[2] = new ComboBoxCellEditor(table, AgeRange.INSTANCES, SWT.READ_ONLY);
	    editors[3] = new ColorCellEditor(table);

	    // Set the editors, cell modifier, and column properties
	    tv.setColumnProperties(columnNames);
	    tv.setCellModifier(new PersonCellModifier(tv));
	    tv.setCellEditors(editors);*/

	    return table;
	}

	protected TableColumn createTableColumn(Table table, int style, String title, int width) {
	    TableColumn tc = new TableColumn(table, style);
	    tc.setText(title);
	    tc.setResizable(true);
	    tc.setWidth(width);
	    tc.pack();

	    return tc;
	}	

	protected void addTableContents(Object[] items) {
		//обнулить таблицу
		tv.getTable().setItemCount(0);
		//назначить новые данные таблице
		tv.setInput(ZebraTableModel.INSTANCE.getLabels());  

/*        for(int i = 0; i < items.length; i++) {
	        String[] item = (String[])items[i];
	        TableItem ti = new TableItem(tv.getTable(), SWT.NONE);
	        ti.setText(item);
	    }*/
	}

	/**
	 * Shows an error
	 *
	 * @param msg the error
	*/
	public void showError(String msg) {
	    MessageDialog.openError(getShell(), "Error", msg);
	}
/*	//вывод сообщения об ошибке
	private void displayError(String msg) {
		try {
			MessageBox box = new MessageBox(shell, SWT.ICON_ERROR | SWT.OK);
			box.setMessage(msg);
			box.open();
		}
		catch (Exception ex) {
			System.out.println("Error:" + msg);			
		}
	}*/

	/**
	 * Creates the menu at the top of the shell where most
	 * of the programs functionality is accessed.
	 *
	 * @return		The <code>Menu</code> widget that was created
	 */
	  protected MenuManager createMenuManager() {
	    // Create the main menu
	    MenuManager mmng = new MenuManager();

	    // Create the File menu
	    MenuManager fileMenu = new MenuManager(confZebra.getString("File_menu_title"));
	    mmng.add(fileMenu);

	    // Add the actions to the File menu
	    fileMenu.add(openAction);
	    fileMenu.add(closeAction);
	    fileMenu.add(new Separator());
	    fileMenu.add(printAction);
	    fileMenu.add(new Separator());
	    fileMenu.add(configAction);
	    fileMenu.add(new Separator());
	    fileMenu.add(exitAction);

	    // Create the Help menu
	    MenuManager helpMenu = new MenuManager("Help");
	    mmng.add(helpMenu);

	    // Add the actions to the Help menu
	    helpMenu.add(aboutAction);

	    return mmng;
	}

	  /**
	   * Creates the toolbar for the application
	   */
	protected ToolBarManager createToolBarManager(int style) {
	    // Create the toolbar manager
	    ToolBarManager tbm = new ToolBarManager(style);
	    // Add the file actions
	    tbm.add(openAction);
	    tbm.add(closeAction);

	    tbm.add(new Separator());
	    tbm.add(printAction);

	    tbm.add(new Separator());
	    tbm.add(configAction);

	    // Add a separator
	    tbm.add(new Separator());

	    // Add the about action
	    tbm.add(aboutAction);

	    tbm.add(new Separator());
	    tbm.add(exitAction);

	    return tbm;
	}

	/**
	* Creates the coolbar for the application
	*/
	protected CoolBarManager createCoolBarManager(int style) {
		// Create the coolbar manager
		CoolBarManager cbm = new CoolBarManager(style);

		// Add the toolbar
		cbm.add(createToolBarManager(SWT.FLAT));

		return cbm;
	}

	/**
	* Creates the status line manager
	*/
	protected StatusLineManager createStatusLineManager() {
		return new StatusLineManager();
	}

/*	private void createHelpMenu(Menu menuBar) {
		//Help Menu
		MenuItem item = new MenuItem(menuBar, SWT.CASCADE);
		item.setText(confZebra.getString("Help_menu_title"));	
		Menu menu = new Menu(shell, SWT.DROP_DOWN);
		item.setMenu(menu);
		
		//Help -> About Text Editor
		MenuItem subItem = new MenuItem(menu, SWT.NONE);
		subItem.setText(confZebra.getString("About"));
		subItem.setImage(getImageFor("help"));
		subItem.addSelectionListener(new SelectionAdapter() {
			public void widgetSelected(SelectionEvent e) {
				MessageBox box = new MessageBox(shell, SWT.NONE);
				box.setText(confZebra.getString("About_1"));
				box.setMessage(confZebra.getString("About_2") + shell.getText());
				box.open();
			}
		});
	}*/

	public void choiceZebraFile() {
		FileDialog fileDialog = new FileDialog(getShell(), SWT.OPEN);

		fileDialog.setFilterExtensions(new String[] {"*.csv;", "*.*"});
		fileDialog.setFilterNames(new String[] {confZebra.getString("Zebra_filter_name") + " (*.csv)", 
												confZebra.getString("All_filter_name") + " (*.*)"});
		loadZebraFile(fileDialog.open());

		getShell().setText(confZebra.getString("Title_bar") + fileDialog.getFileName());
	}

	private void loadZebraFile(String name) {	
		if (name == null) {
			return;
		}

		Cursor waitCursor = new Cursor(getShell().getDisplay(), SWT.CURSOR_WAIT);
		getShell().setCursor(waitCursor);

/*		
		file = new File(name);

		FileReader fileReader = null;
		BufferedReader bufferedReader = null;
		String[] data = new String[0];

		try {
			fileReader = new FileReader(file.getAbsolutePath());
			bufferedReader = new BufferedReader(fileReader);
			String nextLine = bufferedReader.readLine();

			while(nextLine != null) {
				String[] newData = new String[data.length + 1];
				System.arraycopy(data, 0, newData, 0, data.length);
				newData[data.length] = nextLine;
				data = newData;
				nextLine = bufferedReader.readLine();
			}

			bufferedReader.close();
			fileReader.close();
		} catch(FileNotFoundException e) {
			showError(confZebra.getString("File_not_found") + "\n" + file.getName());

			return;
		} catch(IOException ioe) {
			showError(confZebra.getString("IO_error_read") + "\n" + file.getName());

			return;
		} finally {
			if(fileReader != null) {
				try {
					fileReader.close();
				} catch(IOException e) {
					displayError(confZebra.getString("IO_error_close") + "\n" + file.getName());
					return;
				}
			}
		}
		//заполнить массив tableInfo с данными таблицы
        String[][] tableInfo = new String[data.length][table.getColumnCount()];
		int writeIndex = 0;

		for(int i = 0; i < data.length; i++) {
			String[] line = decodeLine(data[i]);
			if (line != null) tableInfo[writeIndex++] = line;
		}
		//обрезать пустой кусок массива 
		if(writeIndex != data.length) {
			String[][] result = new String[writeIndex][table.getColumnCount()];
			System.arraycopy(tableInfo, 0, result, 0, writeIndex);
			tableInfo = result;
		}
		//сортировка данных
		Arrays.sort(tableInfo, new RowComparator(0));
*/		//загрузить массив в грид
//		addTableContents(tableInfo);

		tv.setInput(ZebraTableModel.INSTANCE.getLabels());  

        getShell().setCursor(null);
		waitCursor.dispose();
	
	}

	public boolean printZebraFile() {
/*		//проверить выбран ли файл?
		if (file != null && file.exists()) {
			PrintDialog dialog = new PrintDialog(getShell());
			PrinterData prnSel = dialog.open();
			new FormPrintUnilever(this, file.getAbsolutePath(), prnSel.name);
		}
*/
		return false;
	}

	public boolean closeZebraFile() {
		return true;		
	}

	public boolean configZebraFile() {
		//настройки
		StringWriter stringWriter = new StringWriter();

		ConfigDialog dialog = new ConfigDialog(this, getShell());
		//лейблы параметров
		dialog.setLabels(new String[] {"ZebraPrintFormName", "ZebraPrintFormEAN"});

		String[] values = new String[] {confZebra.getString("ZebraPrintFormName"),
										confZebra.getString("ZebraPrintFormEAN")};
		dialog.setValues(values);

		values = dialog.open();

		if (values != null) {
			//записать изменения в config
			confZebra.setProperty("ZebraPrintFormName", values[0].replace(",", "\\,"));
			confZebra.setProperty("ZebraPrintFormEAN", values[1].replace(",", "\\,"));
	
			try {
//				confZebra.setEncoding("UTF8");
//				confZebra.setOutputProperty(OutputKeys.INDENT, "yes");
				confZebra.save(stringWriter);
				System.out.println(stringWriter.toString());
			} catch (ConfigurationException cex) {
			    // something went wrong, e.g. the file was not found
				showError(cex.getMessage());
			}
//			isModified = true;
		}

		return false;
	}

/*	*//**
	 * To compare entries (rows) by the given column
	 *//*
	private class RowComparator implements Comparator<String []> {
		private int column;
		
		*//**
		 * Constructs a RowComparator given the column index
		 * @param col The index (starting at zero) of the column
		 *//*
		public RowComparator(int col) {
			column = col;
		}
		
		*//**
		 * Compares two rows (type String[]) using the specified
		 * column entry.
		 * @param obj1 First row to compare
		 * @param obj2 Second row to compare
		 * @return negative if obj1 less than obj2, positive if
		 * 			obj1 greater than obj2, and zero if equal.
		 *//*
		public int compare(String[] row1, String[] row2) {
//			String[] row1 = (String[])obj1;
//			String[] row2 = (String[])obj2;
			
			return row1[column].compareTo(row2[column]);
		}
	}
*/
	/**
	 * Closes the application
	*/
	public boolean close() {
	    return super.close();
	}

	/**
	 * Enables or disables the actions
	 *
	 * @param enable true to enable, false to disable
	*/
	private void enableActions(boolean enable) {
/*	    newAction.setEnabled(enable);
	    openAction.setEnabled(enable);
	    saveAction.setEnabled(enable);
	    saveAsAction.setEnabled(enable);
	    addBookAction.setEnabled(enable);
	    removeBookAction.setEnabled(enable);
	    aboutAction.setEnabled(enable);
	    showBookCountAction.setEnabled(enable);*/
	    exitAction.setEnabled(enable);
	}

	public static void main(String[] args) throws FileNotFoundException, PrintException, IOException, ConfigurationException {
//		Zebra appZebra = new Zebra();

		if (args.length > 0) {
//			new FormPrintUnilever(appZebra, args[0], null);
		} else {
			new Zebra().run();
		}
	}
}
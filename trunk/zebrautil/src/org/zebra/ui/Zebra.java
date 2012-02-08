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
import org.eclipse.jface.window.ApplicationWindow;
import org.eclipse.swt.*;
import org.eclipse.swt.events.*;
import org.eclipse.swt.graphics.*;
import org.eclipse.swt.layout.*;
import org.eclipse.swt.printing.PrintDialog;
import org.eclipse.swt.printing.PrinterData;
import org.eclipse.swt.widgets.*;

import org.apache.commons.configuration.ConfigurationException;

import org.library.config.MXMLConfiguration;
import org.library.csv.CSV;
//import org.library.swt.BasicApplication;

import org.zebra.util.FormPrintUnilever;

public class Zebra extends ApplicationWindow {
	// A static instance to the running application
	private static Zebra APP;

	// The actions
/*	private NewAction newAction;
	private OpenAction openAction;
	private SaveAction saveAction;
	private SaveAsAction saveAsAction;
	private AddBookAction addBookAction;
	private RemoveBookAction removeBookAction;
	private ShowBookCountAction showBookCountAction;*/
	private AboutAction aboutAction;
	private ExitAction exitAction;

	private static MXMLConfiguration confZebra = null;

	private Shell shell;
	private Table table;

	private static final String[] columnNames = new String[3];
	private File file = null;
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
/*		hashImages.put("open", new Image(shell.getDisplay(), new Image(shell.getDisplay(), Zebra.class.getResourceAsStream("/org/images/fileopen.png")));
		hashImages.put("close", new Image(shell.getDisplay(), Zebra.class.getResourceAsStream("/org/images/fileclose.png")));
		hashImages.put("print", new Image(shell.getDisplay(), Zebra.class.getResourceAsStream("/org/images/fileprint.png")));
		hashImages.put("configure", new Image(shell.getDisplay(), Zebra.class.getResourceAsStream("/org/images/configure.png")));
		hashImages.put("help", new Image(shell.getDisplay(), Zebra.class.getResourceAsStream("/org/images/help.png")));
		hashImages.put("exit", new Image(shell.getDisplay(), Zebra.class.getResourceAsStream("/org/images/exit.png")));*/
		hashImages.put("help", ImageDescriptor.createFromFile(Zebra.class, "/org/images/help.png"));
		hashImages.put("exit", ImageDescriptor.createFromFile(Zebra.class, "/org/images/exit.png"));

		try	{
			confZebra = new MXMLConfiguration();
			confZebra.setFile(new File("Zebra.xml"));
			//запрет использования разделителей списков
/*			confZebra.setDelimiterParsingDisabled(true);
			confZebra.setAttributeSplittingDisabled(true);
			confZebra.load("Zebra.xml");*/
			confZebra.load();
	
			columnNames[0] = confZebra.getString("Goods_name");
			columnNames[1] = confZebra.getString("Goods_barcode");
			columnNames[2] = confZebra.getString("Number_copies");
		} catch(ConfigurationException cex)	{
		    // something went wrong, e.g. the file was not found
			showError(cex.getMessage());

			return;
		}

/*	    // Create the actions
	    newAction = new NewAction();
	    openAction = new OpenAction();
	    saveAction = new SaveAction();
	    saveAsAction = new SaveAsAction();
	    addBookAction = new AddBookAction();
	    removeBookAction = new RemoveBookAction();
	    showBookCountAction = new ShowBookCountAction();*/
//	    aboutAction = new AboutAction();
	    exitAction = new ExitAction();

//	    addMenuBar();
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
		this.shell = shell;

		// Set the title bar text and the size
		shell.setText("");
//		shell.setSize(table.computeSize(SWT.DEFAULT, SWT.DEFAULT).x, 300);

		shell.addShellListener(new ShellAdapter() {
			public void shellClosed(ShellEvent e) {
				e.doit = closeZebraFile();
			}
		});
	}

	protected Control createContents(Composite parent) {
	    Composite composite = new Composite(parent, SWT.NONE);
	    composite.setLayout(new GridLayout(1, false));

/*
		table = createTable(shell, SWT.SINGLE | SWT.BORDER | SWT.FULL_SELECTION);
 * 	    // Add a checkbox to toggle whether the labels preserve case
	    Button preserveCase = new Button(composite, SWT.CHECK);
	    preserveCase.setText("&Preserve case");

	    // Create the tree viewer to display the file tree
	    final TreeViewer tv = new TreeViewer(composite);
	    tv.getTree().setLayoutData(new GridData(GridData.FILL_BOTH));
	    tv.setContentProvider(new FileTreeContentProvider());
	    tv.setLabelProvider(new FileTreeLabelProvider());
	    tv.setInput("root"); // pass a non-null that will be ignored

	    // When user checks the checkbox, toggle the preserve case attribute
	    // of the label provider
	    preserveCase.addSelectionListener(new SelectionAdapter() {
	      public void widgetSelected(SelectionEvent event) {
	        boolean preserveCase = ((Button) event.widget).getSelection();
	        FileTreeLabelProvider ftlp = (FileTreeLabelProvider) tv
	            .getLabelProvider();
	        ftlp.setPreserveCase(preserveCase);
	      }
	    });*/

	    return composite;
	}

	public ImageDescriptor getImageFor(String cmd) {
		return (ImageDescriptor) hashImages.get(cmd.toLowerCase());
	}

	public MXMLConfiguration getConfZebra() {
		return (MXMLConfiguration) confZebra;
	}

	protected Table createTable(Composite parent, int mode) {
	    table = new Table(parent, mode | SWT.SINGLE | SWT.FULL_SELECTION | 
	                      SWT.V_SCROLL | SWT.H_SCROLL);

	    table.setLayoutData(new GridData(GridData.FILL_BOTH));
		table.setHeaderVisible(true);	

		for(int i = 0; i < columnNames.length; i++) {
		    createTableColumn(table, SWT.NONE, columnNames[i], 150);
		}

//		addTableContents(new Object[] {new String[] {""}});

		return table;
	}

	protected TableColumn createTableColumn(Table table, int style, String title, int width) {
	    TableColumn tc = new TableColumn(table, style);
	    tc.setText(title);
	    tc.setResizable(true);
	    tc.setWidth(width);

	    return tc;
	}	

	protected void addTableContents(Object[] items) {
		//обнулить таблицу
        table.setItemCount(0);

        for(int i = 0; i < items.length; i++) {
	        String[] item = (String[])items[i];
	        TableItem ti = new TableItem(table, SWT.NONE);
	        ti.setText(item);
	    }
	}

	/**
	 * Converts an encoded <code>String</code> to a String array representing a table entry.
	 */
	private String[] decodeLine(String line) {
		if(line == null) return null;
		
		String[] parsedLine = new String[table.getColumnCount()];
		Iterator<String> e = csv.parse(line).iterator();
    	int i = 0;

		while(e.hasNext() && i < table.getColumnCount()) {
			parsedLine[i] = e.next().toString().trim();
			i++;
		}

		return parsedLine;
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

/*	private ToolBar createCoolBar() {
		ToolBar toolBar = new ToolBar(shell, SWT.HORIZONTAL | SWT.FLAT);
		toolBar.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));

		ToolItem item = new ToolItem(toolBar, SWT.PUSH);
		item.setImage(getImageFor("open"));
		item.setToolTipText(confZebra.getMString("Open_zebra_file"));
		item.addSelectionListener(new SelectionAdapter() {
			public void widgetSelected(SelectionEvent event) {
				closeZebraFile();
				choiceZebraFile();
			}
		});	

		item = new ToolItem(toolBar, SWT.PUSH);
		item.setImage(getImageFor("close"));
		item.setToolTipText(confZebra.getMString("Close_zebra_file"));
		item.addSelectionListener(new SelectionAdapter() {
			public void widgetSelected(SelectionEvent event) {
				closeZebraFile();
			}
		});	

		item = new ToolItem(toolBar, SWT.SEPARATOR);

		item = new ToolItem(toolBar, SWT.PUSH);
		item.setImage(getImageFor("configure"));
		item.setToolTipText(confZebra.getMString("Config_print_file"));
		item.addSelectionListener(new SelectionAdapter() {
			public void widgetSelected(SelectionEvent event) {
				configZebraFile();
			}
		});

		item = new ToolItem(toolBar, SWT.PUSH);
		item.setImage(getImageFor("print"));
		item.setToolTipText(confZebra.getMString("Print_zebra_file"));
		item.addSelectionListener(new SelectionAdapter() {
			public void widgetSelected(SelectionEvent event) {
				printZebraFile();
			}
		});

		item = new ToolItem(toolBar, SWT.SEPARATOR);

		item = new ToolItem(toolBar, SWT.PUSH);
		item.setImage(getImageFor("exit"));
		item.setToolTipText(confZebra.getMString("Exit"));
		item.addSelectionListener(new SelectionAdapter() {
			public void widgetSelected(SelectionEvent event) {
				shell.close();
			}
		});

		return toolBar;
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
	    MenuManager fileMenu = new MenuManager("File");
	    mmng.add(fileMenu);

/*	    // Add the actions to the File menu
	    fileMenu.add(newAction);
	    fileMenu.add(openAction);
	    fileMenu.add(saveAction);
	    fileMenu.add(saveAsAction);
	    fileMenu.add(new Separator());
	    fileMenu.add(exitAction);

	    // Create the Book menu
	    MenuManager bookMenu = new MenuManager("Book");
	    mm.add(bookMenu);

	    // Add the actions to the Book menu
	    bookMenu.add(addBookAction);
	    bookMenu.add(removeBookAction);

	    // Create the View menu
	    MenuManager viewMenu = new MenuManager("View");
	    mm.add(viewMenu);

	    // Add the actions to the View menu
	    viewMenu.add(showBookCountAction);*/

	    // Create the Help menu
	    MenuManager helpMenu = new MenuManager("Help");
	    mmng.add(helpMenu);

	    // Add the actions to the Help menu
	    helpMenu.add(aboutAction);

	    return mmng;

/*	    Menu menuBar = new Menu(shell, SWT.BAR);
		shell.setMenuBar(menuBar);
		
		//create each header and subMenu for the menuBar
		createFileMenu(menuBar);
		createHelpMenu(menuBar);
		
		return menuBar;*/
	}

	  /**
	   * Creates the toolbar for the application
	   */
	protected ToolBarManager createToolBarManager(int style) {
	    // Create the toolbar manager
	    ToolBarManager tbm = new ToolBarManager(style);
	    // Add the file actions
/*	    tbm.add(newAction);
	    tbm.add(openAction);
	    tbm.add(saveAction);
	    tbm.add(saveAsAction);*/

	    // Add a separator
	    tbm.add(new Separator());

	    // Add the book actions
/*	    tbm.add(addBookAction);
	    tbm.add(removeBookAction);*/

	    // Add a separator
	    tbm.add(new Separator());

	    // Add the show book count, which will appear as a toggle button
/*	    tbm.add(showBookCountAction);

	    // Add a separator
	    tbm.add(new Separator());*/

	    // Add the about action
//	    tbm.add(aboutAction);
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

/*	private void createFileMenu(Menu menuBar) {
		//File menu.
		MenuItem item = new MenuItem(menuBar, SWT.CASCADE);
		item.setText(confZebra.getMString("File_menu_title"));
		Menu menu = new Menu(shell, SWT.DROP_DOWN);
		item.setMenu(menu);
		menu.addMenuListener(new MenuAdapter() {
			public void menuShown(MenuEvent e) {
				Menu menu = (Menu)e.widget;
				MenuItem[] items = menu.getItems();
				items[1].setEnabled(table.getSelectionCount() != 0); // edit contact
				items[5].setEnabled((file != null) && isModified); // save
				items[6].setEnabled(table.getItemCount() != 0); // save as 
			}
		});
		
		//File -> Open
		MenuItem subItem = new MenuItem(menu, SWT.NONE);
		subItem.setText(confZebra.getMString("Open_zebra_file"));
		subItem.setImage(getImageFor("open"));
		subItem.setAccelerator(SWT.MOD1 + 'O');
		subItem.addSelectionListener(new SelectionAdapter() {
			public void widgetSelected(SelectionEvent e) {
				choiceZebraFile();
			}
		});

		//File -> Close
		subItem = new MenuItem(menu, SWT.NONE);
		subItem.setText(confZebra.getMString("Close_zebra_file"));
		subItem.setImage(getImageFor("close"));
		subItem.setAccelerator(SWT.MOD1 + 'W');
		subItem.addSelectionListener(new SelectionAdapter() {
			public void widgetSelected(SelectionEvent e) {
				closeZebraFile();
			}
		});

		//File -> Config.
		subItem = new MenuItem(menu, SWT.NONE);
		subItem.setText(confZebra.getMString("Config_print_file"));
		subItem.setImage(getImageFor("configure"));
		subItem.addSelectionListener(new SelectionAdapter() {
			public void widgetSelected(SelectionEvent e) {
				configZebraFile();
			}
		});

		//File -> Print.
		subItem = new MenuItem(menu, SWT.NONE);
		subItem.setText(confZebra.getMString("Print_zebra_file"));
		subItem.setImage(getImageFor("print"));
		subItem.setAccelerator(SWT.MOD1 + 'P');
		subItem.addSelectionListener(new SelectionAdapter() {
			public void widgetSelected(SelectionEvent e) {
				printZebraFile();
			}
		});

		new MenuItem(menu, SWT.SEPARATOR);
		
		//File -> Exit.
		subItem = new MenuItem(menu, SWT.NONE);
		subItem.setText(confZebra.getMString("Exit"));
		subItem.setImage(getImageFor("exit"));
		subItem.setAccelerator(SWT.ALT + 'X');
		subItem.addSelectionListener(new SelectionAdapter() {
			public void widgetSelected(SelectionEvent e) {
				shell.close();
			}
		});
	}*/

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

	private void choiceZebraFile() {
		//закрыть старый файл
		closeZebraFile();

		FileDialog fileDialog = new FileDialog(shell, SWT.OPEN);

		fileDialog.setFilterExtensions(new String[] {"*.csv;", "*.*"});
		fileDialog.setFilterNames(new String[] {confZebra.getString("Zebra_filter_name") + " (*.csv)", 
												confZebra.getString("All_filter_name") + " (*.*)"});
		loadZebraFile(fileDialog.open());

		shell.setText(confZebra.getString("Title_bar") + fileDialog.getFileName());
	}

	private void loadZebraFile(String name) {	
		if(name == null) return;
		file = new File(name);

		Cursor waitCursor = new Cursor(shell.getDisplay(), SWT.CURSOR_WAIT);
		shell.setCursor(waitCursor);

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
			shell.setCursor(null);
			waitCursor.dispose();
		
/*			if(fileReader != null) {
				try {
					fileReader.close();
				} catch(IOException e) {
					displayError(confZebra.getString("IO_error_close") + "\n" + file.getName());
					return;
				}
			}
*/		}
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
		//загрузить массив в грид
		addTableContents(tableInfo);
	}

	private boolean closeZebraFile() {
		//обнулить таблицу
        table.setItemCount(0); 
        file = null;

        return true;
	}

	private boolean printZebraFile() {
		//проверить выбран ли файл?
		if(file != null && file.exists()) {
			PrintDialog dialog = new PrintDialog(shell);
			PrinterData prnSel = dialog.open();
			new FormPrintUnilever(this, file.getAbsolutePath(), prnSel.name);
		}

		return false;
	}

	private boolean configZebraFile() {
		//настройки
		StringWriter stringWriter = new StringWriter();

		ConfigDialog dialog = new ConfigDialog(this, shell);
		//лейблы параметров
		dialog.setLabels(new String[] {"ZebraPrintFormName", "ZebraPrintFormEAN"});

		String[] values = new String[] {confZebra.getString("ZebraPrintFormName"),
										confZebra.getString("ZebraPrintFormEAN")};
		dialog.setValues(values);

		values = dialog.open();

		if(values != null) {
			//записать изменения в config
			confZebra.setProperty("ZebraPrintFormName", values[0].replace(",", "\\,"));
			confZebra.setProperty("ZebraPrintFormEAN", values[1].replace(",", "\\,"));
	
			try {
//				confZebra.setEncoding("UTF8");
//				confZebra.setOutputProperty(OutputKeys.INDENT, "yes");
				confZebra.save(stringWriter);
				System.out.println(stringWriter.toString());
			} catch(ConfigurationException cex) {
			    // something went wrong, e.g. the file was not found
				showError(cex.getMessage());
			}
//			isModified = true;
		}

		return false;
	}

	/**
	 * To compare entries (rows) by the given column
	 */
	private class RowComparator implements Comparator<String []> {
		private int column;
		
		/**
		 * Constructs a RowComparator given the column index
		 * @param col The index (starting at zero) of the column
		 */
		public RowComparator(int col) {
			column = col;
		}
		
		/**
		 * Compares two rows (type String[]) using the specified
		 * column entry.
		 * @param obj1 First row to compare
		 * @param obj2 Second row to compare
		 * @return negative if obj1 less than obj2, positive if
		 * 			obj1 greater than obj2, and zero if equal.
		 */
		public int compare(String[] row1, String[] row2) {
//			String[] row1 = (String[])obj1;
//			String[] row2 = (String[])obj2;
			
			return row1[column].compareTo(row2[column]);
		}
	}

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

		if(args.length > 0) {
//			new FormPrintUnilever(appZebra, args[0], null);
		}
		else {
			new Zebra().run();
//		    run(Zebra.class.getName(), "Zebra...", SWT.NONE, 600, 300, args);
//		    Display display = new Display();

//			hashImages = new HashMap<String, Image>();
//			hashImages.put("open", createImage(shell.getDisplay(), Zebra.class.getResourceAsStream("/org/images/fileopen.png")));
//			hashImages.put("open", new Image(display, Zebra.class.getResourceAsStream("/org/images/fileopen.png")));
//			hashImages.put("close", new Image(display, Zebra.class.getResourceAsStream("/org/images/fileclose.png")));
//			hashImages.put("print", new Image(display, Zebra.class.getResourceAsStream("/org/images/fileprint.png")));
//			hashImages.put("configure", new Image(display, Zebra.class.getResourceAsStream("/org/images/configure.png")));
//			hashImages.put("help", new Image(display, Zebra.class.getResourceAsStream("/org/images/help.png")));
//			hashImages.put("exit", new Image(display, Zebra.class.getResourceAsStream("/org/images/exit.png")));

//			Shell shell = appZebra.initGui(display);

//			while(!shell.isDisposed()) {
//				if(!display.readAndDispatch())
//					display.sleep();
//			}

//			display.dispose();
		}
	}
}
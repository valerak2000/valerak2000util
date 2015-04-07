package org.rp5;

import java.util.HashMap;

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
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.*;
import org.eclipse.swt.graphics.*;
import org.eclipse.swt.layout.*;
import org.eclipse.swt.widgets.*;
import org.rp5.ui.model.DownloadWeatherRp5;
import org.rp5.ui.model.ParseXml;
import org.rp5.ui.model.Rp5TableModel;
import org.rp5.ui.model.WeatherRp5;
import org.rp5.ui.view.AboutAction;
import org.rp5.ui.view.ExitAction;
import org.rp5.ui.view.Rp5ContentProvider;
import org.rp5.ui.view.Rp5LabelProvider;

import com.btr.proxy.search.ProxySearch;

/**
 * @param args 1 - Path to DataBase
 *             2 - Name of DataBase
 *             3 - User Name
 *             4 - User Password
 *             5 - Count of keys
 * @throws SAXException
 * @throws ParserConfigurationException
 */
public class Rp5 extends ApplicationWindow {
	// A static instance to the running application
	private static Rp5 APP;
	private TableViewer tv;

	// The actions
//	private OpenAction openAction;
//	private CloseAction closeAction;
//	private ConfigAction configAction;
//	private PrintAction printAction;
//	private AboutAction aboutAction;
	private ExitAction exitAction;

	private static final String[] columnNames = new String[13];
	private static HashMap<String, ImageDescriptor> hashImages;

	{
		APP = this;
	}
	/**
	 * Gets the running application
	*/
	public static final Rp5 getApp() {
	    return APP;
	}

	public Rp5() {
		super(null);

	    hashImages = new HashMap<String, ImageDescriptor>();
		hashImages.put("open", ImageDescriptor.createFromFile(Rp5.class, "/org/images/fileopen.png"));
		hashImages.put("close", ImageDescriptor.createFromFile(Rp5.class, "/org/images/fileclose.png"));
		hashImages.put("print", ImageDescriptor.createFromFile(Rp5.class, "/org/images/fileprint.png"));
		hashImages.put("configure", ImageDescriptor.createFromFile(Rp5.class, "/org/images/configure.png"));
		hashImages.put("help", ImageDescriptor.createFromFile(Rp5.class, "/org/images/help.png"));
		hashImages.put("about", ImageDescriptor.createFromFile(Rp5.class, "/org/images/about.png"));
		hashImages.put("exit", ImageDescriptor.createFromFile(Rp5.class, "/org/images/exit.png"));

		columnNames[0] = "time_step";
		columnNames[1] = "datetime";
		columnNames[2] = "G";
		columnNames[3] = "HHii";
		columnNames[4] = "cloud_cover";
		columnNames[5] = "precipitation";
		columnNames[6] = "pressure";
		columnNames[7] = "temperature";
		columnNames[8] = "humidity";
		columnNames[9] = "wind_direction";
		columnNames[10] = "wind_velocity";
		columnNames[11] = "falls";
		columnNames[12] = "drops";

	    // Create the actions
//	    openAction = new OpenAction();
//	    closeAction = new CloseAction();
//	    configAction = new ConfigAction();
//	    printAction = new PrintAction();
//	    aboutAction = new AboutAction();
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

		// Set the title bar text and the size
		shell.setText("");
		//reaction on close main window by "close button" 
		shell.addShellListener(new ShellAdapter() {
			public void shellClosed(ShellEvent e) {
			}
		});
	}

	protected Control createContents(Composite parent) {
	    Composite composite = new Composite(parent, SWT.NONE);
	    composite.setLayout(new GridLayout(1, false));
	    // Add the TableViewer
	    final TableViewer tv = new TableViewer(composite, SWT.FULL_SELECTION);
	    tv.setContentProvider(new Rp5ContentProvider());
	    tv.setLabelProvider(new Rp5LabelProvider());
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

	protected Table createTable(TableViewer tv, int mode) {
		Table table = tv.getTable();
		table.setLayoutData(new GridData(GridData.FILL_BOTH));

		for (int i = 0; i < columnNames.length; i++) {
		    createTableColumn(table, SWT.NONE, columnNames[i], 150);
		}

		addTableContents(new Object[] {new String[] {""}});
	    table.setHeaderVisible(true);
	    table.setLinesVisible(true);
/*
	    // Create the cell editors
	    CellEditor[] editors = new CellEditor[4];
	    editors[0] = new TextCellEditor(table);
	    editors[1] = new CheckboxCellEditor(table);
	    editors[2] = new ComboBoxCellEditor(table, AgeRange.INSTANCES, SWT.READ_ONLY);
	    editors[3] = new ColorCellEditor(table);

	    // Set the editors, cell modifier, and column properties
	    tv.setColumnProperties(columnNames);
	    tv.setCellModifier(new PersonCellModifier(tv));
	    tv.setCellEditors(editors);
*/
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
//		tv.getTable().setItemCount(0);
//		tv.setInput(Rp5TableModel.INSTANCE.getLabels());  

//		for(int i = 0; i < items.length; i++) {
//	        String[] item = (String[]) items[i];
//	        TableItem ti = new TableItem(tv.getTable(), SWT.NONE);
//	        ti.setText(item);
//	    }
	}

	
	/**
	 * Shows an error
	 *
	 * @param msg the error
	*/
	public void showError(String msg) {
	    MessageDialog.openError(getShell(), "Error", msg);
	}

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
	    MenuManager fileMenu = new MenuManager("File_menu_title");
	    mmng.add(fileMenu);

	    // Add the actions to the File menu
//	    fileMenu.add(openAction);
//	    fileMenu.add(closeAction);
//	    fileMenu.add(new Separator());
//	    fileMenu.add(printAction);
//	    fileMenu.add(new Separator());
//	    fileMenu.add(configAction);
//	    fileMenu.add(new Separator());
	    fileMenu.add(exitAction);

	    // Create the Help menu
	    MenuManager helpMenu = new MenuManager("Help");
	    mmng.add(helpMenu);

	    // Add the actions to the Help menu
//	    helpMenu.add(aboutAction);

	    return mmng;
	}

	  /**
	   * Creates the toolbar for the application
	   */

	protected ToolBarManager createToolBarManager(int style) {
	    // Create the toolbar manager
	    ToolBarManager tbm = new ToolBarManager(style);
	    // Add the file actions
//	    tbm.add(openAction);
//	    tbm.add(closeAction);

//	    tbm.add(new Separator());
//	    tbm.add(printAction);

//	    tbm.add(new Separator());
//	    tbm.add(configAction);

	    // Add a separator
	    tbm.add(new Separator());

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
/*
	private void enableActions(boolean enable) {
	    newAction.setEnabled(enable);
	    openAction.setEnabled(enable);
	    saveAction.setEnabled(enable);
	    saveAsAction.setEnabled(enable);
	    addBookAction.setEnabled(enable);
	    removeBookAction.setEnabled(enable);
	    showBookCountAction.setEnabled(enable);
//	    aboutAction.setEnabled(enable);
//	    exitAction.setEnabled(enable);
	}
*/
	public static void main(String[] args) {
		Rp5 rp5 = new Rp5();
    	rp5.run();
/*
		ProxySearch proxySearch = ProxySearch.getDefaultProxySearch();
//    	   	ProxySearch.main(null);
    	
       	ProxySelector myProxySelector = proxySearch.getProxySelector();
    	ProxySelector.setDefault(myProxySelector);
 
    	DownloadWeatherRp5 dwRp5 = new DownloadWeatherRp5();
 
//    	InputStream ruIs = new FileInputStream("ru.xml");

    	ParseXml px = new ParseXml();
    	List<WeatherRp5> wrp5 = px.parseWeather(dwRp5.getWeather("4429"));
        
    	for(WeatherRp5 iwr5: wrp5) {
    		iwr5.Print();
    	}
//    	px.parseWeather(ruIs);
        

//    	ruIs.close(); 
*/
    }
}
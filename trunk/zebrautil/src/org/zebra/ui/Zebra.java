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
import org.library.swt.BasicApplication;

import org.zebra.util.FormPrintUnilever;

public class Zebra extends BasicApplication {
	private static MXMLConfiguration confZebra = null;

//	private Shell shell;
	private Table table;

	private static final String[] columnNames = new String[3];
	private File file = null;
	private CSV csv = new CSV(';');

	private static HashMap<String, Image> hashImages;

	public Zebra(Shell shell, int style) throws ConfigurationException {
        super(shell, style);   // must always supply parent and style
//		this.shell = shell;

		hashImages = new HashMap<String, Image>();
		hashImages.put("open", createImage(shell.getDisplay(), "/org/images/fileopen.png"));
		hashImages.put("close", createImage(shell.getDisplay(), "/org/images/fileclose.png"));
		hashImages.put("print", createImage(shell.getDisplay(), "/org/images/fileprint.png"));
		hashImages.put("configure", createImage(shell.getDisplay(), "/org/images/configure.png"));
		hashImages.put("help", createImage(shell.getDisplay(), "/org/images/help.png"));
		hashImages.put("exit", createImage(shell.getDisplay(), "/org/images/exit.png"));

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
			displayError(cex.getMessage());

			return;
		}
	}

	public MXMLConfiguration getConfZebra() {
		return confZebra;
	}

	private Image getImageFor(String cmd) {
		return (Image) hashImages.get(cmd.toLowerCase());
	}

    protected void createGui(Zebra app) {
    	createMenuBar();
		createToolBar();

		table = createTable(shell, SWT.SINGLE | SWT.BORDER | SWT.FULL_SELECTION);
    }

 /*   void createShell(Display display) {
		shell = new Shell (display);
		GridLayout layout = new GridLayout();
		layout.numColumns = 1;
		shell.setLayout(layout);

		shell.addShellListener(new ShellAdapter() {
			public void shellClosed(ShellEvent e) {
				e.doit = closeZebraFile();
			}
		});
	}*/

    /** Allow subclasses to initialize the GUI */
    protected void initGui() {
		shell.setSize(table.computeSize(SWT.DEFAULT, SWT.DEFAULT).x, 300);
		shell.open();

//		return shell;
    }

/*	public Shell initGui(Display display) {
		createShell(display);
		createMenuBar();
		createToolBar();

		table = createTable(shell, SWT.SINGLE | SWT.BORDER | SWT.FULL_SELECTION);

		shell.setSize(table.computeSize(SWT.DEFAULT, SWT.DEFAULT).x, 300);
		shell.open();

		return shell;
	}*/

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

	//вывод сообщения об ошибке
	private void displayError(String msg) {
		try {
			MessageBox box = new MessageBox(shell, SWT.ICON_ERROR | SWT.OK);
			box.setMessage(msg);
			box.open();
		}
		catch (Exception ex) {
			System.out.println("Error:" + msg);			
		}
	}

	private ToolBar createToolBar() {
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
	}
	/**
	 * Creates the menu at the top of the shell where most
	 * of the programs functionality is accessed.
	 *
	 * @return		The <code>Menu</code> widget that was created
	 */
	private Menu createMenuBar() {
		Menu menuBar = new Menu(shell, SWT.BAR);
		shell.setMenuBar(menuBar);
		
		//create each header and subMenu for the menuBar
		createFileMenu(menuBar);
		createHelpMenu(menuBar);
		
		return menuBar;
	}

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
			displayError(confZebra.getString("File_not_found") + "\n" + file.getName());

			return;
		} catch(IOException ioe) {
			displayError(confZebra.getString("IO_error_read") + "\n" + file.getName());

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
				displayError(cex.getMessage());
			}
//			isModified = true;
		}

		return false;
	}

	/**
	 * Creates all the items located in the File submenu and
	 * associate all the menu items with their appropriate
	 * functions.
	 *
	 * @param	menuBar Menu
	 *				the <code>Menu</code> that file contain
	 *				the File submenu.
	 */
	private void createFileMenu(Menu menuBar) {
		//File menu.
		MenuItem item = new MenuItem(menuBar, SWT.CASCADE);
		item.setText(confZebra.getMString("File_menu_title"));
		Menu menu = new Menu(shell, SWT.DROP_DOWN);
		item.setMenu(menu);
		/** 
		 * Adds a listener to handle enabling and disabling 
		 * some items in the Edit submenu.
		 */
		menu.addMenuListener(new MenuAdapter() {
			public void menuShown(MenuEvent e) {
/*				Menu menu = (Menu)e.widget;
				MenuItem[] items = menu.getItems();
				items[1].setEnabled(table.getSelectionCount() != 0); // edit contact
				items[5].setEnabled((file != null) && isModified); // save
				items[6].setEnabled(table.getItemCount() != 0); // save as */
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
	}

	/**
	 * Creates all the items located in the Help submenu and
	 * associate all the menu items with their appropriate
	 * functions.
	 *
	 * @param	menuBar	Menu
	 *				the <code>Menu</code> that file contain
	 *				the Help submenu.
	 */
	private void createHelpMenu(Menu menuBar) {
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
	 * @param args
	 * @throws IOException 
	 * @throws PrintException 
	 * @throws FileNotFoundException 
	 * @throws ConfigurationException 
	 */
	/**
	 * @param args
	 * @throws FileNotFoundException
	 * @throws PrintException
	 * @throws IOException
	 * @throws ConfigurationException
	 */
	public static void main(String[] args) throws FileNotFoundException, PrintException, IOException, ConfigurationException {
//		Zebra appZebra = new Zebra();

		if(args.length > 0) {
//			new FormPrintUnilever(appZebra, args[0], null);
		}
		else {
		    run(Zebra.class.getName(), "Zebra...", SWT.NONE, 600, 300, args);
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
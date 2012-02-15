package org.zebra.ui;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Cursor;
import org.library.csv.CSV;

/**
 * This class contains the data model for the ZebraTable
 */
public enum ZebraTableModel {
    INSTANCE;  
	private CSV csv = new CSV(';');
    private List<ZebraLabel> labels;  
	private File file = null;

  /**
   * Constructs a PlayerTableModel Fills the model with data
   */
    private ZebraTableModel() {
    	labels = new ArrayList<ZebraLabel>();  
    	// Image here some fancy database access to read the persons and to  
    	// put them into the model  
    	labels.add(new ZebraLabel("Rainer", "Zufall", 1));  
    }  

	public List<ZebraLabel> getLabels() {  
		return labels;  
	}  
	private void loadZebraFile(String name) {	
    	labels.clear();
		if(name == null) return;
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
	 * Converts an encoded <code>String</code> to a String array representing a table entry.
	 */
	private String[] decodeLine(String line) {
		if(line == null) return null;
		
		String[] parsedLine = new String[tv.getTable().getColumnCount()];
		Iterator<String> e = csv.parse(line).iterator();
    	int i = 0;

		while(e.hasNext() && i < tv.getTable().getColumnCount()) {
			parsedLine[i] = e.next().toString().trim();
			i++;
		}

		return parsedLine;
	}

	public boolean closeZebraFile() {
		//обнулить таблицу
		tv.getTable().setItemCount(0); 
        file = null;

        return true;
	}

}
package org.zebra.util;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import javax.print.*;
import javax.print.attribute.*;
import javax.print.attribute.standard.*;
import java.util.Iterator;

//import org.apache.commons.configuration.XMLConfiguration;
//import org.apache.commons.configuration.ConfigurationException;
//import org.apache.commons.configuration.ConfigurationFactory;

import org.config.MXMLConfiguration;
import org.csvutil.CSV;
import org.zebra.ui.Zebra;

public class FormPrintUnilever {
	PrintService psZebra = null;
	MXMLConfiguration confZebra = null;
	CSV csv = new CSV(';');

	public FormPrintUnilever(Zebra appZebra, String fileName, String prnName) {
		try {
			confZebra = appZebra.getConfZebra();
			psZebra = getZebraPrinterPS(prnName);
	
			if (psZebra == null) {
				System.out.println(prnName + " is not found!");
	
				return;
			}
			else
				prnForm(csv, new BufferedReader(new FileReader(fileName)));
		} catch (FileNotFoundException fnfe) {
			// TODO Auto-generated catch block
			fnfe.printStackTrace();
		}
	}

	public PrintService getZebraPrinterPS(String prnName) {
		PrintService psZebra = null;
		String sPrinterName = null;

		if (prnName == null || prnName.isEmpty())
			prnName = "zebra";

		PrintService[] services = PrintServiceLookup.lookupPrintServices(null, null);

		for (int i = 0; i < services.length; i++) {
			PrintServiceAttribute attr = services[i].getAttribute(PrinterName.class);
			sPrinterName = ((PrinterName)attr).getValue();
		
			if (sPrinterName.toLowerCase().indexOf(prnName.toLowerCase()) >= 0) {
				psZebra = services[i];

				break;
			}
		}

		return psZebra;
	}
	
	public void prnForm(CSV csv, BufferedReader fpBuff) {
		//сбросим старые настройки форм
		String s = confZebra.getString("ZebraPrintBegin"), line, nameGoodsCSV, nameGoods;

		try {
			while ((line = fpBuff.readLine()) != null) {
		    	int i = 0;
				//кодировка 1251, плотность печати 11
				s = s + confZebra.getString("ZebraPrintFormHeader");

				for(Iterator<String> e = csv.parse(line).iterator(); e.hasNext(); ) {
		    		switch(i++) {
		    		case 0:
		    			nameGoodsCSV = e.next().toString().trim();
		    			//форматим строку
		    			if(nameGoodsCSV.length() >= 30) {
		    				nameGoods = nameGoodsCSV.substring(0, 30)
		    						   .concat("\\&")
		    						   .concat(nameGoodsCSV.substring(30, nameGoodsCSV.length() >= 60 ? 60: nameGoodsCSV.length()));
		    			}
		    			else {
		    				//берем целиком поскольку маленькая
		    				nameGoods = nameGoodsCSV.substring(0, nameGoodsCSV.length());
		    			}
						//поле со шрифтом CONSOLA
		    	    	s = s.concat(confZebra.getString("ZebraPrintFormName").replace("%NAME%", nameGoods));
//		    	    	s = s.concat("^FO40,18^A@N,21,20,E:CONSOLA.FNT^FB340,2,0,C^FD" + nameGoods + "^FS\r\n");
	
		    	    	break;
		    	    case 1:
		    			//бар-код EAN-13 плотность линий 3
		    			s = s.concat(confZebra.getString("ZebraPrintFormEAN").replace("%EAN%", e.next().toString().trim()));
//		    			s = s.concat("^FO80,65^BY3^BEN,100,Y,N^FD" + e.next().toString().trim() + "^FS\r\n");
	
		    			break;
		    	    case 2:
		    	    	int numCpy;
	
		    	    	try {
		    	    		numCpy = Integer.parseInt(e.next().toString());						
						} catch (NumberFormatException ne) {
							numCpy = 0;
						}
	
		    	    	if(numCpy > 1)
			    			s = s.concat(confZebra.getString("ZebraPrintFormNCPY").replace("%NUMCPY%", Integer.toString(numCpy)));
//		    	    		s = s.concat("^PQ" + numCpy + "\r\n");
		    		}
		    	}
		    	//конец лабела
				s = s.concat(confZebra.getString("ZebraPrintFormTale"));
			}
			//вывести на принтер
			byte[] by = s.getBytes();
			DocFlavor psInFormat = DocFlavor.BYTE_ARRAY.AUTOSENSE;
			Doc doc = new SimpleDoc(by, psInFormat, null);
			PrintRequestAttributeSet aset = new HashPrintRequestAttributeSet();
			//aset.add(new Copies(1));
			//aset.add(MediaSize.A4);
			//aset.add(Sides.DUPLEX);
	
			DocPrintJob job = psZebra.createPrintJob();
	
			try {
				job.print(doc, aset);
			} catch (PrintException pe) {
				pe.printStackTrace();
			}
		} catch (IOException ioe) {
			// TODO Auto-generated catch block
			ioe.printStackTrace();
		}
	}
}
package org.rp5;

import javax.xml.parsers.ParserConfigurationException;

import org.rp5.DownloadWeather;
import org.rp5.ParseXml;
import org.xml.sax.SAXException;

/**
 * @param args
 * 1 - Path to DataBase
 * 2 - Name of DataBase
 * 3 - User Name
 * 4 - User Password
 * 5 - Count of keys 
 * @throws SAXException 
 * @throws ParserConfigurationException 
 */
public class Rp5 {
    public static void main(String[] args) throws Exception{
    	String wr;
/*    	DownloadWeather dw = new DownloadWeather();
    	wr = dw.getWeather();
    	System.out.println(wr);
    	*/
    	wr = "";
    	ParseXml px = new ParseXml();
    	px.parseWeather(wr);
    }
}
package org.rp5;

import java.io.FileInputStream;
import java.io.InputStream;
import org.rp5.DownloadWeather;
import org.rp5.ParseXml;
/**
 * @param args 1 - Path to DataBase
 *             2 - Name of DataBase
 *             3 - User Name
 *             4 - User Password
 *             5 - Count of keys
 * @throws SAXException
 * @throws ParserConfigurationException
 */
public class Rp5 {
    public static void main(String[] args) throws Exception {
    	DownloadWeather dw = new DownloadWeather();
 
//    	InputStream ruIs = new FileInputStream("ru.xml");

    	ParseXml px = new ParseXml();
//    	px.parseWeather(ruIs);
        px.parseWeather(dw.getWeather());

//    	ruIs.close(); 
    }
}
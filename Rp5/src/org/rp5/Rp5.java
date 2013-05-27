package org.rp5;

<<<<<<< .mine
=======
import java.io.FileInputStream;
import java.io.InputStream;

>>>>>>> .r108
<<<<<<< .mine
import org.rp5.DownloadWeather;
import org.rp5.ParseXml;
=======
>>>>>>> .r108
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
<<<<<<< .mine
    public static void main(String[] args) throws Exception {
    	DownloadWeather dw = new DownloadWeather();
/*        ParseSAX px = new ParseSAX();
        px.parseWeather(wr);
        File ruxml = new File("ru.xml");
*/
        ParseXml px = new ParseXml();
        px.parseWeather(dw.getWeather());
=======
    public static void main(String[] args) throws Exception {
/*    	DownloadWeather dw = new DownloadWeather();
    	wr = dw.getWeather();
    	System.out.println(wr);
    	*/
    	InputStream ruIs = new FileInputStream("ru.xml");

    	ParseXml px = new ParseXml();
    	px.parseWeather(ruIs);

    	ruIs.close(); 
>>>>>>> .r108
    }
}
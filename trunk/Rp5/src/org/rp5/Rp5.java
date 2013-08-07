package org.rp5;

import java.io.FileInputStream;
import java.io.InputStream;
import java.net.InetSocketAddress;
import java.net.Proxy;
import java.net.ProxySelector;
import java.util.List;

import org.rp5.DownloadWeatherRp5;
import org.rp5.ParseXml;

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
public class Rp5 {
    public static void main(String[] args) throws Exception {
    	ProxySearch proxySearch = ProxySearch.getDefaultProxySearch();
/*    	   	ProxySearch.main(null);
       	System.exit(0);*/
    	
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
 
    }
}
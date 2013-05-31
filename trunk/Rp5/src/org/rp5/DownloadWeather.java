package org.rp5;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;

import org.apache.commons.io.IOUtils;

public class DownloadWeather {
    private String wr;

    public InputStream getWeather() throws Exception {
        InputStream in = null;
        InputStream out = null;

        try {
        	/*System.setProperty("http.proxyHost", "172.16.0.91");
        	System.setProperty("http.proxyPort", "16541");
        	System.setProperty("http.proxyUser", "RSTYLE97\\kozlitin.va");
        	System.setProperty("http.proxyPassword", "Rfvytgfl");*/
        	
            URL url = new URL("http://rp5.ru/xml/4429/00000/ru");
            URLConnection uc = url.openConnection();
            /*
            Proxy proxy = new Proxy(Proxy.Type.HTTP, new InetSocketAddress("my.proxy.example.com", 3128));
			URLConnection yc = url.openConnection(proxy);
			System.setProperty("java.net.useSystemProxies","true");
            List l = ProxySelector.getDefault().select(
                        new URI("http://www.yahoo.com/"));

            for (Iterator iter = l.iterator(); iter.hasNext(); ) {

                Proxy proxy = (Proxy) iter.next();

                System.out.println("proxy hostname : " + proxy.type());

                InetSocketAddress addr = (InetSocketAddress)
                    proxy.address();

                if(addr == null) {

                    System.out.println("No Proxy");

                } else {

                    System.out.println("proxy hostname : " + 
                            addr.getHostName());

                    System.out.println("proxy port : " + 
                            addr.getPort());

                }
            }
             */

            try {
                in = uc.getInputStream();
                out = IOUtils.toBufferedInputStream(in);//toString(in);
            } catch (IOException ioe) {
                System.out.println("Oops- an IOException happened. " + ioe.getMessage());
                ioe.printStackTrace();
                System.exit(1);
            } finally {
                IOUtils.closeQuietly(in);
            }
        } catch (MalformedURLException mue) {
            System.out.println("Ouch - a MalformedURLException happened.");
            mue.printStackTrace();
            System.exit(1);
        }

        return (out);
    }
}

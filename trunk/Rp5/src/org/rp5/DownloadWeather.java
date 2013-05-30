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
        	System.setProperty("http.proxyHost", "172.16.0.91");
        	System.setProperty("http.proxyPort", "16541");
        	System.setProperty("http.proxyUser", "RSTYLE97\\kozlitin.va");
        	System.setProperty("http.proxyPassword", "Rfvytgfl");
        	
            URL url = new URL("http://rp5.ru/xml/4429/00000/ru");
            URLConnection uc = url.openConnection();

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

package org.rp5;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.helpers.XMLReaderFactory;
import org.xml.sax.InputSource;

public class ParseXml extends DefaultHandler {
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
	public void parseWeather(String wr) throws ParserConfigurationException, SAXException, IOException {
		GetFieldSAX getFields = new GetFieldSAX();

		XMLReader xr = XMLReaderFactory.createXMLReader();
	    xr.setContentHandler(getFields);
	    xr.setErrorHandler(getFields);
	 
	                // Parse each file provided on the
	                // command line.
        File ruxml=new File("ru.xml");
//        FileReader r = new FileReader("ru.xml");
//        xr.parse(new InputSource(r));
		
        try {
            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            DocumentBuilder db=dbf.newDocumentBuilder();
            Document doc = db.parse(ruxml);
            
            doc.getDocumentElement().normalize();
            System.out.println("Root element ["+doc.getDocumentElement().getNodeName()+"]");
            
            NodeList nodeLst=doc.getElementsByTagName("timestep");
            System.out.println("timestep");
            for(int je = 0; je < nodeLst.getLength(); je++) {
                Node fstNode = nodeLst.item(je);
                if(fstNode.getNodeType() == Node.ELEMENT_NODE) {
                	String timeStep;
                	NodeList nodeLst1 = fstNode.getChildNodes();

                	for(int je1 = 0; je1 < nodeLst1.getLength(); je1++) {
                        Node fstNode1 = nodeLst1.item(je1);

                        if (fstNode1.getNodeName().equals("time_step")) {
                        	timeStep = fstNode1.getFirstChild().getNodeValue();
                    		
                        	System.out.println("time_step=" + timeStep);
                    	}
                    }

//                	Element elj = (Element) fstNode.getNodeValue();
//                    timeStep = elj.getAttribute("time_step").Integer.parseInt(;
//                    xcoo=Integer.parseInt(scoo);
//                    scoo=elj.getAttribute("y");
//                    ycoo=Integer.parseInt(scoo);
                }
            }
		} catch(Exception ei){
			
		}
    }
/*		SAXParserFactory factory = SAXParserFactory.newInstance();
		SAXParser parser = factory.newSAXParser();

		try {
			parser.parse(new File("ru.xml"), getFields);
			System.out.println("=" + getFields.getFieldXml());
		} catch (IOException e) {
			e.printStackTrace();
		}*/
}
/*
<coordinates>
    <point x="1" y="2"></point>
    <point x="3" y="4"></point>
    <point x="5" y="6"></point>
</coordinates>

     String scoo;
        int xcoo,ycoo;
        File fXml=new File("expXml.xml");
        
        try
        {
            DocumentBuilderFactory dbf=DocumentBuilderFactory.newInstance();
            DocumentBuilder db=dbf.newDocumentBuilder();
            Document doc=db.parse(fXml);
            
            doc.getDocumentElement().normalize();
            System.out.println("Root element ["+doc.getDocumentElement().getNodeName()+"]");
            
            NodeList nodeLst=doc.getElementsByTagName("point");
            System.out.println("Points");
            for(int je=0;je<nodeLst.getLength();je++)
            {
                Node fstNode=nodeLst.item(je);
                if(fstNode.getNodeType()==Node.ELEMENT_NODE)
                {
                    Element elj=(Element)fstNode;
                    scoo=elj.getAttribute("x");
                    xcoo=Integer.parseInt(scoo);
                    scoo=elj.getAttribute("y");
                    ycoo=Integer.parseInt(scoo);
                    System.out.println("x, y ["+xcoo+", "+ycoo+"]");
                }
            }
        }
        catch(Exception ei){}
    }
*/
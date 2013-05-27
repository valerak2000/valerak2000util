package org.rp5;

import java.io.IOException;
import java.io.InputStream;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
<<<<<<< .mine
=======
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
>>>>>>> .r108

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
<<<<<<< .mine
=======
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.helpers.XMLReaderFactory;
>>>>>>> .r108

<<<<<<< .mine
public class ParseXml {
    /**
     * @param args 1 - Path to DataBase
     *             2 - Name of DataBase
     *             3 - User Name
     *             4 - User Password
     *             5 - Count of keys
     * @throws
     */
    public void parseWeather(InputStream wr) throws IOException {
        try {
            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            DocumentBuilder db = dbf.newDocumentBuilder();
            Document doc = db.parse(wr);

            doc.getDocumentElement().normalize();
            System.out.println("Root element [" + doc.getDocumentElement().getNodeName() + "]");

            NodeList nodeLst = doc.getElementsByTagName("timestep");
            System.out.println("timestep");
            for (int je = 0; je < nodeLst.getLength(); je++) {
                Node fstNode = nodeLst.item(je);
                if (fstNode.getNodeType() == Node.ELEMENT_NODE) {
                    String timeStep;
                    NodeList nodeLst1 = fstNode.getChildNodes();
=======
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
	 * @throws XPathExpressionException 
	 */
	public void parseWeather(InputStream wr) throws ParserConfigurationException, IOException, SAXException, XPathExpressionException {
		GetFieldSAX getFields = new GetFieldSAX();

		XMLReader xr = XMLReaderFactory.createXMLReader();
	    xr.setContentHandler(getFields);
	    xr.setErrorHandler(getFields);
	 
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        DocumentBuilder db=dbf.newDocumentBuilder();
        Document doc = db.parse(wr);
        
        doc.getDocumentElement().normalize();
>>>>>>> .r108

<<<<<<< .mine
                    for (int je1 = 0; je1 < nodeLst1.getLength(); je1++) {
                        Node fstNode1 = nodeLst1.item(je1);
=======
        XPathFactory xPathfactory = XPathFactory.newInstance();
        XPath xpath = xPathfactory.newXPath();
        
        XPathExpression expr = xpath.compile("//weather/point/timestep[time_step=24]");
        NodeList nodeLst = (NodeList) expr.evaluate(doc, XPathConstants.NODESET);
        for(int je = 0; je < nodeLst.getLength(); je++) {
            Node fstNode = nodeLst.item(je);
            if(fstNode.getNodeType() == Node.ELEMENT_NODE) {
            	String timeStep;
            	NodeList nodeLst1 = fstNode.getChildNodes();
>>>>>>> .r108

<<<<<<< .mine
                        if (fstNode1.getNodeName().equals("time_step")) {
                            timeStep = fstNode1.getFirstChild().getNodeValue();

                            System.out.println("time_step=" + timeStep);
                        }
                    }
=======
            	for(int je1 = 0; je1 < nodeLst1.getLength(); je1++) {
                    Node fstNode1 = nodeLst1.item(je1);
>>>>>>> .r108
<<<<<<< .mine
=======

                    if (!fstNode1.getNodeName().equals("#text")) {
                    	System.out.println(fstNode1.getNodeName() + "=" + fstNode1.getFirstChild().getNodeValue());
/*                    	timeStep = fstNode1.getFirstChild().getNodeValue();
                		
                    	System.out.println("time_step=" + timeStep);*/
                	}
>>>>>>> .r108
                }
            }
<<<<<<< .mine
        } catch (Exception ei) {

        }
    }
}
=======
        }
	}
}
>>>>>>> .r108

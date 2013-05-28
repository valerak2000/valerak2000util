package org.rp5;

import java.io.IOException;
import java.io.InputStream;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.helpers.XMLReaderFactory;

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

        XPathFactory xPathfactory = XPathFactory.newInstance();
        XPath xpath = xPathfactory.newXPath();
        
        XPathExpression expr = xpath.compile("//weather/point/timestep");
        NodeList nodeLst = (NodeList) expr.evaluate(doc, XPathConstants.NODESET);

        for(int je = 0; je < nodeLst.getLength(); je++) {
            Node fstNode = nodeLst.item(je);
            if(fstNode.getNodeType() == Node.ELEMENT_NODE) {
//	        	String timeStep;
	        	NodeList nodeLst1 = fstNode.getChildNodes();
	        	//разбор элементов timestep
	            for(int ji = 0; ji < nodeLst1.getLength(); ji++) {
	                Node fstNode1 = nodeLst1.item(ji);

	                switch (fstNode1.getNodeName()) {
		                case "#text": break;
		                case "time_step":
			            	System.out.println("time_step=" + fstNode1.getFirstChild().getNodeValue());
		                	break;
		                case "datetime":
			            	System.out.println("datetime=" + fstNode1.getFirstChild().getNodeValue());
		                	break;
		                case "G":
			            	System.out.println("G=" + fstNode1.getFirstChild().getNodeValue());
		                	break;
		                case "HHii":
			            	System.out.println("HHii=" + fstNode1.getFirstChild().getNodeValue());
		                	break;
		                case "cloud_cover":
			            	System.out.println("cloud_cover=" + fstNode1.getFirstChild().getNodeValue());
		                	break;
		                case "precipitation":
			            	System.out.println("precipitation=" + fstNode1.getFirstChild().getNodeValue());
		                	break;
		                case "pressure":
			            	System.out.println("pressure=" + fstNode1.getFirstChild().getNodeValue());
		                	break;
		                case "temperature":
			            	System.out.println("temperature=" + fstNode1.getFirstChild().getNodeValue());
		                	break;
		                case "humidity":
			            	System.out.println("humidity=" + fstNode1.getFirstChild().getNodeValue());
		                	break;
		                case "wind_direction":
			            	System.out.println("wind_direction=" + fstNode1.getFirstChild().getNodeValue());
		                	break;
		                case "wind_velocity":
			            	System.out.println("wind_velocity=" + fstNode1.getFirstChild().getNodeValue());
		                	break;
		                case "falls":
			            	System.out.println("falls=" + fstNode1.getFirstChild().getNodeValue());
		                	break;
		                case "drops":
			            	System.out.println("drops=" + fstNode1.getFirstChild().getNodeValue());
		                	break;
		                default:
	                }
/*	                if (!fstNode1.getNodeName().equals("#text")) {
		            	System.out.println(fstNode1.getNodeName() + "=" + fstNode1.getFirstChild().getNodeValue());
		/*                    	timeStep = fstNode1.getFirstChild().getNodeValue();
		                		
		                    	System.out.println("time_step=" + timeStep);
		           	}*/
	            }

	            System.out.println();
            }
        }
	}
}

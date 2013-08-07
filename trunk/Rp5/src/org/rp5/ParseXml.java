package org.rp5;

import java.io.IOException;
import java.io.InputStream;
import java.text.ParseException;
import java.text.SimpleDateFormat;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.w3c.dom.DOMException;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.helpers.XMLReaderFactory;
import org.rp5.WeatherRp5;

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
	 * @throws ParseException 
	 * @throws DOMException 
	 */
	public void parseWeather(InputStream wr) throws ParserConfigurationException, IOException, SAXException, XPathExpressionException, DOMException, ParseException {
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
            	//создать объект погоды
            	WeatherRp5 wrp5 = new WeatherRp5();

            	NodeList nodeLst1 = fstNode.getChildNodes();
	        	//разбор элементов timestep
	            for(int ji = 0; ji < nodeLst1.getLength(); ji++) {
	                Node fstNode1 = nodeLst1.item(ji);

	                switch (fstNode1.getNodeName()) {
		                case "#text": break;
		                case "time_step":
		                	wrp5.timeStep = Integer.parseInt(fstNode1.getFirstChild().getNodeValue().toString());
		                	break;
		                case "datetime":
	                        wrp5.dateTime = new SimpleDateFormat("yyyy-MM-dd hh:mm").parse(fstNode1.getFirstChild().getNodeValue().toString()); 
		                	break;
		                case "G":
		                	wrp5.g = fstNode1.getFirstChild().getNodeValue().toString();
		                	break;
		                case "HHii":
		                	wrp5.hhii = fstNode1.getFirstChild().getNodeValue().toString();
		                	break;
		                case "cloud_cover":
		                	wrp5.cloudCover = Integer.parseInt(fstNode1.getFirstChild().getNodeValue().toString());
		                	break;
		                case "precipitation":
		                	wrp5.precipitation = Double.parseDouble(fstNode1.getFirstChild().getNodeValue().toString());
		                	break;
		                case "pressure":
		                	wrp5.pressure = Integer.parseInt(fstNode1.getFirstChild().getNodeValue().toString());
		                	break;
		                case "temperature":
		                	wrp5.temperature = Integer.parseInt(fstNode1.getFirstChild().getNodeValue().toString());
		                	break;
		                case "humidity":
		                	wrp5.humidity = Integer.parseInt(fstNode1.getFirstChild().getNodeValue().toString());
		                	break;
		                case "wind_direction":
		                	wrp5.windDirection = fstNode1.getFirstChild().getNodeValue().toString();
		                	break;
		                case "wind_velocity":
		                	wrp5.windVelocity = Integer.parseInt(fstNode1.getFirstChild().getNodeValue().toString());
		                	break;
		                case "falls":
		                	wrp5.falls = Integer.parseInt(fstNode1.getFirstChild().getNodeValue().toString());
		                	break;
		                case "drops":
		                	wrp5.drops = Integer.parseInt(fstNode1.getFirstChild().getNodeValue().toString());
		                	break;
		                default:
	                }
	            }

                wrp5.Print();
            }
        }
	}
}

/*
<point_id>4429</point_id>
<region_id>46</region_id>
<country_id>3</country_id>
<point_name>Краснодар</point_name>
<point_name_trim>Краснодар</point_name_trim>
<point_name2>в Краснодаре</point_name2>
<point_timestamp>1375877328</point_timestamp>
<gmt_add>4</gmt_add>
<point_date>Wed, 7 Aug 2013 12:08:48 +0400</point_date>
<point_date_time>2013-8-07 12:08</point_date_time>
*/
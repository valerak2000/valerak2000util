package org.weather.ui.model;

import java.io.IOException;
import java.io.InputStream;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

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
import org.weather.util.GetFieldSAX;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.helpers.XMLReaderFactory;

public class ParseXml extends DefaultHandler {
	/**
	 * @param InputStream
	 * @throws ParserConfigurationException 
	 * @throws SAXException 
	 * @throws XPathExpressionException 
	 * @throws DOMException 
	 * @throws ParseException 
	 */
	public List<Weather> parseWeather(InputStream wr) throws ParserConfigurationException, IOException, SAXException, XPathExpressionException, DOMException, ParseException {
		List<Weather> wth = new ArrayList<Weather>();
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
            	Weather w = new Weather();

            	NodeList nodeLst1 = fstNode.getChildNodes();
	        	//разбор элементов timestep
	            for(int ji = 0; ji < nodeLst1.getLength(); ji++) {
	                Node fstNode1 = nodeLst1.item(ji);

	                switch (fstNode1.getNodeName()) {
		                case "#text": break;
		                case "time_step":
		                	w.setTimeStep(Integer.parseInt(fstNode1.getFirstChild().getNodeValue().toString()));
		                	break;
		                case "datetime":
	                        w.setDateTime(new SimpleDateFormat("yyyy-MM-dd hh:mm").parse(fstNode1.getFirstChild().getNodeValue().toString())); 
		                	break;
		                case "G":
		                	w.setG(fstNode1.getFirstChild().getNodeValue().toString());
		                	break;
		                case "HHii":
		                	w.setHhii(fstNode1.getFirstChild().getNodeValue().toString());
		                	break;
		                case "cloud_cover":
		                	w.setCloudCover(Integer.parseInt(fstNode1.getFirstChild().getNodeValue().toString()));
		                	break;
		                case "precipitation":
		                	w.setPrecipitation(Double.parseDouble(fstNode1.getFirstChild().getNodeValue().toString()));
		                	break;
		                case "pressure":
		                	w.setPressure(Integer.parseInt(fstNode1.getFirstChild().getNodeValue().toString()));
		                	break;
		                case "temperature":
		                	w.setTemperature(Integer.parseInt(fstNode1.getFirstChild().getNodeValue().toString()));
		                	break;
		                case "humidity":
		                	w.setHumidity(Integer.parseInt(fstNode1.getFirstChild().getNodeValue().toString()));
		                	break;
		                case "wind_direction":
		                	w.setWindDirection(fstNode1.getFirstChild().getNodeValue().toString());
		                	break;
		                case "wind_velocity":
		                	w.setWindVelocity(Integer.parseInt(fstNode1.getFirstChild().getNodeValue().toString()));
		                	break;
		                case "falls":
		                	w.setFalls(Integer.parseInt(fstNode1.getFirstChild().getNodeValue().toString()));
		                	break;
		                case "drops":
		                	w.setDrops(Integer.parseInt(fstNode1.getFirstChild().getNodeValue().toString()));
		                	break;
		                default:
	                }
	            }

                wth.add(w);
            }
        }
        return wth;
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
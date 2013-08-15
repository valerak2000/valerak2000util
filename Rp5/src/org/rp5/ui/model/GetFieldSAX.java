package org.rp5.ui.model;

import javax.xml.parsers.ParserConfigurationException;

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

public class GetFieldSAX extends DefaultHandler {
    private int sumXml = 0;

    /**
     * @param args 1 - Path to DataBase
     *             2 - Name of DataBase
     *             3 - User Name
     *             4 - User Password
     *             5 - Count of keys
     * @throws SAXException
     * @throws ParserConfigurationException
     */
    @Override
    public void startElement(String uri, String localName, String qName, Attributes attributes)
            throws SAXException {
        for (int i = 0; i < attributes.getLength(); i++) {
            if (attributes.getQName(i).equals("field")) {
                sumXml += Integer.parseInt(attributes.getValue(i));
            }
        }
    }

    public void endElement(String uri, String name, String qName) {
        if ("".equals(uri))
            System.out.println("End element: " + qName);
        else
            System.out.println("End element:   {" + uri + "}" + name);
    }

    public void startDocument() {
        System.out.println("Start document");
    }

    public void endDocument() {
        System.out.println("End document");
    }

    public void characters(char ch[], int start, int length) {
        System.out.print("Characters:    \"");
        for (int i = start; i < start + length; i++) {
            switch (ch[i]) {
                case '\\':
                    System.out.print("\\\\");
                    break;
                case '"':
                    System.out.print("\\\"");
                    break;
                case '\n':
                    System.out.print("\\n");
                    break;
                case '\r':
                    System.out.print("\\r");
                    break;
                case '\t':
                    System.out.print("\\t");
                    break;
                default:
                    System.out.print(ch[i]);
                    break;
            }
        }
        System.out.print("\"\n");
    }

    public int getFieldXml() {
        return this.sumXml;
    }

}

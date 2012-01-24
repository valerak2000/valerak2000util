package org.mconfig;

import org.apache.commons.configuration.XMLConfiguration;

public class MXMLConfiguration extends XMLConfiguration {
    public String getMString(String key) {
    	return getString(key).replace("\\t", "\t");
    }
}

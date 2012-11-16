package org.library.config;

import org.apache.commons.configuration.XMLConfiguration;

public class MenuXMLConfiguration extends XMLConfiguration {
	@Override
    public String getString(String key) {
    	return super.getString(key).replace("\\t", "\t");
    }
}

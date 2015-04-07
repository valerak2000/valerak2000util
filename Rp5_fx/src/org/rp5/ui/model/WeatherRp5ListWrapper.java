package org.rp5.ui.model;

import java.util.List;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

/**
 * Helper class to wrap a list of WeatherRp5. This is used for saving the
 * list of WeatherRp5 to XML.
 * 
 * @author Kozlitin Valeriy
 */
@XmlRootElement(name = "weatherRp5")
public class WeatherRp5ListWrapper {
    private List<WeatherRp5> weatherRp5;

    @XmlElement(name = "weatherRp5")
    public List<WeatherRp5> getWeatherRp5() {
        return weatherRp5;
    }

    public void setWeatherRp5(List<WeatherRp5> weatherRp5) {
        this.weatherRp5 = weatherRp5;
    }
}

package org.weather.ui.model;

import java.util.List;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

/**
 * Helper class to wrap a list of WeatherRp5. This is used for saving the
 * list of Weather to XML.
 * 
 * @author Kozlitin Valeriy
 */
@XmlRootElement(name = "weather")
public class WeatherDMListWrapper {
    private List<WeatherDM> weather;

    @XmlElement(name = "weather")
    public List<WeatherDM> getWeather() {
        return weather;
    }

    public void setWeather(List<WeatherDM> weather) {
        this.weather = weather;
    }
}

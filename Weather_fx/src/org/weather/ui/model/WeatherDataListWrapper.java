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
public class WeatherDataListWrapper {
    private List<WeatherData> weather;

    @XmlElement(name = "weather")
    public List<WeatherData> getWeather() {
        return weather;
    }

    public void setWeather(List<WeatherData> weather) {
        this.weather = weather;
    }
}

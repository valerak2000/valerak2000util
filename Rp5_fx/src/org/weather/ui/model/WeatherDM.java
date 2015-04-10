/*
point_id - ID НП в базе сайта
region_id - ID региона, в котором находится НП
country_id - ID страны, в которой находится НП
point_name - полное наименование НП. Например, "Дубровка (Дубровский р-н)"
point_name_trim - сокращенное наименование НП без скобок. Например, "Дубровка". point_name_trim соответствует point_name до открывающейся скобки. Если скобки нет, то point_name_trim = point_name.
point_name2 - название НП в предложном падеже с предлогом. Например, "в Дубровке". Используется в заголовках вида "Погода в Дубровке" ("Погода " + point_name2)
point_timestamp - unix-таймстамп даты в НП
gmt_add - UTC-смещение в часах с учетом перехода на летнее-зимнее время
point_date - местное время в НП в момент создания файла с данными с указанием gmt_add. Например, "Sun, 12 Dec 2004 13:00:25 +0300"
point_date_time - местное время в НП в момент создания файла с данными. Используется менее подробный формат. Например, "2004-12-12 13:00"
time_step - временной шаг прогноза в часах от полуночи (00:00 UTC) текущих суток. Например, time_step = 48 означает прогноз на 48 часов вперёд относительно 00:00 UTC текущих суток.
datetime - момент прогноза по местному времени (дата час:минута)
G - момент прогноза по местному времени в часах. Например, "15"
HHii - момент прогноза по местному времени в часах и минутах. Например, "15:00"
cloud_cover - облачность (%)
precipitation - толщина осадков, накопленных в течение 4 часов перед указанным выше моментом времени. Например, если G = 15 час, то осадки накапливались с 11 до 15 час. Таким образом, при визуализации значение осадков - в отличие от всех остальных параметров - лучше располагать между соседними моментами времени
pressure - атмосферное давление
temperature - температура воздуха
humidity - относительная влажность воздуха (%)
wind_direction - направление ветра (С-северный, СВ-северо-восточный и т.д.). Направление указывает ОТКУДА дует ветер. Например, северный ветер дует с севера
wind_velocity - скорость ветра
falls - тип осадков (0 - отсутствие осадков, 1 - дождь, 2 - дождь со снегом, 3 - снег)
drops - коэффициент количества снежинок или капель дождя для визуализации. Возможные значения: 0.5, 1, 2, 3, 4, 5, 6, 7, 8. Чем больше это значение, тем количество или размер капель или снежинок должны быть больше.
 */
package org.weather.ui.model;

import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.util.Date;

import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;

import javafx.beans.property.StringProperty;
import javafx.beans.property.IntegerProperty;
import javafx.beans.property.DoubleProperty;
import javafx.beans.property.ObjectProperty;
import javafx.beans.property.SimpleIntegerProperty;
import javafx.beans.property.SimpleDoubleProperty;
import javafx.beans.property.SimpleObjectProperty;
import javafx.beans.property.SimpleStringProperty;

/**
 * Model class for a WeatherDM.
 *
 * @author
 */
public class WeatherDM {
	private final IntegerProperty timeStep;
	private final ObjectProperty<Date> dateTime;
	private final StringProperty g;
	private final StringProperty hhii;
	private final IntegerProperty cloudCover;
	private final DoubleProperty precipitation;
	private final IntegerProperty pressure;
	private final IntegerProperty temperature;
	private final IntegerProperty humidity;
	private final StringProperty windDirection;
	private final IntegerProperty windVelocity;
	private final IntegerProperty falls;
	private final IntegerProperty drops;

	/**
	 * Default constructor.
	 */
	public WeatherDM() {
		this(0, null, null, null, 0, 0, 0, 0, 0, null, 0, 0, 0);
	}

	/**
	 * Constructor with some initial data.
	 * 
	 * @param timeStep
	 * @param dateTime
	 * @param g
	 * @param hhii
	 * @param cloudCover
	 * @param precipitation
	 * @param pressure
	 * @param temperature
	 * @param humidity
	 * @param windDirection
	 * @param windVelocity
	 * @param falls
	 * @param drops
	 */
	public WeatherDM(int timeStep, Date dateTime, String g, String hhii,
			int cloudCover, double precipitation, int pressure,
			int temperature, int humidity, String windDirection,
			int windVelocity, int falls, int drops) {
		this.timeStep = new SimpleIntegerProperty(timeStep);
		this.dateTime = new SimpleObjectProperty<Date>(dateTime);
		this.g = new SimpleStringProperty(g);
		this.hhii = new SimpleStringProperty(hhii);
		this.cloudCover = new SimpleIntegerProperty(cloudCover);
		this.precipitation = new SimpleDoubleProperty(precipitation);
		this.pressure = new SimpleIntegerProperty(pressure);
		this.temperature = new SimpleIntegerProperty(temperature);
		this.humidity = new SimpleIntegerProperty(humidity);
		this.windDirection = new SimpleStringProperty(windDirection);
		this.windVelocity = new SimpleIntegerProperty(windVelocity);
		this.falls = new SimpleIntegerProperty(falls);
		this.drops = new SimpleIntegerProperty(drops);
	}

	public void Print() {
		System.out.println("time_step=" + timeStep);
		System.out.println("datetime="
				+ new SimpleDateFormat("yyyy-MM-dd hh:mm").format(dateTime));
		System.out.println("G=" + g);
		System.out.println("HHii=" + hhii);
		System.out.println("cloud_cover=" + cloudCover);
		System.out.println("precipitation=" + precipitation);
		System.out.println("pressure=" + pressure);
		System.out.println("temperature=" + temperature);
		System.out.println("humidity=" + humidity);
		System.out.println("wind_direction=" + windDirection);
		System.out.println("wind_velocity=" + windVelocity);
		System.out.println("falls=" + falls);
		System.out.println("drops=" + drops);
		System.out.println();
	}

	public final IntegerProperty timeStepProperty() {
		return this.timeStep;
	}

	public final int getTimeStep() {
		return this.timeStepProperty().get();
	}

	public final void setTimeStep(final int timeStep) {
		this.timeStepProperty().set(timeStep);
	}

	public final ObjectProperty<Date> dateTimeProperty() {
		return this.dateTime;
	}

	public final Date getDateTime() {
		return this.dateTimeProperty().get();
	}

	public final void setDateTime(final Date dateTime) {
		this.dateTimeProperty().set(dateTime);
	}

	public final StringProperty gProperty() {
		return this.g;
	}

	public final java.lang.String getG() {
		return this.gProperty().get();
	}

	public final void setG(final java.lang.String g) {
		this.gProperty().set(g);
	}

	public final StringProperty hhiiProperty() {
		return this.hhii;
	}

	public final java.lang.String getHhii() {
		return this.hhiiProperty().get();
	}

	public final void setHhii(final java.lang.String hhii) {
		this.hhiiProperty().set(hhii);
	}

	public final IntegerProperty cloudCoverProperty() {
		return this.cloudCover;
	}

	public final int getCloudCover() {
		return this.cloudCoverProperty().get();
	}

	public final void setCloudCover(final int cloudCover) {
		this.cloudCoverProperty().set(cloudCover);
	}

	public final DoubleProperty precipitationProperty() {
		return this.precipitation;
	}

	public final double getPrecipitation() {
		return this.precipitationProperty().get();
	}

	public final void setPrecipitation(final double precipitation) {
		this.precipitationProperty().set(precipitation);
	}

	public final IntegerProperty pressureProperty() {
		return this.pressure;
	}

	public final int getPressure() {
		return this.pressureProperty().get();
	}

	public final void setPressure(final int pressure) {
		this.pressureProperty().set(pressure);
	}

	public final IntegerProperty temperatureProperty() {
		return this.temperature;
	}

	public final int getTemperature() {
		return this.temperatureProperty().get();
	}

	public final void setTemperature(final int temperature) {
		this.temperatureProperty().set(temperature);
	}

	public final IntegerProperty humidityProperty() {
		return this.humidity;
	}

	public final int getHumidity() {
		return this.humidityProperty().get();
	}

	public final void setHumidity(final int humidity) {
		this.humidityProperty().set(humidity);
	}

	public final StringProperty windDirectionProperty() {
		return this.windDirection;
	}

	public final java.lang.String getWindDirection() {
		return this.windDirectionProperty().get();
	}

	public final void setWindDirection(final java.lang.String windDirection) {
		this.windDirectionProperty().set(windDirection);
	}

	public final IntegerProperty windVelocityProperty() {
		return this.windVelocity;
	}

	public final int getWindVelocity() {
		return this.windVelocityProperty().get();
	}

	public final void setWindVelocity(final int windVelocity) {
		this.windVelocityProperty().set(windVelocity);
	}

	public final IntegerProperty fallsProperty() {
		return this.falls;
	}

	public final int getFalls() {
		return this.fallsProperty().get();
	}

	public final void setFalls(final int falls) {
		this.fallsProperty().set(falls);
	}

	public final IntegerProperty dropsProperty() {
		return this.drops;
	}

	public final int getDrops() {
		return this.dropsProperty().get();
	}

	public final void setDrops(final int drops) {
		this.dropsProperty().set(drops);
	}
}

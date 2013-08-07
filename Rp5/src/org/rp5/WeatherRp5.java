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
package org.rp5;

import java.text.SimpleDateFormat;
import java.util.Date;

public class WeatherRp5 {
	int timeStep;
	Date dateTime;
	String g;
	String hhii;
	int cloudCover;
	double precipitation;
	int pressure;
	int temperature;
	int humidity;
	String windDirection;
	int windVelocity;
	int falls;
	int drops;
	
	public void Print() {
		System.out.println("time_step=" + timeStep);
		System.out.println("datetime=" + new SimpleDateFormat("yyyy-MM-dd hh:mm").format(dateTime));
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
}

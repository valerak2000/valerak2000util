/*
point_id - ID �� � ���� �����
region_id - ID �������, � ������� ��������� ��
country_id - ID ������, � ������� ��������� ��
point_name - ������ ������������ ��. ��������, "�������� (���������� �-�)"
point_name_trim - ����������� ������������ �� ��� ������. ��������, "��������". point_name_trim ������������� point_name �� ������������� ������. ���� ������ ���, �� point_name_trim = point_name.
point_name2 - �������� �� � ���������� ������ � ���������. ��������, "� ��������". ������������ � ���������� ���� "������ � ��������" ("������ " + point_name2)
point_timestamp - unix-��������� ���� � ��
gmt_add - UTC-�������� � ����� � ������ �������� �� ������-������ �����
point_date - ������� ����� � �� � ������ �������� ����� � ������� � ��������� gmt_add. ��������, "Sun, 12 Dec 2004 13:00:25 +0300"
point_date_time - ������� ����� � �� � ������ �������� ����� � �������. ������������ ����� ��������� ������. ��������, "2004-12-12 13:00"
time_step - ��������� ��� �������� � ����� �� �������� (00:00 UTC) ������� �����. ��������, time_step = 48 �������� ������� �� 48 ����� ����� ������������ 00:00 UTC ������� �����.
datetime - ������ �������� �� �������� ������� (���� ���:������)
G - ������ �������� �� �������� ������� � �����. ��������, "15"
HHii - ������ �������� �� �������� ������� � ����� � �������. ��������, "15:00"
cloud_cover - ���������� (%)
precipitation - ������� �������, ����������� � ������� 4 ����� ����� ��������� ���� �������� �������. ��������, ���� G = 15 ���, �� ������ ������������� � 11 �� 15 ���. ����� �������, ��� ������������ �������� ������� - � ������� �� ���� ��������� ���������� - ����� ����������� ����� ��������� ��������� �������
pressure - ����������� ��������
temperature - ����������� �������
humidity - ������������� ��������� ������� (%)
wind_direction - ����������� ����� (�-��������, ��-������-��������� � �.�.). ����������� ��������� ������ ���� �����. ��������, �������� ����� ���� � ������
wind_velocity - �������� �����
falls - ��� ������� (0 - ���������� �������, 1 - �����, 2 - ����� �� ������, 3 - ����)
drops - ����������� ���������� �������� ��� ������ ����� ��� ������������. ��������� ��������: 0.5, 1, 2, 3, 4, 5, 6, 7, 8. ��� ������ ��� ��������, ��� ���������� ��� ������ ������ ��� �������� ������ ���� ������.
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

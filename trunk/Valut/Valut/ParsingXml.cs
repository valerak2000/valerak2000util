/*
 * набор функций для получения xml из внешний источников
*/
using System;
using System.Collections;
using System.Text;
using System.Xml;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Net;
using System.Globalization;
using Microsoft.SqlServer.Server;

public static partial class UserDefinedFunctions
{
    private class Valut
    {
        public SqlString Code;
        public SqlInt32 Nominal;
        public SqlString Name;
        public SqlDouble Value;

        public Valut(SqlString code, SqlInt32 nominal, SqlString name, SqlDouble value)
        {
            Code = code;
            Nominal = nominal;
            Name = name;
            Value = value;
        }
    }

    public static string GetPageAsString(string url)
    {
        string xmlStr = "";
        //получить содержимое url ввиде строки
        using (var wc = new WebClient())
        {
            xmlStr = wc.DownloadString(url);
        }
        return xmlStr;
    }

    [WebPermission(System.Security.Permissions.SecurityAction.Demand, ConnectPattern = @"*")]
    [SqlFunction(FillRowMethodName = "FillRow", TableDefinition = "code nvarchar(5), value float")]
    public static IEnumerable GetCBRValut(DateTime date)
    {

        ArrayList valut = new ArrayList();
        try {
            XmlDocument doc = new XmlDocument();
            doc.LoadXml(GetPageAsString("http://www.cbr.ru/scripts/XML_daily.asp?date_req=" + date.ToString("dd/MM/yyyy", CultureInfo.InvariantCulture)));
            // Получаем всех детей корневого элемента
            // xmlDoc.DocumentElement - корневой элемент
            foreach (XmlNode table in doc.DocumentElement.ChildNodes)
            {
                string code = "";
                int nominal = 0;
                string name = "";
                double value = 0.00;
                // перебираем всех детей текущего узла
                foreach (XmlNode ch in table.ChildNodes)
                {
                    switch (ch.Name)
		                {
                            case "CharCode":
                                code = ch.FirstChild.Value.Trim();
                                break;
                            case "Nominal":
                                nominal = Convert.ToInt32(ch.FirstChild.Value.Trim());
                                break;
                            case "Name":
                                name = ch.FirstChild.Value.Trim();
                                break;
                            case "Value":
                                value = Convert.ToDouble(ch.FirstChild.Value.Trim());
    			                break;
		                }
                }
                valut.Add(new Valut(code, nominal, name, value));
           }
           }
            catch (Exception ex) {
                valut.Add(new Valut("err", -1, ex.ToString(), -1.0));
            }
        return valut;
    }

    public static void FillRow(Object obj, out SqlString code, out SqlInt32 nominal, out SqlString name, out SqlDouble value)
    {
        Valut val = (Valut) obj;
        code = new SqlString((String) val.Code);
        nominal = new SqlInt32((Int32) val.Nominal);
        name = new SqlString((String) val.Name);
        value = new SqlDouble((Double) val.Value);
    }
}


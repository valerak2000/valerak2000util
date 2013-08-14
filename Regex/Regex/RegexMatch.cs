/*
 * набор функций для использования регулярных выражений
*/
using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Text.RegularExpressions;
using Microsoft.SqlServer.Server;

public partial class UserDefinedFunctions
{
    public static readonly RegexOptions Options =
        RegexOptions.IgnorePatternWhitespace |
        RegexOptions.Compiled | RegexOptions.Singleline;

    [Microsoft.SqlServer.Server.SqlFunction]
    public static SqlBoolean RegexMatch(SqlChars input, SqlString pattern)
    {
        return new Regex(pattern.Value, Options).IsMatch(new string(input.Value));
    }
}

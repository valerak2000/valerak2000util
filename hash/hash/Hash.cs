using System;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Security.Cryptography;

public partial class UserDefinedFunctions
{
    private static HashAlgorithm GetHashAlgotithm(string HashAlgorithmName)
    {
        switch (HashAlgorithmName.ToUpperInvariant())
        {
            case "MD5":
                return MD5.Create();
            case "SHA1":
                return SHA1.Create();
            case "SHA256":
                return SHA256.Create();
            default:
                throw new ArgumentOutOfRangeException("HashType", "Don't know how to create a '" + HashAlgorithmName + "' hash.");
        }
    }

    [Microsoft.SqlServer.Server.SqlFunction(DataAccess = DataAccessKind.None, IsDeterministic = true, SystemDataAccess = SystemDataAccessKind.None)]
    public static SqlBinary Hash(SqlBinary Source, SqlString HashAlgorithmName)
    {
        if (Source.IsNull)
            return null;

        HashAlgorithm ha = GetHashAlgotithm(HashAlgorithmName.Value);

        SqlBinary theHash = new SqlBinary(
         ha.ComputeHash(Source.Value)
         );
        return theHash;
    }
}

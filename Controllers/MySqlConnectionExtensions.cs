using System.Data;
using MySqlConnector;

namespace avg.NET.Controllers;

public static class MySqlConnectionExtensions
{
    // open the connection if needed, and create a command for the sql
    public static async Task<MySqlCommand> CreateCommandAsync(this MySqlConnection connection, string sql)
    {
        if (connection.State != ConnectionState.Open)
        {
            await connection.OpenAsync();
        }

        var cmd = connection.CreateCommand();
        cmd.CommandText = sql;
        return cmd;
    }
}

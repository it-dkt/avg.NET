using System.Data;
using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc;
using MySqlConnector;

namespace avg.NET.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MessageController : ControllerBase
{
    private readonly ILogger<MessageController> _logger;
    private readonly MySqlConnection _connection;

    private const string SQL = 
          "SELECT "
        + "  TEXT, ( ( @flag | SET_FLAG ) & ~UNSET_FLAG ) AS SET_FLAG, EVENT "
        + "FROM MESSAGE "
        + "WHERE "
        + " SCENE_ID IN ( @sceneId, '00000' ) AND"
        + " COMMAND_ID = @commandId AND"
        + " TARGET_ID = @targetId AND"
        + " ( FLAG & @flag ) = FLAG "
        + " ORDER BY SCENE_ID DESC, FLAG DESC ";

    public MessageController(ILogger<MessageController> logger, MySqlConnection connection)
    {
        _logger = logger;
        _connection = connection;
    }

    [HttpGet]
    public async Task<MessageResponse> Get([FromQuery] MessageRequest request)
    {
        _connection.Open();

        using var cmd = _connection.CreateCommand();
        cmd.CommandText = SQL;
        
        cmd.Parameters.Add(new MySqlParameter
        {
            ParameterName = "@sceneId",
            DbType = DbType.String,
            Value = request.SceneId,
        });
        cmd.Parameters.Add(new MySqlParameter
        {
            ParameterName = "@commandId",
            DbType = DbType.String,
            Value = request.CommandId,
        });
        cmd.Parameters.Add(new MySqlParameter
        {
            ParameterName = "@targetId",
            DbType = DbType.String,
            Value = request.TargetId,
        });
        cmd.Parameters.Add(new MySqlParameter
        {
            ParameterName = "@flag",
            DbType = DbType.UInt64,
            Value = request.Flag,
        });

        var reader = await cmd.ExecuteReaderAsync();

        var message = new MessageResponse();
        message.Message = "ERROR: No message!";

        if(await reader.ReadAsync()){

            message.Message = reader.GetString("TEXT");
            message.Flag = reader.GetUInt64("SET_FLAG");
            var eventOrdinal = reader.GetOrdinal("EVENT");
            message.Event = await reader.IsDBNullAsync(eventOrdinal) ? null : reader.GetString(eventOrdinal);
        }

        return message;
    }
}

public class MessageRequest
{
    [Required]
    public string SceneId { get; set;} = "";
    [Required]
    public string CommandId { get; set; } = "";
    [Required]
    public string TargetId { get; set; } = "";
    [Required]
    public ulong Flag { get; set; } 
}

public class MessageResponse
{
    public string Message { get; set; } = "";

    public ulong Flag { get; set; }

    public string? Event { get; set; }
}
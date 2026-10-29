using System.Data;
using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc;
using MySqlConnector;

namespace avg.NET.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TargetController : ControllerBase
{
    private readonly ILogger<TargetController> _logger;
    private readonly MySqlConnection _connection;

    private const string GET_TARGET_SQL =
          "SELECT "
        + "  T.COMMAND_ID, T.TARGET_ID, T.TEXT, T.FORBIDDEN, "
        + "  ( T.SCENE_ID = '00000' ) AS COMMON, " // common targets (ex. items the player has)
        + "  C.MODE "
        + "FROM TARGET T "
        + "INNER JOIN COMMAND C ON "    // join COMMAND to get MODE
        + "  C.SCENE_ID IN ( @sceneId, '00000' ) AND"   // common commands OR scene specific commands.
        + "  C.COMMAND_ID = @commandId "
        + "WHERE "
        + " T.SCENE_ID IN ( @sceneId, '00000' ) AND"    // common targets OR scene specific targets.
        + " T.COMMAND_ID = @commandId AND"
        + " ( T.FLAG & @flag ) = T.FLAG "
        + " ORDER BY T.SCENE_ID DESC, T.TARGET_ID ASC";

    // The Initial Message is the message that asks the player to selecte a target of the command.
    // ex. When the player selected the 'use' command, the Initial Message may be 'What to use?'.
    private const string GET_COMMAND_INITIAL_MESSAGE_SQL =
    	 "SELECT "
        + " TEXT "
        + "FROM MESSAGE "
        + "WHERE "
        + " SCENE_ID = '00000' AND "
        + " COMMAND_ID = @commandId AND "
        + " TARGET_ID = '000' ";    // TARGET_ID of Initial Message is 000

    // The Default Message is the message shown when the command the player selected has no targets.
    // ex. When the player selected the 'use' command, and the player has no item to use, the Default Message may be 'You have no item to use'.
    private const string GET_COMMAND_DEFAULT_MESSAGE_SQL =
    	 "SELECT "
        + " TEXT "
        + "FROM MESSAGE "
        + "WHERE "
        + " SCENE_ID = '00000' AND "
        + " COMMAND_ID = @commandId AND "
        + " TARGET_ID = '999' ";    // TARGET_ID of Default Message is 999

    public TargetController(ILogger<TargetController> logger, MySqlConnection connection)
    {
        _logger = logger;
        _connection = connection;
    }

    [HttpGet]
    public async Task<TargetResponse> Get([FromQuery] TargetRequest request)
    {
        //
        // get targets of the command
        //
        using var targetQuery = await _connection.CreateCommandAsync(GET_TARGET_SQL);
        targetQuery.Parameters.AddWithValue("@sceneId", request.SceneId);
        targetQuery.Parameters.AddWithValue("@commandId", request.CommandId);
        targetQuery.Parameters.AddWithValue("@flag", request.Flag);

        var target = new TargetResponse();
        target.Message = "ERROR: No message!";

        var hasRows = false;
        using(var reader = await targetQuery.ExecuteReaderAsync()){
            hasRows = reader.HasRows;
            while(await reader.ReadAsync()){
                target.Commands.Add(new ViewCommandModel
                {
                    CommandId = reader.GetString("COMMAND_ID"),
                    TargetId = reader.GetString("TARGET_ID"),
                    Mode = reader.GetInt32("MODE"),
                    Text = reader.GetString("TEXT"),
                    Forbidden = reader.GetInt32("FORBIDDEN"),
                    Common = reader.GetBoolean("COMMON")
                });
            }
        }

        //
        // get initial or default messsge of the command
        //
        // initial message if the command has any target, otherwise default message
        var messageSql = hasRows ? GET_COMMAND_INITIAL_MESSAGE_SQL : GET_COMMAND_DEFAULT_MESSAGE_SQL;
        using var initalMessageQuery = await _connection.CreateCommandAsync(messageSql);
        initalMessageQuery.Parameters.AddWithValue("@commandId", request.CommandId);

        using(var reader = await initalMessageQuery.ExecuteReaderAsync()){
            if(await reader.ReadAsync()){
                target.Message = reader.GetString("TEXT");
            }
        }

        return target;
    }
}

public class TargetRequest
{
    [Required]
    public string SceneId { get; set;} = "";
    [Required]
    public string CommandId { get; set; } = "";
    [Required]
    public ulong Flag { get; set; }
}

public class TargetResponse
{
    public string Message { get; set;} = "";

    public List<ViewCommandModel> Commands { get; set; } = new List<ViewCommandModel>();
}
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
        + "  COMMAND_ID, TARGET_ID, TEXT "
        + "FROM TARGET "
        + "WHERE "
        + " SCENE_ID IN ( @sceneId, '00000' ) AND"
        + " COMMAND_ID = @commandId AND"
        + " ( FLAG & @flag ) = FLAG "
        + " ORDER BY SCENE_ID DESC, FLAG DESC ";

    private const string GET_COMMAND_INITIAL_MESSAGE_SQL =
    	 "SELECT "
        + " TEXT "
        + "FROM MESSAGE "
        + "WHERE "
        + " SCENE_ID = '00000' AND "
        + " COMMAND_ID = @commandId AND "
        + " TARGET_ID = '000' ";

    private const string GET_COMMAND_DEFAULT_MESSAGE_SQL =
    	 "SELECT "
        + " TEXT "
        + "FROM MESSAGE "
        + "WHERE "
        + " SCENE_ID = '00000' AND "
        + " COMMAND_ID = @commandId AND "
        + " TARGET_ID = '999' ";

    public TargetController(ILogger<TargetController> logger, MySqlConnection connection)
    {
        _logger = logger;
        _connection = connection;
    }

    [HttpGet]
    public async Task<TargetResponse> Get([FromQuery] TargetRequest request)
    {
        _connection.Open();

        //
        // get targets of the command
        //
        using var targetQuery = _connection.CreateCommand();
        targetQuery.CommandText = GET_TARGET_SQL;
        
        targetQuery.Parameters.Add(new MySqlParameter
        {
            ParameterName = "@sceneId",
            DbType = DbType.String,
            Value = request.SceneId,
        });
        targetQuery.Parameters.Add(new MySqlParameter
        {
            ParameterName = "@commandId",
            DbType = DbType.String,
            Value = request.CommandId,
        });
        targetQuery.Parameters.Add(new MySqlParameter
        {
            ParameterName = "@flag",
            DbType = DbType.UInt64,
            Value = request.Flag,
        });

        var target = new TargetResponse();
        target.Message = "ERROR: No message!";

        var hasRows = false;
        using(var reader = await targetQuery.ExecuteReaderAsync()){
            hasRows = reader.HasRows;
            while(await reader.ReadAsync()){
                target.Commands.Add(new ViewCommandModel{
                    CommandId = reader.GetString("COMMAND_ID"),
                    TargetId = reader.GetString("TARGET_ID"),
                    Text =  reader.GetString("TEXT")
                });
            }
        }

        //
        // get initial or default messsge of the command
        //
        using var initalMessageQuery = _connection.CreateCommand();
        if(hasRows){
            // if the command has any target
            initalMessageQuery.CommandText = GET_COMMAND_INITIAL_MESSAGE_SQL;
        }else{
            // if the command doesn't have any target
            initalMessageQuery.CommandText = GET_COMMAND_DEFAULT_MESSAGE_SQL;
        }

        initalMessageQuery.Parameters.Add(new MySqlParameter
        {
            ParameterName = "@commandId",
            DbType = DbType.String,
            Value = request.CommandId,
        });

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



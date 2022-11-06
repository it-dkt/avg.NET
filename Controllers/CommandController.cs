using System.Data;
using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc;
using MySqlConnector;

namespace avg.NET.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CommandController : ControllerBase
{
    private readonly ILogger<CommandController> _logger;
    private readonly MySqlConnection _connection;

    private const string SQL = 
    	  "SELECT "
        + " COMMAND_ID, TEXT "
        + "FROM COMMAND "
        + "WHERE "
        + " SCENE_ID IN ( @sceneId, '00000' ) AND "
        + " COMMAND_ID NOT LIKE 'TK%' "
        + "ORDER BY SORT_KEY ";

    private const string PERSON_COMMAND_SQL = 
    	  "SELECT "
        + " COMMAND_ID, TEXT "
        + "FROM COMMAND "
        + "WHERE "
        + " SCENE_ID IN ( @sceneId, '00000' ) AND "
        + " ( COMMAND_ID LIKE 'TK%' OR COMMAND_ID = 'GOT' ) "
        + "ORDER BY SORT_KEY ";

    public CommandController(ILogger<CommandController> logger, MySqlConnection connection)
    {
        _logger = logger;
        _connection = connection;
    }

    [HttpGet]
    public async Task<CommandResponse> Get([FromQuery] CommandRequest request)
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

        var command = new CommandResponse();

        using(var reader = await cmd.ExecuteReaderAsync()){
            while(await reader.ReadAsync()){
                command.Commands.Add(new ViewCommandModel{
                    CommandId = reader.GetString("COMMAND_ID"),
                    Text =  reader.GetString("TEXT")
                });
            }
        }

        return command;
    }

    // get person mode commands
    [HttpGet]
    [Route("person")]
    public async Task<CommandResponse> GetPerson([FromQuery] CommandRequest request)
    {
        _connection.Open();

        using var cmd = _connection.CreateCommand();
        cmd.CommandText = PERSON_COMMAND_SQL;
        
        cmd.Parameters.Add(new MySqlParameter
        {
            ParameterName = "@sceneId",
            DbType = DbType.String,
            Value = request.SceneId,
        });

        var command = new CommandResponse();

        using(var reader = await cmd.ExecuteReaderAsync()){
            while(await reader.ReadAsync()){
                command.Commands.Add(new ViewCommandModel{
                    CommandId = reader.GetString("COMMAND_ID"),
                    Text =  reader.GetString("TEXT")
                });
            }
        }

        return command;
    }
}

public class CommandRequest
{
    [Required]
    public string SceneId { get; set;} = "";
}

public class CommandResponse
{
    public List<ViewCommandModel> Commands { get; set; } = new List<ViewCommandModel>();
}

// Model for a command shown in client view
public class ViewCommandModel{

    public string CommandId { get; set; } = "";

    public string TargetId { get; set; } = "";

    public string Text { get; set; } = "";
}
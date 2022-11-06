using System.Data;
using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc;
using MySqlConnector;

namespace avg.NET.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SceneController : ControllerBase
{
    private readonly ILogger<SceneController> _logger;
    private readonly MySqlConnection _connection;

    private const string SQL = 
    	  "SELECT "
        + " S.SCENE_ID, S.PATH "
        + "FROM SCENE S, TARGET T "
        + "WHERE "
        + " S.SCENE_ID = T.DEST_SCENE_ID AND "
        + " T.SCENE_ID = @sceneId AND "
        + " T.COMMAND_ID = @commandId AND "
        + " T.TARGET_ID = @targetId ";

    public SceneController(ILogger<SceneController> logger, MySqlConnection connection)
    {
        _logger = logger;
        _connection = connection;
    }

    [HttpGet]
    [Route("dest")]
    public async Task<SceneResponse> GetDestScene([FromQuery] SceneRequest request)
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
        
        var scene = new SceneResponse();

        using(var reader = await cmd.ExecuteReaderAsync()){
            if(await reader.ReadAsync()){
                scene.SceneId = reader.GetString("SCENE_ID");
                scene.Path = reader.GetString("PATH");
            }
        }

        return scene;
    }
}

public class SceneRequest
{
    [Required]
    public string SceneId { get; set;} = "";
    [Required]
    public string CommandId { get; set; } = "";
    [Required]
    public string TargetId { get; set; } = "";
}

public class SceneResponse
{
    public string SceneId { get; set; } = "";

    public string Path { get; set;} = "";
}
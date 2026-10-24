using System.Net;
using System.Net.Http.Json;
using avg.NET.Controllers;

namespace avg.NET.Tests;

[Collection("api")]
public class CommandApiTests
{
    private readonly HttpClient _client;

    public CommandApiTests(AvgApiFixture fixture)
    {
        _client = fixture.Client;
    }

    [Fact]
    public async Task CommandsInNormalMode()
    {
        var response = await _client.GetFromJsonAsync<CommandResponse>("/api/command?sceneId=00001");

        // common commands (SCENE_ID = '00000') in SORT_KEY order, without person commands
        Assert.Equal(new[] { "CHK", "USE", "MOV", "CNF" }, response!.Commands.Select(c => c.CommandId));
        Assert.DoesNotContain(response.Commands, c => c.Mode == 1);
    }

    [Fact]
    public async Task CommandsInPersonMode()
    {
        var response = await _client.GetFromJsonAsync<CommandResponse>("/api/command/person?sceneId=00001");

        // person commands and move commands only
        Assert.Equal(new[] { "TLK", "SHW", "MOV", "CNF" }, response!.Commands.Select(c => c.CommandId));
        Assert.All(response.Commands, c => Assert.Contains(c.Mode, new[] { 1, 2 }));
    }

    [Fact]
    public async Task TargetsWithInitialMessageOfCommand()
    {
        var response = await _client.GetFromJsonAsync<TargetResponse>("/api/target?sceneId=00001&commandId=MOV&flag=0");

        Assert.Equal("どこへ行く？", response!.Message);
        var target = Assert.Single(response.Commands);
        Assert.Equal("001", target.TargetId);
        Assert.Equal("村の中へ", target.Text);
        Assert.Equal(2, target.Mode);
    }

    [Fact]
    public async Task DefaultMessageOfCommandWhenNoTarget()
    {
        var response = await _client.GetFromJsonAsync<TargetResponse>("/api/target?sceneId=00001&commandId=USE&flag=0");

        Assert.Equal("使える物を持っていない。", response!.Message);
        Assert.Empty(response.Commands);
    }

    [Theory]
    [InlineData("0", new[] { "001", "002", "003", "004" })]
    [InlineData("8", new[] { "001", "002", "003", "004", "005" })]  // FLAG = 8 of '小夜の家'
    [InlineData("1032", new[] { "001", "002", "003", "004", "005", "006" })]    // 1024 | 8
    public async Task TargetsAreFilteredByFlag(string flag, string[] expected)
    {
        var response = await _client.GetFromJsonAsync<TargetResponse>($"/api/target?sceneId=00003&commandId=MOV&flag={flag}");

        Assert.Equal(expected, response!.Commands.Select(c => c.TargetId));
    }

    [Fact]
    public async Task ForbiddenTarget()
    {
        var response = await _client.GetFromJsonAsync<TargetResponse>("/api/target?sceneId=00003&commandId=MOV&flag=1024");

        var swamp = Assert.Single(response!.Commands, c => c.TargetId == "006");
        Assert.Equal(1, swamp.Forbidden);
        Assert.All(response.Commands.Where(c => c.TargetId != "006"), c => Assert.Equal(0, c.Forbidden));
    }

    [Fact]
    public async Task DestinationScene()
    {
        var response = await _client.GetFromJsonAsync<SceneResponse>("/api/scene/dest?sceneId=00001&commandId=MOV&targetId=001");

        Assert.Equal("00003", response!.SceneId);
        Assert.Equal("../scenes/00003.html", response.Path);
    }

    [Theory]
    [InlineData("/")]  // title page
    [InlineData("/scenes/00001.html")]
    [InlineData("/avg.js")]
    public async Task StaticFiles(string path)
    {
        var response = await _client.GetAsync(path);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }
}

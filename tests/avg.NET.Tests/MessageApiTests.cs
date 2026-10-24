using System.Net.Http.Json;
using System.Text.Json;

namespace avg.NET.Tests;

[Collection("api")]
public class MessageApiTests
{
    private readonly HttpClient _client;

    public MessageApiTests(AvgApiFixture fixture)
    {
        _client = fixture.Client;
    }

    private Task<JsonElement> GetMessage(string sceneId, string commandId, string targetId, string flag)
    {
        return _client.GetFromJsonAsync<JsonElement>(
            $"/api/message?sceneId={sceneId}&commandId={commandId}&targetId={targetId}&flag={flag}");
    }

    [Fact]
    public async Task InitialMessageOfScene()
    {
        var message = await GetMessage("00001", "000", "000", "0");

        Assert.StartsWith("^日暮れの山道。", message.GetProperty("message").GetString());
        Assert.Equal("getInitialCommands", message.GetProperty("event").GetString());
        Assert.Equal("0", message.GetProperty("flag").GetString());
    }

    [Fact]
    public async Task MessageWithTheMostSpecificFlagIsSelected()
    {
        // both FLAG = 0 and FLAG = 1024 match, and 1024 is selected
        var message = await GetMessage("00001", "000", "000", "1024");

        Assert.StartsWith("^夜の村の入口。", message.GetProperty("message").GetString());
    }

    [Theory]
    [InlineData("0", "2")]  // SET_FLAG = 2 is turned on
    [InlineData("5", "7")]  // other bits are kept
    public async Task SetFlagIsAppliedToPlayersFlag(string flag, string expected)
    {
        var message = await GetMessage("00002", "CHK", "001", flag);

        Assert.StartsWith("押入れの奥に、", message.GetProperty("message").GetString());
        Assert.Equal(expected, message.GetProperty("flag").GetString());
    }

    [Fact]
    public async Task FlagIsReturnedAsStringWithoutLosingPrecision()
    {
        // 2^64 - 1 can't be represented exactly as a JavaScript number
        var message = await GetMessage("00001", "CHK", "001", "18446744073709551615");

        Assert.Equal(JsonValueKind.String, message.GetProperty("flag").ValueKind);
        Assert.Equal("18446744073709551615", message.GetProperty("flag").GetString());
    }

    [Fact]
    public async Task FlagIsNullWhenNoMessageIsFound()
    {
        var message = await GetMessage("00001", "XXX", "000", "8");

        Assert.Equal("ERROR: No message!", message.GetProperty("message").GetString());
        Assert.Equal(JsonValueKind.Null, message.GetProperty("flag").ValueKind);
        Assert.Equal(JsonValueKind.Null, message.GetProperty("event").ValueKind);
    }
}

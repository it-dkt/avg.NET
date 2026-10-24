using DotNet.Testcontainers.Builders;
using DotNet.Testcontainers.Containers;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;

namespace avg.NET.Tests;

// starts a MySQL container with the sample game data (mysql-setting/initdb.d),
// and the app connected to it. shared by all tests in the "api" collection.
public class AvgApiFixture : IAsyncLifetime
{
    private const int MYSQL_PORT = 3306;

    private readonly IContainer _db = new ContainerBuilder("mysql:8.4")
        .WithEnvironment("MYSQL_ROOT_PASSWORD", "root")
        .WithResourceMapping(new FileInfo(Path.Combine(FindRepositoryRoot(), "mysql-setting", "initdb.d", "init-avg-db.sql")), "/docker-entrypoint-initdb.d/")
        .WithCommand("--character-set-server=utf8mb4", "--collation-server=utf8mb4_general_ci")
        .WithPortBinding(MYSQL_PORT, true)
        // same as the healthcheck in docker-compose.yaml:
        // the server for the init script doesn't listen on TCP, so this succeeds after the init script has finished
        .WithWaitStrategy(Wait.ForUnixContainer().UntilCommandIsCompleted("mysqladmin", "ping", "-h", "127.0.0.1", "-uroot", "-proot"))
        .Build();

    private WebApplicationFactory<Program>? _factory;

    public HttpClient Client { get; private set; } = null!;

    public async Task InitializeAsync()
    {
        await _db.StartAsync();

        // same user and database as appsettings.json, created by the init script
        var connectionString = $"Server={_db.Hostname};Port={_db.GetMappedPublicPort(MYSQL_PORT)};"
            + "User ID=avguser;Password=avgpass;Database=avg_db;";

        _factory = new WebApplicationFactory<Program>()
            .WithWebHostBuilder(builder => builder.UseSetting("ConnectionStrings:Default", connectionString));
        Client = _factory.CreateClient();
    }

    public async Task DisposeAsync()
    {
        Client.Dispose();
        if (_factory != null)
        {
            await _factory.DisposeAsync();
        }
        await _db.DisposeAsync();
    }

    private static string FindRepositoryRoot()
    {
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        while (dir != null && !File.Exists(Path.Combine(dir.FullName, "avg.NET.csproj")))
        {
            dir = dir.Parent;
        }
        return dir?.FullName ?? throw new DirectoryNotFoundException("avg.NET.csproj is not found.");
    }
}

[CollectionDefinition("api")]
public class ApiCollection : ICollectionFixture<AvgApiFixture>
{
}

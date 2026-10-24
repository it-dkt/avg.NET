using MySqlConnector;

public class Startup
{
    public Startup(IConfiguration configuration)
    {
        Configuration = configuration;
    }

    public IConfiguration Configuration { get; }

    public void ConfigureServices(IServiceCollection services)
    {
        services.AddControllers(option => {
            option.Filters.Add<AVGExceptionFilter>();
        });

        services.AddTransient<MySqlConnection>(_ => new MySqlConnection(Configuration["ConnectionStrings:Default"]));
    }

    public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
    {
        // exceptions in the API are handled by AVGExceptionFilter
        if (!env.IsDevelopment())
        {
            app.UseHsts();
        }

        app.UseHttpsRedirection();
        app.UseDefaultFiles();  // serve wwwroot/index.html (title page) at /
        app.UseStaticFiles();
        app.UseRouting();

        app.UseEndpoints(endpoints =>
        {
            endpoints.MapControllers();
        });
    }
}
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

public class AVGExceptionFilter : IExceptionFilter
{
    private readonly IHostEnvironment _hostEnvironment;
    private ILogger<AVGExceptionFilter> _logger;

    public AVGExceptionFilter(IHostEnvironment hostEnvironment, ILogger<AVGExceptionFilter> logger){
        _hostEnvironment = hostEnvironment;
        _logger = logger;
    }

    public void OnException(ExceptionContext context)
    {
        if (!_hostEnvironment.IsDevelopment())
        {
            // Don't display exception details unless running in Development.
            return;
        }

        context.Result = new ContentResult
        {
            Content = context.Exception.ToString()
        };
    }
}
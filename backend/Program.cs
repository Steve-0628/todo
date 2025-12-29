using Microsoft.EntityFrameworkCore;
using System.Text.Json.Serialization;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

var host = Environment.GetEnvironmentVariable("DB_HOSTNAME") ?? "localhost";
var dbName = Environment.GetEnvironmentVariable("DB_DATABASE") ?? "mytododb";
var user = Environment.GetEnvironmentVariable("DB_USER") ?? "postgres";
var password = Environment.GetEnvironmentVariable("DB_PASSWORD") ?? "password";

builder.Services.AddDbContext<TodoDb>(opt =>
    opt.UseNpgsql($"Host={host};Database={dbName};Username={user};Password={password}"));
builder.Services.AddCors(options =>
    {
        options.AddPolicy("_allowAll", policy => { policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod(); });
    });
// Configure JSON options to use PascalCase (default for C# properties) and ignore cycles
builder.Services.Configure<Microsoft.AspNetCore.Http.Json.JsonOptions>(options =>
{
    options.SerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase; // Use CamelCase
    options.SerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles;
});

var app = builder.Build();

app.UseCors("_allowAll");

var isDev = app.Environment.IsDevelopment();
var webRoot = isDev
    ? Path.Combine(builder.Environment.ContentRootPath, "../frontend/dist")
    : Path.Combine(builder.Environment.ContentRootPath, "wwwroot");

if (Directory.Exists(webRoot))
{
    app.UseStaticFiles(new StaticFileOptions
    {
        FileProvider = new Microsoft.Extensions.FileProviders.PhysicalFileProvider(webRoot)
    });
}

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<TodoDb>();
    db.Database.Migrate();
}


app.MapGet("/", async (HttpContext context) =>
{
    context.Response.ContentType = "text/html";
    await context.Response.SendFileAsync(Path.Combine(webRoot, "index.html"));
});

app.MapGet("/new", async (HttpContext context) =>
{
    context.Response.ContentType = "text/html";
    await context.Response.SendFileAsync(Path.Combine(webRoot, "new/index.html"));
});

app.MapGet("/tag", async (HttpContext context) =>
{
    context.Response.ContentType = "text/html";
    await context.Response.SendFileAsync(Path.Combine(webRoot, "tag/index.html"));
});

app.MapGet("/detail/{id:int}", async (HttpContext context) =>
{
    context.Response.ContentType = "text/html";
    await context.Response.SendFileAsync(Path.Combine(webRoot, "detail/index.html"));
});

app.MapGet("/edit/{id:int}", async (HttpContext context) =>
{
    context.Response.ContentType = "text/html";
    await context.Response.SendFileAsync(Path.Combine(webRoot, "edit/index.html"));
});

app.MapGet("/api/todos", async (int page, TodoDb db) =>
{
    var res = await db.Todos.Include(t => t.Tags).ToListAsync();
    return Results.Ok(new
    {
        Result = res.ToArray(),
    });
});

app.MapPost("/api/todos", async (
    Todo req,
    TodoDb db
) =>
{
    var parsed = new Todo
    {
        Title = req.Title,
        Content = req.Content,
        ExpectedDue = req.ExpectedDue,
        ParentTodoId = req.ParentTodoId
    };

    req.Tags.ForEach(t =>
    {
        var tag = db.Tags.Find(t.Id);
        if (tag != null)
        {
            parsed.Tags.Add(tag);
        }
    });

    var res = db.Add(parsed);
    await db.SaveChangesAsync();
    return Results.Ok(res.Entity.Content);
});

app.MapPatch("/api/todos/{id}", async (int id, Todo req, TodoDb db) =>
{
    var todo = await db.Todos.FindAsync(id);
    if (todo is null)
    {
        return Results.NotFound();
    }

    todo.Title = req.Title;
    todo.Content = req.Content;
    todo.ExpectedDue = req.ExpectedDue;
    todo.IsComplete = req.IsComplete;
    todo.ParentTodoId = req.ParentTodoId;

    todo.Tags.Clear();

    req.Tags.ForEach(t =>
    {
        var tag = db.Tags.Find(t.Id);
        if (tag != null)
        {
            todo.Tags.Add(tag);
        }
    });

    await db.SaveChangesAsync();

    return Results.Ok(todo);
});

app.MapGet("/api/todos/{id}", async (int Id, TodoDb db) =>
{
    var todo = await db.Todos
        .Include(t => t.Tags)
        .Include(t => t.ParentTodo)
        .Include(t => t.ChildTodos)
        .FirstOrDefaultAsync(t => t.Id == Id);

    if (todo is null)
    {
        return Results.NotFound();
    }
    else
    {
        return Results.Json(new
        {
            Result = todo
        });
    }
});


app.MapGet("/api/tags", async (TodoDb db) =>
{
    return await db.Tags.ToListAsync();
});

app.MapPost("/api/tags", async (Tag req, TodoDb db) =>
{
    db.Tags.Add(req);
    await db.SaveChangesAsync();
    return Results.Created($"/api/tags/{req.Id}", req);
});

app.MapPatch("/api/tags/{id}", async (int id, Tag req, TodoDb db) =>
{
    var tag = await db.Tags.FindAsync(id);
    if (tag is null)
    {
        return Results.NotFound();
    }

    tag.Name = req.Name;
    await db.SaveChangesAsync();
    return Results.Ok(tag);
});

app.Run();

class Todo
{
    public int Id { get; set; }
    public long CreatedAt { get; set; } = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
    public required string Title { get; set; }
    public string Content { get; set; } = "";
    public long ExpectedDue { get; set; }
    public bool IsComplete { get; set; } = false;
    public List<Tag> Tags { get; set; } = [];
    public int? ParentTodoId { get; set; }
    public Todo? ParentTodo { get; set; }
    public List<Todo> ChildTodos { get; set; } = [];
}

class Tag
{
    public int Id { get; set; }
    public required string Name { get; set; }
}

class TodoDb(DbContextOptions<TodoDb> options) : DbContext(options)
{
    public DbSet<Todo> Todos => Set<Todo>();
    public DbSet<Tag> Tags => Set<Tag>();
}

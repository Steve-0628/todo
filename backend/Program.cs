using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<TodoDb>(opt =>
    opt.UseNpgsql("Host=localhost;Database=mytododb;Username=postgres;Password=password"));
builder.Services.AddCors(options =>
    {
        options.AddPolicy("_allowAll", policy => { policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod(); });
    });
var app = builder.Build();

app.UseCors("_allowAll");

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<TodoDb>();
    // db.Database.EnsureCreated();
}


app.MapGet("/", () => "Hello World!");

app.MapGet("/api/todos", async (int page, TodoDb db) =>
{
    var res = await db.Todos.Include(t => t.Tags).ToListAsync();
    return new
    {
        Result = res.ToArray(),
    }
    ;
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
        ExpectedDue = req.ExpectedDue
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
    return res.Entity.Content;
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
    var todo = db.Todos.Find(Id);
    return new
    {
        Found = todo != null,
        Result = todo
    };
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

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
    db.Database.EnsureCreated();
}


app.MapGet("/", () => "Hello World!");

app.MapGet("/api/todos", async (int page, TodoDb db) =>
{
    var res = await db.Todos.ToListAsync();
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
    };
    var res = db.Add(req);
    await db.SaveChangesAsync();
    return res.Entity.Content;
});

app.MapGet("/api/todos/{id}", async (int Id, TodoDb db) =>
{
    var todo = await db.FindAsync<Todo>(Id);
    return new
    {
        Found = todo != null,
        Result = todo
    };
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
}

class TodoDb(DbContextOptions<TodoDb> options) : DbContext(options)
{
    public DbSet<Todo> Todos => Set<Todo>();
}

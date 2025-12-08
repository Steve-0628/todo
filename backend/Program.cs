using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<TodoDb>(opt => 
    opt.UseNpgsql("Host=localhost;Database=mytododb;Username=postgres;Password=password"));
var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<TodoDb>();
    db.Database.EnsureCreated();
}


app.MapGet("/", () => "Hello World!");

app.MapGet("/api/todos", async (int page, TodoDb db) =>
{
    var res = await db.Todos.ToListAsync();
    return new {
        Result = res.ToArray(),
    }
    ;
});

app.MapPost("/api/todos", async (
    Todo req,
    TodoDb db
) => {
    var res = db.Add(req);
    await db.SaveChangesAsync();
    return res.Entity.Name;
});

app.MapGet("/api/todos/{id}", async (int Id, TodoDb db) =>
{
    var todo = await db.FindAsync<Todo>(Id);
    return new {
        Found = todo != null,
        Result = todo
    };
});

app.Run();


class Todo
{
    public required int Id { get; set; }
    public required string Name { get; set; }
    public bool IsComplete { get; set; } = false;
}

class TodoDb(DbContextOptions<TodoDb> options) : DbContext(options)
{
    public DbSet<Todo> Todos => Set<Todo>();
}

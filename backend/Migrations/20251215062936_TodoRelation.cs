using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace backend.Migrations
{
    /// <inheritdoc />
    public partial class TodoRelation : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "ParentTodoId",
                table: "Todos",
                type: "integer",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Todos_ParentTodoId",
                table: "Todos",
                column: "ParentTodoId");

            migrationBuilder.AddForeignKey(
                name: "FK_Todos_Todos_ParentTodoId",
                table: "Todos",
                column: "ParentTodoId",
                principalTable: "Todos",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Todos_Todos_ParentTodoId",
                table: "Todos");

            migrationBuilder.DropIndex(
                name: "IX_Todos_ParentTodoId",
                table: "Todos");

            migrationBuilder.DropColumn(
                name: "ParentTodoId",
                table: "Todos");
        }
    }
}

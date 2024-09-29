using Godot;
using System;

public partial class Piece : Node
{
	public int x;
	public int y;
	public bool alive;
	public Team team;
	
	public override void _Ready()
	{
	}

	public override void _Process(double delta)
	{
	}
}

public enum Team {
	North = 1,
	East = 2,
	South = 3,
	West = 4,
}

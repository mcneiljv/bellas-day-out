using Godot;

public partial class Player : CharacterBody2D
{
	private const float Speed = 300.0f;
	private const float JumpVelocity = -400.0f;

	public override void _PhysicsProcess(double delta)
	{
		// Velocity is a struct, so copy it, modify the copy, then assign it back.
		Vector2 velocity = Velocity;

		// Add the gravity.
		if (!IsOnFloor())
		{
			velocity += GetGravity() * (float)delta;
		}

		// Handle jump.
		if (Input.IsActionJustPressed("ui_accept") && IsOnFloor())
		{
			velocity.Y = JumpVelocity;
		}

		// Get the input direction and handle the movement/deceleration.
		// As good practice, you should replace UI actions with custom gameplay actions.
		float direction = Input.GetAxis("ui_left", "ui_right");
		if (direction != 0f)
		{
			velocity.X = direction * Speed;
		}
		else
		{
			velocity.X = Mathf.MoveToward(velocity.X, 0f, Speed);
		}

		Velocity = velocity;
		MoveAndSlide();
	}
}

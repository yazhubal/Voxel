function _init()
  -- Player Position
  x = 10
  y = 10
  
  -- Player Velocity (Speed)
  dx = 0 -- Horizontal speed
  dy = 0 -- Vertical speed (Falling/Jumping)
  
  -- Physics Settings
  gravity = 0.3     -- How heavy are we?
  jump_power = -4   -- How hard do we jump? (Negative goes UP)
  speed = 1.5       -- Running speed
  friction = 0.8    -- Slippery floor? (Lower = more sliding)
end

function _update()
  -- 1. APPLY GRAVITY
  -- Always pull the player down
  dy += gravity
  
  -- 2. CONTROLS (Left/Right)
  if (btn(0)) dx -= 0.5 -- Accelerate Left
  if (btn(1)) dx += 0.5 -- Accelerate Right
  
  -- Friction (Slow down if no buttons pressed)
  dx *= friction
  
  -- 3. JUMPING
  -- We can only jump if we are ON THE GROUND
  -- We check: Is there a solid tile (Flag 0) exactly 1 pixel below our feet?
  if (can_jump()) then
     -- If button 4 (Z) is pressed, BOOM!
     if (btnp(4)) dy = jump_power
  else
     -- If we are NOT on the ground, don't let dx get too fast (air control)
  end

  -- 4. APPLY MOVEMENT (The scary part)
  -- We move X and Y separately to check collisions for each
  
  move_x()
  move_y()
end

function _draw()
  cls(12) -- Blue sky!
  map(0,0, 0,0, 16,16) -- Draw the map
  spr(1, x, y)         -- Draw the hero
end

-- CHECK IF WE CAN JUMP
function can_jump()
  -- Look at the map. 
  -- x+4 is the center of our player width
  -- y+8 is the bottom of our feet
  -- mget gets the sprite number at that spot.
  -- fget checks if Flag 0 is on.
  if fget(mget((x+4)/8, (y+8)/8), 0) then
     return true
  else 
     return false
  end
end

-- MOVE HORIZONTALLY SAFELY
function move_x()
  -- Predict where we want to go
  local new_x = x + dx
  
  -- Check walls (Left and Right side of body)
  -- If we hit a wall, stop moving (dx = 0)
  if fget(mget((new_x)/8, y/8), 0) or 
     fget(mget((new_x+7)/8, y/8), 0) then
     dx = 0
  else
     x = new_x -- Path is clear!
  end
end

-- MOVE VERTICALLY SAFELY
function move_y()
  local new_y = y + dy
  
  -- 1. Check Going DOWN (Falling)
  if (dy > 0) then 
     -- Check bottom-left and bottom-right of feet
     if fget(mget(x/8, (new_y+7)/8), 0) or
        fget(mget((x+7)/8, (new_y+7)/8), 0) then
        
        dy = 0 -- Stop falling
        
        -- THE FIX: SNAP TO GRID!
        -- This math forces the player to stand ON TOP of the tile
        y = flr((new_y+7)/8) * 8 - 8
        
     else
        y = new_y -- Air is safe, keep moving
     end
  
  -- 2. Check Going UP (Jumping head bonk)
  elseif (dy < 0) then
     -- Check top-left and top-right of head
     if fget(mget(x/8, new_y/8), 0) or
        fget(mget((x+7)/8, new_y/8), 0) then
        
        dy = 0 -- Ouch, hit head
        y = flr(new_y/8) * 8 + 8 -- Snap below the ceiling
        
     else
        y = new_y
     end
  end
end


function _init()
  -- game state
  state = "title"
  timer = 0
  lap = 1
  
  -- car variables
  px = 0      -- player x position
  pz = 0      -- player z distance
  speed = 0
  
  -- track variables
  track = {}
  track_len = 2000
  seg_l = 200
  cam_h = 1000
  cam_d = 0.8
  
  create_track()
end

function create_track()
  track = {}
  -- straight start
  add_seg(100, 0)
  -- random generation
  while #track < track_len do
    local l = flr(rnd(80)) + 40
    local c = (rnd(1) > 0.5 and 1.5 or -1.5) * (rnd(2) + 1)
    add_seg(l, c)
    add_seg(l, 0)
  end
end

function add_seg(n, c)
  for i=1,n do
    local col1 = 5 -- dark grey
    local col2 = 0 -- black
    if flr(#track/3)%2==0 then 
      col1 = 13 -- lighter grey
    end
    
    local wall = 7 -- white
    if flr(#track/3)%2==0 then 
      wall = 8 -- red
    end
    
    add(track, {curve=c, col=col1, wall=wall})
  end
end

function _update60()
  if state == "title" then
    if btn(4) or btn(5) then 
      state = "racing" 
      timer = 0
    end
    return
  end

  -- gas/brake
  if btn(2) then speed += 0.2
  elseif btn(3) then speed -= 0.5
  else speed *= 0.98 end
  
  -- speed limits
  if speed < 0 then speed = 0 end
  if speed > 15 then speed = 15 end
  
  -- steering
  local steer = 0.02 * (speed/15 + 0.5)
  if btn(0) then px -= steer end
  if btn(1) then px += steer end
  
  -- physics & track curve
  local curr_seg = flr(pz/seg_l) % #track + 1
  px -= (speed/1000) * track[curr_seg].curve
  pz += speed
  
  -- track boundaries
  if abs(px) > 1 then
    speed *= 0.9
    if pz % 5 < 2 then pal(0,8) end -- red flicker
  else
    pal()
  end
  
  -- lap logic
  if pz > #track * seg_l then
    pz = 0
    lap += 1
    if lap > 3 then state = "win" end
  end
  
  timer += 1
end

function _draw()
  cls(3) -- green grass
  
  if state == "title" then
    print("f1 random gp", 40, 50, 7)
    print("press x/z to start", 30, 70, 6)
    return
  end

  draw_track()
  draw_car()
  
  -- hud
  rectfill(0,0,128,12,0)
  print("lap: "..lap.."/3", 2, 4, 7)
  print("time: "..flr(timer/60).."s", 80, 4, 7)
  
  if state == "win" then
    rectfill(20,50,108,80,0)
    print("race complete!", 35, 60, 11)
    print("time: "..flr(timer/60).."s", 45, 70, 7)
  end
end

function draw_track()
  local start_pos = flr(pz/seg_l)
  local x = 0
  local dx = 0
  local maxy = 128
  
  for n=1, 80 do
    local i = (start_pos + n) % #track + 1
    local loop = (start_pos + n) >= #track and (#track * seg_l) or 0
    
    local world_z = (i * seg_l) + loop
    local scale = cam_d / (world_z - pz)
    
    if scale > 0 then
      local px_scr = (1 + scale * (x - px * 2000)) * 64
      local py_scr = (1 - scale * (-cam_h)) * 64
      local pw_scr = scale * 2000 * 64
      
      if n > 1 and py_scr < maxy then
        local p = track[i].proj
        if p then
          -- road
          fillp(0b1010010110100101.1) -- dither for texture
          line(p.x-p.w, p.y, px_scr-pw_scr, py_scr, track[i].col)
          line(p.x+p.w, p.y, px_scr+pw_scr, py_scr, track[i].col)
          fillp()
          -- rumble strips
          line(p.x-p.w, p.y, px_scr-pw_scr, py_scr, track[i].wall)
          line(p.x+p.w, p.y, px_scr+pw_scr, py_scr, track[i].wall)
        end
        maxy = py_scr
      end
      
      track[i].proj = {x=px_scr, y=py_scr, w=pw_scr}
      x += dx
      dx += track[i].curve
    end
  end
end

function draw_car()
  local cx, cy = 64, 110
  -- body
  rectfill(cx-10, cy, cx+10, cy+5, 12)
  rectfill(cx-3, cy-8, cx+3, cy, 12)
  -- wings
  line(cx-15, cy+2, cx+15, cy+2, 7)
  line(cx-8, cy-8, cx+8, cy-8, 7)
  -- tires
  rectfill(cx-14, cy-2, cx-10, cy+4, 0)
  rectfill(cx+10, cy-2, cx+14, cy+4, 0)
end

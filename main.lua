local graphics = require "graphics"

ARROW_LINE = 46.5

function reset_ucs_state()
  currentflashframe = 0.0
  flashframes = 60/bpm
  arrow_alpha = 1

  t0 = love.timer.getTime()
  a_t0 = 0.0
  a_duration = 0.3
  
  entry_index = 0
  next_spawn = 0
  
  ucs_beat = 4
  ucs_split = 4
  
  step_trigger_next = 0.0
  step_trigger_nextindex = 1
end

function init_ucs()
  mode = 1
  bpm = 80
  
  reset_ucs_state()
  
  ucs_data = {}
  ucs_audio = nil
  startscroll = false
  
  t_audio_start = nil
  t_audio = nil
  
  --moving_arrows = queue.new()
  
  notes = {}
  notes.time = {}
  notes.step = {}
end

function love.load()
  graphics.load_assets()
  
  arrow_asset = {
    [1] = a_DL,
    [2] = a_UL,
    [3] = a_C,
    [4] = a_UR,
    [5] = a_DR,
    [6] = a_DL,
    [7] = a_UL,
    [8] = a_C,
    [9] = a_UR,
    [10]= a_DR,
  }

  arrow_hold_asset = {
    [1] = h_DL,
    [2] = h_UL,
    [3] = h_C,
    [4] = h_UR,
    [5] = h_DR,
    [6] = h_DL,
    [7] = h_UL,
    [8] = h_C,
    [9] = h_UR,
    [10]= h_DR,
  }
  
  arrow_endhold_asset = {
    [1] = eh_DL,
    [2] = eh_UL,
    [3] = eh_C,
    [4] = eh_UR,
    [5] = eh_DR,
    [6] = eh_DL,
    [7] = eh_UL,
    [8] = eh_C,
    [9] = eh_UR,
    [10]= eh_DR,
  }
  
  ADX = {207, 267, 326, 386, 445, 507, 567, 626, 686, 745}
  ASX = {153, 213, 273, 332, 391}
  
  LAYOUT_MODE = { [1]=ASX, [2]=ADX }
  
  PF_POS = { [1]=LAYOUT_MODE[1][1], [2]=LAYOUT_MODE[2][3]+25}
  init_ucs()
  
  COMBONUMBER_POS = { [1]=621, [2]=1024 }
end


-- TODO IMPORTANT: time it takes before drawing first note
-- separate variable. so decrement until 0, then start scrolling.

function apply_options(syn)
  local cmd = syn:match(":(%a*)=%d*")
  local val = tonumber(syn:match(":%a*=(%d*)"))
  
  if cmd=="BPM" then
    bpm = val
  elseif cmd=="Delay" then
    -- delay function
  elseif cmd=="Beat" then
    ucs_beat = val
  elseif cmd=="Split" then
    ucs_split = val
  else
    -- reserved
  end
end

function get_options(syn)
  local cmd = syn:match(":(%a*)=%d*")
  
  return cmd
end

function get_value(syn)
  local val = tonumber(syn:match(":%a*=(%d*)"))
  
  return val
end

-- idea for faster time: notes.note[startindex][col]. precomputation.
note_types = { ["."] = 0, ["X"] = 1, ["M"] = 2, ["H"] = 3, ["W"] = 4 }

function parse_ucs()
  if string.sub(ucs_data[2], 7, 7)=='S' then
    mode = 1
  else
    mode = 2
  end
  
  currentflashframe = 0.0
  t0 = love.timer.getTime()
  
  startscroll = true
  
  bpm = tonumber(string.sub(ucs_data[3], 6, #ucs_data[3]))
  
  reset_ucs_state()
  
  --love.timer.sleep(tonumber(string.sub(ucs_data[4], 8, #ucs_data[4]))/1000)
  ucs_beat = tonumber(string.sub(ucs_data[5], 7, #ucs_data[5]))
  ucs_split = tonumber(string.sub(ucs_data[6], 8, #ucs_data[6]))
  
  t_audio_start = love.timer.getTime()
  t_audio = t_audio_start
  
  notes = {}
  notes.time = {}
  notes.step = {}
  notes.bpm = {}
  notes.stepcount = {}
  notes.combocount = {}
  
  local cursorbpm = bpm
  local cursorbeat = ucs_beat
  local cursorsplit = ucs_split
  local cursortime = 0
  local currentcombocount = 0
  
  for i=1,#ucs_data do
    if string.sub(ucs_data[i], 1, 1)==':' then
      cursoroption = get_options(ucs_data[i])
      cursorvalue = get_value(ucs_data[i])
      
      if cursoroption=="BPM" then
        cursorbpm = cursorvalue
      elseif cursoroption=="Delay" then
        cursortime = cursortime + cursorvalue/1000
      elseif cursoroption=="Beat" then
        cursorbeat = cursorvalue
      elseif cursoroption=="Split" then
        cursorsplit = cursorvalue
      else
        -- undefined
      end
    else 
      table.insert(notes.time, cursortime)
      
      local stepentry = {}
      local numberofsteps = 0
      local comboincrement = 0
      for x=1,mode*5 do
        local thenotetype = note_types[string.sub(ucs_data[i], x, x)]
        table.insert(stepentry, thenotetype)
        
        if thenotetype~=0 then
          numberofsteps = numberofsteps + 1
        end
      end
      
      if numberofsteps~=0 then
        comboincrement = comboincrement+1
      end
      
      table.insert(notes.step, stepentry)
      table.insert(notes.bpm, cursorbpm)
      table.insert(notes.stepcount, numberofsteps)
      
      if #notes.combocount==0 then
        table.insert(notes.combocount, 0)
      else 
        if numberofsteps~=0 then
          table.insert(notes.combocount, 1+notes.combocount[#notes.combocount])
        else
          table.insert(notes.combocount, notes.combocount[#notes.combocount])
        end
      end
      
      cursortime = cursortime + (60/cursorbpm)/cursorsplit
    end
  end
  
  --entry_index = 7
  
  total_entry = #notes.step
  
end

function reload_audio(fn)
  if ucs_audio ~= nil then
    love.audio.stop(ucs_audio)
  end
  ucs_audio = love.audio.newSource(string.sub(fn, 1, #fn-3) .. "mp3", "static")
end

-- get first element index greater than _t
function get_start_index(_t, a, b)
  local res = -1
  
  while (a <= b)
  do
    local mid = math.floor((a+b)/2)
    
    local mval = notes.time[mid]
    
    if mval < _t then
      a = mid+1
    elseif mval > _t then
      res = mid
      b = mid-1
    else
      a = mid+1
    end
  end
  
  return res
end

function drawnote(notecol, notetype, ypos, cursorindex)
  if notetype==1 or notetype==2 then
    love.graphics.draw(arrow_asset[notecol].spriteSheet, arrow_asset[notecol].quads[tapNum], LAYOUT_MODE[mode][notecol], ypos, 0, 1.19)
  elseif notetype==3 then
    love.graphics.draw(arrow_hold_asset[notecol].spriteSheet, arrow_hold_asset[notecol].quads[holdNum], LAYOUT_MODE[mode][notecol], ypos, 0, 1.19, 1.85) -- 1.85 subject to change based on bpm
  elseif notetype==4 then
    if notes.step[cursorindex-1][notecol]==2 then
      love.graphics.draw(arrow_hold_asset[notecol].spriteSheet, arrow_hold_asset[notecol].quads[holdNum], LAYOUT_MODE[mode][notecol], ypos-notetimediff*scrollspeed*0.5, 0, 1.19)
      love.graphics.draw(arrow_asset[notecol].spriteSheet, arrow_asset[notecol].quads[tapNum], LAYOUT_MODE[mode][notecol], ypos-notetimediff*scrollspeed, 0, 1.19)
      love.graphics.draw(arrow_endhold_asset[notecol].spriteSheet, arrow_endhold_asset[notecol].quads[tapNum], LAYOUT_MODE[mode][notecol], ypos, 0, 1.19)
    else
      love.graphics.draw(arrow_endhold_asset[notecol].spriteSheet, arrow_endhold_asset[notecol].quads[tapNum], LAYOUT_MODE[mode][notecol], ypos, 0, 1.19)
    end
  else
    -- ?
  end
end

previouscombo = 0
previoustap = { [1]=1,[2]=1,[3]=1,[4]=1,[5]=1,[6]=1,[7]=1,[8]=1,[9]=1,[10]=1 }

taptweencurrent = { [1]=0.5,[2]=0.5,[3]=0.5,[4]=0.5,[5]=0.5,[6]=0.5,[7]=0.5,[8]=0.5,[9]=0.5,[10]=0.5 }
tapperfectcurrent = 0.0
delayperfectcurrent = 0.0

function reset_tap_tween(_col)
  taptweencurrent[_col] = 0.5
  tapperfectcurrent = 0.1
  delayperfectcurrent = 1.4
end


function drawbgtap()
  for i=1,mode*5 do
    local easeval = ease_out(taptweencurrent[i], 0, 1, 0.5)
    local eNum = (math.floor(taptweencurrent[i]/0.5 * #a_UL.quads)+1) % 7
    love.graphics.setColor(255, 255, 255, easeval)
    
    local spritepos = i
    
    if spritepos > 5 then
      spritepos = spritepos-5
    end
    
    
    local ccount = notes.combocount[get_start_index(get_audio_time(), 1, #notes.step)]
    local tf = ""
    if ccount < 10 then
      tf = "0" .. tf
    end
    
    if ccount < 100 then
      tf = "0" .. tf
    end
    
    tf = tf .. ccount
    
    
    if tapperfectcurrent ~= 0 then
      local epval = easee_out(tapperfectcurrent, 0, 0.07, 0.1)  
      --love.graphics.print(epval)
      local pNum = (math.floor(epval/0.1 * #perfect.quads)+1) % 6
      --love.graphics.print(pNum)
      love.graphics.draw(perfect.spriteSheet, perfect.quads[pNum], PF_POS[mode], ARROW_LINE+160, 0, 1.7, 1.7)
      
      
      
      local yNum = epval/0.1 * 15
      
      love.graphics.printf(tf, 0, ARROW_LINE+230+yNum, COMBONUMBER_POS[mode], "center")
      
    else
      if delayperfectcurrent ~= 0 then
        love.graphics.draw(perfect.spriteSheet, perfect.quads[1], PF_POS[mode], ARROW_LINE+160, 0, 1.7, 1.7)
        love.graphics.printf(tf, 0, ARROW_LINE+230, COMBONUMBER_POS[mode], "center")
        -- if 0.7 then start disappearing
        -- current one disappears because it follows the current alpha setting (easeval)
        -- need to have separate variable for this maybe. or not.
      end
    end
    
    love.graphics.setBlendMode("add")
    --love.graphics.draw(TAP_ACCENT.spriteSheet, TAP_ACCENT.quads[spritepos], LAYOUT_MODE[mode][i], ARROW_LINE, 0, 1.19, 1.19)
    love.graphics.draw(TAP_WHITE.spriteSheet, TAP_WHITE.quads[spritepos], LAYOUT_MODE[mode][i], ARROW_LINE, 0, 1.19, 1.19)
    
    if taptweencurrent[i] ~= 0 then
      love.graphics.draw(explosion.spriteSheet, explosion.quads[eNum], LAYOUT_MODE[mode][i]-110, ARROW_LINE-110, 0, 1.19, 1.19)
    end
    love.graphics.setBlendMode("alpha")
  end
  
  love.graphics.setColor(255, 255, 255, 255)
end

function continue_tap_tween(_dt)
  -- iterate for all columns
  -- taptweencurrent[i] = taptweencurrent[i] - _dt/1000
  for i=1,mode*5 do
    taptweencurrent[i] = taptweencurrent[i] - _dt
    
    if taptweencurrent[i] < 0 then
      taptweencurrent[i] = 0
    end
  end
  
  tapperfectcurrent = tapperfectcurrent - _dt
  
  if tapperfectcurrent < 0 then
    tapperfectcurrent = 0
    
    delayperfectcurrent = delayperfectcurrent - _dt
    if delayperfectcurrent < 0 then
      delayperfectcurrent = 0
    end
  end
  
  drawbgtap()
end

function view_model(_time)
  -- do binary search, see which first index has >= _time
  -- start drawing, pivoting based on _time being at the receptor until screen height is reached OR until end of file
  
  -- render at actual bpm
  -- scroll at current bpm
  
  -- TODO if startindex is -1, stop drawing
  --local startindex = get_start_index(_time, 1, #notes.time)
  startindex = get_start_index(_time, 1, #notes.time)
  local prev_y = ARROW_LINE
  
  if startindex~=-1 then
    local comboindex = startindex
    
    local current_cursor = _time
    local yposition = ARROW_LINE
    
    scrollspeed = 1.7*bpm
    
    
    while (yposition <= 576) and (startindex <= total_entry)
    do
      notetimediff = (notes.time[startindex] - current_cursor)*notes.bpm[startindex]/50 -- bpm should be CURSORBPM
      
      yposition = yposition + notetimediff*scrollspeed
      
      if notes.stepcount[startindex]~=0 then
        for i=1,mode*5 do
          local ntype = notes.step[startindex][i]
          
          if ntype==3 then
            if yposition <= ARROW_LINE+21 then
              drawnote(i, 1, ARROW_LINE, startindex)
            else
              drawnote(i, ntype, yposition-15, startindex) -- -15 subject to change based on bpm
            end
          else
            drawnote(i, ntype, yposition, startindex)
          end
          
          if startindex > 1 then
            if ntype==3 and notes.step[startindex-1][i]==2 then
              drawnote(i, 1, prev_y, startindex)
            end
          end
        end
      else -- else check if holds between. If it is, then draw.
        if startindex > 1 then
          for i=1,mode*5 do
            local ntype0 = notes.step[startindex-1][i]
            local ntype1 = notes.step[startindex+1][i]
            if (ntype0==2 and ntype1==3) or (ntype0==3 and ntype1==3) or (ntype==3 and ntype1==4) then
              drawnote(i, 3, yposition-15, startindex)
            end
          end
        end
      end
      
      current_cursor = notes.time[startindex]
      startindex = startindex + 1
      
      prev_y = yposition
    end
    
    local currentcombocount = notes.combocount[comboindex]
    
    if previouscombo ~= currentcombocount then
      previouscombo = currentcombocount
      --reset_combo_tween()
      
      for i=1,mode*5 do
        if notes.step[comboindex][i]~=0 then
          reset_tap_tween(i)
        end
      end
      previoustap = notes.step[comboindex]
    end
  end
  -- regular tap tween starts at 0.3 seconds and capped at 0 seconds. duration is 0.3 second
  -- regular combo and perfect tween starts at 0 seconds and capped at 0 seconds. duration is 0.3 second
  --continue_combo_tween()
  
end


function love.filedropped(file)
  ucs_data = nil
  ucs_data = {}
  notes = {}
  transformations = {}
  
  file:open("r")
  
  for line in file:lines() do
	ucs_data[#ucs_data + 1] = line
  end
  
  local fn = file:getFilename():match( "([^\\]+)$" )
  reload_audio(fn)

  file:close()
  
  parse_ucs()
  
  love.audio.play(ucs_audio)
  
end

thelastdelta = 0
function love.update(dt)
  currentflashframe = (love.timer.getTime()-t0) % flashframes
  
  a_t0 = a_t0 + dt
  if (a_t0 >= a_duration) then
    a_t0 = a_t0 - a_duration
  end
  
  tapNum = (math.floor(a_t0/a_duration * #a_UL.quads)+1) % 7
  holdNum = tapNum % #h_UL.quads + 1

  local applyease = ease_out(currentflashframe, 0, 1, flashframes)
  arrow_alpha = 1-applyease
  thelastdelta = dt
end

function draw_combo()
  --love.graphics.draw(perfect, 407, 240, 0, 1.1, 1.1) 
  --love.graphics.draw(combo, 455, 275, 0, 0.8, 0.7)
  --love.graphics.printf("014", 0, 300, 1024, 'center')
end


function DEBUG_1P_ARROW()
  local tapNum = math.floor(a_t0/a_duration * #a_UL.quads)+1
  love.graphics.draw(a_DL.spriteSheet, a_UL.quads[tapNum], ASX[1], ypos, 0, 1.19)
  love.graphics.draw(a_UL.spriteSheet, a_UL.quads[tapNum], ASX[2], ypos, 0, 1.19)
  love.graphics.draw(a_C.spriteSheet, a_UL.quads[tapNum], ASX[3], ypos, 0, 1.19)
  love.graphics.draw(a_UR.spriteSheet, a_UL.quads[tapNum], ASX[4], ypos, 0, 1.19)
  love.graphics.draw(a_DR.spriteSheet, a_UL.quads[tapNum], ASX[5], ypos, 0, 1.19)
  
  ypos = ypos - 10
  ypos = 500
end

function DEBUG_2P_ARROW()
  local tapNum = math.floor(a_t0/a_duration * #a_UL.quads)+1
  love.graphics.draw(a_DL.spriteSheet, a_UL.quads[tapNum], ADX[1], ypos, 0, 1.19)
  love.graphics.draw(a_UL.spriteSheet, a_UL.quads[tapNum], ADX[2], ypos, 0, 1.19)
  love.graphics.draw(a_C.spriteSheet, a_UL.quads[tapNum], ADX[3], ypos, 0, 1.19)
  love.graphics.draw(a_UR.spriteSheet, a_UL.quads[tapNum], ADX[4], ypos, 0, 1.19)
  love.graphics.draw(a_DR.spriteSheet, a_UL.quads[tapNum], ADX[5], ypos, 0, 1.19)
  love.graphics.draw(a_DL.spriteSheet, a_UL.quads[tapNum], ADX[6], ypos, 0, 1.19)
  love.graphics.draw(a_UL.spriteSheet, a_UL.quads[tapNum], ADX[7], ypos, 0, 1.19)
  love.graphics.draw(a_C.spriteSheet, a_UL.quads[tapNum], ADX[8], ypos, 0, 1.19)
  love.graphics.draw(a_UR.spriteSheet, a_UL.quads[tapNum], ADX[9], ypos, 0, 1.19)
  love.graphics.draw(a_DR.spriteSheet, a_UL.quads[tapNum], ADX[10], ypos, 0, 1.19)
end
  
function get_audio_time()
  return love.timer.getTime()-t_audio_start
end

function next_step_time()
  return next_spawn
end

function update_next_step_time()
  next_spawn = next_spawn + flashframes/ucs_split
end

function compute_dy(dt, thebpm, speed)
  return dt*0.01*thebpm*speed
end

function love.draw()
  graphics.draw_bg()
  
  if mode == 1 then
    graphics.arrows_1p()
    graphics.stagenumber_1p()
    
    if (startscroll) then
      view_model(get_audio_time())
      continue_tap_tween(thelastdelta)
    end
    
    graphics.lifebar_1p()
  else
    graphics.arrows_2p()
	  graphics.stagenumber_2p()
    
    if (startscroll) then
      view_model(get_audio_time())
      continue_tap_tween(thelastdelta)
    end
    
    graphics.lifebar_2p()
  end
  
  --love.graphics.print(bpm, 100, 100)
  
end


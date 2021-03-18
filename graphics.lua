local graphics = {}
--60second/97beats = 0.6185567010309278sec/1beat * 60frames/1sec ~ 37.11340206185567 frames

-- 60 frames / 37.11340206185567 frames = 1.616666...

-- about 0.6sec/beat, so divide by 60 frmes

-- 384*64
-- 6 frames

--local function newAnimation(image, width, height, duration)
local function newAnimation(image, width, height)
  local animation = {}
  animation.spriteSheet = image
  animation.quads = {}
  
  for x = 0, image:getWidth() - width, width do
    table.insert(animation.quads, love.graphics.newQuad(x, 0, width, height, image:getDimensions()))
  end
  
  --animation.duration = duration or 1
  --animation.currentTime = 0
  
  return animation
end

function graphics.load_assets()
  arrows = love.graphics.newImage("skin/base_inactive.png")
  arrows_accent = love.graphics.newImage("skin/base_flash.png")
  
  lifebar_color = love.graphics.newImage("skin/lifebar_color.png")
  lifebar_skeleton = love.graphics.newImage("skin/lifebar_skeleton.png")
  
  lifebar_s_color = love.graphics.newImage("skin/lifebar_color_s.png")
  lifebar_s_skeleton = love.graphics.newImage("skin/lifebar_s.png")
  
  stagenumber = love.graphics.newImage("skin/stagenumber.png")
  
  background_image = love.graphics.newImage("bg.png")
  
  perfect = newAnimation(love.graphics.newImage("skin/perfect.png"), 192, 64)
  perfectwithoutcombo = newAnimation(love.graphics.newImage("skin/perfect.png"), 192, 32)
  
  combo = love.graphics.newImage("skin/combo.png")
  
  --font = love.graphics.newFont("combofont.otf", 47)
  font = love.graphics.newImageFont('skin/fontimage.png', ' 0123456789', -13.5)
  
  love.graphics.setFont(font)
  
  local arrow_time = 0.8
  a_DL = newAnimation(love.graphics.newImage("skin/DL.png"), 64, 64)
  h_DL = newAnimation(love.graphics.newImage("skin/DL_H.png"), 64, 64)
  eh_DL = newAnimation(love.graphics.newImage("skin/DL_H_B.png"), 64, 64)
  
  a_UL = newAnimation(love.graphics.newImage("skin/UL.png"), 64, 64)
  h_UL = newAnimation(love.graphics.newImage("skin/UL_H.png"), 64, 64)
  eh_UL = newAnimation(love.graphics.newImage("skin/UL_H_B.png"), 64, 64)
  
  a_C = newAnimation(love.graphics.newImage("skin/C.png"), 64, 64)
  h_C = newAnimation(love.graphics.newImage("skin/C_H.png"), 64, 64)
  eh_C = newAnimation(love.graphics.newImage("skin/C_H_B.png"), 64, 64)
  
  a_UR = newAnimation(love.graphics.newImage("skin/UR.png"), 64, 64)
  h_UR = newAnimation(love.graphics.newImage("skin/UR_H.png"), 64, 64)
  eh_UR = newAnimation(love.graphics.newImage("skin/UR_H_B.png"), 64, 64)
  
  a_DR = newAnimation(love.graphics.newImage("skin/DR.png"), 64, 64)
  h_DR = newAnimation(love.graphics.newImage("skin/DR_H.png"), 64, 64)
  eh_DR = newAnimation(love.graphics.newImage("skin/DR_H_B.png"), 64, 64)
  
  TAP_ACCENT = newAnimation(love.graphics.newImage("skin/tap_accent.png"), 64, 64)
  TAP_WHITE = newAnimation(love.graphics.newImage("skin/tap_white.png"), 64, 64)
  
  explosion = newAnimation(love.graphics.newImage("skin/explosion.png"), 256, 256)
end

function graphics.draw_bg()
  love.graphics.draw(background_image, 0, 0, 0, 1024/background_image:getPixelWidth(), 576/background_image:getPixelHeight())
end

function easee_out(t, b, c, d)
  t = t / d
  t = t-1
  return c*(t*t*t+1) + b
end

-- quadratic ease out
function ease_out(t, b, c, d)
  t = t / d
  return -c*t*(t-2)+b
end

function graphics.arrows_1p()
  local scale = 1.19
  local arrowpos = 120
  love.graphics.draw(arrows, arrowpos, 43, 0, scale, scale)
  
  --love.graphics.print(arrow_alpha)
  love.graphics.setColor(255, 255, 255, arrow_alpha)
  love.graphics.draw(arrows_accent, arrowpos, 46.5, 0, scale, scale)
  love.graphics.setColor(255, 255, 255, 255)
end

function graphics.lifebar_1p()
  love.graphics.draw(lifebar_s_color, 166, 16, 0, 0.795, 0.775)
  love.graphics.draw(lifebar_s_skeleton, 159, 11, 0, 0.795, 0.775)
end

function graphics.stagenumber_1p()
  love.graphics.draw(stagenumber, 474, 3, 0, 0.8, 0.8)
end

function graphics.arrows_2p()
  local scale = 1.19
  local arrowpos = 174
  local nextarrowpos = arrowpos+256+42+1.5
  love.graphics.draw(arrows, arrowpos, 43, 0, scale, scale)
  love.graphics.draw(arrows, nextarrowpos, 43, 0, scale, scale)
  
  love.graphics.setColor(255, 255, 255, arrow_alpha)
  love.graphics.draw(arrows_accent, arrowpos, 46.5, 0, scale, scale)
  love.graphics.draw(arrows_accent, nextarrowpos, 46.5, 0, scale, scale)
  love.graphics.setColor(255, 255, 255, 255)
end

function graphics.lifebar_2p()
  local scalex = 0.795
  love.graphics.draw(lifebar_color, 222, 16, 0, scalex, 0.775)
  love.graphics.draw(lifebar_skeleton, 215, 11, 0, scalex, 0.775)
end

function graphics.stagenumber_2p()
  love.graphics.draw(stagenumber, 143, 3, 0, 0.8, 0.8)
end

return graphics
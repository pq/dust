--- controls
--
-- "ride the controls"
--
-- in-app param control 
-- experiments

-- reload, really.
-- package.loaded["pq/engine_utils"] = nil
local engine_utils = require "pq/engine_utils"

-- setup an engine
engine.name = "PolySub"

------------------------------------------------------------------------
------
-----  param control and state management
----
------------------------------------------------------------------------
local scalers = {}

local function param_control(name, minval, maxval, step, default)
  -- cache min/max for scaling; could be prettier.
  scalers[name] = {
    min = minval,
    max = maxval
  }
  engine_utils.add_param_control(name, minval, maxval, step, default)
end

local sliders = {}

-- current param index
local index = 1
-- param under edit index
local edit = 1

-- max slider value
local slider_max = 32
-- x offset of meter display
local meter_x

-- timer for fading out the legend
local k = metro[1]
k.count = -1
k.time = 0.1
local ticks = 0
k.callback = function(_)
  ticks = ticks - 1
  if (ticks == 0) then
    k:stop()
  end
  redraw()
end

------------------------------------------------------------------------
------
-----  utils
----
------------------------------------------------------------------------

-- todo: move me
local function scale(x, min_in, max_in, min_out, max_out)
  return min_out + (x - min_in) * (max_out - min_out) / (max_in)
end

------------------------------------------------------------------------
------
-----  norns hooks
----
------------------------------------------------------------------------

function init()
  -- make some sound
  engine.level(0.05)
  engine.start(1, 93)

  -- add controls; for more ideas:
  --   engine.list_commands()
  param_control("shape", 0, 1, 0, 0)
  param_control("timbre", 0, 1, 0, 0.5)
  param_control("noise", 0, 1, 0, 0)
  param_control("cut", 0, 32, 0, 8)
  param_control("fgain", 0, 6, 0, 0)
  param_control("sub", 0, 1, 0, 0)
  param_control("width", 0, 1, 0, 0)
  param_control("detune", 0, 1, 0, 0)
  -- params:print()

  -- setup param sliders
  for i = 1, params["count"] do
    local name = params:get_name(i)
    sliders[i] = scale(params:get(i), scalers[name].min, scalers[name].max, 0, slider_max)
  end

  -- calculate meter offset
  meter_x = (126 - #sliders * 4) / 2

  k:start()
end

function enc(n, delta)
  if n == 1 then
    mix:delta("output", delta)
  elseif n == 2 then
    index = ((index + delta - 1) % (#sliders)) + 1
    edit = index
  elseif n == 3 then
    local name = params:get_name(edit)
    params:delta(edit, delta)
    sliders[edit] = math.floor(scale(params:get(edit), scalers[name].min, scalers[name].max, 0, slider_max))
  end

  if n ~= 1 then
    -- (re) set timer
    ticks = 10
    k:start()
  end

  redraw()
end

function key(n, z)
  -- todo! :)
end

function redraw()
  screen.aa(1)
  screen.line_width(1.0)
  screen.clear()

  -- meters
  for i, slider in ipairs(sliders) do
    screen.level(i == edit and 15 or 2)
    screen.move(meter_x + i * 4, 48)
    screen.line(meter_x + i * 4, 46 - sliders[i])
    screen.stroke()
  end

  -- legend
  if (ticks > 0) then
    screen.level(ticks)
    screen.move(64, 60)
    screen.text_center(params:get_name(index))
  end

  screen.update()
end

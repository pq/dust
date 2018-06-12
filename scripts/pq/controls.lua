--- controls
--
-- "ride the controls"
--
-- in-app param control 
-- experiments

local sys_utils = require"pq/sys_util"
-- reload, really.
local ctl = sys_utils.reload("pq/controls")


-- setup an engine
engine.name = "PolySub"
local controls = ctl.for_engine():with_output_mix()

local lit = {}

-- count of active voices
local nvoices = 0

local max_voices = 3

------------------------------------------------------------------------
------
-----  locals
----
------------------------------------------------------------------------

local function getHzET(note)
  return 55*2^(note/12)
end

local function gridredraw()
  g:all(0)
  for i,e in pairs(lit) do
    g:led(e.x, e.y, 15)
  end

  g:refresh()
end

local function grid_note(e)
  print(e.id)
  local note = ((7-e.y)*5) + e.x
  if e.state > 0 then
    if nvoices < max_voices then
      engine.start(e.id, getHzET(note))
      lit[e.id] = {
        x = e.x,
        y = e.y
      }
      nvoices = nvoices + 1
    end
  else
    if lit[e.id] ~= nil then
      engine.stop(e.id)
      lit[e.id] = nil
      nvoices = nvoices - 1
    end
  end 
  gridredraw()
end


------------------------------------------------------------------------
------
-----  norns hooks
----
------------------------------------------------------------------------

function init()
  engine.level(0.2)
end

function enc(n, delta)
  controls:enc(n, delta)
end

function gridkey(x, y, z)
  grid_note{
    id = x*8 + y,
    x = x,
    y = y,
    state = z
  }
end

function redraw()
  controls:redraw() 
end

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

function init()
  -- make some sound
  engine.level(0.05)
  engine.start(1, 93)
end

------------------------------------------------------------------------
------
-----  norns hooks
----
------------------------------------------------------------------------

function enc(n, delta)
  controls:enc(n, delta)
end

function key(n, z)
  -- todo! :)
end

function redraw()
  controls:redraw() 
end

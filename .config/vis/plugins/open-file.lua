-- open file at primary cursor location
-- Copyright (c) Silvan Jegen 2023, released under the enclosed LICENSE.

local lpeg = vis.lpeg
local l = vis.lexers
local delimiters = lpeg.S('"\'\t\v\f\r()[]{} \n=')
local offset_pattern = lpeg.C(lpeg.P(":") * lpeg.P("/")^0 * lpeg.R("09")^1 + (1 - delimiters)^1)

vis:map(vis.modes.NORMAL, "gf", function(keys)
	local dq_str = l.range('"', true)
	local sq_str = l.range("'", true)
	local filename = dq_str + sq_str + (1 - delimiters)^1

	local mstart, mend = vis.win.file:match_at(filename, vis.win.selection.pos, 200)
	if not mstart or not mend then
		vis:info("No filename found under the cursor.")
		return
	end
	local fnoffstr = vis.win.file:content(mstart, mend-mstart)
	local offset = fnoffstr:find(":")
	local offsetcmd
	local fn = fnoffstr
	if offset then
		offsetcmd = lpeg.match(offset_pattern, fnoffstr:sub(offset))
		fn = fnoffstr:sub(1, offset-1)
	end
	local ok = vis:command(string.format("open %s", fn))
	if not ok then
		vis:info("Could not open file " .. fn)
		return
	end
	if offsetcmd then
		vis:command(offsetcmd)
	end
end, "Open file under cursor in a new window")

vis:map(vis.modes.NORMAL, "<C-w>f", "gf")

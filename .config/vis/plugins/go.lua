local function jump_to(path, line, col)
    if path then
        vis:command(string.format('e %s', path))
    end
    vis.win.selection:to(line, col)
end

local Gostack = { s = {}, i = 1 }

function Gostack:push(v)
    self.s[self.i] = v
    self.i = self.i + 1
end

function Gostack:pop()
    if self.i == 1 then
        return nil
    end
    self.i = self.i - 1
    return self.s[self.i]
end

local function godef(keys)
    local win = vis.win
    if win.syntax ~= "go" then
        return 0
    end

    local file = win.file
    local pos = win.selection.pos
    local cmd = string.format('godef -i -o %d', pos)
    local status, out, err = vis:pipe(file, { start = 0, finish = file.size }, cmd)
	if status ~= 0 or not out then
		if err then vis:info(err) end
		return status
    end

    Gostack:push({ path = file.path, line = win.selection.line, col = win.selection.col })

    local path, line, col = string.match(out, '([^:]+):([^:]+):([^:]+)')
    if not path then
        -- same file
        line, col = string.match(out, '([^:]+):([^:]+)')
    end
    jump_to (path, line, col)
end

local function godef_back(keys)
    if vis.win.syntax ~= "go" then
        return 0
    end

    local pos = Gostack:pop()
    if pos then
        jump_to(pos.path, pos.line, pos.col)
    end
end

vis:map(vis.modes.NORMAL, "gd", godef, "Jump to Go symbol/definition")
vis:map(vis.modes.NORMAL, "gD", godef_back, "Jump back to previous Go symbol/definition")


vis:option_register('go_fmt_binary', 'string', function(value, toogle)
    vis.win.go_fmt_binary = value
    return true
end, 'Binary to format Go code on save')

local function gofmt(file, path)
    local win = vis.win
    if win.syntax ~= "go" then
        return true
    end

    local fmt = "gofmt"
    if vis.win.go_fmt_binary then
        fmt = vis.win.go_fmt_binary 
    end

    local pos = win.selection.pos
    local status, out, err = vis:pipe(file, { start = 0, finish = file.size }, fmt)
	if status ~= 0 or not out then
		if err then vis:info(err) end
		return false
    end

    file:delete(0, file.size)
    file:insert(0, out)
    win.selection.pos = pos
    return true
end

vis.events.subscribe(vis.events.FILE_SAVE_PRE, gofmt)

local function gorename(argv, force, win, selection, range)
    if win.syntax ~= "go" then
        return true
    end

    local name = argv[1]
    if not name then
        vis:info('empty new name provided')
        return false
    end

    local forceFlag = ''
    if force then
        forceFlag = '-force'
    end

    local pos = selection.pos
    local f = io.popen(string.format('gorename -offset %s:#%d -to %s %s 2>&1',
        win.file.path, pos, name, forceFlag), 'r')
    local out = f:read('*all')
    local success, msg, status = f:close()
    if not success then
        vis:message(out)
        return false
    end

    -- refresh current file
    vis:command('e')
    win.selection.pos = pos

    vis:info(out)
    return true
end

vis:command_register("gorename", gorename, "Perform precise type-safe renaming of identifiers in Go source code: :gorename newName")

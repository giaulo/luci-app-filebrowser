module("luci.controller.filebrowser", package.seeall)

function index()

	page = entry({"admin", "system", "filebrowser"}, template("filebrowser"), _("File Browser"), 60)
	page.i18n = "base"
	page.dependent = true

	page = entry({"admin", "system", "filebrowser_list"}, call("filebrowser_list"), nil)
	page.leaf = true

end

function filebrowser_list()
	local fs = require "nixio.fs"
	local rv = { }
	local path = luci.http.formvalue("path")
	rv = scandir(path)	
	if #rv > 0 then
		luci.http.prepare_content("application/json")
		luci.http.write_json(rv)
		return
	end

	luci.http.status(404, "Error on listing "..path)
end

function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen("ls -l "..directory.." | egrep '^d' ; ls -lh "..directory.." | egrep -v '^d'")
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end


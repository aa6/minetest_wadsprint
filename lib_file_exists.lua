function file_exists(name)
   local fd = io.open(name,"r")
   if fd ~= nil then io.close(fd) return true else return false end
end
function file_get_contents(file)
  local fp = io.open(file,"r")
  local data = fp:read("*all")
  fp:close()
  return data
end
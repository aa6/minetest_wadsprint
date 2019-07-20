function file_put_contents(file,data)
  local fp = io.open(file,"w")
  fp:write(data)
  fp:close()
end
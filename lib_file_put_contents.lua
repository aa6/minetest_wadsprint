function file_put_contens(file,data)
  local fp = io.open(file,"w")
  fp:write(data)
  fp:close()
end
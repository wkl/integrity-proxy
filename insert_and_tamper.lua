-- insert AD
function insert_ad(html)
  i, j = string.find(html, "</body>")
  if i then
    -- load AD html
    local f = io.open("/root/integrity_proxy/ad.html", "r");
    local AD = f:read("*all")
    f.close()
    html = string.sub(html, 0, i-1) .. '\n' .. AD .. string.sub(html, i)
  end

  return html
end

-- replace first two occurrences of 'from'
function replace_content(html, from, to)
  return string.gsub(html, from, to)
end

local res = ngx.location.capture("/proxy" .. ngx.var.uri,
                                 { args = ngx.var.args }) 
if res.status == 200 then
  for k, v in pairs(res.header) do
    ngx.header[k] = v
  end

  if string.find(ngx.header["Content-Type"], "text/html") then
    res.body = replace_content(res.body, "2014", "2015")
    res.body = replace_content(res.body, "CS", "MATH")
    res.body = insert_ad(res.body)
    ngx.header["Content-Length"] = #(res.body)
  end

  ngx.print(res.body)
end
